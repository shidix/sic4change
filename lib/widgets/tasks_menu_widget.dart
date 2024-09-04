import 'package:flutter/material.dart';
import 'package:sic4change/pages/tasks_user_page.dart';
import 'package:sic4change/pages/tasks_users_page.dart';
//import 'package:sic4change/pages/tasks_users_page.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget taskMenu(context, tabSelected) {
  //bool taskUser = (tabSelected == "taskUser") ? true : false;
  //bool tasks = (tabSelected == "tasks") ? true : false;
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        //menuTab(context, "Mis tareas", "/tasks_user", {}, selected: taskUser),
        //menuTab(context, "Tareas generales", "/tasks", {}, selected: tasks),
        menuTab2(context, "Mis tareas", const TasksUserPage(),
            selected: (tabSelected == "taskUser")),
        /*menuTab2(context, "Tareas generales", const TasksPage(),
            selected: (tabSelected == "tasks")),*/
        menuTab2(context, "Asignación de tareas", const TasksUsersPage(),
            selected: (tabSelected == "tasksUsers")),
      ],
    ),
  );
}
