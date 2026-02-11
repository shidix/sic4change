import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/contact_info_page.dart';
import 'package:sic4change/pages/organization_info_page.dart';
import 'package:sic4change/pages/organization_invoices_page.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/cache_projects.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const pageContactTitle = "CRM Contactos de la organización";
List orgs = [];
List contacts = [];
List allContacts = [];
List allOrgs = [];
String currentOrg = "Ninguna seleccionada";
bool orgsLoading = false;
bool contactsLoading = false;
Widget? _mainMenu;

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var searchController = TextEditingController();
  ProfileProvider? _provider;
  ProjectsProvider? cacheProjects;
  Organization? _currentOrg;
  Profile? _currentProfile;
  final user = FirebaseAuth.instance.currentUser!;

  void loadOrgs() async {
    setState(() {
      orgsLoading = true;
    });

    if (allOrgs.isEmpty) {
      orgs = await Organization.getOrganizations();
      allOrgs = orgs;
      setState(() {
        orgsLoading = false;
      });
    } else {
      orgs = allOrgs;
      orgsLoading = false;
      if (mounted) {
        setState(() {
          orgsLoading = false;
        });
      }
    }
  }

  void findOrganizations(value) async {
    setState(() {
      orgsLoading = true;
    });

    if (value == "") {
      orgs = allOrgs;
    } else {
      orgs = allOrgs
          .where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    }
    if (mounted) {
      setState(() {
        orgsLoading = false;
      });
    }

    // await searchOrganizations(value).then((val) {
    //   orgs = val;
    //   setState(() {
    //     orgsLoading = false;
    //   });
    // });
  }

  void findContacts(value) async {
    setState(() {
      contactsLoading = true;
    });

    if (value == "") {
      contacts = allContacts;
    } else {
      contacts = allContacts.where((element) {
        element.organizationObj ??= orgs.firstWhere(
            (org) => org.uuid == element.organization,
            orElse: () => Organization(""));
        if (element.organizationObj!.name == "") {
          element.organizationObj = allOrgs.firstWhere(
              (org) => ((element.email ?? "").contains(org.email) &&
                  (org.domain.length > 4)),
              orElse: () => Organization(""));
        }
        return (element.name.toLowerCase().contains(value.toLowerCase()) ||
            element.email.toLowerCase().contains(value.toLowerCase()) ||
            element.organizationObj.name
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            element.companyObj.name
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            element.positionObj.name
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            element.phone.toLowerCase().contains(value.toLowerCase()));
      }).toList();
    }
    if (mounted) {
      setState(() {
        contactsLoading = false;
      });
    }

    // searchContacts(value).then((val) {
    //   contacts = val;
    //   setState(() {
    //     contactsLoading = false;
    //   });
    // });
  }

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<ProfileProvider>(context, listen: false);
    _provider?.addListener(() {
      _currentOrg = _provider?.organization;
      _currentProfile = _provider?.profile;
      if (_currentOrg == null || _currentProfile == null) {
        _provider?.loadProfile();
      }
      if (mounted) {
        _mainMenu = mainMenu(context, "/contacts");

        setState(() {});
      }
    });
    cacheProjects = context.read<ProjectsProvider?>();
    if (cacheProjects == null) {
      cacheProjects ??= ProjectsProvider();
      cacheProjects?.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      cacheProjects?.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (cacheProjects!.profiles.isEmpty) {
        cacheProjects!.loadProfiles();
      }
    }

    _currentOrg = _provider?.organization;
    _currentProfile = _provider?.profile;
    _mainMenu = mainMenu(context, "/contacts");
    if (_currentOrg == null || _currentProfile == null) {
      _provider?.loadProfile();
    }
    orgs = [];
    allOrgs = [];
    if (allContacts.isEmpty) {
      Contact.getAll().then((val) {
        allContacts = val;
        for (Contact c in allContacts) {
          c.loadObjs().then((value) {
            contacts.add(c);
            if (mounted) {
              setState(() {});
            }
          });
        }
      });
    } else {
      contacts = allContacts;
      if (mounted) {
        setState(() {});
      }
    }
    loadOrgs();

    // loadContacts("-1");
  }

  @override
  Widget build(BuildContext context) {
    _mainMenu ??= mainMenu(context, "/contacts");
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        //mainMenu(context, "/contacts"),
        _mainMenu!,
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
        s4cTitleBar("Organizaciones", null, null, 10),
        Container(
            padding: const EdgeInsets.all(5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: SearchBar(
                        onChanged: (value) {
                          findOrganizations(value);
                        },
                        onSubmitted: (value) {
                          findOrganizations(value);
                        },
                        leading: const Icon(Icons.search),
                      )),
                  Expanded(
                      flex: 1,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            iconBtn(
                                context, filterOrganizations, {"filter": "all"},
                                text: "Vet Todas", icon: Icons.search),
                            iconBtn(
                              context,
                              callEditOrgDialog,
                              {'org': Organization("")},
                              text: "Nueva Organización",
                              icon: Icons.add,
                            ),
                          ]))
                ])),
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
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            //width: double.infinity,
            //width: MediaQuery.of(context).size.width / 3,
            child: DataTable(
              sortColumnIndex: 0,
              showCheckboxColumn: false,
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
                            currentOrg = org.name;
                            contacts = allContacts
                                .where((element) =>
                                    ((element.organization == org.uuid)) ||
                                    ((element.email.endsWith(org.domain) &&
                                        (org.domain.length > 4))))
                                .toList();
                            if (mounted) {
                              setState(() {});
                            }
                            //loadContacts(org.uuid);
                          }
                        },
                        cells: [
                          DataCell(Row(children: [
                            Text(org.name),
                            space(width: 5),
                            if (org.uuid == _currentOrg?.uuid)
                              Icon(Icons.my_location_outlined, color: mainColor)
                          ])),
                          DataCell(Row(children: [
                            Icon(org.isFinancier()),
                            customText("  -  ", 14),
                            Icon(org.isPartner())
                          ])),
                          DataCell(Row(children: [
                            goPageIcon(
                              context,
                              "Ver",
                              Icons.info,
                              OrganizationInfoPage(org: org),
                            ),
                            goPageIcon(
                              context,
                              "Facturas",
                              Icons.inventory,
                              OrganizationInvoicesPage(org: org),
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

  void saveOrganization(List args) async {
    Organization org = args[0];
    org.save();
    loadOrgs();

    Navigator.of(context).pop(org);
  }

  void callEditOrgDialog(context, Map<String, dynamic> args) async {
    Organization org = args["org"];
    Organization? orgNew = await orgEditDialog(context, org);
    int index = orgs.indexWhere((element) => element.uuid == orgNew!.uuid);
    if (index != -1) {
      orgs[index] = orgNew;
    } else {
      orgs.add(orgNew);
    }
    index = allOrgs.indexWhere((element) => element.uuid == orgNew!.uuid);
    if (index != -1) {
      allOrgs[index] = orgNew;
    } else {
      allOrgs.add(orgNew);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<Organization?> orgEditDialog(context, org) {
    return showDialog<Organization?>(
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
                  size: 300,
                  fieldValue: (String val) {
                    org.name = val;
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
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns2(context, saveOrganization, [org]),
          ],
        );
      },
    );
  }

  void removeOrganizationDialog(context, args) async {
    //customRemoveDialog(context, args["org"], loadOrgs, null);
    await customRemoveDialog(context, null, removeOrganization, args["org"]);
    if (mounted) {
      setState(() {});
    }
  }

  void removeOrganization(args) {
    String uuid2remove = args.uuid;

    Organization org = args;
    org.delete();

    allOrgs.removeWhere((element) => element.uuid == uuid2remove);
    orgs.removeWhere((element) => element.uuid == uuid2remove);
    loadOrgs();
    //print(org.name);
  }

/*-------------------------------------------------------------
                            CONTACTS
-------------------------------------------------------------*/
  void filterContacts(context, args) {
    if (args["filter"] == "all") {
      findContacts("");
      currentOrg = "Todas";
      _currentOrg = null;
      //loadContacts("-1");
    }
    if (args["filter"] == "generic") {
      currentOrg = "Sin organización";
      _currentOrg = null;
      contacts = allContacts.where((element) {
        Organization org = orgs.firstWhere(
            (org) => org.uuid == element.organization,
            orElse: () => Organization(""));
        if (org.name == "") {
          org = allOrgs.firstWhere(
              (org) => ((element.email.endsWith(org.domain)) &&
                  (org.domain.length > 4)),
              orElse: () => Organization(""));
        }
        return org.name == "";
      }).toList();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget contactList(context, args) {
    return Builder(builder: ((context) {
      return Column(children: [
        s4cTitleBar("Contactos", null, null, 10),
        Container(
            padding: const EdgeInsets.all(5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: 500,
                      child: SearchBar(
                        controller: searchController,
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 12.0)),
                        onChanged: (value) {
                          findContacts(value);
                        },
                        // onSubmitted: (value) {
                        //   findContacts(value);
                        // },
                        leading: const Icon(Icons.search),
                      )),
                  addBtnRow(context, filterContacts, {"filter": "generic"},
                      text: "Genéricos", icon: Icons.search),
                  addBtnRow(context, filterContacts, {"filter": "all"},
                      text: "Todos", icon: Icons.search),
                  addBtnRow(context, callEditDialog, {"contact": Contact("")},
                      text: ""),
                ])),
        Container(
            padding: const EdgeInsets.only(top: 20, left: 30),
            child: Row(
              children: [
                customText("Organización seleccionada:", 16,
                    textColor: mainColor),
                space(width: 10),
                currentOrg == ""
                    ? customText("Ninguna seleccionada", 16,
                        textColor: Colors.red)
                    : customText(currentOrg, 16, textColor: mainColor)
              ],
            )),
        Container(
          padding: const EdgeInsets.all(5),
          child: dataBody(context),
        )
      ]);
    }));
  }

  Widget contactTable(context) {
    //if (contacts.isNotEmpty) {
    List<Profile> allProfiles = cacheProjects!.profiles;
    if (contactsLoading == false) {
      return DataTable(
        sortColumnIndex: 0,
        showCheckboxColumn: false,
        dataRowMinHeight: 60,
        dataRowMaxHeight: 90,
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
        rows: contacts.map((contact) {
          Organization org = orgs.firstWhere(
              (org) => org.uuid == contact.organization,
              orElse: () => Organization(""));
          if (org.name == "") {
            org = allOrgs.firstWhere(
                (org) => ((contact.email != null &&
                        contact.email != "" &&
                        contact.email.endsWith(org.domain)) &&
                    (org.domain.length > 4)),
                orElse: () => Organization(""));
          }
          contact.organizationObj = org;
          Profile contactProfile = allProfiles.firstWhere(
              (profile) => profile.email == contact.email,
              orElse: () => Profile.getEmpty(
                  mainRole: "Externo", email: contact.email ?? ""));

          return DataRow(cells: [
            DataCell(Text(contact.name + " " + contact.email)),
            DataCell(
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(contact.organizationObj.name),
              space(height: 5),
              Text(contactProfile.mainRole, style: smallText)
            ])),
            DataCell(
              Text(contact.companyObj.name),
            ),
            // const DataCell(Text("")),
            DataCell(Text(contact.positionObj.name)),
            DataCell(Text(
              contact.phone,
              softWrap: false,
            )),
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
          ]);
        }).toList(),
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
    List<KeyValue> organizations = await Organization.getOrganizationsHash();
    List<KeyValue> companies = await Company.getCompaniesHash();
    List<KeyValue> positions = await Position.getPositionsHash();
    _contactEditDialog(context, contact, organizations, companies, positions);
  }

  void saveContact(List args) async {
    Contact contact = args[0];
    contact.save();
    contact.loadObjs().then((value) {
      allContacts.add(contact);
      findContacts("");
      setState(() {});
    });

    // loadContacts("");

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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Si no encuentra la posición o la empresa, contacte con el administrador',
                  maxLines: 2,
                  style: smallText,
                )
              ],
            ),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveContact, contact),
          ],
        );
      },
    );
  }

  void removeContactDialog(context, args) {
    //customRemoveDialog(context, args["contact"], loadContacts, "-1");
    Contact contact = args["contact"];
    customRemoveDialog(context, args["contact"], () {
      contacts.remove(contact);
      allContacts.remove(contact);
      if (mounted) {
        setState(() {});
      }
    }, null);
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
