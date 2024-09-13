import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/invoices_pages.dart';
import 'package:sic4change/pages/home_page.dart';
import 'package:sic4change/pages/employee_page.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/notifications_lib.dart';
import 'package:sic4change/widgets/common_widgets.dart';

int notif = 0;
//Color notifColor = Colors.white54;

/*Widget userWidget(context, user, url) {
  return Column(children: [
    /*(notif > 0)
        ? notificationsBadge(context, user.email, notif.toString(), url)
        : Container(),*/
    //space(height: 5),
    customText(user.email!, 14, textColor: Colors.white54),
  ]);
}*/

Widget mainMenuUser(context, [user, url]) {
  return Container(
    padding: const EdgeInsets.all(3),
    color: bgColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        logo(),
        menuBtn(context, "Inicio", Icons.home, "/home",
            color:
                (url == "/home") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
        menuBtn(context, "Tareas", Icons.grading_sharp, "/tasks_user",
            color: (url == "/tasks_user")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Programas", Icons.list_alt, "/projects",
            color: (url == "/projects")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Documentos", Icons.folder, "/documents",
            color: (url == "/documents")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Facturas", Icons.receipt, "/invoices",
            color: (url == "/invoices")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Contactos", Icons.handshake, "/contacts",
            color: (url == "/contacts")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Roles", Icons.group, "/orgchart",
            color: (url == "/orgchart")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        logoutBtn(context, "Salir", Icons.arrow_back),
        //if (user != null) userWidget(context, user, url),

        if (user != null)
          Container(
            padding: const EdgeInsets.only(top: 22),
            child: customText(user.email!, 14, textColor: Colors.white54),
          )
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
        menuBtn(context, "Inicio", Icons.home, "/home_admin",
            color: (url == "/home_admin")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Programas", Icons.list_alt, "/project_list",
            color: (url == "/project_list")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Documentos", Icons.folder, "/documents",
            color: (url == "/documents")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Contactos", Icons.handshake, "/contacts",
            color: (url == "/contacts")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Admin", Icons.settings, "/admin",
            color: (url == "/admin")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        logoutBtn(context, "Salir", Icons.arrow_back),
        if (user != null)
          menuBtn(context, user.email!, Icons.supervised_user_circle_outlined,
              "/profile",
              color: (url == "/profile")
                  ? mainMenuBtnSelectedColor
                  : mainMenuBtnColor),
      ],
    ),
  );
}

Widget mainMenuOperator(context, {url, profile, key}) {
  key ??= const Key('mainMenuOperator');
  return Container(
    key: key,
    padding: const EdgeInsets.all(3),
    color: bgColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        logo(),
        (url == "/home")
            ? menuBtnSelected(
                context,
                'Inicio',
                Icons.home,
              )
            : menuBtnGo(
                context, 'Inicio', const HomePage(), Icons.home, "/home",
                currentUrl: url),
        menuBtnGo(context, "RR.HH.", EmployeesPage(profile: profile),
            Icons.list_alt, "/rrhh",
            currentUrl: url),
        menuBtnGo(
            context, "Facturas", InvoicePage(), Icons.receipt, "/invoices",
            currentUrl: url),
        menuBtn(context, "Documentos", Icons.folder, "/documents",
            color: (url == "/documents")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtn(context, "Contactos", Icons.handshake, "/contacts",
            color: (url == "/contacts")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        logoutBtn(context, "Salir", Icons.arrow_back),
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
        } else if (profile.mainRole == "Administrativo") {
          return mainMenuOperator(context, url: url, profile: profile);
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
