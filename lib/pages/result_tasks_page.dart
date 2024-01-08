// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const PAGE_TASKS_TITLE = "Tareas";
List result_task_list = [];

class ResultTasksPage extends StatefulWidget {
  final Result? result;
  const ResultTasksPage({super.key, this.result});

  @override
  State<ResultTasksPage> createState() => _ResultTasksPageState();
}

class _ResultTasksPageState extends State<ResultTasksPage> {
  Result? result;

  void loadTasks(value) async {
    await getResultTasksByResult(value).then((val) {
      result_task_list = val;
    });
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    result = widget.result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        taskPath(context, result),
        taskHeader(context, result),
        contentTab(context, taskList, result),
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
            addBtn(context, editTaskDialog, {"task": null, "result": result}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveResultTask(List args) async {
    ResultTask task = args[0];
    task.save();
    loadTasks(task.result);

    Navigator.pop(context);
  }

  Future<void> editTaskDialog(context, HashMap args) {
    Result result = args["result"];
    ResultTask task = ResultTask(result.uuid);

    if (args["task"] != null) {
      task = args["task"];
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar(
              (result.name != "") ? 'Editando Tarea' : 'Añadiendo Tarea'),
          content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: task.name,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => task.name = val);
                  },
                )
              ])),
          actions: <Widget>[dialogsBtns(context, saveResultTask, task)],
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
      editBtn(context, editTaskDialog, {"task": task, "result": result}),
      removeBtn(context, removeResultTaskDialog,
          {"result": result.uuid, "task": task})
    ]);
  }

  void removeResultTaskDialog(context, args) {
    customRemoveDialog(context, args["task"], loadTasks, args["result"]);
  }
}
