import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/contact_info_page.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const pageContactTitle = "CRM Contactos de la organización";
List orgs = [];
List contacts = [];

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var searchController = TextEditingController();
  User user = FirebaseAuth.instance.currentUser!;

  void loadOrgs() async {
    await getOrganizations().then((val) {
      orgs = val;
    });
  }

  void loadContacts(value) async {
    if (value != "") {
      await getContactsByOrg(value).then((val) {
        contacts = val;
      });
    } else {
      await getContacts().then((val) {
        contacts = val;
      });
    }
    setState(() {});
    /*await searchContacts(value).then((val) {
      contacts = val;
    });
    if (mounted) {
      setState(() {});
    }*/
  }

  @override
  void initState() {
    loadOrgs();
    loadContacts("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        mainMenu(context, user, "/contacts"),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.only(left: 40),
            child: const Text(pageContactTitle, style: headerTitleText),
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
                //addCBtn(context),
                addBtn(context, callEditDialog, {"contact": Contact("")}),
              ],
            ),
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //contentTab(context, orgList, null),
            SizedBox(
              //width: MediaQuery.of(context).size.width / 2.5,
              width: 200,
              child: contentTab(context, orgList, null),
            ),
            contentTab(context, contactList, null),
          ],
        )
        /*Expanded(
            child: Container(
          padding: const EdgeInsets.all(10),
          // color: Colors.white,

          child: CardRounded(
            child: contactList(context),
          ),
          // contactList(context),
        ))*/
      ]),
    );
  }

/*-------------------------------------------------------------
                            ORGANIZATIONS
-------------------------------------------------------------*/
  void saveOrganization(List args) async {
    Organization org = args[0];
    org.save();
    loadOrgs();

    Navigator.pop(context);
  }

  void callEditOrgDialog(context, Map<String, dynamic> args) async {
    Organization org = args["org"];
    List<KeyValue> types = await getOrganizationsTypeHash();
    orgEditDialog(context, org, types);
  }

  Future<void> orgEditDialog(context, org, types) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Organización"),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: org.name,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => org.name = val);
                  },
                )
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Tipo',
                  size: 220,
                  selected: org.typeObj.toKeyValue(),
                  options: types,
                  onSelectedOpt: (String val) {
                    org.type = val;
                  },
                ),
              ]),
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveOrganization, org),
          ],
        );
      },
    );
  }

  Widget orgList(context, args) {
    return Builder(builder: ((context) {
      if (orgs.isNotEmpty) {
        return Column(children: [
          s4cTitleBar("Organizaciones"),
          Container(
            padding: const EdgeInsets.all(5),
            child: dataBodyOrg(context),
          )
        ]);
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    }));
  }

  SingleChildScrollView dataBodyOrg(context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: false,
            columns: [
              DataColumn(
                  label: customText("Nombre", 14, bold: FontWeight.bold),
                  tooltip: "Nombre"),
              DataColumn(
                  label: customText("Tipo", 14, bold: FontWeight.bold),
                  tooltip: "Tipo"),
              DataColumn(
                  label: customText("Acciones", 14, bold: FontWeight.bold),
                  tooltip: "Acciones"),
            ],
            rows: orgs
                .map(
                  (org) => DataRow(
                      onSelectChanged: (bool? selected) {
                        if (selected == true) {
                          loadContacts(org.uuid);
                          //print("--1--");
                        }
                      },
                      cells: [
                        DataCell(Text(org.name)),
                        DataCell(Text(org.typeObj.name)),
                        DataCell(Row(children: [
                          editBtn(context, callEditOrgDialog, {"org": org}),
                          /*removeBtn(
                        context, _removeContactDialog, {"contact": contact})*/
                        ]))
                      ]),
                )
                .toList(),
          ),
        ));
  }

  void removeOrganizationDialog(context, args) {
    customRemoveDialog(context, args["org"], loadOrgs, null);
  }

/*-------------------------------------------------------------
                            CONTACTS
-------------------------------------------------------------*/
/*Widget addCBtn(context) {
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
}*/

  Widget contactList(context, args) {
    return Builder(builder: ((context) {
      return Column(children: [
        s4cTitleBar("Contactos"),
        Container(
          padding: const EdgeInsets.all(5),
          child: dataBody(context),
        )
      ]);

      /*if (contacts.isNotEmpty) {
        return Column(children: [
          s4cTitleBar("Contactos"),
          Container(
            padding: const EdgeInsets.all(5),
            child: dataBody(context),
          )
        ]);
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }*/
    }));
  }

/*Widget contactList2(context) {
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
}*/

  DataTable contactTable(context) {
    return DataTable(
      sortColumnIndex: 0,
      showCheckboxColumn: false,
      columns: [
        DataColumn(
            label: customText("Nombre", 14, bold: FontWeight.bold),
            tooltip: "Nombre"),
        DataColumn(
            label: customText("Organización", 14, bold: FontWeight.bold),
            tooltip: "Organización"),
        DataColumn(
          label: customText(AppLocalizations.of(context)!.company, 14,
              bold: FontWeight.bold),
          tooltip: AppLocalizations.of(context)!.company,
        ),
        DataColumn(
            label: customText("Proyecto", 14, bold: FontWeight.bold),
            tooltip: "Proyecto"),
        DataColumn(
            label: customText("Posición", 14, bold: FontWeight.bold),
            tooltip: "Posición"),
        DataColumn(
            label: customText("Teléfono", 14, bold: FontWeight.bold),
            tooltip: "Teléfono"),
        DataColumn(
            label: customText("Acciones", 14, bold: FontWeight.bold),
            tooltip: "Acciones"),
      ],
      rows: contacts
          .map(
            (contact) => DataRow(cells: [
              DataCell(Text(contact.name)),
              DataCell(
                Text(contact.organizationObj.name),
              ),
              DataCell(
                Text(contact.companyObj.name),
              ),
              const DataCell(Text("")),
              DataCell(Text(contact.position)),
              DataCell(Text(contact.phone)),
              DataCell(Row(children: [
                IconButton(
                    icon: const Icon(Icons.info),
                    tooltip: 'View',
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => ContactInfoPage(
                                    contact: contact,
                                  ))));
                    }),
                editBtn(context, callEditDialog, {"contact": contact}),
                removeBtn(context, removeContactDialog, {"contact": contact})
              ]))
            ]),
          )
          .toList(),
    );
  }

  SingleChildScrollView dataBody(context) {
    //print(contacts);

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          child: contactTable(context),
          /*child: DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: false,
            columns: [
              DataColumn(
                  label: customText("Nombre", 14, bold: FontWeight.bold),
                  tooltip: "Nombre"),
              DataColumn(
                  label: customText("Organización", 14, bold: FontWeight.bold),
                  tooltip: "Organización"),
              DataColumn(
                label: customText(AppLocalizations.of(context)!.company, 14,
                    bold: FontWeight.bold),
                tooltip: AppLocalizations.of(context)!.company,
              ),
              DataColumn(
                  label: customText("Proyecto", 14, bold: FontWeight.bold),
                  tooltip: "Proyecto"),
              DataColumn(
                  label: customText("Posición", 14, bold: FontWeight.bold),
                  tooltip: "Posición"),
              DataColumn(
                  label: customText("Teléfono", 14, bold: FontWeight.bold),
                  tooltip: "Teléfono"),
              DataColumn(
                  label: customText("Acciones", 14, bold: FontWeight.bold),
                  tooltip: "Acciones"),
            ],
            rows: contacts
                .map(
                  (contact) => DataRow(cells: [
                    DataCell(Text(contact.name)),
                    DataCell(
                      Text(contact.organizationObj.name),
                    ),
                    DataCell(
                      Text(contact.companyObj.name),
                    ),
                    const DataCell(Text("")),
                    DataCell(Text(contact.position)),
                    DataCell(Text(contact.phone)),
                    DataCell(Row(children: [
                      IconButton(
                          icon: const Icon(Icons.info),
                          tooltip: 'View',
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => ContactInfoPage(
                                          contact: contact,
                                        ))));
                          }),
                      editBtn(context, callEditDialog, {"contact": contact}),
                      removeBtn(
                          context, removeContactDialog, {"contact": contact})
                      /*IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () async {
                          callEditDialog(context, contact);
                        }),*/
                      /*IconButton(
                        icon: const Icon(Icons.remove_circle),
                        tooltip: 'Remove',
                        onPressed: () {
                          _removeContactDialog(context, contact);
                        }),*/
                    ]))
                  ]),
                )
                .toList(),
          ),*/
        ));
  }

  void callEditDialog(context, Map<String, dynamic> args) async {
    Contact contact = args["contact"];
    List<KeyValue> organizations = await getOrganizationsHash();
    List<KeyValue> companies = await getCompaniesHash();
    List<KeyValue> positions = await getPositionsHash();
    _contactEditDialog(context, contact, organizations, companies, positions);
    /*Contact? contact;
  if (args["contact"] != null) {
    contact = args["contact"];
  }
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
  });*/
  }

  /*void _saveContact(context, _contact, _name, _comp, _pos, _email, _phone,
      _companies, _positions) async {
    if (_contact != null) {
      _contact.name = _name;
      _contact.company = _comp;
      _contact.position = _pos;
      _contact.email = _email;
      _contact.phone = _phone;
      _contact.save();
    } else {
      _contact = Contact(_name, _comp, _pos, _email, _phone);
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
  }*/

  void saveContact(List args) async {
    Contact contact = args[0];
    contact.save();
    loadContacts("");

    Navigator.pop(context);
  }

  Future<void> _contactEditDialog(
      context, contact, organizations, companies, positions) {
    /*TextEditingController nameController = TextEditingController(text: "");
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
  }*/

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Contacto"),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: contact.name,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => contact.name = val);
                  },
                )
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Organización',
                  size: 220,
                  selected: contact.organizationObj.toKeyValue(),
                  options: organizations,
                  onSelectedOpt: (String val) {
                    contact.organization = val;
                    /*setState(() {
                        proj.type = val;
                      });*/
                  },
                ),
              ]),

              /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Nombre:", 16, textColor: successColor),
              customTextField(nameController, "Nombre", size: 460),
            ]),*/
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Correo electrónico",
                  initial: contact.email,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => contact.email = val);
                  },
                )
              ]),
              /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Correo electrónico:", 16, textColor: successColor),
                customTextField(emailController, "Correo electrónico"),
              ]),*/
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Teléfono",
                  initial: contact.phone,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => contact.phone = val);
                  },
                )
              ]),

              /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Teléfono:", 16, textColor: successColor),
                customTextField(phoneController, "Teléfono"),
              ]),*/
              space(width: 20),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Empresa',
                  size: 220,
                  selected: contact.companyObj.toKeyValue(),
                  options: companies,
                  onSelectedOpt: (String val) {
                    contact.company = val;
                    /*setState(() {
                        proj.type = val;
                      });*/
                  },
                ),
              ]),
              /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Empresa:", 16, textColor: successColor),
                customAutocompleteField(compController, _companies, "Empresa"),
              ]),*/
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Posición',
                  size: 220,
                  selected: contact.positionObj.toKeyValue(),
                  options: positions,
                  onSelectedOpt: (String val) {
                    contact.position = val;
                    /*setState(() {
                        proj.type = val;
                      });*/
                  },
                ),
              ]),

              /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Posición:", 16, textColor: successColor),
                customAutocompleteField(posController, _positions, "Posición")
              ])*/
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveContact, contact),
          ],
          /*actions: <Widget>[
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
          ],*/
        );
      },
    );
  }

  void removeContactDialog(context, args) {
    customRemoveDialog(context, args["contact"], loadContacts, null);
  }

  /*Future<void> _removeContactDialog(context, _contact) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Remove Contact'),
          content: const SingleChildScrollView(
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
  }*/
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
}
