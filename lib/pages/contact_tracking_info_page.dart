import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xffdfdfdf),
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: contactTrackingInfoDetails(context),
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
        editDialog(context, tracking);
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
/*                      CONTACT TRACKING EDIT                         */
/*--------------------------------------------------------------------*/
  void saveTracking(context, tracking, name, desc, date, manager, assistants,
      topics, agreements, contact) async {
    tracking ??= ContactTracking(contact.uuid);
    tracking.name = name;
    tracking.description = desc;
    tracking.date = date;
    tracking.manager = manager;
    tracking.assistants = assistants;
    tracking.topics = topics;
    tracking.agreements = agreements;
    tracking.save();
    reloadContactTrackingInfo();
    Navigator.of(context).pop();
  }

  Future<void> editDialog(context, tracking) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    TextEditingController dateController = TextEditingController(text: "");
    TextEditingController managerController = TextEditingController(text: "");
    TextEditingController assistantsController =
        TextEditingController(text: "");
    TextEditingController topicsController = TextEditingController(text: "");
    TextEditingController agreementsController =
        TextEditingController(text: "");

    if (tracking != null) {
      nameController = TextEditingController(text: tracking.name);
      descController = TextEditingController(text: tracking.description);
      dateController = TextEditingController(text: tracking.date);
      managerController = TextEditingController(text: tracking.manager);
      assistantsController = TextEditingController(text: tracking.assistants);
      topicsController = TextEditingController(text: tracking.topics);
      agreementsController = TextEditingController(text: tracking.agreements);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar seguimiento'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Nombre:", 16, textColor: Colors.blue),
                customTextField(nameController, "Nombre..."),
              ]),
              space(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Fecha:", 16, textColor: Colors.blue),
                customDateField(context, dateController),
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Descripción:", 16, textColor: Colors.blue),
                customTextField(descController, "Descripción...", size: 440),
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Responsable:", 16, textColor: Colors.blue),
                customTextField(managerController, "Responsable...", size: 440),
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Asistentes:", 16, textColor: Colors.blue),
                customTextField(assistantsController, "Asistentes...",
                    size: 440),
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Temas tratados:", 16, textColor: Colors.blue),
                customTextField(topicsController, "Temas tratados...",
                    size: 440),
              ]),
            ]),
            space(width: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Acuerdos:", 16, textColor: Colors.blue),
                customTextField(agreementsController, "Acuerdos...", size: 440),
              ]),
            ]),
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                saveTracking(
                    context,
                    tracking,
                    nameController.text,
                    descController.text,
                    dateController.text,
                    managerController.text,
                    assistantsController.text,
                    topicsController.text,
                    agreementsController.text,
                    contactT);
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

  Widget customDateField(context, dateController) {
    return SizedBox(
        width: 220,
        child: TextField(
          controller: dateController, //editing controller of this TextField
          decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Introducir fecha" //label text of field
              ),
          readOnly: true, //set it true, so that user will not able to edit text
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(
                    2000), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2101));

            if (pickedDate != null) {
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);

              setState(() {
                dateController.text = formattedDate;
              });
            } else {
              //print("Date is not selected");
            }
          },
        ));
  }

/*--------------------------------------------------------------------*/
/*                      CONTACT TRACKING INFO                         */
/*--------------------------------------------------------------------*/
  Widget contactTrackingInfoDetails(context) {
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
                      customText(tracking?.date, 16, bold: FontWeight.bold)
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
              ],
            )));
  }
}
