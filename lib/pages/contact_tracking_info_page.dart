import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_tracking.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/contact_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactTrackingInfoTitle = "Detalles del Seguimiento";
Contact? contactT;
ContactTracking? tracking;

class ContactTrackingInfoPage extends StatefulWidget {
  const ContactTrackingInfoPage({super.key});

  @override
  State<ContactTrackingInfoPage> createState() =>
      _ContactTrackingInfoPageState();
}

class _ContactTrackingInfoPageState extends State<ContactTrackingInfoPage> {
  void reloadContactTrackingInfo() async {
    tracking?.reload().then((val) {
      tracking = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      contactT = args["contact"];
      tracking = args["tracking"];
    } else {
      tracking = null;
    }

    if (tracking == null) return const Page404();

    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          mainMenu(context),
          contactTrackingInfoHeader(context),
          contactMenu(context, contactT, "tracking"),
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffdfdfdf),
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: contactTrackingInfoDetails(context),
                    //child: projectInfoDetails(context, _project),
                  )))
        ]));
  }

  Widget contactTrackingInfoHeader(context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(tracking!.name, 22),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        editBtn(context),
                        returnBtn(context),
                      ],
                    ),
                  ),
                ]),
          ),
        ]));
  }

  Widget editBtn(context) {
    return FilledButton(
      onPressed: () {
        //callContactInfoEditDialog(context);
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
  }

/*--------------------------------------------------------------------*/
/*                      CONTACT TRACKING INFO                         */
/*--------------------------------------------------------------------*/
  Widget contactTrackingInfoDetails(context) {
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customText(tracking?.name, 16, bold: FontWeight.bold),
                      customText(tracking?.date, 16, bold: FontWeight.bold)
                    ]),
                space(height: 10),
                customRowDividerBlue(),
                space(height: 30),
                Column(
                  children: [
                    customText("Responsable", 16, textColor: titleColor),
                    space(height: 10),
                    customText(tracking?.manager, 16),
                  ],
                ),
                space(height: 30),
                Column(
                  children: [
                    customText("Asistentes", 16, textColor: titleColor),
                    space(height: 10),
                    customText(tracking?.assistants, 16),
                  ],
                ),
                space(height: 30),
                Column(
                  children: [
                    customText("Temas tratados", 16, textColor: titleColor),
                    space(height: 10),
                    customText(tracking?.topics, 16)
                  ],
                ),
                space(height: 30),
                Column(
                  children: [
                    customText("Acuerdos", 16, textColor: titleColor),
                    space(height: 10),
                    customText(tracking?.agreements, 16)
                  ],
                ),

                /*contactInfoProjectsHeader(context),
                contactInfoProjects(context, tracking),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow0(context, tracking),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow1(context, tracking),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow2(context, tracking),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow3(context, tracking),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow4(context, tracking),
                space(height: 10),
                customRowDivider(),
                space(height: 10),
                contactInfoDetailsRow5(context, tracking),
                space(height: 10),*/
                /*customRowDivider(),
                space(height: 5),
                contactInfoDetailsRow6(context, _contactInfo),*/
              ],
            )));
  }

/*--------------------------------------------------------------------*/
/*                           EDIT TRACKING                            */
/*--------------------------------------------------------------------*/
  /*void callContactInfoEditDialog(context) async {
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
        TextEditingController(text: tracking?.organization);
    TextEditingController chargeController =
        TextEditingController(text: tracking?.charge);
    TextEditingController catController =
        TextEditingController(text: tracking?.category);
    TextEditingController subcatController =
        TextEditingController(text: tracking?.subcategory);
    TextEditingController zoneController =
        TextEditingController(text: tracking?.zone);
    TextEditingController subzoneController =
        TextEditingController(text: tracking?.subzone);
    TextEditingController emailController =
        TextEditingController(text: tracking?.email);
    TextEditingController phoneController =
        TextEditingController(text: tracking?.phone);
    TextEditingController mobileController =
        TextEditingController(text: tracking?.mobile);
    TextEditingController decisionController =
        TextEditingController(text: tracking?.decision);
    TextEditingController linkedinController =
        TextEditingController(text: tracking?.linkedin);
    TextEditingController twitterController =
        TextEditingController(text: tracking?.twitter);
    TextEditingController networksController =
        TextEditingController(text: tracking?.networks);
    TextEditingController kolController =
        TextEditingController(text: tracking?.kol);
    TextEditingController contactPersonController =
        TextEditingController(text: tracking?.contactPerson);
    TextEditingController ambitController =
        TextEditingController(text: tracking?.ambit);
    TextEditingController skateholderController =
        TextEditingController(text: tracking?.skateholder);
    TextEditingController sectorController =
        TextEditingController(text: tracking?.sector);

    List<KeyValue> kolDic = [KeyValue("Si", "Si"), KeyValue("No", "No")];
    String kolVal = (tracking?.kol == "Si") ? "Si" : "No";
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
                      tracking?.orgObj.toKeyValue(),
                      "Selecciona una organización")
                  /*customAutocompleteField(orgController, organizations,
                      "Escribe o selecciona una organización..."),*/
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Cargo:", 16, textColor: titleColor),
                  customDropdownField(chargeController, charges,
                      tracking?.chargeObj.toKeyValue(), "Selecciona un cargo")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Grado de decisión:", 16, textColor: titleColor),
                  customDropdownField(
                      decisionController,
                      decisions,
                      tracking?.decisionObj.toKeyValue(),
                      "Selecciona una sun zona")
                ]),
              ]),
              space(height: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Categoría:", 16, textColor: titleColor),
                  customDropdownField(catController, categories,
                      tracking?.catObj.toKeyValue(), "Selecciona una categoría")
                  /*customAutocompleteField(catController, _categories,
                      "Escribe o selecciona una categoría..."),*/
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Subcategoría:", 16, textColor: titleColor),
                  customDropdownField(
                      subcatController,
                      categories,
                      tracking?.subcatObj.toKeyValue(),
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
                      tracking?.zoneObj.toKeyValue(), "Selecciona una zona")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Sub zona:", 16, textColor: titleColor),
                  customDropdownField(
                      subzoneController,
                      zones,
                      tracking?.subzoneObj.toKeyValue(),
                      "Selecciona una sun zona")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Ambito:", 16, textColor: titleColor),
                  customDropdownField(ambitController, ambits,
                      tracking?.ambitObj.toKeyValue(), "Selecciona un ambito")
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
                      tracking?.skateholderObj.toKeyValue(),
                      "Selecciona un skateholder")
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Tipo de sector:", 16, textColor: titleColor),
                  customDropdownField(sectorController, sectors,
                      tracking?.sectorObj.toKeyValue(), "Selecciona un sector")
                ]),
              ]),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                tracking?.organization = orgController.text;
                tracking?.charge = chargeController.text;
                tracking?.category = catController.text;
                tracking?.subcategory = subcatController.text;
                tracking?.zone = zoneController.text;
                tracking?.subzone = subzoneController.text;
                tracking?.email = emailController.text;
                tracking?.decision = decisionController.text;
                tracking?.linkedin = linkedinController.text;
                tracking?.twitter = twitterController.text;
                tracking?.networks = networksController.text;
                tracking?.kol = kolController.text;
                tracking?.ambit = ambitController.text;
                tracking?.phone = phoneController.text;
                tracking?.mobile = mobileController.text;
                tracking?.contactPerson = contactPersonController.text;
                tracking?.skateholder = skateholderController.text;
                tracking?.sector = sectorController.text;
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
    tracking?.save();

    Navigator.of(context).pop();
    reloadContactTrackingInfo();
  }*/

  /*--------------------------------------------------------------------*/
  /*                           PROJECTS                                 */
  /*--------------------------------------------------------------------*/
  /*void _saveProject(context, contactInfo, name, projects) async {
    contactInfo.projects.add(name);
    Navigator.of(context).pop();
    await contactInfo.updateProjects();
    reloadContactTrackingInfo();
  }

  void _removeProject(context, contactInfo) async {
    await contactInfo.updateProjects();
    reloadContactTrackingInfo();
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
                _saveProject(context, tracking, nameController.text, projects);
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
}
