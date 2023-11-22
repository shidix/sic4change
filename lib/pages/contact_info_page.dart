import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactInfoTitle = "Detalles del Contacto";
ContactInfo? _contactInfo;
Contact? _contact;
bool isLoading = false;

class ContactInfoPage extends StatefulWidget {
  const ContactInfoPage({super.key});

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  void reloadContactInfo() async {
    setState(() {
      isLoading = false;
    });

    _contactInfo?.reload().then((val) {
      _contactInfo = val;
      setState(() {
        isLoading = true;
      });
    });
  }

  /*void loadContactInfo(contactInfo) async {
    await contactInfo.reload.then((val) {
      Navigator.popAndPushNamed(context, "/contact_info",
          arguments: {"contactInfo": val, "contact": _contact});
    });
  }*/
  void loadContactInfo(contact) async {
    await contact.getContactInfo().then((val) {
      _contactInfo = val;
      setState(() {
        isLoading = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _contact = args["contact"];
      loadContactInfo(_contact);
    } else {
      _contactInfo = null;
      _contact = null;
    }

    if (_contact == null) return Page404();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          contactInfoHeader(context),
          contactInfoMenu(context),
          isLoading
              ? Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xffdfdfdf),
                            width: 2,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: contactInfoDetails(context),
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
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(_contact!.name, 22),
                  ),
                  /*VerticalDivider(
                    width: 10,
                    color: Colors.grey,
                  ),*/
                  /*Text(_task.status,
                      style: TextStyle(
                          fontSize: 16, color: getStatusColor(_task.status))),*/
                  IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                      onPressed: () async {
                        callContactInfoEditDialog(context);
                      }),
                ]),
          ),
        ]));
  }

  Widget contactInfoMenu(context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          menuTabSelect(context, "Info", "/contact_info",
              {'contactInfo': _contactInfo, 'contact': _contact}),
          menuTab(context, "Seguimiento", "/project_info",
              {'contactInfo': _contactInfo, 'contact': _contact}),
          menuTab(context, "Reclamaciones", "/project_info",
              {'contactInfo': _contactInfo, 'contact': _contact}),
        ],
      ),
    );
  }

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget contactInfoDetails(context) {
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            padding: EdgeInsets.all(10),
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
            customText("Organización", 16, textColor: titleColor),
            customText("Cargo", 16, textColor: titleColor),
            customText("Grado de decisión", 16, textColor: titleColor),
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
            customText("Categoría", 16, textColor: titleColor),
            customText("Subcategoría", 16, textColor: titleColor),
            customText("KOL", 16, textColor: titleColor),
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
            customText("Zona greográfica de influencia", 16,
                textColor: titleColor),
            customText("Sub Zona geográfica de influencia", 16,
                textColor: titleColor),
            customText("Ambito", 16, textColor: titleColor),
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
            customText("Correo electrónico", 16, textColor: titleColor),
            customText("Teléfono fijo", 16, textColor: titleColor),
            customText("Móvil", 16, textColor: titleColor),
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
            customText("Linkedin", 16, textColor: titleColor),
            customText("Twitter", 16, textColor: titleColor),
            customText("Otras redes sociales", 16, textColor: titleColor),
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
            customText("Persona de contacto", 16, textColor: titleColor),
            customText("Tipo de skateholder", 16, textColor: titleColor),
            customText("Tipo de sector", 16, textColor: titleColor),
          ]),
          TableRow(children: [
            customText(_contactInfo.contactPerson, 16),
            customText(_contactInfo.skateholder, 16),
            customText(_contactInfo.sector, 16),
          ])
        ]);
  }

  Widget contactInfoProjectsHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Proyectos:", 16, textColor: titleColor),
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
                            Text('${prList[index].name}'),
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
    List<KeyValue> skateholders = [];
    List<KeyValue> sectors = [];

    await getOrganizations().then((value) async {
      for (Organization item in value) {
        organizations.add(item.toKeyValue());
      }
      await getContactCharges().then((value) async {
        for (ContactCharge item2 in value) {
          charges.add(item2.toKeyValue());
        }
        await getContactCategories().then((value) async {
          for (ContactCategory item3 in value) {
            categories.add(item3.toKeyValue());
          }
          await getZones().then((value) async {
            for (Zone item4 in value) {
              zones.add(item4.toKeyValue());
            }
            await getContactDecisions().then((value) async {
              for (ContactDecision item5 in value) {
                decisions.add(item5.toKeyValue());
              }
              await getAmbits().then((value) async {
                for (Ambit item6 in value) {
                  ambits.add(item6.toKeyValue());
                }
                await getContactSkateholders().then((value) async {
                  for (ContactSkateholder item6 in value) {
                    skateholders.add(item6.toKeyValue());
                  }
                  await getSectors().then((value) async {
                    for (Sector item7 in value) {
                      sectors.add(item7.toKeyValue());
                    }
                    editContactInfoDialog(
                        context,
                        organizations,
                        charges,
                        categories,
                        zones,
                        decisions,
                        ambits,
                        skateholders,
                        sectors);
                  });
                });
              });
            });
          });
        });
      });
    });
  }

  Future<void> editContactInfoDialog(context, organizations, charges,
      categories, zones, decisions, ambits, skateholders, sectors) {
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
    TextEditingController skateholderController =
        TextEditingController(text: _contactInfo?.skateholder);
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
                  customText("Tipo de skateholder:", 16, textColor: titleColor),
                  customDropdownField(
                      skateholderController,
                      skateholders,
                      _contactInfo?.skateholderObj.toKeyValue(),
                      "Selecciona un skateholder")
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
                _contactInfo?.skateholder = skateholderController.text;
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
    await getProjects().then((value) async {
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
