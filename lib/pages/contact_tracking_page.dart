import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sic4change/pages/contact_tracking_info_page.dart';
import 'package:sic4change/pages/contacts_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/services/models_contact_tracking.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/task_form.dart';
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
    //loadContactTracking(contact?.uuid);
    loadContactTracking();
  }

  /*void loadContactTracking(value) async {
    await getTrakingsByContact(value).then((val) {
      trackingList = val;
    });
    setState(() {});
  }*/

  void loadContactTracking() async {
    await getTrakingsByContact(contact!.uuid).then((val) {
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
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        addBtn(context, editDialog,
                            {'tracking': ContactTracking(contact!.uuid)}),
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

  Widget contactTrackingList(context, param) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: dataBody(context),
    );
  }

  SingleChildScrollView dataBody(context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: false,
            columns: [
              DataColumn(
                  label: customText("Encuentro", 14, bold: FontWeight.bold),
                  tooltip: "Encuentro"),
              DataColumn(
                  label: customText("Fecha:", 14, bold: FontWeight.bold),
                  tooltip: "Fecha"),
              DataColumn(
                  label: Expanded(
                      child: customText("Acciones", 14,
                          bold: FontWeight.bold, align: TextAlign.end)),
                  tooltip: "Acciones"),
            ],
            rows: trackingList
                .map(
                  (tracking) => DataRow(
                      onSelectChanged: (bool? selected) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => ContactTrackingInfoPage(
                                    tracking: tracking, contact: contact))));
                      },
                      cells: [
                        DataCell(Text(tracking.name)),
                        DataCell(
                          Text(DateFormat('yyyy-MM-dd').format(tracking.date)),
                        ),
                        DataCell(Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              /*goPageIcon(
                              context,
                              "Detalles",
                              Icons.info,
                              ContactTrackingInfoPage(
                                  tracking: tracking, contact: contact)),*/
                              //editBtn(context, editDialog, {'claim': claim}),
                              editBtn(context, callTaskEditDialog,
                                  {"tracking": tracking},
                                  icon: Icons.grading_sharp,
                                  text: "Añadir tarea"),
                              removeBtn(context, removeTrackingDialog,
                                  {"tracking": tracking})
                            ]))
                      ]),
                )
                .toList(),
          ),
        ));
  }

  void saveTracking(List args) async {
    ContactTracking tracking = args[0];
    tracking.save();
    loadContactTracking();
  }

  void editDialog(context, args) {
    ContactTracking? tracking = args["tracking"];
    _editDialog(context, tracking);
  }

  Future<void> _editDialog(context, tracking) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Seguimiento"),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: tracking.name,
                size: 220,
                fieldValue: (String val) {
                  tracking.name = val;
                },
              )
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Descripción",
                initial: tracking.description,
                size: 220,
                fieldValue: (String val) {
                  tracking.description = val;
                },
              )
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: 220,
                  child: DateTimePicker(
                    labelText: 'Fecha:',
                    selectedDate: tracking.date,
                    onSelectedDate: (DateTime date) {
                      tracking.date = date;
                      /*setState(() {
                            dates.approved = date;
                          });*/
                    },
                  )),
            ]),
          ])),
          actions: <Widget>[dialogsBtns(context, saveTracking, tracking)],
        );
      },
    );
  }

  void removeTrackingDialog(context, args) {
    customRemoveDialog(context, args["tracking"], loadContactTracking, null);
  }

/*--------------------------------------------------------------------*/
/*                           ACTIVITY TASK                                */
/*--------------------------------------------------------------------*/
  void callTaskEditDialog(context, HashMap args) async {
    ContactTracking tracking = args["tracking"];
    List<KeyValue> statusList = await getTasksStatusHash();
    List<KeyValue> contactList = await getContactsHash();
    //List<KeyValue> projectList = await getProjectsHash();
    //List<KeyValue> programmeList = await getProgrammesHash();
    List<KeyValue> profileList = await Profile.getProfileHash();
    List<KeyValue> orgList = await getOrganizationsHash();

    List projectList = await getProjects();
    List programmeList = await getProgrammes();

    final List<MultiSelectItem<KeyValue>> cList = contactList
        .map((contact) => MultiSelectItem<KeyValue>(contact, contact.value))
        .toList();
    final List<MultiSelectItem<KeyValue>> oList = orgList
        .map((org) => MultiSelectItem<KeyValue>(org, org.value))
        .toList();
    final List<MultiSelectItem<KeyValue>> pList = profileList
        .map((prof) => MultiSelectItem<KeyValue>(prof, prof.value))
        .toList();
    taskEditDialog(context, tracking, statusList, projectList, programmeList,
        pList, cList, oList);
  }

  void saveTask(List args) async {
    STask task = args[0];
    ContactTracking tracking = args[1];
    task.save();

    TasksRelation rel = TasksRelation(task.uuid);
    rel.objId = tracking.uuid;
    rel.model = "s4c_contact_tracking";
    rel.save();
    /*if (mounted) {
      setState(() {
      });
    }*/

    Navigator.pop(context);
  }

  Future<void> taskEditDialog(context, tracking, statusList, projectList,
      programmeList, profileList, contactList, orgList) {
    STask task = STask("");
    task.initializeProjectList(projectList);
    task.initializeProgrammeList(programmeList);
    //task.project = project!.uuid;
    //task.projectObj = project!;
    var user = FirebaseAuth.instance.currentUser!;
    task.sender = user.email!;
    task.public = true;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Nueva tarea'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return taskForm(task, projectList, programmeList, statusList,
                profileList, contactList, orgList, setState);
          }),
          actions: <Widget>[
            dialogsBtns2(context, saveTask, [task, tracking]),
          ],
        );
      },
    );
  }

  /*Widget customDateField(context, dateController) {
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
  }*/

  //Widget contactTrackingList(context, contact) {
  /*Widget contactTrackingList(context, param) {
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
          customText(DateFormat("dd-MM-yyyy").format(tracking.date), 14,
              bold: FontWeight.bold),
        ]),
        Column(children: [
          trackingRowOptions(context, tracking),
        ])
      ],
    );
  }

  Widget trackingRowOptions(context, tracking) {
    return Row(children: [
      goPageIcon(context, "Detalles", Icons.info,
          ContactTrackingInfoPage(tracking: tracking, contact: contact)),
      editBtn(context, editDialog, {'tracking': tracking}),
      removeBtn(context, removeTrackingDialog, {"tracking": tracking})
      /*IconButton(
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
          }),*/
    ]);
  }*/

  /*Future<void> _removeDialog(context, tracking) async {
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
  }*/
}
