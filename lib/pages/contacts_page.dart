import 'package:flutter/material.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const pageContactTitle = "CRM Contactos de la organización";
List contacts = [];

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var searchController = TextEditingController();

  void loadContacts(value) async {
    await searchContacts(value).then((val) {
      contacts = val;
    });
    setState(() {});
  }

  @override
  void initState() {
    loadContacts("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.only(left: 40),
            child: customText(pageContactTitle, 20),
          ),
          SearchBar(
            controller: searchController,
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
            onSubmitted: (value) {
              loadContacts(value);
            },
            leading: const Icon(Icons.search),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                addBtn(context),
              ],
            ),
          ),
        ]),
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(10),
          child: contactList(context),
        ))
      ]),
    );
  }
}

/*-------------------------------------------------------------
                            CONTACTS
-------------------------------------------------------------*/
Widget addBtn(context) {
  return FilledButton(
    onPressed: () {
      callEditDialog(context, null);
    },
    style: FilledButton.styleFrom(
      side: const BorderSide(width: 0, color: Color(0xffffffff)),
      backgroundColor: const Color(0xffffffff),
    ),
    child: const Column(
      children: [
        Icon(Icons.add, color: Colors.black54),
        SizedBox(height: 5),
        Text(
          "Añadir",
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    ),
  );
}

Widget contactList(context) {
  return FutureBuilder(
      future: getContacts(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(5),
                child: dataBody(context),
              ))
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }));
}

SingleChildScrollView dataBody(context) {
  return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          sortColumnIndex: 0,
          showCheckboxColumn: false,
          columns: [
            DataColumn(
                label: customText("Nombre", 16,
                    textColor: const Color(0xff00809a), bold: FontWeight.bold),
                tooltip: "Name"),
            DataColumn(
              label: customText("Empresa", 16,
                  textColor: const Color(0xff00809a), bold: FontWeight.bold),
              tooltip: "Email",
            ),
            DataColumn(
                label: customText("Proyecto", 16,
                    textColor: const Color(0xff00809a), bold: FontWeight.bold),
                tooltip: "Phone"),
            DataColumn(
                label: customText("Posición", 16,
                    textColor: const Color(0xff00809a), bold: FontWeight.bold),
                tooltip: "Company"),
            DataColumn(
                label: customText("Teléfono", 16,
                    textColor: const Color(0xff00809a), bold: FontWeight.bold),
                tooltip: "Position"),
            DataColumn(
                label: customText("Actions", 16,
                    textColor: const Color(0xff00809a), bold: FontWeight.bold),
                tooltip: "Actions"),
          ],
          rows: contacts
              .map(
                (contact) => DataRow(cells: [
                  DataCell(Text(contact.name)),
                  DataCell(
                    Text(contact.company),
                  ),
                  const DataCell(Text("")),
                  DataCell(Text(contact.position)),
                  DataCell(Text(contact.phone)),
                  DataCell(Row(children: [
                    IconButton(
                        icon: const Icon(Icons.info),
                        tooltip: 'View',
                        onPressed: () async {
                          Navigator.pushNamed(context, "/contact_info",
                              arguments: {'contact': contact});
                        }),
                    IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () async {
                          callEditDialog(context, contact);
                        }),
                    IconButton(
                        icon: const Icon(Icons.remove_circle),
                        tooltip: 'Remove',
                        onPressed: () {
                          _removeContactDialog(context, contact);
                        }),
                  ]))
                ]),
              )
              .toList(),
        ),
      ));
}

void callEditDialog(context, contact) async {
  List<String> companies = [];
  List<String> positions = [];
  await getCompanies().then((value) async {
    for (Company item in value) {
      companies.add(item.name);
    }
    await getPositions().then((value2) {
      for (Position item in value2) {
        positions.add(item.name);
      }
      _contactEditDialog(context, contact, companies, positions);
    });
  });
}

void _saveContact(context, _contact, _name, _comp, _pos, _email, _phone,
    _companies, _positions) async {
  if (_contact != null) {
    _contact.name = _name;
    _contact.company = _comp;
    _contact.position = _pos;
    _contact.email = _email;
    _contact.phone = _phone;
    _contact.save();
  } else {
    Contact _contact = Contact(_name, _comp, _pos, _email, _phone);
  }
  if (!_companies.contains(_comp)) {
    Company _company = Company(_comp);
    _company.save();
  }
  if (!_positions.contains(_pos)) {
    Position _position = Position(_pos);
    _position.save();
  }
  Navigator.popAndPushNamed(context, "/contacts");
}

Future<void> _contactEditDialog(context, _contact, _companies, _positions) {
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController compController = TextEditingController(text: "");
  TextEditingController posController = TextEditingController(text: "");
  if (_contact != null) {
    nameController = TextEditingController(text: _contact.name);
    emailController = TextEditingController(text: _contact.email);
    phoneController = TextEditingController(text: _contact.phone);
    compController = TextEditingController(text: _contact.company);
    posController = TextEditingController(text: _contact.position);
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: const Text('Editar contacto'),
        content: SingleChildScrollView(
            child: Column(children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Nombre:", 16, textColor: Colors.blue),
              customTextField(nameController, "Nombre", size: 460),
            ]),
          ]),
          space(height: 20),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Correo electrónico:", 16, textColor: Colors.blue),
              customTextField(emailController, "Correo electrónico"),
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Teléfono:", 16, textColor: Colors.blue),
              customTextField(phoneController, "Teléfono"),
            ]),
            space(width: 20),
          ]),
          space(height: 20),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Empresa:", 16, textColor: Colors.blue),
              customAutocompleteField(compController, _companies, "Empresa"),
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Posición:", 16, textColor: Colors.blue),
              customAutocompleteField(posController, _positions, "Posición")
            ])
          ]),
        ])),
        actions: <Widget>[
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              _saveContact(
                  context,
                  _contact,
                  nameController.text,
                  compController.text,
                  posController.text,
                  emailController.text,
                  phoneController.text,
                  _companies,
                  _positions);
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _removeContactDialog(context, _contact) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: const Text('Remove Contact'),
        content: SingleChildScrollView(
          child: Text("Are you sure to remove this element?"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Remove'),
            onPressed: () async {
              _contact.delete();
              Navigator.popAndPushNamed(context, "/contacts");
              /*await deleteContact(id).then((value) {
                Navigator.popAndPushNamed(context, "/contacts");
              });*/
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
/*Widget contactList() {
  return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemCount: contacts.length,
      itemBuilder: (_, index) {
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[100],
          child: Text(contacts[index]["name"]),
        );
      });
}*/
