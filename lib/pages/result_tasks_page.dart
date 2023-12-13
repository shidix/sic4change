import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
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
    final Result? _result;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _result = args["result"];
    } else {
      _result = null;
    }

    if (_result == null) return const Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        taskPath(context, _result),
        taskHeader(context, _result),
        //marcoMenu(context, _result, "marco"),
        Expanded(
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
                )))
      ]),
    );
  }

/*-------------------------------------------------------------
                            ACTIVITY
-------------------------------------------------------------*/
  Widget taskPath(context, _result) {
    return FutureBuilder(
        future: getProjectByResultTask(_result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final _path = snapshot.data!;
            return pathHeader(context, _path);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget taskHeader(context, _result) {
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
            addBtn(context, _result),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget addBtn(context, _result) {
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
  }

  void _saveTask(context, _task, _name, _result) async {
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
    if (_task != null) _task = ResultTask(_result);
    _task.name = _name;
    _task.save();
    loadTasks(_result.uuid);
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
        future: getResultTasksByResult(_result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            result_task_list = snapshot.data!;
            if (result_task_list.length > 0) {
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
                                ResultTask _task = result_task_list[index];
                                return Container(
                                  height: 80,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xffdfdfdf))),
                                  ),
                                  child: taskRow(context, _task, _result),
                                );
                              })))
                ],
              );
            } else
              return const Text("");
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
              style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
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
            _removeTaskDialog(context, _task, _result);
          }),
    ]);
  }

  Future<void> _removeTaskDialog(context, _task, _result) async {
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
                _task.delete();
                loadTasks(_result.uuid);
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
