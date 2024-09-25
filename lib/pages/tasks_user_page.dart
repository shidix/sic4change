import 'dart:collection';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sic4change/pages/task_info_page.dart';
import 'package:sic4change/services/log_lib.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/notifications_lib.dart';
import 'package:sic4change/services/task_form.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/task_widgets.dart';
import 'package:sic4change/widgets/tasks_menu_widget.dart';

const pageTaskUserTitle = "Tareas";
bool tasksLoading = false;
bool myTasksLoading = false;

class TasksUserPage extends StatefulWidget {
  const TasksUserPage({super.key});

  @override
  State<TasksUserPage> createState() => _TasksUserPageState();
}

class _TasksUserPageState extends State<TasksUserPage> {
  List myTasks = [];
  List myTasksSearch = [];
  List tasksUser = [];
  List tasksUserSearch = [];

  var searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  bool sortAsc = false;
  int sortColumnIndex = 0;

  void addTaskToList(task) {
    if (task.assigned.contains(user.email)) myTasks.add(task);
    if (task.sender == user.email) tasksUser.add(task);
  }

  void loadTasks() async {
    setState(() {
      tasksLoading = true;
      myTasksLoading = true;
    });
    await getTasks().then((value) {
      List<STask> tList = value as List<STask>;
      for (STask t in tList) {
        t.rel = "Cargando...";
        t.assignedStr = "Cargando...";
        t.statusObj = TasksStatus("Cargando...");
        addTaskToList(t);
      }
      setState(() {
        tasksLoading = false;
        myTasksLoading = false;
      });
    });

    for (STask t in myTasks) {
      await t.loadObjs();
    }
    for (STask t in tasksUser) {
      await t.loadObjs();
    }

    myTasksSearch = myTasks;
    tasksUserSearch = tasksUser;
    if (mounted) setState(() {});
  }

  void findTasks(value) async {
    if (value == "") {
      myTasks = myTasksSearch;
    } else {
      List aux = [];
      for (STask t in myTasksSearch) {
        if (t.name == value) aux.add(t);
      }
      myTasks = aux;
    }
    setState(() {});
  }

  void findTasksUsers(value) async {
    if (value == "") {
      tasksUser = tasksUserSearch;
    } else {
      List aux = [];
      for (STask t in tasksUserSearch) {
        if (t.name == value) aux.add(t);
      }
      tasksUser = aux;
    }
    setState(() {});
  }

  @override
  void initState() {
    loadTasks();
    super.initState();
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

  Widget taskListPanel(context, user) {
    int myTasksNum = myTasks.length;
    int createdTasks = tasksUser.length;
    return Column(
      children: [
        ExpansionTile(
          title: customText("Para mí ($myTasksNum)", 16, textColor: mainColor),
          initiallyExpanded: true,
          children: [
            Builder(builder: ((context) {
              if (myTasksLoading == false) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    dataBody(context, myTasks, 0),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
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
              if (tasksLoading == false) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    dataBody(context, tasksUser, 1),
                    //dataBodyTasksUser(context),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }))
          ],
        )
      ],
    );
  }

  void onSort(int columnIndex, bool asc) {
    if (columnIndex == 0) {
      myTasks.sort((t1, t2) => compareString(asc, t1.name, t2.name));
    } else if (columnIndex == 1) {
      myTasks.sort((t1, t2) => compareDates(asc, t1.dealDate, t2.dealDate));
    } else if (columnIndex == 2) {
      myTasks.sort(
          (t1, t2) => compareDates(asc, t1.deadLineDate, t2.dealLineDate));
    } else if (columnIndex == 3) {
      myTasks.sort((t1, t2) => compareString(
          asc, t1.assignedObj.first.name, t2.assignedObj.first.name));
    } else if (columnIndex == 4) {
      myTasks.sort(
          (t1, t2) => compareString(asc, t1.statusObj.name, t2.statusObj.name));
    } else if (columnIndex == 5) {
      myTasks.sort((t1, t2) => compareString(asc, t1.rel, t2.rel));
    }

    setState(() {
      sortColumnIndex = columnIndex;
      sortAsc = asc;
    });
  }

  void onSort2(int columnIndex, bool asc) {
    if (columnIndex == 0) {
      tasksUser.sort((t1, t2) => compareString(asc, t1.name, t2.name));
    } else if (columnIndex == 1) {
      tasksUser.sort((t1, t2) => compareDates(asc, t1.dealDate, t2.dealDate));
    } else if (columnIndex == 2) {
      tasksUser.sort(
          (t1, t2) => compareDates(asc, t1.deadLineDate, t2.dealLineDate));
    } else if (columnIndex == 3) {
      tasksUser.sort((t1, t2) => compareString(
          asc, t1.assignedObj.first.name, t2.assignedObj.first.name));
    } else if (columnIndex == 4) {
      tasksUser.sort(
          (t1, t2) => compareString(asc, t1.statusObj.name, t2.statusObj.name));
    } else if (columnIndex == 5) {
      tasksUser.sort((t1, t2) => compareString(asc, t1.rel, t2.rel));
    }

    setState(() {
      sortColumnIndex = columnIndex;
      sortAsc = asc;
    });
  }

  DataColumn customColumn(String text, int table) {
    return DataColumn(
      label: customText(text, 14, bold: FontWeight.bold),
      tooltip: text,
      onSort: (table == 0) ? onSort : onSort2,
    );
  }

  List<DataColumn> columnList(int table) {
    return [
      customColumn("Tarea", table),
      customColumn("Inicio", table),
      customColumn("Fin", table),
      customColumn("Ejecutores", table),
      customColumn("Estado", table),
      customColumn("Relacionado con", table),
      const DataColumn(label: Text(""), tooltip: ""),
    ];
  }

  DataRow emptyRow() {
    return const DataRow(cells: [
      DataCell(Text("No hay tareas asignadas")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
    ]);
  }

  Widget customSearchBar(int table) {
    return SizedBox(
        //width: 100,
        height: 40,
        child: SearchBar(
          hintStyle:
              MaterialStateProperty.all(const TextStyle(color: Colors.grey)),
          hintText: "Tarea...",
          shape: const MaterialStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder()),
          onSubmitted: (value) {
            if (table == 0) {
              findTasks(value);
            } else {
              findTasksUsers(value);
            }
          },
          //leading: const Icon(Icons.search),
        ));
  }

  //SingleChildScrollView dataBody(context, List taskList, int table) {
  Widget dataBody(context, List taskList, int table) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customSearchBar(table),
              space(height: 10),
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  sortAscending: sortAsc,
                  sortColumnIndex: sortColumnIndex,
                  showCheckboxColumn: false,
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return headerListBgColor.withOpacity(0.5);
                    }
                    return headerListBgColor;
                  }),
                  columns: columnList(table),
                  //rows: tasksUser.isEmpty
                  rows: taskList.isEmpty
                      ? [emptyRow()]
                      //: tasksUser
                      : taskList
                          .map(
                            (task) => DataRow(cells: [
                              DataCell(Text(task.name)),
                              DataCell(
                                Text(DateFormat('yyyy-MM-dd')
                                    .format(task.dealDate)),
                              ),
                              DataCell(Text(DateFormat('yyyy-MM-dd')
                                  .format(task.deadLineDate))),
                              //DataCell(Text(task.getAssignedStr())),
                              DataCell(Text(task.assignedStr)),
                              DataCell(customTextStatus(task.statusObj.name,
                                  size: 14)),
                              DataCell(customText(task.rel, 14)),
                              DataCell(Row(children: [
                                goPageIcon(context, "Ver", Icons.view_compact,
                                    TaskInfoPage(task: task)),
                                removeConfirmBtn(context, () {
                                  task.delete();
                                  sendAnalyticsEvent("Tareas",
                                      "Eliminada tarea: ${task.name}");
                                  /*createLog(task.sender,
                                      "Se ha eliminado la tarea ${task.name}");*/
                                  setState(() {
                                    myTasks.remove(task);
                                    tasksUser.remove(task);
                                  });
                                }, null),
                              ]))
                            ]),
                          )
                          .toList(),
                ),
              ),
            ]));
  }

/*--------------------------------------------------------------------*/
/*                           EDIT TASK                                */
/*--------------------------------------------------------------------*/
  void callEditDialog(context, HashMap args) async {
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
    taskEditDialog(
        context, statusList, projectList, programmeList, pList, cList, oList);
  }

  void saveTask(List args) async {
    STask task = args[0];
    task.save();
    await task.loadObjs();
    //sendAnalyticsEvent("Tareas", "Nueva tarea: ${task.name}");
    //createLog(task.sender, "Se ha creado la tarea ${task.name}");
    createNotification(
        task.sender, task.assigned, "Se le ha asignado la tarea ${task.name}");

    if (mounted) {
      setState(() {
        addTaskToList(task);
        /*allTasksUser.add(task);
        taskListPanel = taskListCache(context, user);*/
      });
    }

    Navigator.pop(context);
  }

  Future<void> taskEditDialog(context, statusList, projectList, programmeList,
      profileList, contactList, orgList) async {
    STask task = STask("");
    task.initializeProjectList(projectList);
    task.initializeProgrammeList(programmeList);

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
            dialogsBtns(context, saveTask, task),
          ],
        );
      },
    );
  }
}
