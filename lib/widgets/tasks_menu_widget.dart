import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget taskMenu(context, tabSelected) {
  bool taskUser = (tabSelected == "taskUser") ? true : false;
  bool tasks = (tabSelected == "tasks") ? true : false;
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        menuTab(context, "Mis tareas", "/tasks_user", {}, selected: taskUser),
        menuTab(context, "Tareas generales", "/tasks", {}, selected: tasks),
      ],
    ),
  );
}
