import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sic4change/pages/task_info_page.dart';
import 'package:sic4change/pages/tasks_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/task_form.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/task_widgets.dart';
import 'package:sic4change/widgets/tasks_menu_widget.dart';

const pageTaskUserTitle = "Tareas";
List tasksUser = [];

class TasksUserPage extends StatefulWidget {
  const TasksUserPage({super.key});

  @override
  State<TasksUserPage> createState() => _TasksUserPageState();
}

class _TasksUserPageState extends State<TasksUserPage> {
  List<Profile> profiles = [];
  List<STask> allTasksUser = [];
  List<TasksStatus> statusListCache = [];

  var searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  Widget taskListPanel = const Align(
      alignment: Alignment.center, child: CircularProgressIndicator());

  void updateObjects(task) {
    task.statusObj = statusListCache
        .firstWhere((element) => element.uuid == task.status, orElse: () {
      return TasksStatus("No iniciado");
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    TasksStatus.getTasksStatus().then((value) {
      statusListCache = value;
      STask.getByUser(user.email).then((value) {
        setState(() {
          allTasksUser = value;
          for (STask task in allTasksUser) {
            updateObjects(task);
          }
          taskListPanel = taskListCache(context, user);

          List<String> emails = [];
          for (STask task in allTasksUser) {
            if (!emails.contains(task.sender)) {
              emails.add(task.sender);
            }
          }
          for (STask task in allTasksUser) {
            for (String email in task.assigned) {
              if (!emails.contains(email)) {
                emails.add(email);
              }
            }
          }

          Profile.getProfiles(emails: emails).then((value) {
            setState(() {
              profiles = value;
              for (STask task in allTasksUser) {
                task.senderObj = profiles.firstWhere(
                    (element) => element.email == task.sender,
                    orElse: () => Profile.getEmpty());
                task.assignedObj = profiles
                    .where((element) => task.assigned.contains(element.email))
                    .toList();
              }
            });
          });
        });
      });
    });

    // taskListPanel = taskList(context, user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        mainMenu(context, "/tasks_user"),
        taskHeader(context),
        space(height: 20),
        taskMenu(context, "taskUser"),
        contentTabSized(context, taskListPanel, user),
        footer(context)
      ]),
    ));
  }

/*-------------------------------------------------------------
                            TASKS
-------------------------------------------------------------*/
  Widget taskHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: const Text(pageTaskUserTitle, style: headerTitleText),
      ),
      SearchBar(
        controller: searchController,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onSubmitted: (value) {
          //loadTasks();
        },
        leading: const Icon(Icons.search),
      ),
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

  /*Widget taskMenu(context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          menuTab(context, "Mis tareas", "/tasks_user", {}, selected: true),
          menuTab(context, "Tareas generales", "/tasks", {}),
        ],
      ),
    );
  }*/

  /*Widget taskAddBtn(context) {
    return ElevatedButton(
      onPressed: () {
        _callEditDialog(context, null);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          customText("Añadir tarea", 14, textColor: Colors.black),
        ],
      ),
    );
  }*/

  Widget taskListCache(context, user) {
    int myTasks =
        allTasksUser.where((task) => task.assigned.contains(user.email)).length;
    int createdTasks =
        allTasksUser.where((task) => task.sender == user.email).length;
    return Column(
      children: [
        ExpansionTile(
          title: customText("Para mí ($myTasks)", 16, textColor: mainColor),
          initiallyExpanded: true,
          children: [
            Builder(
                //future: getTasksByAssigned(user.uid),
                builder: ((contextt) {
              tasksUser = allTasksUser
                  .where((task) => task.assigned.contains(user.email))
                  .toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  dataBody(context),
                ],
              );
            }))
          ],
        ),
        space(height: 20),
        ExpansionTile(
          title: customText("Creadas por mí ($createdTasks)", 16,
              textColor: mainColor),
          initiallyExpanded: true,
          children: [
            Builder(builder: ((context) {
              tasksUser = allTasksUser
                  .where((task) => task.sender == user.email)
                  .toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  dataBody(context),
                ],
              );
            }))
          ],
        )
      ],
    );
  }

  // Widget taskList(context, user) {
  //   return Column(
  //     children: [
  //       ExpansionTile(
  //         title: customText("Para mí", 16, textColor: mainColor),
  //         initiallyExpanded: true,
  //         children: [
  //           FutureBuilder(
  //               //future: getTasksByAssigned(user.uid),
  //               future: STask.getByAssigned(user.email),
  //               builder: ((context, snapshot) {
  //                 if (snapshot.hasData) {
  //                   tasksUser = snapshot.data!;
  //                   return Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     verticalDirection: VerticalDirection.down,
  //                     children: <Widget>[
  //                       dataBody(context),
  //                     ],
  //                   );
  //                 } else {
  //                   return const Center(
  //                     child: CircularProgressIndicator(),
  //                   );
  //                 }
  //               }))
  //         ],
  //       ),
  //       ExpansionTile(
  //         title: customText("Creadas por mí", 16, textColor: mainColor),
  //         children: [
  //           FutureBuilder(
  //               future: getTasksBySender(user.email),
  //               builder: ((context, snapshot) {
  //                 if (snapshot.hasData) {
  //                   tasksUser = snapshot.data!;
  //                   return Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     verticalDirection: VerticalDirection.down,
  //                     children: <Widget>[
  //                       dataBody(context),
  //                     ],
  //                   );
  //                 } else {
  //                   return const Center(
  //                     child: CircularProgressIndicator(),
  //                   );
  //                 }
  //               }))
  //         ],
  //       )
  //     ],
  //   );
  // }

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
                label: customText("Tarea", 14, bold: FontWeight.bold),
                tooltip: "Tarea",
              ),
              DataColumn(
                label: customText("Inicio", 14, bold: FontWeight.bold),
                tooltip: "Inicio",
              ),
              DataColumn(
                  label: customText("Fin", 14, bold: FontWeight.bold),
                  tooltip: "Fin"),
              DataColumn(
                  label: customText("Ejecutores", 14, bold: FontWeight.bold),
                  tooltip: "Ejecutores"),
              DataColumn(
                  label: customText("Estado", 14, bold: FontWeight.bold),
                  tooltip: "Estado"),
              const DataColumn(label: Text(""), tooltip: ""),
            ],
            rows: tasksUser.isEmpty
                ? [
                    const DataRow(cells: [
                      DataCell(Text("No hay tareas asignadas")),
                      DataCell(Text("")),
                      DataCell(Text("")),
                      DataCell(Text("")),
                      DataCell(Text("")),
                      DataCell(Text("")),
                    ])
                  ]
                : tasksUser
                    .map(
                      (task) => DataRow(cells: [
                        DataCell(Text(task.name)),
                        DataCell(
                          Text(DateFormat('yyyy-MM-dd').format(task.dealDate)),
                        ),
                        DataCell(Text(DateFormat('yyyy-MM-dd')
                            .format(task.deadLineDate))),
                        DataCell(Text(task.assigned.join(","))),
                        // DataCell(Text(task.getAssignedStr())),
                        DataCell(
                            customTextStatus(task.statusObj.name, size: 14)),
                        DataCell(Row(children: [
                          /*IconButton(
                          icon: const Icon(Icons.view_compact),
                          tooltip: 'Ver',
                          onPressed: () async {
                            Navigator.pushNamed(context, "/task_info",
                                arguments: {'task': task});
                          }),*/
                          goPageIcon(context, "Ver", Icons.view_compact,
                              TaskInfoPage(task: task)),
                          removeConfirmBtn(context, () {
                            task.delete();
                            setState(() {
                              allTasksUser.remove(task);
                              taskListPanel = taskListCache(context, user);
                            });
                          }, null),
                        ]))
                      ]),
                    )
                    .toList(),
          ),
        ));
  }

/*--------------------------------------------------------------------*/
/*                           EDIT TASK                                */
/*--------------------------------------------------------------------*/
  void callEditDialog(context, HashMap args) async {
    List<KeyValue> statusList = await getTasksStatusHash();
    List<KeyValue> contactList = await getContactsHash();
    List<KeyValue> projectList = await getProjectsHash();
    List<KeyValue> profileList = await Profile.getProfileHash();
    List<KeyValue> orgList = await getOrganizationsHash();
    final List<MultiSelectItem<KeyValue>> cList = contactList
        .map((contact) => MultiSelectItem<KeyValue>(contact, contact.value))
        .toList();
    final List<MultiSelectItem<KeyValue>> oList = orgList
        .map((org) => MultiSelectItem<KeyValue>(org, org.value))
        .toList();
    final List<MultiSelectItem<KeyValue>> pList = profileList
        .map((prof) => MultiSelectItem<KeyValue>(prof, prof.value))
        .toList();
    taskEditDialog(context, statusList, projectList, pList, cList, oList);
  }

  void saveTask(List args) async {
    STask task = args[0];
    task.save();
    if (mounted) {
      setState(() {
        allTasksUser.add(task);
        taskListPanel = taskListCache(context, user);
      });
    }

    Navigator.pop(context);
  }

  Future<void> taskEditDialog(
      context, statusList, projectList, profileList, contactList, orgList) {
    STask task = STask("");
    var user = FirebaseAuth.instance.currentUser!;
    task.sender = user.email!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Nueva tarea'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return taskForm(task, projectList, statusList, profileList,
                contactList, orgList, setState);
          }),
          actions: <Widget>[
            dialogsBtns(context, saveTask, task),
          ],
        );
      },
    );
  }

  /*void _callEditDialog(context, task) async {
    _taskEditDialog(context, task);
  }

  void _saveTask(
    context,
    name,
  ) async {
    STask task = STask(name);
    task.save();

    Navigator.pushNamed(context, "/task_info", arguments: {'task': task});
  }

  Future<void> _taskEditDialog(context, task) {
    TextEditingController nameController = TextEditingController(text: "");

    if (task != null) {
      nameController = TextEditingController(text: task.name);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact edit'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Nombre:", 16, textColor: Colors.blue),
                customTextField(nameController, "Nombre", size: 700),
              ])
            ]),
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveTask(context, nameController.text);
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

  Future<void> _removeTaskDialog(context, _task) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Borrar tarea'),
          content: const SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Borrar'),
              onPressed: () async {
                _task.delete();
                loadTasks();
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
