import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/task_widgets.dart';

const pageTaskUserTitle = "Tareas";
List tasksUser = [];

class TasksUserPage extends StatefulWidget {
  const TasksUserPage({super.key});

  @override
  State<TasksUserPage> createState() => _TasksUserPageState();
}

class _TasksUserPageState extends State<TasksUserPage> {
  var searchController = TextEditingController();

  /*void loadTasks() async {
    await getTasks().then((val) {
      tasksUser = val;
    });
    setState(() {});
  }

  @override
  void initState() {
    loadTasks();
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        taskHeader(context),
        space(height: 20),
        taskMenu(context),
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xffdfdfdf),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: taskList(context, user),
                ))),
      ]),
    );
  }

/*-------------------------------------------------------------
                            TASKS
-------------------------------------------------------------*/
  Widget taskHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: customText(pageTaskUserTitle, 20),
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
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //taskAddBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget taskMenu(context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          menuTab(context, "Mis tareas", "/tasks_user", {}, selected: true),
          menuTab(context, "Tareas generales", "/tasks", {}),
        ],
      ),
    );
  }

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

  Widget taskList(context, user) {
    return Column(
      children: [
        ExpansionTile(
          title: customText("Para mi", 16, textColor: titleColor),
          initiallyExpanded: true,
          children: [
            FutureBuilder(
                future: getTasksByAssigned(user.uid),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    tasksUser = snapshot.data!;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      verticalDirection: VerticalDirection.down,
                      children: <Widget>[
                        dataBody(context),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }))
          ],
        ),
        ExpansionTile(
          title: customText("Creadas por mi", 16, textColor: titleColor),
          children: [
            FutureBuilder(
                future: getTasksBySender(user.uid),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    tasksUser = snapshot.data!;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      verticalDirection: VerticalDirection.down,
                      children: <Widget>[
                        dataBody(context),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }))
          ],
        )
      ],
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
            columns: const [
              DataColumn(
                  label: Text(
                    "Tarea",
                    style: TextStyle(
                        color: Color(0xff008096), fontWeight: FontWeight.bold),
                  ),
                  tooltip: "Tarea"),
              DataColumn(
                label: Text(
                  "Inicio",
                  style: TextStyle(
                      color: Color(0xff008096), fontWeight: FontWeight.bold),
                ),
                tooltip: "Inicio",
              ),
              DataColumn(
                  label: Text(
                    "Fin",
                    style: TextStyle(
                        color: Color(0xff008096), fontWeight: FontWeight.bold),
                  ),
                  tooltip: "Fin"),
              DataColumn(
                  label: Text(
                    "Eviada a",
                    style: TextStyle(
                        color: Color(0xff008096), fontWeight: FontWeight.bold),
                  ),
                  tooltip: "Enviada a"),
              DataColumn(
                  label: Text(
                    "Estado",
                    style: TextStyle(
                        color: Color(0xff008096), fontWeight: FontWeight.bold),
                  ),
                  tooltip: "Estado"),
              DataColumn(label: Text(""), tooltip: ""),
            ],
            rows: tasksUser
                .map(
                  (task) => DataRow(cells: [
                    DataCell(Text(task.name)),
                    DataCell(
                      Text(task.deal_date),
                    ),
                    DataCell(Text(task.deadline_date)),
                    //DataCell(Text(task.assigned.join(","))),
                    DataCell(Text(task.getAssignedStr())),
                    DataCell(customTextStatus(task.statusObj.name, 14)),
                    DataCell(Row(children: [
                      IconButton(
                          icon: const Icon(Icons.view_compact),
                          tooltip: 'Ver',
                          onPressed: () async {
                            Navigator.pushNamed(context, "/task_info",
                                arguments: {'task': task});
                          }),
                      IconButton(
                          icon: const Icon(Icons.remove_circle),
                          tooltip: 'Remove',
                          onPressed: () {
                            //_removeTaskDialog(context, task);
                          }),
                    ]))
                  ]),
                )
                .toList(),
          ),
        ));
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
