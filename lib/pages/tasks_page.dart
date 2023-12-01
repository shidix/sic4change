import 'package:flutter/material.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/task_widgets.dart';

const pageTaskTitle = "Tareas";
List tasks = [];

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  var searchController = TextEditingController();

  void loadTasks() async {
    await getTasks().then((val) {
      tasks = val;
    });
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
      body: Column(children: [
        mainMenu(context),
        taskHeader(context),
        space(height: 20),
        taskMenu(context),
        //contactsHeader(context),
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
                  child: taskList(context),
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
        child: customText(pageTaskTitle, 20),
      ),
      SearchBar(
        controller: searchController,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onSubmitted: (value) {
          loadTasks();
        },
        leading: const Icon(Icons.search),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            taskAddBtn(context),
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
          menuTab(context, "Mis tareas", "/tasks_user", {}),
          menuTab(context, "Tareas generales", "/tasks", {}, selected: true),
        ],
      ),
    );
  }

  Widget taskAddBtn(context) {
    return FilledButton(
      onPressed: () {
        _callEditDialog(context, null);
      },
      style: FilledButton.styleFrom(
        side: const BorderSide(width: 0, color: Color(0xffffffff)),
        backgroundColor: const Color(0xffffffff),
      ),
      child: const Column(
        children: [
          Icon(Icons.add, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Añadir",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget taskList(context) {
    return FutureBuilder(
        future: getTasks(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(5),
                  child: dataBody(context),
                ))
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
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
                  label: customText("Tarea", 16, textColor: titleColor),
                  tooltip: "Tarea"),
              DataColumn(
                label: customText("Acuerdo", 16, textColor: titleColor),
                tooltip: "Acuerdo",
              ),
              DataColumn(
                  label: customText("Deadline", 16, textColor: titleColor),
                  tooltip: "Deadline"),
              DataColumn(
                  label:
                      customText("Nuevo deadline", 16, textColor: titleColor),
                  tooltip: "Nuevo deadline"),
              DataColumn(
                  label: customText("Devolución", 16, textColor: titleColor),
                  tooltip: "Devolución"),
              DataColumn(
                  label: customText("Responsables", 16, textColor: titleColor),
                  tooltip: "Responsables"),
              DataColumn(
                  label: customText("Estado", 16, textColor: titleColor),
                  tooltip: "Estado"),
              DataColumn(
                  label: customText("Acciones", 16, textColor: titleColor),
                  tooltip: "Acciones"),
            ],
            rows: tasks
                .map(
                  (task) => DataRow(cells: [
                    DataCell(Text(task.name)),
                    DataCell(
                      Text(task.deal_date),
                    ),
                    DataCell(Text(task.deadline_date)),
                    DataCell(Text(task.new_deadline_date)),
                    DataCell(Text(task.senderObj.name)),
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
                            _removeTaskDialog(context, task);
                          }),
                    ]))
                  ]),
                )
                .toList(),
          ),
        ));
  }

  void _callEditDialog(context, task) async {
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
  }
}
