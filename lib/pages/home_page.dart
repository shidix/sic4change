import 'dart:math';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
// import 'package:sic4change/pages/contacts_page.dart';
//import 'package:sic4change/custom_widgets/custom_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //bool _main = false;
  User user = FirebaseAuth.instance.currentUser!;
  List<STask>? mytasks = [];
  Contact? contact;
  Future<void> loadMyTasks() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
      STask.getByAssigned(value.uuid).then((value) {
        mytasks = value;
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadMyTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          mainMenu(context, user),
          Container(
            height: 10,
          ),
          // topButtons(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: workTimePanel(context)),
              Expanded(flex: 1, child: holidayPanel(context)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: tasksPanel(context)),
              Expanded(flex: 1, child: notifyPanel(context)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: projectsPanel(context)),
            ],
          )
        ],
      ),
    ));
  }

  Widget topButtons(BuildContext context) {
    List<Widget> buttons = [
      actionButton(context, "Imprimir", printSummary, Icons.print, context),
      space(width: 10),
      backButton(context),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  void printSummary(context) {
    setState(() {});

    print("printSummary");
  }

  List worktimeItems() {
    List items = [];
    int maxItems = Random().nextInt(10);
    for (int i = 0; i < maxItems; i++) {
      // TimeOfDay start = TimeOfDay(hour: Random().nextInt(3)+7, minute: Random().nextInt(60));
      DateTime start = DateTime.now().subtract(Duration(
          days: i,
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond));
      start = start.add(Duration(
          hours: Random().nextInt(3) + 7, minutes: Random().nextInt(60)));
      items.add([
        start,
        start.add(Duration(
            hours: 6 + Random().nextInt(3), minutes: Random().nextInt(60))),
      ]);
    }
    return items;
  }

  Widget workTimePanel(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Card(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child: Icon(Icons.access_time,
                                    color: Colors.black),
                              )),
                            )),
                        Expanded(
                            flex: 4,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Registro de jornada",
                                            style: cardHeaderTextStyle,
                                          )),
                                      Text(dateToES(DateTime.now()),
                                          style: subTitle),
                                    ]))),
                        Expanded(
                            flex: 3,
                            child: actionButton(
                                context,
                                "Empezar jornada",
                                printSummary,
                                Icons.play_circle_outline_sharp,
                                context)),
                      ],
                    )),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    color: Colors.white,
                    child: const ListTile(
                      title: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Fecha",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Entrada",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Salida",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Horas",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                worktimeRows(context),
              ],
            )));
  }

  Widget worktimeRows(context) {
    List myItems = worktimeItems();
    Widget result = Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        height: 150,
        color: Colors.white,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: myItems.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  subtitle: Column(children: [
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                dateToES(myItems.elementAt(index).elementAt(0)),
                                style: normalText,
                              )),
                        )),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            DateFormat('HH:mm')
                                .format(myItems.elementAt(index).elementAt(0)),
                            style: normalText,
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            DateFormat('HH:mm')
                                .format(myItems.elementAt(index).elementAt(1)),
                            style: normalText,
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            (((myItems
                                        .elementAt(index)
                                        .elementAt(1)
                                        .difference(myItems
                                            .elementAt(index)
                                            .elementAt(0))
                                        .inMinutes) /
                                    60) as double)
                                .toStringAsFixed(2),
                            style: normalText,
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ],
                )
              ]));
            }));
    return result;
  }

  List holidayItems() {
    List categories = ['Vacaciones', 'Enfermedad', 'Asuntos propios'];
    List items = [];
    int maxItems = Random().nextInt(10);
    for (int i = 0; i < maxItems; i++) {
      categories.elementAt(Random().nextInt(categories.length));
      DateTime start =
          DateTime(DateTime.now().subtract(const Duration(days: 90)).year, 1, 1)
              .add(Duration(days: Random().nextInt(300)));
      items.add([start, start.add(Duration(days: Random().nextInt(15)))]);
    }
    items.sort((a, b) => a.elementAt(0).compareTo(b.elementAt(0)));
    return (items);
  }

  Widget holidayPanel(BuildContext context) {
    List holidayPeriods = [];
    for (int i = 0; i < 5; i++) {
      DateTime from = DateTime(DateTime.now().year, 1, 1)
          .add(Duration(days: Random().nextInt(300)));
      DateTime to = from.add(Duration(days: Random().nextInt(10)));
      holidayPeriods.add([from, to]);
    }
    holidayPeriods.sort((a, b) => a.elementAt(0).compareTo(b.elementAt(0)));
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Card(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child:
                                    Icon(Icons.beach_access, color: mainColor),
                              )),
                            )),
                        const Expanded(
                            flex: 4,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Solcitud de vacaciones",
                                            style: cardHeaderTextStyle,
                                          )),
                                      Row(
                                        children: [
                                          Text("Me quedan ", style: subTitle),
                                          Text("20", style: mainText),
                                          Text(" días libres", style: subTitle),
                                        ],
                                      )
                                    ]))),
                        Expanded(
                            flex: 3,
                            child: actionButton(
                                context,
                                "Solicitar días",
                                printSummary,
                                Icons.play_circle_outline_sharp,
                                context)),
                      ],
                    )),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    color: Colors.white,
                    child: const ListTile(
                      title: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Concepto",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Desde",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Hasta",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Días Totales",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                Container(
                    height: 150,
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 10),
                    color: Colors.white,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: Random.secure().nextInt(6),
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              subtitle: Column(children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            ([
                                              'Vacaciones',
                                              'Asuntos propios',
                                              'Enfermedad'
                                            ]).elementAt(Random().nextInt(3)),
                                            style: normalText,
                                          )),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            holidayPeriods
                                                .elementAt(index)
                                                .elementAt(0)),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            holidayPeriods
                                                .elementAt(index)
                                                .elementAt(1)),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        getWorkingDaysBetween(
                                                holidayPeriods
                                                    .elementAt(index)
                                                    .elementAt(0),
                                                holidayPeriods
                                                    .elementAt(index)
                                                    .elementAt(1))
                                            .toString(),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                              ],
                            )
                          ]));
                        })),
              ],
            )));
  }

  Widget taskRows(BuildContext context) {
    return Container(
        height: 150,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        color: Colors.white,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: mytasks!.length,
            itemBuilder: (BuildContext context, int index) {
              STask task = mytasks!.elementAt(index);
              return ListTile(
                  subtitle: Column(children: [
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                task.name,
                                style: normalText,
                              )),
                        )),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            task.deadline_date,
                            style: normalText,
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            task.deadline_date,
                            style: normalText,
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                              color: task.statusObj.getColor(),
                              child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    task.statusObj.name,
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  )))),
                    ),
                  ],
                )
              ]));
            }));
  }

  Widget tasksPanel(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Card(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child: Icon(Icons.playlist_add_check,
                                    color: Colors.cyan),
                              )),
                            )),
                        Expanded(
                            flex: 7,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Mis tareas",
                                            style: cardHeaderTextStyle,
                                          )),
                                      Text(dateToES(DateTime.now()),
                                          style: subTitle),
                                    ]))),
                      ],
                    )),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    color: Colors.white,
                    child: const ListTile(
                      title: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Tarea",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Inicio",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Fin",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Status",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                taskRows(context),
              ],
            )));
  }

  Widget notifyPanel(BuildContext context) {
    List holidayPeriods = [];
    for (int i = 0; i < 5; i++) {
      DateTime from = DateTime(DateTime.now().year, 1, 1)
          .add(Duration(days: Random().nextInt(300)));
      DateTime to = from.add(Duration(days: Random().nextInt(10)));
      holidayPeriods.add([from, to]);
    }
    holidayPeriods.sort((a, b) => a.elementAt(0).compareTo(b.elementAt(0)));
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[100],
                    child: const Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Card(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child: Icon(Icons.notifications_active,
                                    color: Colors.red),
                              )),
                            )),
                        Expanded(
                            flex: 7,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Mis notificaciones",
                                            style: cardHeaderTextStyle,
                                          )),
                                      Row(
                                        children: [
                                          Text("Tienes ", style: subTitle),
                                          Text("3", style: danger),
                                          Text(" notificaciones sin leer",
                                              style: subTitle),
                                        ],
                                      ),
                                    ]))),
                      ],
                    )),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    color: Colors.white,
                    child: const ListTile(
                      title: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Concepto",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Desde",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Hasta",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Días Totales",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                Container(
                    height: 150,
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 10),
                    color: Colors.white,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 3,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              subtitle: Column(children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            ([
                                              'Vacaciones',
                                              'Asuntos propios',
                                              'Enfermedad'
                                            ]).elementAt(Random().nextInt(3)),
                                            style: normalText,
                                          )),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            holidayPeriods
                                                .elementAt(index)
                                                .elementAt(0)),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            holidayPeriods
                                                .elementAt(index)
                                                .elementAt(1)),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        getWorkingDaysBetween(
                                                holidayPeriods
                                                    .elementAt(index)
                                                    .elementAt(0),
                                                holidayPeriods
                                                    .elementAt(index)
                                                    .elementAt(1))
                                            .toString(),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                              ],
                            )
                          ]));
                        })),
              ],
            )));
  }

  Widget projectsPanel(BuildContext context) {
    List holidayPeriods = [];
    for (int i = 0; i < 5; i++) {
      DateTime from = DateTime(DateTime.now().year, 1, 1)
          .add(Duration(days: Random().nextInt(300)));
      DateTime to = from.add(Duration(days: Random().nextInt(10)));
      holidayPeriods.add([from, to]);
    }
    holidayPeriods.sort((a, b) => a.elementAt(0).compareTo(b.elementAt(0)));
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    color: Colors.grey[100],
                    child: const Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Card(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child:
                                    Icon(Icons.list_alt, color: Colors.orange),
                              )),
                            )),
                        Expanded(
                            flex: 15,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Mis proyectos",
                                            style: cardHeaderTextStyle,
                                          )),
                                      Row(
                                        children: [
                                          Text("Actualmente participan en ",
                                              style: subTitle),
                                          Text("3", style: warningStyle),
                                          Text(" proyectos", style: subTitle),
                                        ],
                                      ),
                                    ]))),
                      ],
                    )),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    color: Colors.white,
                    child: const ListTile(
                      title: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Concepto",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Desde",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Hasta",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Días Totales",
                                style: subTitle,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 10),
                    color: Colors.white,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 3,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              subtitle: Column(children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            ([
                                              'Vacaciones',
                                              'Asuntos propios',
                                              'Enfermedad'
                                            ]).elementAt(Random().nextInt(3)),
                                            style: normalText,
                                          )),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            holidayPeriods
                                                .elementAt(index)
                                                .elementAt(0)),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        DateFormat('yyyy-MM-dd').format(
                                            holidayPeriods
                                                .elementAt(index)
                                                .elementAt(1)),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        getWorkingDaysBetween(
                                                holidayPeriods
                                                    .elementAt(index)
                                                    .elementAt(0),
                                                holidayPeriods
                                                    .elementAt(index)
                                                    .elementAt(1))
                                            .toString(),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                              ],
                            )
                          ]));
                        })),
              ],
            )));
  }
}
