import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
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
                  //Text(_task.name, style: TextStyle(fontSize: 20)),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(task.name, 22),
                  ),
                  /*VerticalDivider(
                    width: 10,
                    color: Colors.grey,
                  ),*/
                  Text(task.statusObj.name,
                      style: TextStyle(
                          fontSize: 16,
                          color: getStatusColor(task.statusObj.name))),
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
                            addBtn(context, _callEditDialog, task,
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
                taskInfoSenderPublic(context, task),
                space(height: 5),
                customRowDivider(),
                space(height: 10),
                customText("Descripción de la tarea:", 16,
                    textColor: smallColor),
                space(height: 5),
                customText(task?.description, 16),
                space(height: 5),
                customRowDivider(),
                space(height: 10),
                customText("Comentarios:", 16, textColor: smallColor),
                space(height: 5),
                customText(task?.comments, 16),
                space(height: 5),
                customRowDivider(),
                space(height: 10),
                taskInfoDates(context, task),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                taskAssignedHeader(context, task),
                taskAssigned(context, task),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                //taskProgrammesHeader(context, task),
                //taskProgrammes(context, task),
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

  Widget taskAssignedHeader(context, task) {
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
  }

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
  void _callEditDialog(context, task) async {
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
  }

  /*--------------------------------------------------------------------*/
  /*                           ASSIGNED                                 */
  /*--------------------------------------------------------------------*/
  void saveAssigned(List args) async {
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
  }

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
