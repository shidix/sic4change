import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const taskStatusTitle = "Estados de tareas";
List taskStatus = [];
bool loadingStatus = false;
Widget? _mainMenu;

class TaskStatusPage extends StatefulWidget {
  const TaskStatusPage({super.key});

  @override
  State<TaskStatusPage> createState() => _TaskStatusPageState();
}

class _TaskStatusPageState extends State<TaskStatusPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingStatus = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingStatus = false;
    });
  }

  void loadTaskStatus() async {
    setLoading();
    await TasksStatus.getTasksStatus().then((val) {
      taskStatus = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadTaskStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        taskStatusHeader(context),
        loadingStatus
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : taskStatusList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            TASK STATUS
-------------------------------------------------------------*/
  Widget taskStatusHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("ESTADOS DE TAREAS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editTaskStatusDialog, {'status': TasksStatus("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveTaskStatus(List args) async {
    TasksStatus status = args[0];
    status.save();
    loadTaskStatus();

    Navigator.pop(context);
  }

  Future<void> editTaskStatusDialog(context, Map<String, dynamic> args) {
    TasksStatus status = args["status"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Estados de tareas"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: status.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => status.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveTaskStatus, status),
          ],
        );
      },
    );
  }

  Widget taskStatusList(context) {
    return Container(
      decoration: tableDecoration,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          sortColumnIndex: 0,
          showCheckboxColumn: false,
          headingRowColor:
              MaterialStateColor.resolveWith((states) => headerListBgColor),
          headingRowHeight: 40,
          columns: [
            DataColumn(
              label: customText("Nombre", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(label: Container()),
          ],
          rows: taskStatus
              .map(
                (status) => DataRow(cells: [
                  DataCell(Text(status.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editTaskStatusDialog, {"status": status}),
                    removeBtn(
                        context, removeTaskStatusDialog, {"status": status})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeTaskStatusDialog(context, args) {
    customRemoveDialog(context, args["status"], loadTaskStatus, null);
  }
}
