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
                            space(width: 10),
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
              customText(
                  DateFormat('yyyy-MM-dd').format(task.deadLineDate), 16),
              customText(
                  DateFormat('yyyy-MM-dd').format(task.newDeadLineDate), 16),
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

  /*void _saveTask(List args) async {
    STask task = args[1];
    task.save();
    loadTask(task);
    Navigator.pop(context);
  }*/

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _taskEditDialog(
      context, task, statusList, contactList, projectList) {
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
                SizedBox(
                    width: 700,
                    child: CustomDropdown(
                      labelText: 'Proyecto',
                      selected: task.projectObj.toKeyValue(),
                      options: projectList,
                      onSelectedOpt: (String val) {
                        setState(() {
                          task.project = val;
                        });
                      },
                    )),
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
                SizedBox(
                    width: 340,
                    child: CustomDropdown(
                      labelText: 'Estado',
                      selected: task.statusObj.toKeyValue(),
                      options: statusList,
                      onSelectedOpt: (String val) {
                        setState(() {
                          task.status = val;
                        });
                      },
                    )),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Devolución:", 16, textColor: mainColor),
                SizedBox(
                    width: 340,
                    child: CustomDropdown(
                      labelText: 'Devolución',
                      selected: task.senderObj.toKeyValue(),
                      options: contactList,
                      onSelectedOpt: (String val) {
                        setState(() {
                          task.sender = val;
                        });
                      },
                    )),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: 220,
                    child: DateTimePicker(
                      labelText: 'Acuerdo',
                      selectedDate: task.dealDate,
                      onSelectedDate: (DateTime date) {
                        setState(() {
                          task.dealDate = date;
                        });
                      },
                    )),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: 220,
                    child: DateTimePicker(
                      labelText: 'Deadline',
                      selectedDate: task.deadLineDate,
                      onSelectedDate: (DateTime date) {
                        setState(() {
                          task.deadLineDate = date;
                        });
                      },
                    )),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: 220,
                    child: DateTimePicker(
                      labelText: 'Nuevo deadline',
                      selectedDate: task.newDeadLineDate,
                      onSelectedDate: (DateTime date) {
                        setState(() {
                          task.newDeadLineDate = date;
                        });
                      },
                    )),
              ]),
              space(width: 20),
            ])
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                task.save();
                loadTask(task);
                Navigator.pop(context);
                //_saveTask([context, task, statusList]);
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
  void _saveProgrammes(context, task, name, programmesList) async {
    task.programmes.add(name);
    task.updateProgrammes();
    if (!programmesList.contains(name)) {
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
