import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/firebase_service.dart';
import 'package:sic4change/services/firebase_service_contact.dart';
import 'package:sic4change/services/firebase_service_tasks.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const TASK_INFO_TITLE = "Detalles de la tarea";
STask? _task;

class TaskInfoPage extends StatefulWidget {
  const TaskInfoPage({super.key});

  @override
  State<TaskInfoPage> createState() => _TaskInfoPageState();
}

class _TaskInfoPageState extends State<TaskInfoPage> {
  void loadTask(id) async {
    await getTaskById(id).then((val) {
      Navigator.popAndPushNamed(context, "/task_info",
          arguments: {"task": val});
      /*setState(() {
        _project = val;
        print(_project?.announcement);
      });*/
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

    if (_task == null) return Page404();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          projectTaskHeader(context, _task),
          space(height: 20),
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: taskInfoDetails(context),
                  ))),
        ],
      ),
    );
  }

  Color getStatusColor(status) {
    if (status == "Completado")
      return Colors.green;
    else if (status == "En proceso") return Colors.orange;
    return Colors.black;
  }

  Widget projectTaskHeader(context, _task) {
    return Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Text(_task.name, style: TextStyle(fontSize: 20)),
                  Container(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(_task.name, 22),
                  ),
                  /*VerticalDivider(
                    width: 10,
                    color: Colors.grey,
                  ),*/
                  Text(_task.status,
                      style: TextStyle(
                          fontSize: 16, color: getStatusColor(_task.status))),
                  IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Ver',
                      onPressed: () async {
                        _callEditDialog(context, _task);
                      }),
                ]),
            //Divider(color: Colors.grey),
          )
        ]));
  }

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget taskInfoDetails(context) {
    return SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //customText(_task?.sender, 16),
                taskInfoSenderPublic(context, _task),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                customText("Descripción de la tarea:", 16,
                    textColor: Colors.grey),
                space(height: 5),
                customText(_task?.description, 16),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                customText("Comentarios:", 16, textColor: Colors.grey),
                space(height: 5),
                customText(_task?.comments, 16),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                taskInfoDates(context, _task),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                taskAssignedHeader(context, _task),
                taskAssigned(context, _task),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                taskProgrammesHeader(context, _task),
                taskProgrammes(context, _task),
                space(height: 5),
              ],
            )));
  }

  Widget taskInfoSenderPublic(context, _task) {
    String _public = "Privada";
    if (_task.public) _public = "Pública";

    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Devolución a:", 16, textColor: Colors.grey),
                  space(height: 5),
                  customText(_task.sender, 16),
                ],
              )),
          VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          Container(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Proyecto:", 16, textColor: Colors.grey),
                  space(height: 5),
                  customText(_task.project, 16),
                ],
              )),
          VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          Container(
              //width: MediaQuery.of(context).size.width / 2.2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                customText("Pública / Privada:", 16, textColor: Colors.grey),
                space(height: 5),
                customText(_public, 16),
              ])),
        ],
      ),
    );
  }

  Widget taskInfoDates(context, _task) {
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
              customText(_task.deal_date, 16),
              customText(_task.deadline_date, 16),
              customText(_task.new_deadline_date, 16),
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

  Widget taskAssigned(context, _task) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _task.assigned.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_task.assigned[index]}'),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar responsable',
                      onPressed: () async {
                        _task.assigned.remove(_task.assigned[index]);
                        _removeAssigned(context, _task);
                      },
                    )
                  ]));
        });
  }

  Widget taskProgrammesHeader(context, _task) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Programas:", 16, textColor: Colors.grey),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir programa',
        onPressed: () {
          _callProgrammesEditDialog(context, _task);
        },
      )
    ]);
  }

  Widget taskProgrammes(context, _task) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _task.programmes.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_task.programmes[index]}'),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar programa',
                      onPressed: () async {
                        _task.programmes.remove(_task.programmes[index]);
                        _removeProgrammes(context, _task);
                      },
                    )
                  ]));
        });
  }

/*--------------------------------------------------------------------*/
/*                           EDIT TASK                                */
/*--------------------------------------------------------------------*/
  void _callEditDialog(context, task) async {
    List<String> status_list = [];
    List<String> contact_list = [];
    List<String> project_list = [];

    await getTasksStatus().then((value) async {
      for (TasksStatus item in value) {
        status_list.add(item.name);
      }
      await getContacts().then((value) async {
        for (Contact item in value) {
          contact_list.add(item.name);
        }

        await getProjects().then((value) async {
          for (SProject item in value) {
            project_list.add(item.name);
          }

          _taskEditDialog(
              context, task, status_list, contact_list, project_list);
        });
      });
    });
  }

  void _saveTask(
      context,
      _task,
      _name,
      _description,
      _comments,
      _status,
      _deal_date,
      _deadline_date,
      _new_deadline_date,
      _sender,
      _project,
      _public,
      _status_list) async {
    List<String> _assigned =
        (_task.assigned as List).map((item) => item as String).toList();
    List<String> _programmes =
        (_task.programmes as List).map((item) => item as String).toList();
    if (_task != null) {
      await updateTask(
              _task.id,
              _task.uuid,
              _name,
              _description,
              _comments,
              _status,
              _deal_date,
              _deadline_date,
              _new_deadline_date,
              _sender,
              _project,
              _assigned,
              _programmes,
              _public)
          .then((value) async {
        if (!_status_list.contains(_status)) await addTasksStatus(_status);
        loadTask(_task.id);
        Navigator.pop(context);
        //Navigator.popAndPushNamed(context, "/contacts");
      });
    } else {
      await addTask(
              _name,
              _description,
              _comments,
              _status,
              _deal_date,
              _deadline_date,
              _new_deadline_date,
              _sender,
              _project,
              List.empty(),
              List.empty(),
              _public)
          .then((value) async {
        if (!_status_list.contains(_status)) await addTasksStatus(_status);
        loadTask(_task.id);
        Navigator.pop(context);
        //Navigator.popAndPushNamed(context, "/contacts");
      });
    }
  }

  Widget customDateField(context, dateController) {
    return SizedBox(
        width: 220,
        child: TextField(
          controller: dateController, //editing controller of this TextField
          decoration: InputDecoration(
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

  Future<void> _taskEditDialog(
      context, _task, _status_list, _contact_list, _project_list) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descriptionController =
        TextEditingController(text: "");
    TextEditingController commentsController = TextEditingController(text: "");
    TextEditingController statusController = TextEditingController(text: "");
    TextEditingController dealDateController = TextEditingController(text: "");
    TextEditingController deadlineDateController =
        TextEditingController(text: "");
    TextEditingController newDeadlineDateController =
        TextEditingController(text: "");
    TextEditingController senderController = TextEditingController(text: "");
    TextEditingController projectController = TextEditingController(text: "");
    bool _public = false;

    if (_task != null) {
      nameController = TextEditingController(text: _task.name);
      descriptionController = TextEditingController(text: _task.description);
      commentsController = TextEditingController(text: _task.comments);
      statusController = TextEditingController(text: _task.status);
      dealDateController = TextEditingController(text: _task.deal_date);
      deadlineDateController = TextEditingController(text: _task.deadline_date);
      newDeadlineDateController =
          TextEditingController(text: _task.new_deadline_date);
      senderController = TextEditingController(text: _task.sender);
      projectController = TextEditingController(text: _task.project);
      _public = _task.public;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Modificar tarea'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Nombre:", 16, textColor: Colors.blue),
                customTextField(nameController, "Nombre", size: 600),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Pública:", 16, textColor: Colors.blue),
                FormField<bool>(builder: (FormFieldState<bool> state) {
                  return Checkbox(
                    value: _public,
                    onChanged: (bool? value) {
                      setState(() {
                        _public = value!;
                        state.didChange(_public);
                      });
                    },
                  );
                })
              ])
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Proyecto:", 16, textColor: Colors.blue),
                customAutocompleteField(projectController, _project_list,
                    "Write or select project...",
                    width: 700),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Descripción:", 16, textColor: Colors.blue),
                customTextField(descriptionController, "Descripción",
                    size: 700),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Comentarios:", 16, textColor: Colors.blue),
                customTextField(commentsController, "Comentarios", size: 700),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Estado:", 16, textColor: Colors.blue),
                customAutocompleteField(
                    statusController, _status_list, "Write or select status...",
                    width: 340),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Devolución:", 16, textColor: Colors.blue),
                customAutocompleteField(senderController, _contact_list,
                    "Write or select contact...",
                    width: 340),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Acuerdo:", 16, textColor: Colors.blue),
                customDateField(context, dealDateController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Deadline:", 16, textColor: Colors.blue),
                customDateField(context, deadlineDateController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Nuevo Deadline:", 16, textColor: Colors.blue),
                customDateField(context, newDeadlineDateController),
              ]),
              space(width: 20),
            ])
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveTask(
                    context,
                    _task,
                    nameController.text,
                    descriptionController.text,
                    commentsController.text,
                    statusController.text,
                    dealDateController.text,
                    deadlineDateController.text,
                    newDeadlineDateController.text,
                    senderController.text,
                    projectController.text,
                    _public,
                    _status_list);
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
  void _saveAssigned(context, _task, _name, _contacts) async {
    _task.assigned.add(_name);
    await updateTaskAssigned(_task.id, _task.assigned).then((value) async {
      if (!_contacts.contains(_name))
        await addContact(_name, "", [], "", "", "");
      loadTask(_task.id);
    });
    Navigator.of(context).pop();
  }

  void _removeAssigned(context, _task) async {
    await updateTaskAssigned(_task.id, _task.assigned).then((value) async {
      loadTask(_task.id);
    });
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

  Future<void> _editTaskAssignedDialog(context, _task, _contacts) {
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
                  nameController, _contacts, "Write or select contact..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveAssigned(context, _task, nameController.text, _contacts);
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
  void _saveProgrammes(context, _task, _name, _programmes_list) async {
    _task.programmes.add(_name);
    await updateTaskProgrammes(_task.id, _task.programmes).then((value) async {
      if (!_programmes_list.contains(_name)) await addProgramme(_name);
      loadTask(_task.id);
    });
    Navigator.of(context).pop();
  }

  void _removeProgrammes(context, _task) async {
    await updateTaskProgrammes(_task.id, _task.programmes).then((value) async {
      loadTask(_task.id);
    });
  }

  void _callProgrammesEditDialog(context, _task) async {
    List<String> programme_list = [];
    await getProgrammes().then((value) async {
      for (Programme item in value) {
        programme_list.add(item.name);
      }

      _editTaskProgrammesDialog(context, _task, programme_list);
    });
  }

  Future<void> _editTaskProgrammesDialog(context, _task, _programme_list) {
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
              customAutocompleteField(nameController, _programme_list,
                  "Write or select contact..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveProgrammes(
                    context, _task, nameController.text, _programme_list);
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
