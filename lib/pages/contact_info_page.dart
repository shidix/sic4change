//import 'dart:collection';

// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/contacts_page.dart';
import 'package:sic4change/services/cache_profiles.dart';
// import 'package:sic4change/pages/contact_tracking_page.dart';
//import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/contact_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactInfoTitle = "Detalles del Contacto";
bool isLoading = false;

class ContactInfoPage extends StatefulWidget {
  final Contact? contact;
  final ContactInfo? contactInfo;

  const ContactInfoPage({super.key, this.contact, this.contactInfo});

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  late ProfileProvider _provider;
  Contact? contact;
  ContactInfo? _contactInfo;
  Widget? contactInfoDetailsPanel;
  Organization? currentOrg;
  Profile? currentProfile;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<ProfileProvider>(context, listen: false);

    _provider.addListener(() {
      if (!mounted) return;
      currentOrg = _provider.organization;
      currentProfile = _provider.profile;
      if (currentOrg == null || currentProfile == null) {
        _provider.loadProfile();
      }
      setState(() {});
    });
    if ((currentOrg == null) || (currentProfile == null)) {
      _provider.loadProfile();
    }

    contact = widget.contact;
    _contactInfo = widget.contactInfo;
    contactInfoDetailsPanel = contactInfoDetails(context);

    if (_contactInfo == null) {
      contact!.getContactInfo().then((val) {
        _contactInfo = val;
        setState(() {
          isLoading = true;
          contactInfoDetailsPanel = contactInfoDetails(context);
        });
      });
    }
  }

  Future<void> reloadContactInfo() async {
    setState(() {
      isLoading = false;
    });

    _contactInfo?.reload().then((val) {
      _contactInfo = val;
      contactInfoDetailsPanel = contactInfoDetails(context);
      setState(() {
        isLoading = true;
      });
    });
  }

  Future<ContactInfo?> loadContactInfo(contact) async {
    if (_contactInfo == null) {
      await contact.getContactInfo().then((val) {
        _contactInfo = val;
        setState(() {
          isLoading = true;
        });
      });
    }
    return _contactInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          isLoading
              ? contactInfoHeader(context)
              : const Center(
                  child: Text(""),
                ),
          isLoading
              //? contactInfoMenu(context)
              ? contactMenu(context, widget.contact, _contactInfo, "info")
              : const Center(
                  child: Text(""),
                ),
          isLoading
              ? Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xffdfdfdf),
                            width: 2,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: contactInfoDetailsPanel ?? Container(),
                        //child: projectInfoDetails(context, _project),
                      )))
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }

  Widget contactInfoHeader(context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Text(_task.name, style: TextStyle(fontSize: 20)),
                  Container(
                    child: customText(contact!.name, 22),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //editBtn(context),
                        addBtn(context, callContactInfoEditDialog, null,
                            text: "Editar", icon: Icons.edit),
                        space(width: 10),
                        goPage(context, "Volver", const ContactsPage(),
                            Icons.arrow_circle_left_outlined),
                        //customRowPopBtn(context, "Volver", Icons.arrow_back)
                      ],
                    ),
                  ),
                ]),
          ),
        ]));
  }

  /*Widget editBtn(context) {
    return FilledButton(
      onPressed: () {
        callContactInfoEditDialog(context);
      },
      style: FilledButton.styleFrom(
        side: const BorderSide(width: 0, color: Color(0xffffffff)),
        backgroundColor: Color(0xffffffff),
      ),
      child: const Column(
        children: [
          Icon(Icons.edit, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Editar",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }*/

  // Widget contactInfoMenu(context) {
  //   return Container(
  //     padding: const EdgeInsets.only(left: 10, right: 10),
  //     child: Row(
  //       children: [
  //         menuTabSelect(context, "Info", "/contact_info", {'contact': contact}),
  //         menuTab2(context, "Seguimiento-n",
  //           ContactTrackingPage(contact: contact),
  //           selected: false),
  //         // menuTab(context, "Seguimiento", "/contact_trackings",
  //         //     {'contact': contact}),
  //         menuTab(context, "Reclamaciones", "/project_info",
  //             {'contactInfo': _contactInfo, 'contact': contact}),
  //       ],
  //     ),
  //   );
  // }

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget contactInfoDetails(context) {
    if (_contactInfo == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                contactInfoProjectsHeader(context),
                contactInfoProjects(context, _contactInfo),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow0(context, _contactInfo),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow1(context, _contactInfo),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow2(context, _contactInfo),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow3(context, _contactInfo),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow4(context, _contactInfo),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow5(context, _contactInfo),
                space(height: 10),
                /*customRowDivider(),
                space(height: 5),
                contactInfoDetailsRow6(context, _contactInfo),*/
              ],
            )));
  }

  Widget contactInfoDetailsRow0(context, contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Organización", 14, bold: FontWeight.bold),
            customText("Cargo", 14, bold: FontWeight.bold),
            customText("Grado de decisión", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            customText(contactInfo.orgObj.name, 16),
            customText(contactInfo.chargeObj.name, 16),
            customText(contactInfo.decisionObj.name, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow1(context, contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Categoría", 14, bold: FontWeight.bold),
            customText("Subcategoría", 14, bold: FontWeight.bold),
            customText("KOL", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            customText(contactInfo.catObj.name, 16),
            customText(contactInfo.subcatObj.name, 16),
            customText(contactInfo.kol, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow2(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Zona greográfica de influencia", 14,
                bold: FontWeight.bold),
            customText("Sub Zona geográfica de influencia", 14,
                bold: FontWeight.bold),
            customText("Ambito", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            customText(_contactInfo.zoneObj.name, 16),
            customText(_contactInfo.subzoneObj.name, 16),
            customText(_contactInfo.ambitObj.name, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow3(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Correo electrónico", 14, bold: FontWeight.bold),
            customText("Teléfono fijo", 14, bold: FontWeight.bold),
            customText("Móvil", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            customText(_contactInfo.email, 16),
            customText(_contactInfo.phone, 16),
            customText(_contactInfo.mobile, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow4(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Linkedin", 14, bold: FontWeight.bold),
            customText("Twitter", 14, bold: FontWeight.bold),
            customText("Otras redes sociales", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            customText(_contactInfo.linkedin, 16),
            customText(_contactInfo.twitter, 16),
            customText(_contactInfo.networks, 16),
          ])
        ]);
  }

  /*Widget contactInfoDetailsRow5(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("¿Se considera un KOL?", 16, textColor: titleColor),
            customText("Proyecto o programa", 16, textColor: titleColor),
          ]),
          TableRow(children: [
            customText(_contactInfo.kol, 16),
            //customText(_contactInfo.project, 16),
            customText(_contactInfo.contactPerson, 16),
          ])
        ]);
  }*/

  Widget contactInfoDetailsRow5(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Persona de contacto", 14, bold: FontWeight.bold),
            customText("Tipo de stakeholder", 14, bold: FontWeight.bold),
            customText("Tipo de sector", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            customText(_contactInfo.contactPerson, 16),
            customText(_contactInfo.stakeholder, 16),
            customText(_contactInfo.sector, 16),
          ])
        ]);
  }

  Widget contactInfoProjectsHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Proyectos:", 14, bold: FontWeight.bold),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir financiador',
        onPressed: () {
          _callProjectEditDialog(context);
        },
      )
    ]);
  }

  Widget contactInfoProjects(context, contactInfo) {
    return FutureBuilder(
        future: _contactInfo?.getProjects(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List<SProject> prList = snapshot.data!;
            return ListView.builder(
                //padding: const EdgeInsets.all(8),
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: prList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(prList[index].name),
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                size: 12,
                              ),
                              tooltip: 'Eliminar financiador',
                              onPressed: () async {
                                contactInfo.projects.remove(prList[index].uuid);
                                _removeProject(context, contactInfo);
                              },
                            )
                          ]));
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

/*--------------------------------------------------------------------*/
/*                           EDIT PROJECT                             */
/*--------------------------------------------------------------------*/
  void callContactInfoEditDialog(context) async {
    List<KeyValue> organizations = [];
    List<KeyValue> charges = [];
    List<KeyValue> categories = [];
    List<KeyValue> zones = [];
    List<KeyValue> decisions = [];
    List<KeyValue> ambits = [];
    List<KeyValue> stakeholders = [];
    List<KeyValue> sectors = [];

    await Organization.getOrganizations().then((value) async {
      for (Organization item in value) {
        organizations.add(item.toKeyValue());
      }
    });

    await ContactCharge.getContactCharges().then((value) async {
      for (ContactCharge item2 in value) {
        charges.add(item2.toKeyValue());
      }
    });
    await ContactCategory.getContactCategories().then((value) async {
      for (ContactCategory item3 in value) {
        categories.add(item3.toKeyValue());
      }
    });
    await Zone.getZones().then((value) async {
      for (Zone item4 in value) {
        zones.add(item4.toKeyValue());
      }
    });
    await ContactDecision.getContactDecisions().then((value) async {
      for (ContactDecision item5 in value) {
        decisions.add(item5.toKeyValue());
      }
    });
    await Ambit.getAmbits().then((value) async {
      for (Ambit item6 in value) {
        ambits.add(item6.toKeyValue());
      }
    });
    await ContactStakeholder.getContactStakeholders().then((value) async {
      for (ContactStakeholder item6 in value) {
        stakeholders.add(item6.toKeyValue());
      }
    });
    await Sector.getSectors().then((value) async {
      for (Sector item7 in value) {
        sectors.add(item7.toKeyValue());
      }
    });

    editContactInfoDialog(context, organizations, charges, categories, zones,
        decisions, ambits, stakeholders, sectors);

    // await getOrganizations().then((value) async {
    //   for (Organization item in value) {
    //     organizations.add(item.toKeyValue());
    //   }
    //   await getContactCharges().then((value) async {
    //     for (ContactCharge item2 in value) {
    //       charges.add(item2.toKeyValue());
    //     }
    //     await getContactCategories().then((value) async {
    //       for (TasksStatus item3 in value) {
    //         categories.add(item3.toKeyValue());
    //       }
    //       await Zone.getZones().then((value) async {
    //         for (Zone item4 in value) {
    //           zones.add(item4.toKeyValue());
    //         }
    //         await getContactDecisions().then((value) async {
    //           for (ContactDecision item5 in value) {
    //             decisions.add(item5.toKeyValue());
    //           }
    //           await Ambit.getAmbits().then((value) async {
    //             for (Ambit item6 in value) {
    //               ambits.add(item6.toKeyValue());
    //             }
    //             await getContactStakeholders().then((value) async {
    //               for (ContactStakeholder item6 in value) {
    //                 stakeholders.add(item6.toKeyValue());
    //               }
    //               await Sector.getSectors().then((value) async {
    //                 for (Sector item7 in value) {
    //                   sectors.add(item7.toKeyValue());
    //                 }
    //                 editContactInfoDialog(
    //                     context,
    //                     organizations,
    //                     charges,
    //                     categories,
    //                     zones,
    //                     decisions,
    //                     ambits,
    //                     stakeholders,
    //                     sectors);
    //               });
    //             });
    //           });
    //         });
    //       });
    //     });
    //   });
    // });
  }

  Future<void> editContactInfoDialog(context, organizations, charges,
      categories, zones, decisions, ambits, stakeholders, sectors) {
    TextEditingController orgController =
        TextEditingController(text: _contactInfo?.organization);
    TextEditingController chargeController =
        TextEditingController(text: _contactInfo?.charge);
    TextEditingController catController =
        TextEditingController(text: _contactInfo?.category);
    TextEditingController subcatController =
        TextEditingController(text: _contactInfo?.subcategory);
    TextEditingController zoneController =
        TextEditingController(text: _contactInfo?.zone);
    TextEditingController subzoneController =
        TextEditingController(text: _contactInfo?.subzone);
    TextEditingController emailController =
        TextEditingController(text: _contactInfo?.email);
    TextEditingController phoneController =
        TextEditingController(text: _contactInfo?.phone);
    TextEditingController mobileController =
        TextEditingController(text: _contactInfo?.mobile);
    TextEditingController decisionController =
        TextEditingController(text: _contactInfo?.decision);
    TextEditingController linkedinController =
        TextEditingController(text: _contactInfo?.linkedin);
    TextEditingController twitterController =
        TextEditingController(text: _contactInfo?.twitter);
    TextEditingController networksController =
        TextEditingController(text: _contactInfo?.networks);
    TextEditingController kolController =
        TextEditingController(text: _contactInfo?.kol);
    TextEditingController contactPersonController =
        TextEditingController(text: _contactInfo?.contactPerson);
    TextEditingController ambitController =
        TextEditingController(text: _contactInfo?.ambit);
    TextEditingController stakeholderController =
        TextEditingController(text: _contactInfo?.stakeholder);
    TextEditingController sectorController =
        TextEditingController(text: _contactInfo?.sector);

    List<KeyValue> kolDic = [KeyValue("Si", "Si"), KeyValue("No", "No")];
    String kolVal = (_contactInfo?.kol == "Si") ? "Si" : "No";
    KeyValue currentKol = KeyValue(kolVal, kolVal);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Modificar información de contacto'),
          content: SingleChildScrollView(
            child: Column(children: [
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Organización:", 16, textColor: titleColor),
                  customDropdownField(
                      orgController,
                      organizations,
                      _contactInfo?.orgObj.toKeyValue(),
                      "Selecciona una organización")
                  /*customAutocompleteField(orgController, organizations,
                      "Escribe o selecciona una organización..."),*/
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Cargo:", 16, textColor: titleColor),
                  customDropdownField(
                      chargeController,
                      charges,
                      _contactInfo?.chargeObj.toKeyValue(),
                      "Selecciona un cargo")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Grado de decisión:", 16, textColor: titleColor),
                  customDropdownField(
                      decisionController,
                      decisions,
                      _contactInfo?.decisionObj.toKeyValue(),
                      "Selecciona una sun zona")
                ]),
              ]),
              space(height: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Categoría:", 16, textColor: titleColor),
                  customDropdownField(
                      catController,
                      categories,
                      _contactInfo?.catObj.toKeyValue(),
                      "Selecciona una categoría")
                  /*customAutocompleteField(catController, _categories,
                      "Escribe o selecciona una categoría..."),*/
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Subcategoría:", 16, textColor: titleColor),
                  customDropdownField(
                      subcatController,
                      categories,
                      _contactInfo?.subcatObj.toKeyValue(),
                      "Selecciona una subcategoría")
                  /*customAutocompleteField(subcatController, _categories,
                      "Escribe o selecciona una sub categoría..."),*/
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("¿Se considera un KOL?:", 16,
                      textColor: titleColor),
                  customDropdownField(
                      kolController, kolDic, currentKol, "Si o No")
                ]),
              ]),
              space(width: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Zona:", 16, textColor: titleColor),
                  customDropdownField(zoneController, zones,
                      _contactInfo?.zoneObj.toKeyValue(), "Selecciona una zona")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Sub zona:", 16, textColor: titleColor),
                  customDropdownField(
                      subzoneController,
                      zones,
                      _contactInfo?.subzoneObj.toKeyValue(),
                      "Selecciona una sun zona")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Ambito:", 16, textColor: titleColor),
                  customDropdownField(
                      ambitController,
                      ambits,
                      _contactInfo?.ambitObj.toKeyValue(),
                      "Selecciona un ambito")
                ]),
              ]),
              space(width: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Correo electrónico:", 16, textColor: titleColor),
                  customTextField(emailController, "Correo electrónico")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Teléfono fijo:", 16, textColor: titleColor),
                  customTextField(phoneController, "Teléfono fijo")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Teléfono móvil:", 16, textColor: titleColor),
                  customTextField(mobileController, "Teléfono móvil")
                ]),
              ]),
              space(width: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Linkedin:", 16, textColor: titleColor),
                  customTextField(linkedinController, "Linkedin")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Twitter:", 16, textColor: titleColor),
                  customTextField(twitterController, "Twitter")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Otras redes:", 16, textColor: titleColor),
                  customTextField(networksController, "Otras redes")
                ]),
              ]),
              space(width: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Persona de contacto:", 16, textColor: titleColor),
                  customTextField(
                      contactPersonController, "Persona de contacto")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Tipo de stakeholder:", 16, textColor: titleColor),
                  customDropdownField(
                      stakeholderController,
                      stakeholders,
                      _contactInfo?.stakeholderObj.toKeyValue(),
                      "Selecciona un stakeholder")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Tipo de sector:", 16, textColor: titleColor),
                  customDropdownField(
                      sectorController,
                      sectors,
                      _contactInfo?.sectorObj.toKeyValue(),
                      "Selecciona un sector")
                ]),
              ]),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _contactInfo?.organization = orgController.text;
                _contactInfo?.charge = chargeController.text;
                _contactInfo?.category = catController.text;
                _contactInfo?.subcategory = subcatController.text;
                _contactInfo?.zone = zoneController.text;
                _contactInfo?.subzone = subzoneController.text;
                _contactInfo?.email = emailController.text;
                _contactInfo?.decision = decisionController.text;
                _contactInfo?.linkedin = linkedinController.text;
                _contactInfo?.twitter = twitterController.text;
                _contactInfo?.networks = networksController.text;
                _contactInfo?.kol = kolController.text;
                _contactInfo?.ambit = ambitController.text;
                _contactInfo?.phone = phoneController.text;
                _contactInfo?.mobile = mobileController.text;
                _contactInfo?.contactPerson = contactPersonController.text;
                _contactInfo?.stakeholder = stakeholderController.text;
                _contactInfo?.sector = sectorController.text;
                //_saveContactInfo(context, organizations, charges, categories);
                _saveContactInfo(context);
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

  void _saveContactInfo(context) async {
    _contactInfo?.save();

    Navigator.of(context).pop();
    reloadContactInfo();
  }

  /*--------------------------------------------------------------------*/
  /*                           PROJECTS                                 */
  /*--------------------------------------------------------------------*/
  void _saveProject(context, contactInfo, name, projects) async {
    contactInfo.projects.add(name);
    Navigator.of(context).pop();
    await contactInfo.updateProjects();
    reloadContactInfo();
  }

  void _removeProject(context, contactInfo) async {
    await contactInfo.updateProjects();
    reloadContactInfo();
  }

  void _callProjectEditDialog(context) async {
    List<KeyValue> projects = [];
    await SProject.getProjects().then((value) async {
      for (SProject item in value) {
        projects.add(item.toKeyValue());
      }

      _editDialog(context, projects);
    });
  }

  Future<void> _editDialog(context, projects) {
    TextEditingController nameController = TextEditingController(text: "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Añadir proyecto'),
          content: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Proyecto:", 16, textColor: titleColor),
              customDropdownField(
                  nameController, projects, null, "Seleccione proyecto"),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveProject(
                    context, _contactInfo, nameController.text, projects);
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
}
