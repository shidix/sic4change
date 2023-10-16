import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/firebase_service.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/project_header_widget.dart';

const PAGE_TASKS_TITLE = "Tareas";
List task_list = [];

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  void loadTasks(value) async {
    await getTasksByResult(value).then((val) {
      task_list = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Result? _result;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _result = args["result"];
    } else {
      _result = null;
    }

    if (_result == null) return Page404();

    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        taskProjectHeader(context, _result),
        taskHeader(context, _result),
        //goalMenu(context, _goal),
        Expanded(
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: taskList(context, _result),
                )))
      ]),
    );
  }

  Widget taskProjectHeader(context, _result) {
    return FutureBuilder(
        future: getProjectByTask(_result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final _project = snapshot.data!;
            if (_project != null)
              return projectHeader(context, _project);
            else
              return Text("Project not found!");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

/*-------------------------------------------------------------
                            ACTIVITY
-------------------------------------------------------------*/
  Widget taskHeader(context, _result) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.only(left: 40),
          child: Text(_result.name, style: TextStyle(fontSize: 20)),
        ),
        space(height: 10),
        Container(
          padding: EdgeInsets.only(left: 40),
          child: Row(children: [
            Icon(Icons.chevron_right_rounded),
            Text("Tareas",
                style: TextStyle(fontSize: 20, color: Colors.blueGrey))
          ]),
        ),
      ]),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            taskAddBtn(context, _result),
            customRowPopBtn(context, "Volver", Icons.arrow_back)
          ],
        ),
      ),
    ]);
  }

  Widget taskAddBtn(context, _result) {
    return ElevatedButton(
      onPressed: () {
        _editTaskDialog(context, null, _result);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          Text(
            "Add task",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _saveTask(context, _task, _name, _result) async {
    if (_task != null) {
      await updateTask(_task.id, _task.uuid, _name, _result.uuid)
          .then((value) async {
        loadTasks(_result.uuid);
      });
    } else {
      await addTask(_name, _result.uuid).then((value) async {
        loadTasks(_result.uuid);
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _editTaskDialog(context, _task, _result) {
    TextEditingController nameController = TextEditingController(text: "");

    if (_task != null) {
      nameController = TextEditingController(text: _task.name);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Task edit'),
          content: SingleChildScrollView(
              child: Column(children: [
            customTextField(nameController, "Enter name"),
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveTask(context, _task, nameController.text, _result);
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

  Widget taskList(context, _result) {
    return FutureBuilder(
        future: getTasksByResult(_result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            task_list = snapshot.data!;
            if (task_list.length > 0) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(15),
                          child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: task_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                Task _task = task_list[index];
                                return Container(
                                  height: 80,
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  child: taskRow(context, _task, _result),
                                );
                              })))
                ],
              );
            } else
              return Text("");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget taskRow(context, _task, _result) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_task.name}',
              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
            taskRowOptions(context, _task, _result),
          ],
        ),
      ],
    );
  }

  Widget taskRowOptions(context, _task, _result) {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () async {
            _editTaskDialog(context, _task, _result);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Remove',
          onPressed: () {
            _removeTaskDialog(context, _task.id, _result);
          }),
    ]);
  }

  Future<void> _removeTaskDialog(context, id, _result) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Remove Task'),
          content: SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                await deleteTask(id).then((value) {
                  loadTasks(_result.uuid);
                  Navigator.of(context).pop();
                });
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
