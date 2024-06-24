import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget mainMenuUser(context, [user, url]) {
  return Container(
    padding: const EdgeInsets.all(3),
    color: bgColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        logo(),
        menuBtn(context, "Inicio", Icons.home, "/home",
            (url == "/home") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        menuBtn(
            context,
            "Tareas",
            Icons.grading_sharp,
            "/tasks_user",
            (url == "/tasks_user")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Programas", Icons.list_alt, "/projects",
            (url == "/projects") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        menuBtn(
            context,
            "Documentos",
            Icons.folder,
            "/documents",
            (url == "/documents")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Facturas", Icons.receipt, "/invoices",
            (url == "/invoices") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        menuBtn(context, "Contactos", Icons.handshake, "/contacts",
            (url == "/contacts") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        menuBtn(context, "Roles", Icons.group, "/orgchart",
            (url == "/orgchart") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        logoutBtn(context, "Salir", Icons.arrow_back),
        if (user != null)
          customText(user.email!, 14, textColor: Colors.white54),
      ],
    ),
  );
}

Widget mainMenuAdmin(context, [user, url]) {
  return Container(
    padding: const EdgeInsets.all(3),
    color: bgColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        logo(),
        menuBtn(
            context,
            "Inicio",
            Icons.home,
            "/home_admin",
            (url == "/home_admin")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(
            context,
            "Programas",
            Icons.list_alt,
            "/project_list",
            (url == "/project_list")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(
            context,
            "Documentos",
            Icons.folder,
            "/documents",
            (url == "/documents")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Contactos", Icons.handshake, "/contacts",
            (url == "/contacts") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        menuBtn(context, "Admin", Icons.settings, "/admin",
            (url == "/admin") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        logoutBtn(context, "Salir", Icons.arrow_back),
        if (user != null)
          menuBtn(
              context,
              user.email!,
              Icons.supervised_user_circle_outlined,
              "/profile",
              (url == "/profile")
                  ? mainMenuBtnSelectedColor
                  : mainMenuBtnColor),
      ],
    ),
  );
}

Widget mainMenu(context, [url]) {
  final user = FirebaseAuth.instance.currentUser!;
  String email = user.email!;

  return FutureBuilder<Profile>(
    future:
        Profile.getProfile(email), // Llama a la función que devuelve el Future
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Si el Future está en estado de espera, muestra un indicador de carga
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Si ocurre un error al cargar el Future, muestra un mensaje de error
        return Text('Error: ${snapshot.error}');
      } else {
        // Si el Future se completó exitosamente, muestra los datos
        //return Text('Datos: ${snapshot.data}');
        Profile profile = snapshot.data!;
        if (profile.mainRole == "Admin") {
          return mainMenuAdmin(context, user, url);
        } else {
          return mainMenuUser(context, user, url);
        }
      }
    },
  );
}

Widget logo() {
  return const Image(
    image: AssetImage('assets/images/logo.jpg'),
    width: 100,
  );
}
