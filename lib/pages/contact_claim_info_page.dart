import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_claim.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/contact_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactClaimInfoTitle = "Detalles del Seguimiento";
//Contact? contactC;
//ContactClaim? claim;

class ContactClaimInfoPage extends StatefulWidget {
  final Contact? contact;
  final ContactClaim? claim;
  const ContactClaimInfoPage({super.key, this.contact, this.claim});

  @override
  State<ContactClaimInfoPage> createState() => _ContactClaimInfoPageState();
}

class _ContactClaimInfoPageState extends State<ContactClaimInfoPage> {
  Contact? contact;
  ContactClaim? claim;

  void reloadContactClaimInfo() async {
    claim?.reload().then((val) {
      claim = val;
    });
  }

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
    claim = widget.claim;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          mainMenu(context),
          contactClaimInfoHeader(context),
          contactMenu(context, contact, null, "claim"),
          contentTab(context, contactClaimInfoDetails, null)
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(claim!.name, 22),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //editBtn(context),
                        /*addBtn(context, editClaimInfoDialog, claim,
                            icon: Icons.edit, text: "Editar"),*/
                        addBtn(context, editDialog, claim,
                            icon: Icons.edit, text: "Editar"),
                        space(width: 10),
                        returnBtn(context),
                      ],
                    ),
                  ),
                ]),
          ),
        ]));
  }

/*--------------------------------------------------------------------*/
/*                      CONTACT CLAIM INFO                            */
/*--------------------------------------------------------------------*/
  Widget contactClaimInfoDetails(context, param) {
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customText(claim!.name, 16, bold: FontWeight.bold),
                      customText(
                          DateFormat('yyyy-MM-dd').format(claim!.date), 16,
                          bold: FontWeight.bold)
                    ]),
                space(height: 10),
                customRowDividerBlue(),
                space(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Responsable", 16, textColor: titleColor),
                    space(height: 10),
                    customText(claim?.managerObj.name, 16),
                  ],
                ),
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
                          customText(
                              DateFormat('yyyy-MM-dd')
                                  .format(claim!.resolutionDate),
                              16)
                        ],
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText("Conforme Si/No", 16, textColor: titleColor),
                      space(height: 10),
                      customText(claim?.agree, 16)
                    ],
                  ),
                ]),
              ],
            )));
  }

/*--------------------------------------------------------------------*/
/*                           EDIT CLAIM INFO                          */
/*--------------------------------------------------------------------*/
  void saveClaim(List args) async {
    ContactClaim claim = args[0];
    claim.save();
    await claim.getManager();
    setState(() {});
    if (claim.task == "") {
      STask task =
          STask("Reclamación: ${claim.name} [${claim.contactObj.name}]");
      task.description = "Reclamación: ${claim.name} [${claim.uuid}]";
      task.assigned.add(claim.managerObj.email);
      task.save();
      claim.task = task.uuid;
      claim.save();
    }
    //reloadContactTrackingInfo();
    Navigator.of(context).pop();
  }

  Future<void> editDialog(context, claim) async {
    List<KeyValue> contacts = await getContactsProfilesHash();
    editClaimInfoDialog(context, claim, contacts);
  }

  Future<void> editClaimInfoDialog(context, claim, contacts) {
    List<KeyValue> yesnoDic = [KeyValue("Si", "Si"), KeyValue("No", "No")];
    String agreeVal = (claim?.agree == "Si") ? "Si" : "No";
    KeyValue currentAgree = KeyValue(agreeVal, agreeVal);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modificar información de contacto'),
          content: SingleChildScrollView(
            child: Column(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: claim.name,
                  size: 440,
                  fieldValue: (String val) {
                    claim.name = val;
                  },
                )
              ]),
              space(width: 20),
              /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Responsable:",
                  initial: claim.manager,
                  size: 220,
                  fieldValue: (String val) {
                    claim.manager = val;
                  },
                )
              ]),*/
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Responsable:',
                  size: 440,
                  selected: claim.managerObj.toKeyValue(),
                  options: contacts,
                  onSelectedOpt: (String val) {
                    claim.manager = val;
                  },
                ),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: 440,
                    child: DateTimePicker(
                      labelText: 'Fecha:',
                      selectedDate: claim.date,
                      onSelectedDate: (DateTime date) {
                        claim.date = date;
                      },
                    )),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: 'Objeto de la reclamación:',
                  size: 440,
                  initial: claim.description,
                  fieldValue: (String val) {
                    claim.description = val;
                  },
                ),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: 'Motivación (explicación):',
                  size: 440,
                  initial: claim.motivation,
                  fieldValue: (String val) {
                    claim.motivation = val;
                  },
                ),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: 'Medidas tomadas/solución:',
                  size: 440,
                  initial: claim.actions,
                  fieldValue: (String val) {
                    claim.actions = val;
                  },
                ),
              ]),
              space(height: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Fecha de solución:',
                        selectedDate: claim.resolutionDate,
                        onSelectedDate: (DateTime date) {
                          claim.resolutionDate = date;
                        },
                      )),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //customText("Conforme Si/No:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Conforme Si/No',
                    size: 210,
                    selected: currentAgree,
                    options: yesnoDic,
                    onSelectedOpt: (String val) {
                      claim.agree = val;
                    },
                  ),
                ]),
              ]),
              space(width: 20),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveClaim, claim)],
        );
      },
    );
  }

  /*void _saveContactInfo(context) async {
    claim?.save();

    Navigator.of(context).pop();
    reloadContactClaimInfo();
  }*/

  /*Widget customDateField(context, dateController) {
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
  }*/
}
