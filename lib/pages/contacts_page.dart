import 'package:flutter/material.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

//final List<Map> contacts =
//    List.generate(100, (index) => {"id": index, "name": "Contact $index"});

const PAGE_CONTACT_TITLE = "Contactos";
//List<dynamic>? contact_list;
List contact_list = [];

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var searchController = new TextEditingController();

  void loadContacts(value) async {
    //print(value);
    await searchContacts(value).then((val) {
      contact_list = val;
      //print(contact_list);
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
    //loadContacts("");

    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Other Page'),
      ),*/
      body: Column(children: [
        mainMenu(context),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: EdgeInsets.only(left: 40),
            child: Text(PAGE_CONTACT_TITLE, style: TextStyle(fontSize: 20)),
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
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                contactAddBtn(context),
              ],
            ),
          ),
        ]),
        //contactsHeader(context),
        Expanded(
            child: Container(
          child: contactList(context),
          padding: EdgeInsets.all(10),
        ))
      ]),
    );
  }
}

/*-------------------------------------------------------------
                            CONTACTS
-------------------------------------------------------------*/
/*Widget contactsHeader(context) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Container(
      padding: EdgeInsets.only(left: 40),
      child: Text(PAGE_CONTACT_TITLE, style: TextStyle(fontSize: 20)),
    ),
    Container(
      padding: EdgeInsets.only(left: 40),
      child: searchBar(context),
    ),
    Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          contactAddBtn(context),
        ],
      ),
    ),
  ]);
}*/

/*Widget searchBar(context) {
  var controller = new TextEditingController();
  return SearchBar(
    controller: controller,
    padding: const MaterialStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 16.0)),
    onTap: () {
      //controller.openView();
    },
    onChanged: (_) {
      //contact_list = [];
    },
    leading: const Icon(Icons.search),
  );
}*/

Widget contactAddBtn(context) {
  return ElevatedButton(
    onPressed: () {
      _callEditDialog(context, null);
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
    ),
    child: Row(
      children: [
        Icon(
          Icons.add,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          "Add contact",
          style: TextStyle(color: Colors.black, fontSize: 14),
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
                padding: EdgeInsets.all(5),
                //child: dataBody(context, snapshot.data),
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

/*SingleChildScrollView dataBody(context, List? listContact) {
  List values = List.empty();
  if (listContact != null) values = listContact;*/
SingleChildScrollView dataBody(context) {
  return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          sortColumnIndex: 0,
          showCheckboxColumn: false,
          columns: [
            DataColumn(label: Text("Name"), tooltip: "Name"),
            DataColumn(
              label: Text("Email"),
              tooltip: "Email",
            ),
            DataColumn(label: Text("Phone"), tooltip: "Phone"),
            DataColumn(label: Text("Company"), tooltip: "Company"),
            DataColumn(label: Text("Position"), tooltip: "Position"),
            DataColumn(label: Text("Actions"), tooltip: "Actions"),
          ],
          rows: contact_list
              .map(
                (contact) => DataRow(cells: [
                  DataCell(Text(contact.name)),
                  DataCell(
                    Text(contact.email),
                  ),
                  DataCell(Text(contact.phone)),
                  DataCell(Text(contact.company)),
                  DataCell(Text(contact.position)),
                  DataCell(Row(children: [
                    IconButton(
                        icon: const Icon(Icons.info),
                        tooltip: 'View',
                        onPressed: () async {
                          await getContactInfoByContact(contact.uuid)
                              .then((contactInfo) {
                            Navigator.pushNamed(context, "/contact_info",
                                arguments: {
                                  'contactInfo': contactInfo,
                                  'contact': contact
                                });
                          });
                        }),
                    IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () async {
                          _callEditDialog(context, contact);
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

void _callEditDialog(context, contact) async {
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
      ;
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
    /*await updateContact(_contact.id, _contact.uuid, _name, _comp,
            _contact.projects, _pos, _email, _phone)
        .then((value) async {
      if (!_companies.contains(_comp)) await addCompany(_comp);
      if (!_positions.contains(_pos)) await addPosition(_pos);
      Navigator.popAndPushNamed(context, "/contacts");
    });*/
  } else {
    Contact _contact = Contact(_name, _comp, _pos, _email, _phone);
    /*await addContact(_name, _comp, List.empty(), _pos, _email, _phone)
        .then((value) async {
      if (!_companies.contains(_comp)) await addCompany(_comp);
      if (!_positions.contains(_pos)) await addPosition(_pos);
      Navigator.popAndPushNamed(context, "/contacts");
    });*/
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
        title: const Text('Contact edit'),
        content: SingleChildScrollView(
            child: Row(children: [
          customTextField(nameController, "Enter name"),
          space(width: 20),
          customTextField(emailController, "Enter email"),
          space(width: 20),
          customTextField(phoneController, "Enter phone"),
          space(width: 20),
          customAutocompleteField(
              compController, _companies, "Write or select company..."),
          customAutocompleteField(
              posController, _positions, "Write or select position...")
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
