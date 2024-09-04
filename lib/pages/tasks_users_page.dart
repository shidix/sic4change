import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/task_form.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/tasks_menu_widget.dart';

const pageUsersTaskTitle = "Carga de tareas por usuario";
List users = [];
Map<String, dynamic> occupation = {};
bool usersLoading = false;
Widget? _mainMenu;
var user;

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

    await Profile.getProfiles().then((value) async {
      users = value;
      for (Profile p in users) {
        //print("Usuario: ${p.name}");
        occupation[p.email] = await STask.getOccupation(p.email);
      }
      setState(() {
        usersLoading = false;
      });
    });
    //setState(() {});
  }

  @override
  void initState() {
    loadUsers();
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
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

  Widget cellValue(us, row) {
    try {
      return SizedBox.expand(
          child: Container(
              margin: const EdgeInsets.all(3),
              color: occupation[us.email][row]['color'],
              child: Align(
                alignment: Alignment.center,
                child: customText("${occupation[us.email][row]['text']} %", 14),
              )));
    } catch (e) {
      print(e);
    }
    return SizedBox.expand(
        child: Container(
            margin: const EdgeInsets.all(3),
            color: Colors.grey,
            child: Align(
              alignment: Alignment.center,
              child: customText("--- %", 14),
            )));
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
                    DataCell(customText(us.name, 14)),
                    DataCell(cellValue(us, "today")),
                    DataCell(cellValue(us, "tomorrow")),
                    DataCell(cellValue(us, "week")),
                    DataCell(cellValue(us, "month")),
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
    List<KeyValue> programmeList = await getProgrammesHash();
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
    taskEditDialog(
        context, statusList, projectList, programmeList, pList, cList, oList);
  }

  void saveTask(List args) async {
    STask task = args[0];
    task.save();

    Navigator.pop(context);
  }

  Future<void> taskEditDialog(context, statusList, projectList, programmeList,
      profileList, contactList, orgList) {
    STask task = STask("");
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

  void removeTaskDialog(context, args) {
    customRemoveDialog(context, args["task"], loadUsers);
  }
}
