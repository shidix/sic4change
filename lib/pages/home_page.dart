// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'dart:math';
import 'dart:html' as html;
import "dart:developer" as dev;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:googleapis/batch/v1.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/holiday_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/models_workday.dart';
import 'package:sic4change/services/notifications_lib.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/services/workday_form.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
  late Map<String, TasksStatus> hashStatus;
  late Map<String, SProject> hashProjects;

  late String _currentPage;

  User user = FirebaseAuth.instance.currentUser!;
  Profile? profile;
  List<STask>? mytasks = [];
  Contact? contact;
  HolidayRequest? currentHoliday;
  List<HolidayRequest>? myHolidays = [];
  int holidayDays = 0;

  Workday? currentWorkday;
  Widget workdayButton = Container();
  List<Workday>? myWorkdays = [];
  Widget mainMenuWidget = Container();
  List<Employee> mypeople = [];
  List<HolidayRequest> myPeopleHolidays = []; 

  Widget contentWorkPanel = Container();
  Widget contentTasksPanel = Container();
  Widget contentProjectsPanel = Container();
  Widget topButtonsPanel = Container();

  List<SProject>? myProjects;

  List notificationList = [];
  //List logList = [];

  @override
  void dispose() {
    super.dispose();
  }

  Map<String, Color> holidayStatusColors = {
    "pendiente": warningColor,
    "aprobado": successColor,
    "rechazado": dangerColor,
  };

  Future<void> loadMyTasks() async {
    // await Contact.byEmail(user.email!).then((value) {
    //   contact = value;
    //   STask.getByAssigned(value.uuid).then((value) {
    //     print(value.length);
    //     // mytasks = value;
    //     setState(() {
    //       mytasks = value;
    //     });
    //   });
    // });
    STask.getByAssigned(user.email!, lazy: false).then((value) {
      mytasks = value;
      contentTasksPanel = tasksPanel();
      contentProjectsPanel = projectsPanel();
      setState(() {});
    });
  }

  Future<void> loadMyHolidays() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
      HolidayRequest.byUser(value.uuid).then((value) {
        myHolidays = value;
        holidayDays = widget.HOLIDAY_DAYS;
        for (HolidayRequest holiday in myHolidays!) {
          if (holiday.status != "Rechazado") {
          holidayDays -=
              getWorkingDaysBetween(holiday.startDate, holiday.endDate);}
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
    if ((myWorkdays == null) || (myWorkdays!.isEmpty)) {
      await Contact.byEmail(user.email!).then((value) {
        contact = value;
        Workday.byUser(value.email).then((value) {
          setState(() {
            myWorkdays = value;
            myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));
          });
        });
      });
    } else {
      setState(() {
        if (currentWorkday!.open) {
          workdayButton = actionButton(
              context, null, workdayAction, Icons.stop_circle_outlined, context,
              iconColor: dangerColor);
        } else {
          workdayButton = actionButton(context, null, workdayAction,
              Icons.play_circle_outline_sharp, context,
              iconColor: successColor);
        }
        myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));
        myWorkdays = myWorkdays;
      });
    }
  }

  Future<void> loadMyData() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
    });
    contact!.getProjects().then((value) {
      if (mounted) {
        setState(() {
          myProjects = value;
        });
      }
    });
    STask.getByAssigned(contact!.uuid).then((value) {
      if (mounted) {
        setState(() {
          mytasks = value;
        });
      }
    });
    HolidayRequest.byUser(user.email!).then((value) {
      myHolidays = value;
      holidayDays = widget.HOLIDAY_DAYS;
      for (HolidayRequest holiday in myHolidays!) {
        if (holiday.status != "Rechazado") {
        holidayDays -=
            getWorkingDaysBetween(holiday.startDate, holiday.endDate);}
      }
      if (mounted) {
        setState(() {});
      }
    });
    Workday.byUser(user.email!).then((value) {
      myWorkdays = value;
      myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));
      if ((myWorkdays!.first.open) &&
          (truncDate(myWorkdays!.first.startDate) ==
              truncDate(DateTime.now()))) {
        currentWorkday = myWorkdays!.first;
      } else {
        currentWorkday = Workday.getEmpty();
        currentWorkday!.userId = user.email!;
        currentWorkday!.open = true;
        currentWorkday!.save();
      }

      contentWorkPanel = workTimePanel();
      if (mounted) {
        setState(() {});
      }
    });

    Profile.getProfiles().then((List<Profile> value) {
      for (var element in value) {
          if (element.holidaySupervisor.contains(user.email)) {
            Employee.byEmail(element.email).then((value) {
              if (value != null) {
                mypeople.add(value);
              }
            });

              HolidayRequest.byUser(element!.email).then((value) {
                myPeopleHolidays.addAll(value);
                if (mounted) {
                  setState(() {});
                }
              });
  
          }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  void getNotifications() async {
    NotificationValues nVal = await getNotificationList(user.email);
    notificationList = nVal.nList;
    notif = nVal.unread;
    setState(() {});
  }

  /*void getLogs() async {
    SLogs.getLogs().then((val) {
      logList = val;
      setState(() {});
    });
  }*/

  @override
  void initState() {
    super.initState();
    _currentPage = "home";
    hashStatus = {};
    hashProjects = {};
    topButtonsPanel = topButtons(context);
    TasksStatus.all().then((value) {
      if (value.isNotEmpty) {
        for (var item in value) {
          hashStatus[item.id] = item;
          hashStatus[item.uuid] = item;
        }
      }
    });
    SProject.all().then((value) {
      if (value.isNotEmpty) {
        for (var item in value) {
          hashProjects[item.id] = item;
          hashProjects[item.uuid] = item;
        }
      }
    });
    if (user.email == null) {
      Navigator.of(context).pushNamed('/');
    } else {
      Profile.getProfile(user.email!).then((value) {
        profile = value;
        if ((profile != null) && (profile!.mainRole == "Administrativo")) {
          mainMenuWidget = mainMenuOperator(context,
              url: ModalRoute.of(context)!.settings.name, profile: profile);
        } else {
          mainMenuWidget = mainMenu(context, "/home");
        }

        if (mounted) {
          setState(() {});
        }
      });
      loadMyData();
      autoStartWorkday(context);
      if (mounted) {
        setState(() {});
      }

      loadMyTasks().then((value) {
        if (mounted) {
          setState(() {});
        }
      });

      notif = 0;
      getNotifications();
      //getLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = [];
    if (_currentPage == "home") {
      contents = [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: contentWorkPanel),
            Expanded(flex: 1, child: holidayPanel(context)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: contentTasksPanel),
            Expanded(flex: 1, child: notifyPanel(context)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: contentProjectsPanel),
            //Expanded(flex: 1, child: logsPanel(context)),
          ],
        ),
      ];
    } else if (_currentPage == "yourpeople") {
      contents = [        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: contentWorkPanel),
            Expanded(flex: 1, child: holidayPeoplePanel(context)),
          ],
        ),];
    }

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          mainMenuWidget,
          space(height: 10),
          topButtons(context),
          space(height: 10),
          ...contents,
          footer(context),
        ],
      ),
    ));
  }

  Widget topButtons(BuildContext context) {
    List<Widget> buttons = [
      actionButton(context, "Dashboard", () {
        setState(() {
          _currentPage = "home";
        });
      }, Icons.dashboard, null,
          bgColor:
              (_currentPage == "home") ? Colors.green.shade50 : Colors.white),
      space(width: 10),
      actionButton(context, "Personal a cargo", () {
        setState(() {
          _currentPage = "yourpeople";
        });
      }, Icons.people, null,
          bgColor: (_currentPage == "yourpeople")
              ? Colors.green.shade50
              : Colors.white),
      space(width: 10),
      // backButton(context),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  void printSummary(context) {
    setState(() {});
    dev.log("printSummary");
  }

/////////// WORKTIME ///////////

  void autoStartWorkday(context) async {
    Workday.currentByUser(user.email!).then((value) {
      currentWorkday = value;
      // if ((currentWorkday == null) || (!currentWorkday!.open)) {
      //   currentWorkday = Workday.getEmpty();
      //   currentWorkday!.userId = user.email!;
      //   currentWorkday!.open = true;
      //   currentWorkday!.save();
      // }
      if (mounted) {
        setState(() {
          currentWorkday = currentWorkday;
        });
      }
    });
  }

  void autoStopWorkday(context) async {
    Workday.currentByUser(user.email!).then((value) {
      currentWorkday = value;
      if (currentWorkday!.open) {
        currentWorkday!.endDate = DateTime.now();
        currentWorkday!.open = false;
        currentWorkday!.save();
      }
    });
  }

  void workdayAction(context) {
    _workdayAction(context);
  }

  void _workdayAction(context) async {
    if (currentWorkday!.open) {
      currentWorkday!.endDate = DateTime.now();
      currentWorkday!.open = false;
      currentWorkday!.save().then((value) {
        myWorkdays![0] = value;
        if (mounted) {
          setState(() {
            myWorkdays = myWorkdays;
            contentWorkPanel = workTimePanel();
          });
        }
      });
    } else {
      currentWorkday = Workday.getEmpty();
      currentWorkday!.userId = user.email!;
      currentWorkday!.startDate = DateTime.now();
      currentWorkday!.open = true;
      currentWorkday!.save().then((value) {
        myWorkdays!.insert(0, value);
        if (mounted) {
          setState(() {
            myWorkdays = myWorkdays;
            contentWorkPanel = workTimePanel();
          });
        }
      });
    }

    // loadMyWorkdays();
  }

  Widget workTimePanel() {
    if (myWorkdays!.isNotEmpty) {
      myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));

      currentWorkday = myWorkdays!.first;
    }

    if (currentWorkday?.open == true) {
      workdayButton = actionButton(
          context, null, workdayAction, Icons.stop_circle_outlined, context,
          iconColor: dangerColor);
    } else {
      workdayButton = actionButton(context, null, workdayAction,
          Icons.play_circle_outline_sharp, context,
          iconColor: successColor);
    }
    Widget addWorkdayButton = actionButton(context, null, () {
      _editWorkdayDialog(Workday.getEmpty(open: false, email: user.email!))
          .then((value) {
        if ((value != null) && (!myWorkdays!.contains(value))) {
          myWorkdays!.add(value);
          if (mounted) {
            setState(() {
              myWorkdays = myWorkdays;
              myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));
            });
          }
        }
      });
    }, Icons.add, null);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha:0.5),
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
                            flex: 5,
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
                            flex: 1,
                            child: Tooltip(
                                message: (currentWorkday != null)
                                    ? (currentWorkday!.open)
                                        ? "Parar jornadas"
                                        : "(Re)Iniciar jornadas"
                                    : "",
                                child: workdayButton)),
                        Expanded(
                            flex: 1,
                            child: Tooltip(
                                message: "Añadir registro horario",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  child: addWorkdayButton,
                                ))),
                        Expanded(
                            flex: 1,
                            child: Tooltip(
                                message: "Imprimir hoja de registro",
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    child: actionButton(
                                      context,
                                      null,
                                      dialogPrintWorkday,
                                      Icons.print,
                                      context,
                                    )))),
                      ],
                    )),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    color: Colors.white,
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                              flex: 4,
                              child: Text(
                                "Fecha",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Entrada",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Salida",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Horas",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          )
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                worktimeRows(),
              ],
            )));
  }

  Widget worktimeRows() {
    myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));
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
                  // item.open = (index == 0);
                  return ListTile(
                      subtitle: Column(children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy').format(
                                        myWorkdays!.elementAt(index).startDate),
                                    style:
                                        (item.open) ? successText : normalText,
                                  )),
                            )),
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                DateFormat('HH:mm').format(item.startDate),
                                style: (item.open) ? successText : normalText,
                                textAlign: TextAlign.center,
                              )),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                DateFormat('HH:mm').format(item.open
                                    ? DateTime.now()
                                    : myWorkdays!.elementAt(index).endDate),
                                style: (item.open) ? successText : normalText,
                                textAlign: TextAlign.center,
                              )),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                item.open
                                    ? "En curso"
                                    : (((myWorkdays!
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
                        Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Icon(Icons.edit, size: 15),
                              onPressed: () {
                                _editWorkdayDialog(item);
                              },
                            )),
                      ],
                    )
                  ]));
                })
            : const Center(
                child: CircularProgressIndicator(),
              ));

    return result;
  }

  Future<Workday?> _editWorkdayDialog(Workday workday) {
    return showDialog<Workday>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Editar registro horario', context),
          content: WorkdayForm(
            key: null,
            currentWorkday: workday,
            user: user,
          ),
        );
      },
    ).then((value) {
      if ((value != null) && (!myWorkdays!.contains(value))) {
        myWorkdays!.add(value);
      }
      if ((value != null) && (value.id == "")) {
        myWorkdays!.remove(value);
      }
      if (mounted) {
        setState(() {
          contentWorkPanel = workTimePanel();
        });
      }

      return value;
    });
  }

  void dialogPrintWorkday(context) {
    _dialogPrintWorkday(context);
  }

  Widget printWorkdaysButtons(context) {
    List<DateTime> dates = [];
    DateTime currentMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    for (int i = 0; i < 12; i++) {
      dates.add(DateTime(currentMonth.year, currentMonth.month - i, 1));
    }

    dates = dates.reversed.toList();

    List<dynamic> matrix = reshape(dates, 3, 4);

    List<Widget> buttonsMonth = [];
    for (var row in matrix) {
      List<Widget> buttonsRow = [];
      for (var date in row) {
        buttonsRow.add(Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: actionButton(
                  context,
                  "${MONTHS[date.month - 1]} ${date.year}",
                  printWorkday,
                  Icons.print,
                  {'month': date},
                ))));
      }
      buttonsMonth.add(Row(
        children: buttonsRow,
      ));
      buttonsMonth.add(space(height: 5));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: buttonsMonth);
  }

  void printWorkday(Map<String, dynamic> args) {
    _printWorkday(args);
  }

  Future<void> _printWorkday(Map<String, dynamic> args) async {
    DateTime month = DateTime(DateTime.now().year, DateTime.now().month, 1);
    try {
      month = args['month'];
    } catch (e) {
      dev.log(e.toString());
    }

    List<Workday> workdays = [];
    await Workday.byUser(user.email!, month).then((value) {
      workdays = value;
    });

    workdays.sort((a, b) => b.startDate.compareTo(a.startDate));
    workdays = workdays.reversed.toList();
    Map<String, double> hoursDict = {};
    Map<String, DateTime> inDict = {};
    Map<String, DateTime> outDict = {};

    for (Workday workday in workdays) {
      if (workday.startDate.month == month.month &&
          workday.startDate.year == month.year) {
        String key = DateFormat('yyyy-MM-dd').format(workday.startDate);
        if (hoursDict.containsKey(key)) {
          hoursDict[key] = hoursDict[key]! + workday.hours();
        } else {
          hoursDict[key] = workday.hours();
        }
        if (inDict.containsKey(key)) {
          if (workday.startDate.isBefore(inDict[key]!)) {
            inDict[key] = workday.startDate;
          }
        } else {
          inDict[key] = workday.startDate;
        }
        if (outDict.containsKey(key)) {
          if (workday.endDate.isAfter(outDict[key]!)) {
            outDict[key] = workday.endDate;
          }
        } else {
          outDict[key] = workday.endDate;
        }
      }
    }

    // Crea un nuevo documento PDF
    pw.TextStyle headerPdf = pw.TextStyle(
        fontSize: 10, color: PdfColors.black, fontWeight: pw.FontWeight.bold);
    pw.TextStyle normalPdf =
        const pw.TextStyle(fontSize: 10, color: PdfColors.black);

    List<pw.TableRow> rows = [];

    List<String> keysSorted = hoursDict.keys.toList();
    keysSorted.sort((a, b) => a.compareTo(b));

    for (var keyDate in keysSorted) {
      double normalHours = min(hoursDict[keyDate]!, 8);
      double extraHours = max(hoursDict[keyDate]! - 8, 0);
      rows.add(pw.TableRow(children: [
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                    DateFormat("dd-MM-yyyy").format(inDict[keyDate]!),
                    style: normalPdf,
                    textAlign: pw.TextAlign.center))),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(DateFormat('HH:mm').format(inDict[keyDate]!),
                    style: normalPdf, textAlign: pw.TextAlign.center))),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(DateFormat('HH:mm').format(outDict[keyDate]!),
                    style: normalPdf, textAlign: pw.TextAlign.center))),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(normalHours.toStringAsFixed(2),
                    style: normalPdf, textAlign: pw.TextAlign.center))),
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(extraHours.toStringAsFixed(2),
                    style: normalPdf, textAlign: pw.TextAlign.center))),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: pw.SizedBox(width: 60, height: 5, child: pw.Container()),
        )
      ]));
    }

    final pdf = pw.Document();
    // Añade una cabecera al documento
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        //margin: const pw.EdgeInsets.all(5),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              children: [
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('Empresa', style: headerPdf)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(contact!.company, style: normalPdf)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('Año', style: headerPdf)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(month.year.toString(),
                                style: normalPdf)),
                        // pw.Text('Empresa', style: headerPdf),
                        // pw.Text(contact!.company, style: normalPdf),
                        // pw.Text('Año', style: headerPdf),
                        // pw.Text(month.year.toString(), style: normalPdf),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('Trabajador', style: headerPdf)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(contact!.name, style: normalPdf)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('Mes', style: headerPdf)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(MONTHS[month.month - 1],
                                style: normalPdf)),
                      ],
                    ),
                    pw.TableRow(
                        //decoration: pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text('Cargo', style: headerPdf)),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child:
                                  pw.Text(contact!.position, style: normalPdf)),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text('Centro', style: headerPdf)),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text('--', style: normalPdf)),
                        ])
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('Fecha',
                            style: headerPdf, textAlign: pw.TextAlign.center),
                        pw.Text('Hora\nentrada',
                            style: headerPdf, textAlign: pw.TextAlign.center),
                        pw.Text('Hora\nsalida',
                            style: headerPdf, textAlign: pw.TextAlign.center),
                        pw.Text('Horas\nnormales',
                            style: headerPdf, textAlign: pw.TextAlign.center),
                        pw.Text('Horas\nExtraordinarias',
                            style: headerPdf, textAlign: pw.TextAlign.center),
                        pw.Text('Firma',
                            style: headerPdf, textAlign: pw.TextAlign.center),
                      ],
                    ),
                    ...rows,
                  ],
                ),
              ],
            ),
          );
        }));

    final List<int> savedFile = await pdf.save();
    List<int> fileInts = List.from(savedFile);
    html.AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
      ..setAttribute("download",
          "Hoja_horario_${DateTime.now().millisecondsSinceEpoch}.pdf")
      ..click();
  }

  Future<void> _dialogPrintWorkday(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context2) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Imprimir hojas de registro', context),
          content: printWorkdaysButtons(context),
        );
      },
    );
  }

/////////// HOLIDAYS ///////////
  void addHolidayRequestDialog(context) {
    _addHolidayRequestDialog(context).then((value) {
      currentHoliday = null;
      HolidayRequest.byUser(user.email!).then((value) {
        myHolidays = value;
        holidayDays = 30;
        for (HolidayRequest holiday in myHolidays!) {
          if (holiday.status != "Rechazado") {
            holidayDays -=
              getWorkingDaysBetween(holiday.startDate, holiday.endDate);
          }
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
          title: s4cTitleBar('Solicitud de días libres', context),
          content: HolidayRequestForm(
            key: null,
            currentRequest: currentHoliday,
            user: user,
          ),
        );
      },
    );
  }

  Widget holidayRows() {
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
                                      color: holidayStatusColors[holiday.status.toLowerCase()]!,
                                      child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            holiday.status,
                                            style:  TextStyle(
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

  Widget holidayPeopleRows() {
    return Container(
        height: 150,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        color: Colors.white,
        child: mypeople.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: myPeopleHolidays.length,
                itemBuilder: (BuildContext context, int index) {
                  HolidayRequest holiday = myPeopleHolidays.elementAt(index);
                  Employee elementEmployee = mypeople.firstWhere(
                      (element) => element.email == holiday.userId);

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
                                        "${elementEmployee.getFullName()} (${holiday.catetory})",
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
                                      color: holidayStatusColors[holiday.status.toLowerCase()]!,
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
            : 
                
                SizedBox(
                  width: double.infinity,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Expanded(child: Text("No hay solicitudes de vacaciones", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: mainColor)))],))

              );
  }


  Widget holidayPeoplePanel(BuildContext contextt) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha:0.5),
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
                                child: Icon(Icons.people, color: Colors.black),
                              )),
                            )),
                        Expanded(
                            flex: 5,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Solicitudes de vacaciones",
                                            style: cardHeaderText,
                                          )),
                                      Text(
                                        "Personal a cargo",
                                        style: subTitleText,
                                      ),
                                    ])),
                        ),
                        Expanded(
                            flex: 2,
                            child: actionButton(
                                context,
                                "Añadir solicitud",
                                addHolidayRequestDialog,
                                Icons.add,
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
                                "Empleado",
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
                              
                                   flex: 1, child: Text("Días", style: subTitleText, textAlign: TextAlign.center)),
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
                holidayPeopleRows(),
              ],
            )));
  }

  Widget holidayPanel(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
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
                holidayRows(),
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
                                DateFormat('dd-MM-yyyy')
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
                                DateFormat('dd-MM-yyyy')
                                    .format(task.deadLineDate),
                                style: normalText,
                                textAlign: TextAlign.center,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: statusCard(
                              (hashStatus.containsKey(task.status))
                                  ? hashStatus[task.status]!.getName()
                                  : ""),
                        ),
                      ],
                    )
                  ]));
                })
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  Widget tasksPanel() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha:0.5),
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
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Mis tareas (${mytasks!.length})",
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

  /*Widget notifyPanelSubHead() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
        ));
  }

  Widget notifyPanelContentOld() {
    return Container(
        height: 150,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
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
                              padding: const EdgeInsets.only(bottom: 10),
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
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "A"
                            /*DateFormat('dd-MM-yyyy').format(
                                            holidayPeriods
                                                .elementAt(index)
                                                .elementAt(0))*/
                            ,
                            style: normalText,
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "B"
                            /*DateFormat('dd-MM-yyyy').format(
                                            holidayPeriods
                                                .elementAt(index)
                                                .elementAt(1))*/
                            ,
                            style: normalText,
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "C"
                            /*getWorkingDaysBetween(
                                                holidayPeriods
                                                    .elementAt(index)
                                                    .elementAt(0),
                                                holidayPeriods
                                                    .elementAt(index)
                                                    .elementAt(1))
                                            .toString()*/
                            ,
                            style: normalText,
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ],
                )
              ]));
            }));
  }*/
  Widget notifyPanelHead() {
    return Container(
        padding: const EdgeInsets.all(10),
        color: Colors.grey[100],
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    child: Icon(Icons.notifications_active, color: Colors.red),
                  )),
                )),
            Expanded(
                flex: 7,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              Text("$notif", style: dangerText),
                              Text(" notificaciones sin leer",
                                  style: subTitleText),
                            ],
                          ),
                        ]))),
          ],
        ));
  }

  Widget notifyPanelContent() {
/*    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: [*/
    //Container(
    //  color: Colors.white,
    //child: SizedBox(
    return SizedBox(
        width: double.infinity,
        //height: 100,
        child: DataTable(
          showCheckboxColumn: false,
          columns: [
            DataColumn(
                label: customText("Notificación", 16,
                    bold: FontWeight.bold, textColor: subTitleColor)),
            DataColumn(
                label: customText("Usuario", 16,
                    bold: FontWeight.bold, textColor: subTitleColor)),
            DataColumn(
                label: customText("Fecha", 16,
                    bold: FontWeight.bold, textColor: subTitleColor)),
            DataColumn(label: Container()),
          ],
          rows: notificationList
              .map(
                (notify) => DataRow(
                    onSelectChanged: (bool? selected) {
                      if (notify.readed) {
                        notify.readed = false;
                        notify.save();
                        notif += 1;
                      } else {
                        notify.readed = true;
                        notify.save();
                        notif += -1;
                      }
                      setState(() {});
                    },
                    color: (notify.readed)
                        ? MaterialStateColor.resolveWith(
                            (states) => Colors.white)
                        : MaterialStateColor.resolveWith((states) => greyColor),
                    cells: [
                      DataCell(Text(notify.msg)),
                      DataCell(Text(notify.sender)),
                      DataCell(
                        Text(DateFormat('yyyy-MM-dd').format(notify.date)),
                      ),
                      DataCell(Row(children: [
                        removeConfirmBtn(context, () {
                          notify.delete();
                          setState(() {
                            notificationList.remove(notify);
                          });
                        }, null),
                      ]))
                    ]),
              )
              .toList(),
        )); //)
    //]));
  }

  Widget notifyPanel(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Card(
            /*decoration: tabDecoration,
            padding: const EdgeInsets.all(2),*/
            child: Column(
          children: [
            notifyPanelHead(),
            notifyPanelContent(),
            /*notifyPanelSubHead(),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                notifyPanelContentOld(),*/
          ],
        )));

    /*List holidayPeriods = [];
    for (int i = 0; i < 5; i++) {
      DateTime from = DateTime(DateTime.now().year, 1, 1)
          .add(Duration(days: Random().nextInt(300)));
      DateTime to = from.add(Duration(days: Random().nextInt(10)));
      holidayPeriods.add([from, to]);
    }
    holidayPeriods.sort((a, b) => a.elementAt(0).compareTo(b.elementAt(0)));*/
    /*return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            //decoration: homePanelDecoration,
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                notifyPanelHead(),
                /*notifyPanelSubHead(),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                notifyPanelContentOld(),*/
                notifyPanelContent(),
              ],
            )));*/
  }

/////////// PROJECTS ///////////
  Widget projectsPanel() {
    myProjects = [];
    for (STask task in mytasks!) {
      if (hashProjects.containsKey(task.project)) {
        SProject project = hashProjects[task.project]!;
        if (!myProjects!.contains(project)) {
          myProjects!.add(project);
        }
      }
    }
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
                                          Text(
                                              (myProjects == null)
                                                  ? "0"
                                                  : myProjects!.length
                                                      .toString(),
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
                    child: myProjects != null
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
                                            DateFormat('dd-MM-yyyy')
                                                .format(project.datesObj.start),
                                            //project.datesObj.start,
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
                                            DateFormat('dd-MM-yyyy')
                                                .format(project.datesObj.end),
                                            //project.datesObj.end,
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
                                const Divider()
                              ]));
                            })
                        : const Center(
                            child: CircularProgressIndicator(),
                          )),
              ],
            )));
  }

/////////// LOGS ///////////

  /*Widget logsPanelHead() {
    return Container(
        padding: const EdgeInsets.all(10),
        color: Colors.grey[100],
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    child: Icon(Icons.notifications_active, color: Colors.red),
                  )),
                )),
            Expanded(
                flex: 7,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Logs",
                                style: cardHeaderText,
                              )),
                          Text(dateToES(DateTime.now()), style: subTitleText)
                        ]))),
          ],
        ));
  }*/

  /*Widget logsPanelContent() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            color: Colors.white,
            child: SizedBox(
                width: double.infinity,
                height: 190,
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: [
                    DataColumn(
                        label: customText("Fecha", 16,
                            bold: FontWeight.bold, textColor: subTitleColor)),
                    DataColumn(
                        label: customText("Usuario", 16,
                            bold: FontWeight.bold, textColor: subTitleColor)),
                    DataColumn(
                        label: customText("Log", 16,
                            bold: FontWeight.bold, textColor: subTitleColor)),
                    DataColumn(label: Container()),
                  ],
                  rows: logList
                      .map(
                        (log) => DataRow(cells: [
                          DataCell(
                            Text(DateFormat('yyyy-MM-dd').format(log.date)),
                          ),
                          DataCell(Text(log.user)),
                          DataCell(Text(log.msg)),
                          DataCell(Row(children: [
                            /*removeConfirmBtn(context, () {
                                  notify.delete();
                                  setState(() {
                                    notificationList.remove(notify);
                                  });
                                }, null),*/
                          ]))
                        ]),
                      )
                      .toList(),
                ))));
  }*/

  /*Widget logsPanel(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Card(
            child: Column(
          children: [
            logsPanelHead(),
            logsPanelContent(),
          ],
        )));
  }*/
}
