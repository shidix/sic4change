import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sic4change/pages/documents_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/task_widgets.dart';

const taskInfoTitle = "Detalles de la tarea";

class TaskInfoPage extends StatefulWidget {
  final STask? task;
  const TaskInfoPage({super.key, this.task});

  @override
  State<TaskInfoPage> createState() => _TaskInfoPageState();
}

class _TaskInfoPageState extends State<TaskInfoPage> {
  STask? task;
  void loadTask(task) async {
    await task.reload().then((val) {
      setState(() {
        task = val;
      });
    });
  }

  @override
  initState() {
    super.initState();
    task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context, "/tasks_user"),
          projectTaskHeader(context, task),
          space(height: 20),
          contentTab(context, taskInfoDetails, null)
        ],
      ),
    );
  }

  Widget projectTaskHeader(context, task) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customText(task.name, 22),
                  Text(task.statusObj.name,
                      style: TextStyle(
                          fontSize: 16,
                          color: getStatusColor(task.statusObj.name))),
                  returnBtn(context),
                ]),
          )
        ]));
  }

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget taskInfoDetails(context, param) {
    String receivers = "";
    for (Contact item in task!.receiversObj) {
      receivers += "${item.name}, ";
    }
    String assigned = "";
    for (Profile item in task!.assignedObj) {
      assigned += "${item.email}, ";
    }
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //customRowDivider(),
                taskInfoRow1(context, task),
                space(height: 5),
                taskInfoRow2(context, task),
                space(height: 15),
                taskInfoRow3(context, task),
                space(height: 15),
                customText("Descripción de la tarea:", 16,
                    textColor: smallColor),
                space(height: 5),
                customText(task?.description, 16),
                space(height: 10),
                customText("Comentarios:", 16, textColor: smallColor),
                space(height: 5),
                customText(task?.comments, 16),
                space(height: 10),
                customText("Ejecutores:", 16, textColor: smallColor),
                space(height: 5),
                customText(assigned, 16),
                space(height: 10),
                customText("Destinatarios:", 16, textColor: smallColor),
                space(height: 5),
                customText(receivers, 16),
                space(height: 5),

                //customRowDivider(),
                /*taskAssignedHeader(context, task),
                taskAssigned(context, task),
                space(height: 5),
                customRowDivider(),
                space(height: 5),*/
                //taskProgrammesHeader(context, task),
                //taskProgrammes(context, task),
              ],
            )));
  }

  Widget taskInfoRow1(context, task) {
    String public = (task.public) ? "Si" : "No";
    String revision = (task.revision) ? "Si" : "No";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width / 5,
            child: Row(
              children: [
                customText("Proyecto:", 16, textColor: Colors.grey),
                space(width: 5),
                customText(task.projectObj.name, 16),
              ],
            )),
        Row(
          children: [
            /*const VerticalDivider(
                width: 10,
                color: Colors.grey,
              ),*/
            customText("Documentos:", 16, textColor: Colors.grey),
            space(width: 5),
            goPageIcon(
                context,
                "Ver",
                Icons.folder,
                DocumentsPage(
                  currentFolder: task.folderObj,
                ))
          ],
        ),
        Row(children: [
          customText("Pública:", 16, textColor: Colors.grey),
          space(width: 5),
          customText(public, 16),
          space(width: 10),
          customText("Revisión:", 16, textColor: Colors.grey),
          space(width: 5),
          customText(revision, 16),
        ]),
      ],
    );
  }

  Widget taskInfoRow2(context, task) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 7,
          child: Row(
            children: [
              customText("Estado:", 16, textColor: Colors.grey),
              space(height: 5),
              customText(task.statusObj.name, 16),
            ],
          ),
        ),
        Row(
          children: [
            customText("Prioridad:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(task.statusObj.name, 16),
          ],
        ),
        Row(children: [
          customText("Duración:", 16, textColor: Colors.grey),
          space(height: 5),
          customText(task.duration, 16),
        ]),
      ],
    );
  }

  Widget taskInfoRow3(context, task) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
          width: MediaQuery.of(context).size.width / 4.3,
          child: Row(children: [
            customText("Acuerdo:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(DateFormat('yyyy-MM-dd').format(task.dealDate), 16),
          ])),
      Row(children: [
        customText("Deadline:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(DateFormat('yyyy-MM-dd').format(task.deadLineDate), 16),
      ]),
      Row(children: [
        customText("Nuevo deadline", 16, textColor: Colors.grey),
        space(height: 5),
        customText(DateFormat('yyyy-MM-dd').format(task.newDeadLineDate), 16),
      ])
    ]);
  }

/*  Widget taskInfoSenderPublic(context, task) {
    String public = (task.public) ? "Si" : "No";
    String revision = (task.revision) ? "Si" : "No";

    return IntrinsicHeight(
      child: Row(
        children: [
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
            color: Colors.grey,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Documentos:", 16, textColor: Colors.grey),
                  space(height: 5),
                  customText(task.folder, 16),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: smallColor,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Pública:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(public, 16),
          ]),
          const VerticalDivider(
            width: 10,
            color: smallColor,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Revisión:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(revision, 16),
          ]),
        ],
      ),
    );
  }*/

  /*Widget taskInfoDates(context, task) {
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
  }*/

  /*Widget taskAssignedHeader(context, task) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Responsables:", 16, textColor: Colors.grey),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir responsable',
        onPressed: () {
          _callAssignedEditDialog(context, task);
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
        itemCount: task.assignedObj.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${task.assignedObj[index].name}'),
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
  }*/

  /*Widget taskProgrammesHeader(context, task) {
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
  }*/

  /*Widget taskProgrammes(context, task) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: task.programmesObj.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${task.programmesObj[index].name}'),
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
  }*/

/*--------------------------------------------------------------------*/
/*                           EDIT TASK                                */
/*--------------------------------------------------------------------*/
  void callEditDialog(context, HashMap args) async {
    List<KeyValue> statusList = await getTasksStatusHash();
    List<KeyValue> contactList = await getContactsHash();
    List<KeyValue> projectList = await getProjectsHash();
    final List<MultiSelectItem<KeyValue>> _items = contactList
        .map((contact) => MultiSelectItem<KeyValue>(contact, contact.value))
        .toList();
    taskEditDialog(
        context, args["task"], statusList, contactList, projectList, _items);
  }

  void saveTask(List args) async {
    STask task = args[0];
    task.save();

    Navigator.pop(context);
    //Navigator.pushNamed(context, "/task_info", arguments: {'task': task});
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> taskEditDialog(
      context, task, statusList, contactList, projectList, items) {
    STask task = STask("");
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Nueva tarea'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                child: Column(children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Nombre",
                    initial: task.name,
                    size: 600,
                    fieldValue: (String val) {
                      task.name = val;
                      //setState(() => task.comments = val);
                    },
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Pública:", 16, textColor: mainColor),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: task.public,
                      onChanged: (bool? value) {
                        task.public = value!;
                        state.didChange(task.public);
                      },
                    );
                  })
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Revisión:", 16, textColor: mainColor),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: task.revision,
                      onChanged: (bool? value) {
                        task.revision = value!;
                        state.didChange(task.revision);
                      },
                    );
                  })
                ])
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //customText("Proyecto:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Proyecto',
                    size: 340,
                    selected: task.projectObj.toKeyValue(),
                    options: projectList,
                    onSelectedOpt: (String val) {
                      task.project = val;
                    },
                  ),
                ]),
                space(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Documentos",
                    initial: task.name,
                    size: 340,
                    fieldValue: (String val) {
                      task.name = val;
                      //setState(() => task.comments = val);
                    },
                  )
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Descripción",
                    initial: task.description,
                    minLines: 2,
                    maxLines: 999,
                    size: 700,
                    fieldValue: (String val) {
                      task.description = val;
                    },
                  )
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Comentarios",
                    initial: task.comments,
                    minLines: 2,
                    maxLines: 999,
                    size: 700,
                    fieldValue: (String val) {
                      task.comments = val;
                    },
                  )
                ]),
              ]),
              space(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //customText("Estado:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Estado',
                    size: 230,
                    selected: task.statusObj.toKeyValue(),
                    options: statusList,
                    onSelectedOpt: (String val) {
                      task.status = val;
                    },
                  ),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //customText("Prioridad:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Prioridad',
                    size: 230,
                    selected: task.priorityKeyValue(),
                    options: STask.priorityList(),
                    onSelectedOpt: (String val) {
                      task.priority = val;
                    },
                  ),
                ]),
                space(width: 10),
                /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Duración",
                    initial: task.duration,
                    minLines: 2,
                    maxLines: 999,
                    size: 230,
                    fieldValue: (String val) {
                      task.duration = val;
                    },
                  )
                ]),*/
                /*space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Devolución:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Devolución',
                    size: 340,
                    selected: task.senderObj.toKeyValue(),
                    options: contactList,
                    onSelectedOpt: (String val) {
                      task.sender = val;
                    },
                  ),
                ]),*/
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
                          task.deadLineDate = date;
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
                          task.newDeadLineDate = date;
                        },
                      )),
                ]),
                space(width: 20),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  MultiSelectDialogField(
                    items: items,
                    title: customText("Ejecutores", 16),
                    selectedColor: mainColor,
                    decoration: multiSelectDecoration,
                    buttonIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: mainColor,
                    ),
                    //buttonText: customText("Seleccionar ejecutores", 16, textColor: mainColor),
                    buttonText: const Text(
                      "Seleccionar ejecutores",
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (results) {
                      for (KeyValue kv in results as List) {
                        task.assigned.add(kv.key);
                        //print(kv.value);
                      }
                      //_selectedAnimals = results;
                    },
                  ),
                ]),
                space(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  MultiSelectDialogField(
                    items: items,
                    title: customText("Destinatarios", 16),
                    selectedColor: mainColor,
                    decoration: multiSelectDecoration,
                    buttonIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: mainColor,
                    ),
                    //buttonText: customText("Seleccionar ejecutores", 16, textColor: mainColor),
                    buttonText: const Text(
                      "Seleccionar destinatarios",
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (results) {
                      for (KeyValue kv in results as List) {
                        task.receivers.add(kv.key);
                        //print(kv.value);
                      }
                      //_selectedAnimals = results;
                    },
                  ),
                ]),
              ]),
            ]));
          }),
          actions: <Widget>[
            dialogsBtns(context, saveTask, task),
            /*actions: <Widget>[
            Row(children: [
              Expanded(
                flex: 5,
                child: actionButton(
                    context, "Enviar", saveTask, Icons.save_outlined, [task]),
              ),
              space(width: 10),
              Expanded(
                  flex: 5,
                  child: actionButton(
                      context, "Cancelar", cancelItem, Icons.cancel, context))
            ]),*/
          ],
        );
      },
    );
  }

  /*void removeTaskDialog(context, args) {
    customRemoveDialog(context, args["task"], loadUsers);
  }*/

  /* VIEJO */
  /*void _callEditDialog(context, task) async {
    List<KeyValue> statusList = await getTasksStatusHash();
    List<KeyValue> contactList = await getContactsHash();
    List<KeyValue> projectList = await getProjectsHash();
    _taskEditDialog(context, task, statusList, contactList, projectList);
  }

  void saveTask(List args) async {
    STask task = args[0];
    task.save();
    loadTask(task);
    Navigator.pop(context);
  }

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
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar tarea'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                child: Column(children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Nombre",
                    initial: task.name,
                    size: 600,
                    fieldValue: (String val) {
                      task.name = val;
                      //setState(() => task.comments = val);
                    },
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Pública:", 16, textColor: mainColor),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: task.public,
                      onChanged: (bool? value) {
                        task.public = value!;
                        state.didChange(task.public);
                        /*setState(() {
                        task.public = value!;
                        state.didChange(task.public);
                      });*/
                      },
                    );
                  })
                ])
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Proyecto:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Proyecto',
                    size: 700,
                    selected: task.projectObj.toKeyValue(),
                    options: projectList,
                    onSelectedOpt: (String val) {
                      task.project = val;
                    },
                  ),
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Descripción",
                    initial: task.description,
                    size: 600,
                    fieldValue: (String val) {
                      task.description = val;
                    },
                  )
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Comentarios",
                    initial: task.comments,
                    size: 600,
                    fieldValue: (String val) {
                      task.comments = val;
                    },
                  )
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Estado:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Estado',
                    size: 340,
                    selected: task.statusObj.toKeyValue(),
                    options: statusList,
                    onSelectedOpt: (String val) {
                      task.status = val;
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Devolución:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Devolución',
                    size: 340,
                    selected: task.senderObj.toKeyValue(),
                    options: contactList,
                    onSelectedOpt: (String val) {
                      task.sender = val;
                    },
                  ),
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
                          //task.dealDate = date;
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
                          task.deadLineDate = date;
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
                          task.newDeadLineDate = date;
                        },
                      )),
                ]),
                space(width: 20),
              ])
            ]));
          }),
          actions: <Widget>[
            dialogsBtns(context, saveTask, task),
          ],
        );
      },
    );
  }*/

  /*--------------------------------------------------------------------*/
  /*                           ASSIGNED                                 */
  /*--------------------------------------------------------------------*/
  /*void saveAssigned(List args) async {
    STask task = args[0];
    task.updateAssigned();
    loadTask(task);
    Navigator.of(context).pop();
  }

  void _callAssignedEditDialog(context, task) async {
    List<KeyValue> contacts = await getContactsHash();
    _editTaskAssignedDialog(context, task, contacts);
  }

  Future<void> _editTaskAssignedDialog(context, task, contacts) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Añadir responsable'),
          content: SingleChildScrollView(
            child: Column(children: [
              CustomDropdown(
                labelText: 'Responsable',
                size: 340,
                selected: KeyValue("", ""),
                options: contacts,
                onSelectedOpt: (String val) {
                  task.assigned.add(val);
                  /*setState(() {
                      task.sender = val;
                    });*/
                },
              ),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveAssigned, task)],
        );
      },
    );
  }*/

  /*--------------------------------------------------------------------*/
  /*                           PROGRAMMES                               */
  /*--------------------------------------------------------------------*/
  /*void saveProgrammes(List args) async {
    STask task = args[0];
    task.updateProgrammes();
    loadTask(task);
    Navigator.of(context).pop();
  }*/

  /*void _callProgrammesEditDialog(context, task) async {
    List<KeyValue> programmeList = await getProgrammesHash();
    _editTaskProgrammesDialog(context, task, programmeList);
  }*/

  /*Future<void> _editTaskProgrammesDialog(context, task, programmeList) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Añadir programa'),
          content: SingleChildScrollView(
            child: Column(children: [
              CustomDropdown(
                labelText: 'Programa',
                size: 340,
                selected: KeyValue("", ""),
                options: programmeList,
                onSelectedOpt: (String val) {
                  task.programmes.add(val);
                },
              ),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveProgrammes, task)],
        );
      },
    );
  }*/
}
