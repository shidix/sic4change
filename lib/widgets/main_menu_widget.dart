import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/invoices_pages.dart';
import 'package:sic4change/pages/home_page.dart';
import 'package:sic4change/pages/rrhh_employee_page.dart';
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
Widget notificationBadge(context, user) {
  return Positioned(
    top: 10,
    right: 50,
    child: (notif > 0)
        ? notificationsBadge(context, user.email, notif.toString(), "/home")
        : Container(),
  );
}

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
        if (user != null)
          Container(
            padding: const EdgeInsets.only(top: 22),
            child: (MediaQuery.of(context).size.width > 1300)
                ? customText(user.email!, 14, textColor: Colors.white54)
                : Container(),
          )
      ],
    ),
  );
}

Widget mainMenuEmpty(context, [url]) {
  return Container(
    padding: const EdgeInsets.all(3),
    color: bgColor,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            flex: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                logo(),
                menuBtn(context, "Inicio", Icons.home, "/home",
                    color: (url == "/home")
                        ? mainMenuBtnSelectedColor
                        : mainMenuBtnColor),
              ],
            )),
        Expanded(
            flex: 2,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              (FirebaseAuth.instance.currentUser != null)
                  ? logoutBtn(context, "Salir", Icons.arrow_back)
                  : Container(),
            ]))
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
        menuBtn(context, "Inicio", Icons.home, "/home",
            color:
                (url == "/home") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
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
        menuBtn(context, "Logs", Icons.settings, "/logs",
            color:
                (url == "/Logs") ? mainMenuBtnSelectedColor : mainMenuBtnColor),
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

Widget mainMenuOperator(context, {url, User? user, key}) {
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
        menuBtnGo(
            context, "RR.HH.", const EmployeesPage(), Icons.list_alt, "/rrhh",
            currentUrl: url),
        menuBtn(context, "Programas", Icons.list_alt, "/project_list",
            color: (url == "/project_list")
                ? mainMenuBtnSelectedColor
                : mainMenuBtnColor),
        menuBtnGo(context, "Facturas", const InvoicePage(), Icons.receipt,
            "/invoices",
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
        if (user != null)
          menuBtn(context, user.email, Icons.supervised_user_circle_outlined,
              "/profile",
              color: (url == "/profile")
                  ? mainMenuBtnSelectedColor
                  : mainMenuBtnColor),
      ],
    ),
  );
}

Widget mainMenu(context, [url]) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return mainMenuEmpty(context, url);
  }

  Profile? profile =
      Provider.of<ProfileProvider>(context, listen: false).profile;

  return Builder(
    builder: (context) {
      if (profile == null) {
        return mainMenuEmpty(context, url);
      } else if (profile.mainRole == "Admin") {
        return Stack(
          children: [
            mainMenuAdmin(context, user, url),
            notificationBadge(context, user),
          ],
        );
      } else if (profile.mainRole == "Administrativo") {
        return Stack(
          children: [
            mainMenuOperator(context, url: url, user: user),
            notificationBadge(context, user),
          ],
        );
      } else {
        return Stack(
          children: [
            mainMenuUser(context, user, url),
            notificationBadge(context, user),
          ],
        );
      }
    },
  );

  // return FutureBuilder<Profile>(
  //   future: (profile != null)
  //       ? Future.value(profile)
  //       : Profile.getProfile(
  //           email), // Llama a la función que devuelve el Future
  //   builder: (context, snapshot) {
  //     if (snapshot.connectionState == ConnectionState.waiting) {
  //       // Si el Future está en estado de espera, muestra un indicador de carga
  //       return const CircularProgressIndicator();
  //     } else if (snapshot.hasError) {
  //       // Si ocurre un error al cargar el Future, muestra un mensaje de error
  //       return Text('Error: ${snapshot.error}');
  //     } else {
  //       // Si el Future se completó exitosamente, muestra los datos
  //       //return Text('Datos: ${snapshot.data}');
  //       Profile profile = snapshot.data!;
  //       if (profile.mainRole == "Admin") {
  //         //return mainMenuAdmin(context, user, url);
  //         return Stack(
  //           children: [
  //             mainMenuAdmin(context, user, url),
  //             notificationBadge(context, user),
  //           ],
  //         );
  //       } else if (profile.mainRole == "Administrativo") {
  //         //return mainMenuOperator(context, url: url, profile: profile);
  //         return Stack(
  //           children: [
  //             mainMenuOperator(context, url: url, profile: profile),
  //             notificationBadge(context, user),
  //           ],
  //         );
  //       } else {
  //         //return mainMenuUser(context, user, url);
  //         return Stack(
  //           children: [
  //             mainMenuUser(context, user, url),
  //             notificationBadge(context, user),
  //           ],
  //         );
  //       }
  //     }
  //   },
  // );
}

Widget logo({Profile? profile}) {
  if (profile != null) {
    // return Image + profile.email
    return Column(
      children: [
        const Image(
          image: AssetImage('assets/images/logo.jpg'),
          width: 100,
        ),
        space(height: 10),
        customText(profile.email, 14,
            textColor: Colors.white54, align: TextAlign.center),
      ],
    );
  }

  return const Image(
    image: AssetImage('assets/images/logo.jpg'),
    width: 100,
  );
}
