import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget mainMenu(context) {
  return Container(
    /*decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
            "https://www.freecodecamp.org/news/content/images/size/w2000/2022/09/jonatan-pie-3l3RwQdHRHg-unsplash.jpg"),
        fit: BoxFit.cover,
      ),
    ),*/
    child: Container(
      padding: EdgeInsets.all(3),
      //margin: EdgeInsets.all(120.0),
      color: Colors.blueGrey,
      child: Row(
        children: [
          logo(),
          menuBtn(context, "Inicio", Icons.home, "/home"),
          menuBtn(context, "Cuadro de mando", Icons.grading_sharp, "/home"),
          menuBtn(context, "Proyectos", Icons.list_alt, "/projects"),
          menuBtn(context, "Documentos", Icons.folder, "/documents"),
          menuBtn(context, "Contactos", Icons.handshake, "/contacts"),
          logoutBtn(context, "Salir", Icons.arrow_back),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    ),
  );
}

Widget logo() {
  return Image(
    image: AssetImage('assets/images/logo.jpg'),
    width: 100,
  );
}
