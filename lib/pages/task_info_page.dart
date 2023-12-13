import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/task_widgets.dart';

const taskInfoTitle = "Detalles de la tarea";
STask? _task;

class TaskInfoPage extends StatefulWidget {
  const TaskInfoPage({super.key});

  @override
  State<TaskInfoPage> createState() => _TaskInfoPageState();
}

class _TaskInfoPageState extends State<TaskInfoPage> {
  void loadTask(task) async {
    await task.reload().then((val) {
      Navigator.popAndPushNamed(context, "/task_info",
          arguments: {"task": val});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _task = args["task"];
    } else {
      _task = null;
    }

    if (_task == null) return const Page404();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context, null, "/tasks_user"),
          projectTaskHeader(context, _task),
          space(height: 20),
          contentTab(context, taskInfoDetails, null)
          /*Expanded(
              child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: taskInfoDetails(context),
                  ))),*/
        ],
      ),
    );
  }

  Widget projectTaskHeader(context, _task) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Text(_task.name, style: TextStyle(fontSize: 20)),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(_task.name, 22),
                  ),
                  /*VerticalDivider(
                    width: 10,
                    color: Colors.grey,
                  ),*/
                  Text(_task.statusObj.name,
                      style: TextStyle(
                          fontSize: 16,
                          color: getStatusColor(_task.statusObj.name))),
                  /*IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Ver',
                      onPressed: () async {
                        _callEditDialog(context, _task);
                      }),*/
                  Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //editBtn(context),
                            addBtn(context, _callEditDialog, _task,
                                icon: Icons.edit, text: "Editar"),
                            //returnBtn(context)
                            FilledButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/tasks");
                              },
                              style: btnStyle,
                              child: Column(
                                children: [
                                  const Icon(Icons.arrow_circle_left_outlined,
                                      color: subTitleColor),
                                  space(height: 5),
                                  customText(returnText, 12,
                                      textColor: subTitleColor)
                                ],
                              ),
                            )
                          ]))
                ]),
            //Divider(color: Colors.grey),
          )
        ]));
  }

  /*Widget editBtn(context) {
    return FilledButton(
      onPressed: () {
        _callEditDialog(context, _task);
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

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget taskInfoDetails(context, param) {
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //customText(_task?.sender, 16),
                taskInfoSenderPublic(context, _task),
                space(height: 5),
                customRowDivider(),
                space(height: 10),
                customText("Descripción de la tarea:", 16,
                    textColor: smallColor),
                space(height: 5),
                customText(_task?.description, 16),
                space(height: 5),
                customRowDivider(),
                space(height: 10),
                customText("Comentarios:", 16, textColor: smallColor),
                space(height: 5),
                customText(_task?.comments, 16),
                space(height: 5),
                customRowDivider(),
                space(height: 10),
                taskInfoDates(context, _task),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                taskAssignedHeader(context, _task),
                taskAssigned(context, _task),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                taskProgrammesHeader(context, _task),
                taskProgrammes(context, _task),
                space(height: 5),
              ],
            )));
  }

  Widget taskInfoSenderPublic(context, task) {
    String public = "Privada";
    if (task.public) public = "Pública";

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Devolución a:", 16, textColor: Colors.grey),
                  space(height: 5),
                  customText(task.senderObj.name, 16),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Proyecto:", 16, textColor: Colors.grey),
                  space(height: 5),
                  customText(task.projectObj.name, 16),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: smallColor,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Pública / Privada:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(public, 16),
          ]),
        ],
      ),
    );
  }

  Widget taskInfoDates(context, task) {
    return Column(children: [
      Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              customText("Acuerdo", 16, textColor: Colors.grey),
              customText("Deadline", 16, textColor: Colors.grey),
              customText("Nuevo deadline", 16, textColor: Colors.grey),
            ]),
            TableRow(children: [
              customText(DateFormat('yyyy-MM-dd').format(task.dealDate), 16),
              customText(task.deadline_date, 16),
              customText(task.new_deadline_date, 16),
            ])
          ])
    ]);
  }

  Widget taskAssignedHeader(context, _task) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Responsables:", 16, textColor: Colors.grey),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir responsable',
        onPressed: () {
          _callAssignedEditDialog(context, _task);
        },
      )
    ]);
  }

  Widget taskAssigned(context, task) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: task.assigned.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${task.assigned[index]}'),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar responsable',
                      onPressed: () async {
                        task.assigned.remove(task.assigned[index]);
                        task.updateAssigned();
                        loadTask(task);
                        //_removeAssigned(context, _task);
                      },
                    )
                  ]));
        });
  }

  Widget taskProgrammesHeader(context, task) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Programas:", 16, textColor: smallColor),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir programa',
        onPressed: () {
          _callProgrammesEditDialog(context, task);
        },
      )
    ]);
  }

  Widget taskProgrammes(context, task) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: task.programmes.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${task.programmes[index]}'),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar programa',
                      onPressed: () async {
                        task.programmes.remove(task.programmes[index]);
                        //_removeProgrammes(context, _task);
                        task.updateProgrammes();
                        loadTask(task);
                      },
                    )
                  ]));
        });
  }

/*--------------------------------------------------------------------*/
/*                           EDIT TASK                                */
/*--------------------------------------------------------------------*/
  void _callEditDialog(context, task) async {
    List<KeyValue> statusList = await getTasksStatusHash();
    List<KeyValue> contactList = await getContactsHash();
    List<KeyValue> projectList = await getProjectsHash();
    _taskEditDialog(context, task, statusList, contactList, projectList);
  }

  void _saveTask(List args) async {
    STask task = args[1];
    task.save();
    loadTask(task);
    Navigator.pop(context);
  }

  Widget customDateField(context, dateController) {
    return SizedBox(
        width: 220,
        child: TextField(
          controller: dateController, //editing controller of this TextField
          decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Enter Date" //label text of field
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
              //print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);
              //print(formattedDate); //formatted date output using intl package =>  2021-03-16

              setState(() {
                dateController.text = formattedDate;
              });
            } else {
              print("Date is not selected");
            }
          },
        ));
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _taskEditDialog(
      context, task, statusList, contactList, projectList) {
    print("--0--");
    TextEditingController statusController = TextEditingController(text: "");
    //TextEditingController dealDateController = TextEditingController(text: "");
    TextEditingController deadlineDateController =
        TextEditingController(text: "");
    TextEditingController newDeadlineDateController =
        TextEditingController(text: "");
    TextEditingController senderController = TextEditingController(text: "");
    TextEditingController projectController = TextEditingController(text: "");

    if (task != null) {
      statusController = TextEditingController(text: task.status);
      //dealDateController = TextEditingController(text: task.deal_date);
      deadlineDateController = TextEditingController(text: task.deadline_date);
      newDeadlineDateController =
          TextEditingController(text: task.new_deadline_date);
      senderController = TextEditingController(text: task.sender);
      projectController = TextEditingController(text: task.project);
    }
    print("--1--");

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Modificar tarea'),
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar tarea'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 600,
                  child: TextFormField(
                    initialValue: (task.name != "") ? task.name : "",
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (val) => setState(() => task.name = val),
                  ),
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Pública:", 16, textColor: mainColor),
                FormField<bool>(builder: (FormFieldState<bool> state) {
                  return Checkbox(
                    value: task.public,
                    onChanged: (bool? value) {
                      setState(() {
                        task.public = value!;
                        state.didChange(task.public);
                      });
                    },
                  );
                })
              ])
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Proyecto:", 16, textColor: mainColor),
                customDropdownField(projectController, projectList,
                    task.projectObj.toKeyValue(), "Selecciona proyecto",
                    width: 700),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 600,
                  child: TextFormField(
                    initialValue:
                        (task.description != "") ? task.description : "",
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    onChanged: (val) => setState(() => task.description = val),
                  ),
                ),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 600,
                  child: TextFormField(
                    initialValue: (task.comments != "") ? task.comments : "",
                    decoration: const InputDecoration(labelText: 'Comentarios'),
                    onChanged: (val) => setState(() => task.comments = val),
                  ),
                ),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Estado:", 16, textColor: mainColor),
                customDropdownField(statusController, statusList,
                    task.statusObj.toKeyValue(), "Selecciona estado",
                    width: 340),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Devolución:", 16, textColor: mainColor),
                customDropdownField(senderController, contactList,
                    task.senderObj.toKeyValue(), "Selecciona devolución",
                    width: 340),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /*customText("Acuerdo:", 16, textColor: mainColor),
                customDateField(context, dealDateController),*/
                DateTimePicker(
                  labelText: 'Acuerdo',
                  selectedDate: task.dealDate,
                  onSelectedDate: (DateTime date) {
                    setState(() {
                      task.dealDate = date;
                    });
                  },
                ),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Deadline:", 16, textColor: mainColor),
                customDateField(context, deadlineDateController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Nuevo Deadline:", 16, textColor: mainColor),
                customDateField(context, newDeadlineDateController),
              ]),
              space(width: 20),
            ])
          ])),
          actions: <Widget>[
            /*Row(children: [
              Expanded(
                flex: 5,
                child: actionButton(
                    context, "Enviar", _saveTask, Icons.save_outlined, [
                  context,
                  task,
                  nameController.text,
                  descriptionController.text,
                  commentsController.text,
                  statusController.text,
                  dealDateController.text,
                  deadlineDateController.text,
                  newDeadlineDateController.text,
                  senderController.text,
                  projectController.text,
                  public,
                  statusList
                ]),
              ),
              space(width: 10),
              Expanded(
                  flex: 5,
                  child: actionButton(
                      context, "Cancelar", cancelItem, Icons.cancel, context))
            ]),*/
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveTask([
                  context,
                  task,
                  //commentsController.text,
                  statusController.text,
                  //dealDateController.text,
                  deadlineDateController.text,
                  newDeadlineDateController.text,
                  senderController.text,
                  projectController.text,
                  statusList
                ]);
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

  /*--------------------------------------------------------------------*/
  /*                           ASSIGNED                                 */
  /*--------------------------------------------------------------------*/
  void _saveAssigned(context, task, name, contacts) async {
    task.assigned.add(name);
    task.updateAssigned();

    if (!contacts.contains(name)) {
      Contact _contact = Contact(name, "", "", "", "");
      _contact.save();
    }
    loadTask(task);
    Navigator.of(context).pop();
  }

  void _callAssignedEditDialog(context, _task) async {
    List<String> contacts = [];
    await getContacts().then((value) async {
      for (Contact item in value) {
        contacts.add(item.name);
      }

      _editTaskAssignedDialog(context, _task, contacts);
    });
  }

  Future<void> _editTaskAssignedDialog(context, task, contacts) {
    TextEditingController nameController = TextEditingController(text: "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Añadir responsable'),
          content: SingleChildScrollView(
            child: Column(children: [
              customAutocompleteField(
                  nameController, contacts, "Write or select contact..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveAssigned(context, task, nameController.text, contacts);
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

  /*--------------------------------------------------------------------*/
  /*                           PROGRAMMES                               */
  /*--------------------------------------------------------------------*/
  void _saveProgrammes(context, task, name, programmes_list) async {
    task.programmes.add(name);
    task.updateProgrammes();
    if (!programmes_list.contains(name)) {
      Programme programme = Programme(name);
      programme.save();
    }
    loadTask(task);
    Navigator.of(context).pop();
  }

  void _callProgrammesEditDialog(context, task) async {
    List<String> programmeList = [];
    await getProgrammes().then((value) async {
      for (Programme item in value) {
        programmeList.add(item.name);
      }

      _editTaskProgrammesDialog(context, task, programmeList);
    });
  }

  Future<void> _editTaskProgrammesDialog(context, task, programmeList) {
    TextEditingController nameController = TextEditingController(text: "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Añadir responsable'),
          content: SingleChildScrollView(
            child: Column(children: [
              customAutocompleteField(
                  nameController, programmeList, "Write or select contact..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveProgrammes(
                    context, task, nameController.text, programmeList);
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
