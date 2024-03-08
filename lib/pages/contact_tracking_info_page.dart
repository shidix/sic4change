import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_tracking.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/contact_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactTrackingInfoTitle = "Detalles del Seguimiento";

class ContactTrackingInfoPage extends StatefulWidget {
  final Contact? contact;
  final ContactTracking? tracking;
  const ContactTrackingInfoPage({super.key, this.contact, this.tracking});

  @override
  State<ContactTrackingInfoPage> createState() =>
      _ContactTrackingInfoPageState();
}

class _ContactTrackingInfoPageState extends State<ContactTrackingInfoPage> {
  Contact? contact;
  ContactTracking? tracking;

  void reloadContactTrackingInfo() async {
    tracking?.reload().then((val) {
      tracking = val;
    });
  }

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
    tracking = widget.tracking;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          mainMenu(context),
          contactTrackingInfoHeader(context),
          contactMenu(context, contact, null, "tracking"),
          contentTab(context, contactTrackingInfoDetails, null)
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
                        //editBtn(context),
                        addBtn(context, editDialog, tracking,
                            icon: Icons.edit, text: "Editar"),
                        returnBtn(context),
                      ],
                    ),
                  ),
                ]),
          ),
        ]));
  }

/*--------------------------------------------------------------------*/
/*                      CONTACT TRACKING EDIT                         */
/*--------------------------------------------------------------------*/
  void saveTracking(List args) async {
    ContactTracking tracking = args[0];
    tracking.save();
    setState(() {});
    //reloadContactTrackingInfo();
    Navigator.of(context).pop();
  }

  Future<void> editDialog(context, tracking) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Editar seguimiento'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: 'Nombre',
                  size: 300,
                  initial: tracking.name,
                  fieldValue: (String val) {
                    tracking.name = val;
                  },
                ),
              ]),
              space(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: 290,
                    child: DateTimePicker(
                      labelText: 'Fecha:',
                      selectedDate: tracking.date,
                      onSelectedDate: (DateTime date) {
                        tracking.date = date;
                      },
                    )),
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Descripción",
                  initial: tracking.description,
                  size: 600,
                  fieldValue: (String val) {
                    tracking.description = val;
                  },
                )
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Responsable",
                  initial: tracking.manager,
                  size: 600,
                  fieldValue: (String val) {
                    tracking.manager = val;
                  },
                )
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Asistentes",
                  initial: tracking.assistants,
                  size: 600,
                  fieldValue: (String val) {
                    tracking.assistants = val;
                  },
                )
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Temas tratados",
                  initial: tracking.topics,
                  size: 600,
                  fieldValue: (String val) {
                    tracking.topics = val;
                  },
                )
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Acuerdos",
                  initial: tracking.agreements,
                  size: 600,
                  fieldValue: (String val) {
                    tracking.agreements = val;
                  },
                )
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Siguientes Pasos",
                  initial: tracking.nextSteps,
                  size: 600,
                  fieldValue: (String val) {
                    tracking.nextSteps = val;
                  },
                )
              ]),
            ]),
          ])),
          actions: <Widget>[dialogsBtns(context, saveTracking, tracking)],
        );
      },
    );
  }

/*--------------------------------------------------------------------*/
/*                      CONTACT TRACKING INFO                         */
/*--------------------------------------------------------------------*/
  Widget contactTrackingInfoDetails(context, param) {
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
                      customText(tracking?.name, 16, bold: FontWeight.bold),
                      customText(
                          DateFormat("dd-MM-yyyy").format(tracking!.date), 16,
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
                    customText(tracking?.manager, 16),
                  ],
                ),
                space(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Asistentes", 16, textColor: titleColor),
                    space(height: 10),
                    customText(tracking?.assistants, 16),
                  ],
                ),
                space(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Temas tratados", 16, textColor: titleColor),
                    space(height: 10),
                    customText(tracking?.topics, 16)
                  ],
                ),
                space(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Acuerdos", 16, textColor: titleColor),
                    space(height: 10),
                    customText(tracking?.agreements, 16)
                  ],
                ),
                space(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Siguientes pasos", 16, textColor: titleColor),
                    space(height: 10),
                    customText(tracking?.nextSteps, 16)
                  ],
                ),
              ],
            )));
  }
}
