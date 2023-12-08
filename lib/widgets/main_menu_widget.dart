import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget mainMenu(context, [user, url]) {
  return Container(
    /*decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
            "https://www.freecodecamp.org/news/content/images/size/w2000/2022/09/jonatan-pie-3l3RwQdHRHg-unsplash.jpg"),
        fit: BoxFit.cover,
      ),
    ),*/
    child: Container(
      padding: const EdgeInsets.all(3),
      //margin: EdgeInsets.all(120.0),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          logo(),
          menuBtn(context, "Inicio", Icons.home, "/home",
              (url == "/home") ? Colors.white : Colors.black45),
          menuBtn(context, "Tareas", Icons.grading_sharp, "/tasks"),
          menuBtn(context, "Proyectos", Icons.list_alt, "/projects"),
          menuBtn(context, "Documentos", Icons.folder, "/documents"),
          menuBtn(context, "Contactos", Icons.handshake, "/contacts"),
          menuBtn(context, "Organigrama", Icons.group, "/orgchart",
              (url == "/orgchart") ? Colors.black : Colors.black45),
          logoutBtn(context, "Salir", Icons.arrow_back),
          if (user != null) Text(user.email!),
        ],
      ),
    ),
  );
}

Widget logo() {
  return const Image(
    image: AssetImage('assets/images/logo.jpg'),
    width: 100,
  );
}
