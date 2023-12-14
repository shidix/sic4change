import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/holiday_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/models_workday.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
// import 'package:sic4change/pages/contacts_page.dart';
//import 'package:sic4change/custom_widgets/custom_appbar.dart';

class HomePage extends StatefulWidget {
  final int HOLIDAY_DAYS = 30;
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //bool _main = false;
  User user = FirebaseAuth.instance.currentUser!;
  List<STask>? mytasks = [];
  Contact? contact;
  HolidayRequest? currentHoliday;
  List<HolidayRequest>? myHolidays = [];
  int holidayDays = 0;

  Workday? currentWorkday;
  Widget workdayButton = Container();
  List<Workday>? myWorkdays = [];

  List<SProject>? myProjects = [];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadMyTasks() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
      // STask.getByAssigned(value.uuid).then((value) {
      //   mytasks = value;
      //   setState(() {});
      // });
    });
  }

  Future<void> loadMyHolidays() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
      HolidayRequest.byUser(value.uuid).then((value) {
        myHolidays = value;
        holidayDays = widget.HOLIDAY_DAYS;
        for (HolidayRequest holiday in myHolidays!) {
          holidayDays -=
              getWorkingDaysBetween(holiday.startDate, holiday.endDate);
        }
        setState(() {});
      });
    });
  }

  Future<void> loadMyProjects() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
      contact!.getProjects().then((value) {
        myProjects = value;
        setState(() {});
      });
    });
  }

  Future<void> loadMyWorkdays() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
      Workday.byUser(value.email).then((value) {
        myWorkdays = value;
        setState(() {});
      });
    });
  }

  Future loadMyData() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
    });
    await contact!.getProjects().then((value) {
      myProjects = value;
    });
    // await STask.getByAssigned(contact!.uuid).then((value) {
    //   mytasks = value;
    // });
    await HolidayRequest.byUser(user.email!).then((value) {
      myHolidays = value;
      holidayDays = widget.HOLIDAY_DAYS;
      for (HolidayRequest holiday in myHolidays!) {
        holidayDays -=
            getWorkingDaysBetween(holiday.startDate, holiday.endDate);
      }
    });
    await Workday.byUser(user.email!).then((value) {
      myWorkdays = value;
    });

    await Workday.currentByUser(user.email!).then((value) {
      currentWorkday = value;
    });

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadMyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          mainMenu(context, user, "/home"),
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

/////////// WORKTIME ///////////

  void workdayAction(context) {
    _workdayAction(context);
  }

  void _workdayAction(context) async {
    await Workday.currentByUser(contact!.email).then((value) {
      currentWorkday = value;
      if (currentWorkday!.open) {
        currentWorkday!.endDate = DateTime.now();
        currentWorkday!.open = false;
        currentWorkday!.save();
      } else {
        currentWorkday = Workday.getEmpty();
        currentWorkday!.userId = contact!.email;
        currentWorkday!.open = true;
        currentWorkday!.save();
      }
    });
    loadMyWorkdays();
  }

  Widget workTimePanel(BuildContext context) {
    workdayButton = actionButton(context, "(Re)Iniciar jornada", workdayAction,
        Icons.play_circle_outline_sharp, context,
        iconColor: successColor);
    if (currentWorkday?.open == true) {
      workdayButton = actionButton(context, "Finalizar jornada", workdayAction,
          Icons.stop_circle_outlined, context,
          iconColor: dangerColor);
    }
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
                                            style: cardHeaderText,
                                          )),
                                      Text(dateToES(DateTime.now()),
                                          style: subTitleText),
                                    ]))),
                        Expanded(
                          flex: 3,
                          child: workdayButton,
                        )
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
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Entrada",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Salida",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Horas",
                                style: subTitleText,
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
    // List myItems = worktimeItems();

    Widget result = Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        height: 150,
        color: Colors.white,
        child: contact != null
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: myWorkdays!.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  Workday item = myWorkdays!.elementAt(index);
                  return ListTile(
                      subtitle: Column(children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    // dateToES(
                                    //     myWorkdays!.elementAt(index).startDate),
                                    DateFormat('dd-MM-yyyy').format(
                                        myWorkdays!.elementAt(index).startDate),
                                    style:
                                        (item.open) ? successText : normalText,
                                  )),
                            )),
                        Expanded(
                          flex: 1,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                DateFormat('HH:mm').format(
                                    myWorkdays!.elementAt(index).startDate),
                                style: (item.open) ? successText : normalText,
                                textAlign: TextAlign.center,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                DateFormat('HH:mm').format(
                                    myWorkdays!.elementAt(index).endDate),
                                style: (item.open) ? successText : normalText,
                                textAlign: TextAlign.center,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                (((myWorkdays!
                                            .elementAt(index)
                                            .endDate
                                            .difference(myWorkdays!
                                                .elementAt(index)
                                                .startDate)
                                            .inMinutes) /
                                        60))
                                    .toStringAsFixed(2),
                                style: (item.open) ? successText : normalText,
                                textAlign: TextAlign.center,
                              )),
                        ),
                      ],
                    )
                  ]));
                })
            : Center(
                child: CircularProgressIndicator(),
              ));

    return result;
  }

/////////// HOLIDAYS ///////////
  void addHolidayRequestDialog(context) {
    _addHolidayRequestDialog(context).then((value) {
      currentHoliday = null;
      HolidayRequest.byUser(user.email!).then((value) {
        myHolidays = value;
        holidayDays = 30;
        for (HolidayRequest holiday in myHolidays!) {
          holidayDays -=
              getWorkingDaysBetween(holiday.startDate, holiday.endDate);
        }
        setState(() {
          myHolidays = value;
        });
      });
    });
  }

  Future<void> _addHolidayRequestDialog(context) {
    if (currentHoliday == null) {
      currentHoliday = HolidayRequest.getEmpty();
      currentHoliday!.userId = user.email!;
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context2) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Solicitud de vacaciones'),
          content: HolidayRequestForm(
            key: null,
            currentRequest: currentHoliday,
            user: user,
          ),
        );
      },
    );
  }

  Widget holidayRows(BuildContext context) {
    return Container(
        height: 150,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        color: Colors.white,
        child: contact != null
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: myHolidays!.length,
                itemBuilder: (BuildContext context, int index) {
                  HolidayRequest holiday = myHolidays!.elementAt(index);
                  return ListTile(
                      subtitle: Column(children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        holiday.catetory,
                                        style: normalText,
                                      )),
                                )),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(holiday.startDate),
                                    style: normalText,
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(holiday.endDate),
                                    style: normalText,
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    getWorkingDaysBetween(
                                            holiday.startDate, holiday.endDate)
                                        .toString(),
                                    style: normalText,
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Card(
                                      color: warningColor,
                                      child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            holiday.status,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          )))),
                            ),
                          ],
                        )
                      ]),
                      onTap: () {
                        currentHoliday = holiday;
                        addHolidayRequestDialog(context);
                      });
                })
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  Widget holidayPanel(BuildContext context) {
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
                    offset: const Offset(0, 3),
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
                                            "Solicitud de vacaciones",
                                            style: cardHeaderText,
                                          )),
                                      Row(
                                        children: [
                                          const Text("Me quedan ",
                                              style: subTitleText),
                                          Text(holidayDays.toString(),
                                              style: mainText),
                                          const Text(" días libres",
                                              style: subTitleText),
                                        ],
                                      )
                                    ]))),
                        Expanded(
                            flex: 3,
                            child: actionButton(
                                context,
                                "Solicitar días",
                                addHolidayRequestDialog,
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
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Desde",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Hasta",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Días",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Estado",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                holidayRows(context),
              ],
            )));
  }

/////////// TASKS ///////////
  Widget taskRows(BuildContext context) {
    return Container(
        height: 150,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        color: Colors.white,
        child: contact != null
            ? ListView.builder(
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
                                DateFormat('yyyy-MM-dd')
                                    .format(task.deadLineDate),
                                style: normalText,
                                textAlign: TextAlign.center,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(task.deadLineDate),
                                style: normalText,
                                textAlign: TextAlign.center,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: statusCard(task.statusObj.getName()),
                        ),
                      ],
                    )
                  ]));
                })
            : Center(
                child: CircularProgressIndicator(),
              ));
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
                                            style: cardHeaderText,
                                          )),
                                      Text(dateToES(DateTime.now()),
                                          style: subTitleText),
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
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Inicio",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Fin",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Status",
                                style: subTitleText,
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

/////////// NOTIFICATIONS ///////////
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
                                            style: cardHeaderText,
                                          )),
                                      Row(
                                        children: [
                                          Text("Tienes ", style: subTitleText),
                                          Text("3", style: dangerText),
                                          Text(" notificaciones sin leer",
                                              style: subTitleText),
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
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Desde",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Hasta",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Días Totales",
                                style: subTitleText,
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
                                        DateFormat('dd-MM-yyyy').format(
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
                                        DateFormat('dd-MM-yyyy').format(
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

/////////// PROJECTS ///////////
  Widget projectsPanel(BuildContext context) {
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
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Mis proyectos",
                                            style: cardHeaderText,
                                          )),
                                      Row(
                                        children: [
                                          const Text(
                                              "Actualmente participan en ",
                                              style: subTitleText),
                                          Text(myProjects!.length.toString(),
                                              style: warningText),
                                          const Text(" proyectos",
                                              style: subTitleText),
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
                              flex: 4,
                              child: Text(
                                "Projecto",
                                style: subTitleText,
                                textAlign: TextAlign.left,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Fecha de Inicio",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Fecha de Fin",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Estado",
                                style: subTitleText,
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
                    child: contact != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: myProjects!.length,
                            itemBuilder: (BuildContext context, int index) {
                              SProject project = myProjects!.elementAt(index);
                              return ListTile(
                                  subtitle: Column(children: [
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: Column(children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: Text(
                                                  project.name,
                                                  style: normalText,
                                                )),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: Text(
                                                  project.description,
                                                  style: smallText,
                                                )),
                                          )
                                        ])),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            // DateFormat('dd-MM-yyyy').format((project.getDates() as ProjectDates).start),
                                            project.datesObj.start,
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
                                            project.datesObj.end,
                                            style: normalText,
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: statusCard(project.getStatus()),
                                    ),
                                  ],
                                ),
                                Divider()
                              ]));
                            })
                        : Center(
                            child: CircularProgressIndicator(),
                          )),
              ],
            )));
  }
}
