import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/tasks_menu_widget.dart';

const pageUsersTaskTitle = "Carga de tareas por usuario";
List users = [];
bool usersLoading = false;
Widget? _mainMenu;

class TasksUsersPage extends StatefulWidget {
  const TasksUsersPage({super.key});

  @override
  State<TasksUsersPage> createState() => _TasksUsersPageState();
}

class _TasksUsersPageState extends State<TasksUsersPage> {
  var searchController = TextEditingController();

  void loadUsers() async {
    setState(() {
      usersLoading = true;
    });

    await Profile.getProfiles().then((value) {
      setState(() {
        users = value;
        usersLoading = false;
      });
    });
    //setState(() {});
  }

  @override
  void initState() {
    loadUsers();
    super.initState();
    _mainMenu = mainMenu(context, "/tasks_users");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        taskUsersHeader(context),
        space(height: 20),
        taskMenu(context, "tasksUsers"),
        usersLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : contentTabSized(context, taskUsersList, null),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            TASKS
-------------------------------------------------------------*/
  Widget taskUsersHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: const Text(pageUsersTaskTitle, style: headerTitleText),
      ),
      /*SearchBar(
        controller: searchController,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onSubmitted: (value) {
          loadUsers();
        },
        leading: const Icon(Icons.search),
      ),*/
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, callEditDialog, {"task": null}),
            //taskAddBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget taskUsersList(context, param) {
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
                  label: customText("Usuario", 14, bold: FontWeight.bold),
                  tooltip: "Usuario"),
              DataColumn(
                label: customText("Hoy", 14, bold: FontWeight.bold),
                tooltip: "Hoy",
              ),
              DataColumn(
                  label: customText("Mañana", 14, bold: FontWeight.bold),
                  tooltip: "Mañana"),
              DataColumn(
                  label: customText("Semana", 14, bold: FontWeight.bold),
                  tooltip: "Semana"),
              DataColumn(
                  label: customText("Mes", 14, bold: FontWeight.bold),
                  tooltip: "Mes"),
            ],
            rows: users
                .map(
                  (us) => DataRow(cells: [
                    DataCell(customText(us.email, 14)),
                    DataCell(Container(
                      margin: const EdgeInsets.all(5),
                      color: Colors.green,
                    )),
                    DataCell(Text("")),
                    DataCell(Text("")),
                    DataCell(Text("")),
                  ]),
                )
                .toList(),
          ),
        ));
  }

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
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                ]),
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

  void removeTaskDialog(context, args) {
    customRemoveDialog(context, args["task"], loadUsers);
  }
}
