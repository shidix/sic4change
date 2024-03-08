import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/contact_info_page.dart';
import 'package:sic4change/pages/organization_info_page.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const pageContactTitle = "CRM Contactos de la organización";
List orgs = [];
List contacts = [];
bool orgsLoading = false;
bool contactsLoading = false;

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var searchController = TextEditingController();
  User user = FirebaseAuth.instance.currentUser!;

  void loadOrgs() async {
    setState(() {
      orgsLoading = true;
    });
    await getOrganizations().then((val) {
      orgs = val;

      setState(() {
        orgsLoading = false;
      });
    });
  }

  void loadContacts(value) async {
    setState(() {
      contactsLoading = true;
    });

    if (value != "-1") {
      await getContactsByOrg(value).then((val) {
        contacts = val;
        setState(() {
          contactsLoading = false;
        });
      });
    } else {
      await getContacts().then((val) {
        contacts = val;
        setState(() {
          contactsLoading = false;
        });
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  void findOrganizations(value) async {
    setState(() {
      orgsLoading = true;
    });

    await searchOrganizations(value).then((val) {
      orgs = val;
      setState(() {
        orgsLoading = false;
      });
    });
  }

  void findContacts(value) async {
    setState(() {
      contactsLoading = true;
    });

    await searchContacts(value).then((val) {
      contacts = val;
      setState(() {
        contactsLoading = false;
      });
    });
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
        body: SingleChildScrollView(
      child: Column(children: [
        mainMenu(context, user, "/contacts"),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(pageContactTitle, style: headerTitleText),
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: contentTab(context, orgList, null),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: contentTab(context, contactList, null),
            ),*/
            contentTabSized(context, orgList, null, widthFactor: 0.33),
            contentTabSized(context, contactList, null, widthFactor: 0.66),
          ],
        )
      ]),
    ));
  }

/*-------------------------------------------------------------
                            ORGANIZATIONS
-------------------------------------------------------------*/
  void filterOrganizations(context, args) {
    if (args["filter"] == "all") {
      loadOrgs();
    }
  }

  Widget orgList(context, args) {
    return Builder(builder: ((context) {
      //if (orgs.isNotEmpty) {
      return Column(children: [
        s4cTitleBar("Organizaciones"),
        Row(children: [
          SizedBox(
              width: 300,
              child: SearchBar(
                onSubmitted: (value) {
                  findOrganizations(value);
                },
                leading: const Icon(Icons.search),
              )),
          addBtnRow(context, filterOrganizations, {"filter": "all"},
              text: "Ver todas", icon: Icons.search),
        ]),
        Container(
          padding: const EdgeInsets.all(5),
          //width: MediaQuery.of(context).size.width / 3,
          child: dataBodyOrg(context),
        )
      ]);
      /*} else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }*/
    }));
  }

  Widget dataBodyOrg(context) {
    //if (orgs.isNotEmpty) {
    if (orgsLoading == false) {
      return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            //width: double.infinity,
            //width: MediaQuery.of(context).size.width / 3,
            child: DataTable(
              sortColumnIndex: 0,
              showCheckboxColumn: false,
              columnSpacing: 25,
              columns: [
                DataColumn(
                    label: customText("Nombre", 14, bold: FontWeight.bold),
                    tooltip: "Nombre"),
                DataColumn(
                    label:
                        customText("Finan - Socio", 14, bold: FontWeight.bold),
                    tooltip: "Finan - Socio"),
                /*DataColumn(
                    label: customText("Socio", 14, bold: FontWeight.bold),
                    tooltip: "Socio"),*/
                DataColumn(
                    label: customText("Acciones", 14,
                        bold: FontWeight.bold, align: TextAlign.end),
                    tooltip: "Acciones"),
              ],
              rows: orgs
                  .map(
                    (org) => DataRow(
                        onSelectChanged: (bool? selected) {
                          if (selected == true) {
                            loadContacts(org.uuid);
                          }
                        },
                        cells: [
                          DataCell(Text(org.name)),
                          DataCell(Row(children: [
                            Icon(org.isFinancier()),
                            customText("  -  ", 14),
                            Icon(org.isPartner())
                          ])),
                          //DataCell(Icon(org.isPartner())),
                          //DataCell(Text(org.typeObj.name)),
                          DataCell(Row(children: [
                            /*editBtn(context, callEditOrgDialog, {"org": org},
                                iconSize: 18),
                            editBtn(context, callEditOrgBillingDialog,
                                    {"org": org},
                                    icon: Icons.abc_outlined, iconSize: 14),*/
                            goPageIcon(
                              context,
                              "View",
                              Icons.info,
                              OrganizationInfoPage(org: org),
                            ),
                            removeBtn(
                                context, removeOrganizationDialog, {"org": org},
                                iconSize: 18)
                          ]))
                        ]),
                  )
                  .toList(),
            ),
          ));
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void removeOrganizationDialog(context, args) {
    //customRemoveDialog(context, args["org"], loadOrgs, null);
    customRemoveDialog(context, null, removeOrganization, args["org"]);
  }

  void removeOrganization(args) {
    Organization org = args;
    //print(org.name);
  }

  void filterContacts(context, args) {
    if (args["filter"] == "all") {
      loadContacts("-1");
    }
    if (args["filter"] == "generic") {
      loadContacts("");
    }
  }

  Widget contactList(context, args) {
    return Builder(builder: ((context) {
      return Column(children: [
        s4cTitleBar("Contactos"),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(
              width: 600,
              child: SearchBar(
                controller: searchController,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 12.0)),
                onSubmitted: (value) {
                  findContacts(value);
                },
                leading: const Icon(Icons.search),
              )),
          addBtnRow(context, filterContacts, {"filter": "generic"},
              text: "Ver genéricos", icon: Icons.search),
          addBtnRow(context, filterContacts, {"filter": "all"},
              text: "Ver todos", icon: Icons.search),
        ]),
        Container(
          padding: const EdgeInsets.all(5),
          child: dataBody(context),
        )
      ]);
    }));
  }

  Widget contactTable(context) {
    //if (contacts.isNotEmpty) {
    if (contactsLoading == false) {
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
          /*DataColumn(
              label: customText("Proyecto", 14, bold: FontWeight.bold),
              tooltip: "Proyecto"),*/
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
                // const DataCell(Text("")),
                DataCell(Text(contact.position)),
                DataCell(Text(contact.phone)),
                DataCell(Row(children: [
                  goPageIcon(
                    context,
                    "View",
                    Icons.info,
                    ContactInfoPage(contact: contact),
                  ),
                  editBtn(context, callEditDialog, {"contact": contact}),
                  removeBtn(context, removeContactDialog, {"contact": contact})
                ]))
              ]),
            )
            .toList(),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  SingleChildScrollView dataBody(context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          child: contactTable(context),
        ));
  }

  void callEditDialog(context, Map<String, dynamic> args) async {
    Contact contact = args["contact"];
    List<KeyValue> organizations = await getOrganizationsHash();
    List<KeyValue> companies = await getCompaniesHash();
    List<KeyValue> positions = await getPositionsHash();
    _contactEditDialog(context, contact, organizations, companies, positions);
  }

  void saveContact(List args) async {
    Contact contact = args[0];
    contact.save();
    loadContacts("");

    Navigator.pop(context);
  }

  Future<void> _contactEditDialog(
      context, contact, organizations, companies, positions) {
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
                  },
                ),
              ]),
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
                  },
                ),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Posición',
                  size: 220,
                  selected: contact.positionObj.toKeyValue(),
                  options: positions,
                  onSelectedOpt: (String val) {
                    contact.position = val;
                  },
                ),
              ]),
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveContact, contact),
          ],
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

/*-------------------------------------------------------------
                            ORGANIZATIONS BILLING
-------------------------------------------------------------*/
  /*void saveOrganizationBilling(List args) async {
    OrganizationBilling orgBilling = args[0];
    orgBilling.save();

    //loadOrgs();

    Navigator.pop(context);
  }

  void callEditOrgBillingDialog(context, Map<String, dynamic> args) async {
    Organization org = args["org"];
    OrganizationBilling orgBilling =
        await OrganizationBilling.byOrganization(org.uuid);
    if (orgBilling.name == "None") {
      orgBilling.organization = org.uuid;
      orgBilling.org = org;
      orgBilling.save();
    }
    orgBillingEditDialog(context, orgBilling);
  }

  Future<void> orgBillingEditDialog(context, org) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Datos de Facturación"),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: org.name,
                  size: 280,
                  fieldValue: (String val) {
                    org.name = val;
                    //setState(() => org.name = val);
                  },
                )
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "CIF",
                  initial: org.cif,
                  size: 150,
                  fieldValue: (String val) {
                    org.cif = val;
                  },
                )
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Dirección",
                  initial: org.address,
                  size: 600,
                  fieldValue: (String val) {
                    org.address = val;
                  },
                )
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Número de cuenta",
                  initial: org.account,
                  size: 600,
                  fieldValue: (String val) {
                    org.account = val;
                  },
                )
              ]),
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveOrganizationBilling, org),
          ],
        );
      },
    );
  }*/

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
}
  /*void saveOrganization(List args) async {
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
              Column(children: [
                customText("Financiador", 12),
                FormField<bool>(builder: (FormFieldState<bool> state) {
                  return Checkbox(
                    value: org.financier,
                    onChanged: (bool? value) {
                      setState(() {
                        org.financier = value!;
                        state.didChange(org.financier);
                      });
                    },
                  );
                })
              ]),
              space(width: 20),
              Column(children: [
                customText("Socio", 12),
                FormField<bool>(builder: (FormFieldState<bool> state) {
                  return Checkbox(
                    value: org.partner,
                    onChanged: (bool? value) {
                      setState(() {
                        org.partner = value!;
                        state.didChange(org.partner);
                      });
                    },
                  );
                })
              ]),

              /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Tipo',
                  size: 220,
                  selected: org.typeObj.toKeyValue(),
                  options: types,
                  onSelectedOpt: (String val) {
                    org.type = val;
                  },
                ),
              ]),*/
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveOrganization, org),
          ],
        );
      },
    );
  }*/

*/
}
