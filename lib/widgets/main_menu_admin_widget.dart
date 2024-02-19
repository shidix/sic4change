import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget mainMenuAdmin(context, [user, url]) {
  return Container(
    padding: const EdgeInsets.all(3),
    color: bgColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        logo(),
        menuBtn(context, "Inicio", Icons.home, "/home",
            (url == "/home") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        /*menuBtn(
            context,
            "Tareas",
            Icons.grading_sharp,
            "/tasks_user",
            (url == "/tasks_user")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),*/
        menuBtn(
            context,
            "Programas",
            Icons.list_alt,
            "/project_list",
            (url == "/project_list")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        /*menuBtn(
            context,
            "Documentos",
            Icons.folder,
            "/documents",
            (url == "/documents")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Contactos", Icons.handshake, "/contacts",
            (url == "/contacts") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        menuBtn(context, "Roles", Icons.group, "/orgchart",
            (url == "/orgchart") ? mainMenuBtnSelectedColor : mainMenuBtnColor),*/
        logoutBtn(context, "Salir", Icons.arrow_back),
        if (user != null)
          customText(user.email!, 14, textColor: Colors.white54),
      ],
    ),
  );
}

Widget logo() {
  return const Image(
    image: AssetImage('assets/images/logo.jpg'),
    width: 100,
  );
}
