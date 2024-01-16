import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/contacts_page.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/services/models_contact_tracking.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/contact_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactTrackingPageTitle = "Seguimiento";
List trackingList = [];

class ContactTrackingPage extends StatefulWidget {
  final Contact? contact;
  final ContactInfo? contactInfo;
  const ContactTrackingPage(
      {super.key, required this.contact, this.contactInfo});

  @override
  State<ContactTrackingPage> createState() => _ContactTrackingPageState();
}

class _ContactTrackingPageState extends State<ContactTrackingPage> {
  Contact? contact;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
    loadContactTracking(contact?.uuid);
  }

  void loadContactTracking(value) async {
    await getTrakingsByContact(value).then((val) {
      trackingList = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        contactTrackingHeader(context),
        contactMenu(context, widget.contact, widget.contactInfo, "tracking"),
        contentTab(context, contactTrackingList, null)
        /*Expanded(
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
                  child: contactTrackingList(context, contact),
                )))*/
      ]),
    );
  }

/*-------------------------------------------------------------
                            TRACKINGS
-------------------------------------------------------------*/
  Widget contactTrackingHeader(context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(contact!.name, 22),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        addBtn(context, editDialog, {
                          'tracking': ContactTracking(widget.contact!.uuid)
                        }),
                        space(width: 10),
                        goPage(context, "Volver", const ContactsPage(),
                            Icons.arrow_circle_left_outlined),
                      ],
                    ),
                  ),
                ]),
          ),
        ]));
  }

  /*Widget contactTrackingMenu(context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          menuTab(context, "Info", "/contact_info", {'contact': contact}),
          menuTabSelect(context, "Seguimiento", "/contact_trackings",
              {'contact': contact}),
          menuTab(
              context, "Reclamaciones", "/project_info", {'contact': contact}),
        ],
      ),
    );
  }*/

  // Widget addBtn(context) {
  //   return FilledButton(
  //     onPressed: () {
  //       _editDialog(context, null);
  //     },
  //     style: FilledButton.styleFrom(
  //       side: const BorderSide(width: 0, color: Color(0xffffffff)),
  //       backgroundColor: const Color(0xffffffff),
  //     ),
  //     child: const Column(
  //       children: [
  //         Icon(Icons.add, color: Colors.black54),
  //         SizedBox(height: 5),
  //         Text(
  //           "Añadir",
  //           style: TextStyle(color: Colors.black54, fontSize: 12),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void saveTracking(context, tracking, name, desc, contact) async {
    tracking ??= ContactTracking(contact.uuid);
    tracking.name = name;
    tracking.description = desc;
    tracking.save();
    loadContactTracking(contact.uuid);
    Navigator.of(context).pop();
  }

  void editDialog(context, args) {
    ContactTracking? tracking = args["tracking"];
    _editDialog(context, tracking);
  }

  Future<void> _editDialog(context, tracking) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    TextEditingController dateController = TextEditingController(text: "");

    if (tracking != null) {
      nameController = TextEditingController(text: tracking.name);
      descController = TextEditingController(text: tracking.description);
      dateController = TextEditingController(text: tracking.date);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Editar seguimiento'),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Nombre:", 16, textColor: Colors.blue),
              customTextField(nameController, "Nombre..."),
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Descripción:", 16, textColor: Colors.blue),
              customTextField(descController, "Descripción..."),
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Fecha:", 16, textColor: Colors.blue),
              customDateField(context, dateController),
            ]),
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                saveTracking(context, tracking, nameController.text,
                    descController.text, contact);
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

  //Widget contactTrackingList(context, contact) {
  Widget contactTrackingList(context, param) {
    return FutureBuilder(
        future: getTrakingsByContact(contact!.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            trackingList = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: trackingHeaderRow(context),
                ),
                Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: trackingList.length,
                        itemBuilder: (BuildContext context, int index) {
                          ContactTracking track = trackingList[index];
                          return Container(
                            height: 100,
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Color(0xffdfdfdf), width: 1)),
                            ),
                            child: trackingRow(context, track),
                          );
                        }))
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget trackingHeaderRow(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText("Encuentro", 16,
                textColor: titleColor, bold: FontWeight.bold),
          ],
        ),
        Column(children: [
          customText("Fecha", 16, textColor: titleColor, bold: FontWeight.bold),
        ]),
        Column(children: [
          customText("Acciones", 16,
              textColor: titleColor, bold: FontWeight.bold),
        ]),
      ],
    );
  }

  Widget trackingRow(context, tracking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(tracking.name, 14, bold: FontWeight.bold),
            space(height: 10),
            customText(tracking.description, 14),
          ],
        ),
        Column(children: [
          customText(tracking.date, 14, bold: FontWeight.bold),
        ]),
        Column(children: [
          trackingRowOptions(context, tracking),
        ])
      ],
    );
  }

  Widget trackingRowOptions(context, tracking) {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.info),
          tooltip: 'Detalles',
          onPressed: () {
            Navigator.pushNamed(context, "/contact_tracking_info",
                arguments: {'contact': contact, 'tracking': tracking});
          }),
      IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Editar',
          onPressed: () async {
            _editDialog(context, tracking);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Borrar',
          onPressed: () {
            _removeDialog(context, tracking);
          }),
    ]);
  }

  Future<void> _removeDialog(context, tracking) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Borrar seguimiento'),
          content: const SingleChildScrollView(
            child: Text("Está seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Borrar'),
              onPressed: () async {
                tracking.delete();
                loadContactTracking(contact?.uuid);
                Navigator.of(context).pop();
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
}
