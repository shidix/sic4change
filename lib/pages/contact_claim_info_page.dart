import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_claim.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/contact_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactClaimInfoTitle = "Detalles del Seguimiento";
Contact? contactC;
ContactClaim? claim;

class ContactClaimInfoPage extends StatefulWidget {
  const ContactClaimInfoPage({super.key});

  @override
  State<ContactClaimInfoPage> createState() => _ContactClaimInfoPageState();
}

class _ContactClaimInfoPageState extends State<ContactClaimInfoPage> {
  void reloadContactClaimInfo() async {
    claim?.reload().then((val) {
      claim = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      contactC = args["contact"];
      claim = args["claim"];
    } else {
      claim = null;
    }

    if (claim == null) return const Page404();

    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          mainMenu(context),
          contactClaimInfoHeader(context),
          contactMenu(context, contactC, "claim"),
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
                    child: contactClaimInfoDetails(context),
                    //child: projectInfoDetails(context, _project),
                  )))
        ]));
  }

  Widget contactClaimInfoHeader(context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(claim!.name, 22),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
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
        editClaimInfoDialog(context);
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
  Widget contactClaimInfoDetails(context) {
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
                      customText(claim?.name, 16, bold: FontWeight.bold),
                      customText(claim?.date, 16, bold: FontWeight.bold)
                    ]),
                space(height: 10),
                customRowDividerBlue(),
                space(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Objeto de la reclamación", 16,
                        textColor: titleColor),
                    space(height: 10),
                    customText(claim?.description, 16),
                  ],
                ),
                space(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Motivación (explicación)", 16,
                        textColor: titleColor),
                    space(height: 10),
                    customText(claim?.motivation, 16),
                  ],
                ),
                space(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Medidas tomadas/solución", 16,
                        textColor: titleColor),
                    space(height: 10),
                    customText(claim?.actions, 16)
                  ],
                ),
                space(height: 30),
                Row(children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customText("Fecha de solución", 16,
                              textColor: titleColor),
                          space(height: 10),
                          customText(claim?.resolutionDate, 16)
                        ],
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText("Conforme Si/No", 16, textColor: titleColor),
                      space(height: 10),
                      customText(claim?.resolutionDate, 16)
                    ],
                  ),
                ]),
              ],
            )));
  }

/*--------------------------------------------------------------------*/
/*                           EDIT CLAIM INFO                          */
/*--------------------------------------------------------------------*/
  Future<void> editClaimInfoDialog(context) {
    TextEditingController descController =
        TextEditingController(text: claim?.description);
    TextEditingController motivationController =
        TextEditingController(text: claim?.motivation);
    TextEditingController actionsController =
        TextEditingController(text: claim?.actions);
    TextEditingController resDateController =
        TextEditingController(text: claim?.resolutionDate);
    TextEditingController agreeController =
        TextEditingController(text: claim?.agree);

    List<KeyValue> yesnoDic = [KeyValue("Si", "Si"), KeyValue("No", "No")];
    String agreeVal = (claim?.agree == "Si") ? "Si" : "No";
    KeyValue currentAgree = KeyValue(agreeVal, agreeVal);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Modificar información de contacto'),
          content: SingleChildScrollView(
            child: Column(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Objeto de la reclamación:", 16,
                    textColor: titleColor),
                customTextField(descController, "Objeto de la reclamación",
                    size: 440)
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Motivación (explicación):", 16,
                    textColor: titleColor),
                customTextField(
                    motivationController, "Motivación (explicación)",
                    size: 440)
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Medidas tomadas/solución:", 16,
                    textColor: titleColor),
                customTextField(actionsController, "Medidas tomadas/solución",
                    size: 440)
              ]),
              space(height: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Fecha de solución:", 16, textColor: titleColor),
                  customDateField(context, resDateController),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Conforme Si/No:", 16, textColor: titleColor),
                  customDropdownField(
                      agreeController, yesnoDic, currentAgree, "Si o No")
                ]),
              ]),
              space(width: 20),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                claim?.description = descController.text;
                claim?.motivation = motivationController.text;
                claim?.actions = actionsController.text;
                claim?.resolutionDate = resDateController.text;
                claim?.agree = agreeController.text;
                _saveContactInfo(context);
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
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
    claim?.save();

    Navigator.of(context).pop();
    reloadContactClaimInfo();
  }

  Widget customDateField(context, dateController) {
    return SizedBox(
        width: 220,
        child: TextField(
          controller: dateController,
          decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today), labelText: "Enter Date"),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101));

            if (pickedDate != null) {
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);

              setState(() {
                dateController.text = formattedDate;
              });
            } else {
              print("Date is not selected");
            }
          },
        ));
  }
}
