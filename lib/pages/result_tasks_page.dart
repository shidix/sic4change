// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const PAGE_TASKS_TITLE = "Tareas";
List result_task_list = [];

class ResultTasksPage extends StatefulWidget {
  const ResultTasksPage({super.key});

  @override
  State<ResultTasksPage> createState() => _ResultTasksPageState();
}

class _ResultTasksPageState extends State<ResultTasksPage> {
  void loadTasks(value) async {
    await getResultTasksByResult(value).then((val) {
      result_task_list = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Result? result;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      result = args["result"];
    } else {
      result = null;
    }

    if (result == null) return const Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        taskPath(context, result),
        taskHeader(context, result),
        //marcoMenu(context, _result, "marco"),
        contentTab(context, taskList, result),

        /*Expanded(
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xffdfdfdf),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: taskList(context, _result),
                )))*/
      ]),
    );
  }

/*-------------------------------------------------------------
                            ACTIVITY
-------------------------------------------------------------*/
  Widget taskPath(context, result) {
    return FutureBuilder(
        future: getProjectByResultTask(result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final path = snapshot.data!;
            return pathHeader(context, path);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget taskHeader(context, result) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        /*Container(
          padding: EdgeInsets.only(left: 40),
          child: Text(_result.name, style: TextStyle(fontSize: 20)),
        ),
        space(height: 10),*/
        Container(
          padding: const EdgeInsets.only(left: 40),
          child: const Row(children: [
            Text(PAGE_TASKS_TITLE, style: headerTitleText),
          ]),
        ),
      ]),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //addBtn(context, _result),
            addBtn(context, _editTaskDialog, {"task": null, "result": result}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  /*Widget addBtn(context, _result) {
    return FilledButton(
      onPressed: () {
        _editTaskDialog(context, null, _result);
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
  }*/

  void _saveTask(context, task, name, result) async {
    /*if (_task != null) {
      await updateResultTask(_task.id, _task.uuid, _name, _result.uuid)
          .then((value) async {
        loadTasks(_result.uuid);
      });
    } else {
      await addResultTask(_name, _result.uuid).then((value) async {
        loadTasks(_result.uuid);
      });
    }*/
    if (task != null) task = ResultTask(result);
    task.name = name;
    task.save();
    loadTasks(result.uuid);
    Navigator.of(context).pop();
  }

  Future<void> _editTaskDialog(context, HashMap args) {
    Result result = args["result"];
    TextEditingController nameController = TextEditingController(text: "");

    if (args["_task"] != null) {
      nameController = TextEditingController(text: args["_task"].name);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Task edit'),
          content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                customText("Nombre:", 16, textColor: Colors.blue),
                customTextField(nameController, "Nombre..."),
              ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveTask(context, args["_task"], nameController.text, result);
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

  Widget taskList(context, result) {
    return FutureBuilder(
        future: getResultTasksByResult(result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            result_task_list = snapshot.data!;
            if (result_task_list.isNotEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: result_task_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                ResultTask task = result_task_list[index];
                                return Container(
                                  height: 80,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xffdfdfdf))),
                                  ),
                                  child: taskRow(context, task, result),
                                );
                              })))
                ],
              );
            } else {
              return const Text("");
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget taskRow(context, task, result) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customText('${task.name}', 16),
            taskRowOptions(context, task, result),
          ],
        ),
      ],
    );
  }

  Widget taskRowOptions(context, task, result) {
    return Row(children: [
      editBtn(context, _editTaskDialog, {"task": task, "result": result}),
      /*IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () async {
            _editTaskDialog(context, _task, _result);
          }),*/
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Remove',
          onPressed: () {
            _removeTaskDialog(context, task, result);
          }),
    ]);
  }

  Future<void> _removeTaskDialog(context, task, result) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Remove Task'),
          content: const SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                task.delete();
                loadTasks(result.uuid);
                Navigator.of(context).pop();
                /*await deleteResultTask(id).then((value) {
                  loadTasks(_result.uuid);
                  Navigator.of(context).pop();
                });*/
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
