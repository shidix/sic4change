// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import "dart:developer" as dev;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:googleapis/batch/v1.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/holiday_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/models_workday.dart';
import 'package:sic4change/services/notifications_lib.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/services/workday_form.dart';
import 'package:sic4change/widgets/calendar_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/holidays_widgets.dart';
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
  late final VoidCallback _listener;
  late final ProfileProvider _profileProvider;

  late Map<String, TasksStatus> hashStatus;
  late Map<String, SProject> hashProjects;

  Organization? currentOrganization;
  Employee? currentEmployee;

  late String _currentPage;
  User user = FirebaseAuth.instance.currentUser!;
  Profile? profile;
  List<STask>? mytasks = [];
  Contact? contact;
  HolidayRequest? currentHoliday;
  List<HolidayRequest>? myHolidays = [];
  List<HolidaysCategory>? holCat = [];
  Map<String, int> remainingHolidays = {};
  int holidayDays = 0;

  Workday? currentWorkday;
  Widget workdayButton = Container();
  List<Workday>? myWorkdays = [];
  Widget mainMenuWidget = Container();
  List<Employee> mypeople = [];
  List<HolidayRequest> myPeopleHolidays = [];
  List<Workday> myPeopleWorkdays = [];

  Widget contentHolidaysPanel = Container();
  Widget contentWorkPanel = Container();
  Widget contentTasksPanel = Container();
  Widget contentProjectsPanel = Container();
  Widget topButtonsPanel = Container();

  List<SProject>? myProjects;

  List notificationList = [];
  //List logList = [];

  bool onHolidays(String userEmail, DateTime date) {
    if (myHolidays == null) return false;
    for (HolidayRequest holiday in myHolidays!) {
      if (holiday.userId == userEmail &&
          date.isAfter(holiday.startDate) &&
          date.isBefore(holiday.endDate)) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _profileProvider.removeListener(_listener);
    super.dispose();
  }

  Map<String, Color> holidayStatusColors = {
    "pendiente": warningColor,
    "aprobado": successColor,
    "rechazado": dangerColor,
  };

  // Future<List<HolidayRequest>?> loadMyHolidays() async {
  //   contact ??= await Contact.byEmail(user.email!);
  //   holCat ??= await HolidaysCategory.byOrganization(currentOrganization!);

  //   holidayDays = 0;
  //   for (HolidaysCategory cat in holCat!) {
  //     if (!cat.retroactive) {
  //       holidayDays += cat.days;
  //     }
  //   }
  //   myHolidays ??= [];
  //   if (myHolidays!.isNotEmpty) {
  //     myHolidays!.sort((a, b) => b.startDate.compareTo(a.startDate));
  //     for (HolidayRequest holiday in myHolidays!) {
  //       if (holiday.status != "Rechazado") {
  //         holidayDays -=
  //             getWorkingDaysBetween(holiday.startDate, holiday.endDate);
  //       }
  //     }
  //   }
  //   return myHolidays;
  // }

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
      myWorkdays = await Workday.byUser(user.email!);
      if (myWorkdays!.isEmpty) {
        currentWorkday = Workday.getEmpty(email: user.email!, open: true);
        currentWorkday!.save();
        myWorkdays = [currentWorkday!];
      }
    }

    myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));
    currentWorkday = myWorkdays!.first;
    if (!currentWorkday!.open) {
      currentWorkday = Workday.getEmpty(email: user.email!, open: true);
      currentWorkday!.save();
      myWorkdays!.insert(0, currentWorkday!);
    } else {
      // Check if the current workday is from today; if not, close it and create a new one
      if (truncDate(currentWorkday!.startDate) != truncDate(DateTime.now())) {
        currentWorkday!.endDate = truncDate(currentWorkday!.startDate)
            .add(Duration(hours: 23, minutes: 59, seconds: 59));
        currentWorkday!.open = false;
        currentWorkday!.save();
        currentWorkday = Workday.getEmpty(email: user.email!, open: true);
        currentWorkday!.save();
        myWorkdays!.insert(0, currentWorkday!);
      }
    }
    // Set workday.open to false for all workdays except the first one
    for (var workday in myWorkdays!) {
      if (workday != currentWorkday) {
        if (workday.open) {
          workday.open = false;
          // Set the endDate to 23.59:59 of the same day
          workday.endDate = DateTime(workday.startDate.year,
              workday.startDate.month, workday.startDate.day, 23, 59, 59);
          workday.save();
        }
      }
    }
    if (mounted) {
      if (currentWorkday!.open) {
        workdayButton = actionButton(
            context, null, workdayAction, Icons.stop_circle_outlined, context,
            iconColor: dangerColor);
      } else {
        workdayButton = actionButton(context, null, workdayAction,
            Icons.play_circle_outline_sharp, context,
            iconColor: successColor);
      }
    }
  }

  Future<void> loadMyData() async {
    contact ??= await Contact.byEmail(user.email!);
    final results = await Future.wait([
      contact!.getProjects(),
      STask.getByAssigned(user.email!, lazy: true),
      HolidayRequest.byUser(user.email!),
      Workday.byUser(user.email!),
      ((currentEmployee != null) && (mypeople.isEmpty))
          ? currentEmployee!.getSubordinates()
          : Future.value(mypeople),
      // Future.value(mypeople),
      getNotificationList(user.email)
    ]);

    myProjects = results[0] as List<SProject>;
    mytasks = results[1] as List<STask>;
    contentTasksPanel = tasksPanel();
    contentProjectsPanel = projectsPanel();
    myHolidays = results[2] as List<HolidayRequest>;
    currentEmployee ??= await Employee.byEmail(user.email!);
    updateRemainingHolidays();

    myWorkdays = results[3] as List<Workday>;
    myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));
    if ((myWorkdays!.first.open) &&
        (truncDate(myWorkdays!.first.startDate) == truncDate(DateTime.now()))) {
      currentWorkday = myWorkdays!.first;
    } else {
      currentWorkday = Workday.getEmpty();
      currentWorkday!.userId = user.email!;
      currentWorkday!.open = true;
      currentWorkday!.save();
    }

    contentWorkPanel = workTimePanel();

    mypeople = results[4] as List<Employee>;
    currentEmployee ??= await Employee.byEmail(user.email!);
    mypeople.add(currentEmployee!);
    loadMyPeopleWorkdays().then((value) {
      myPeopleWorkdays = value;
      myPeopleWorkdays.sort((a, b) => b.startDate.compareTo(a.startDate));
    });

    for (Employee element in mypeople) {
      HolidayRequest.byUser(element.email).then((value) {
        myPeopleHolidays.addAll(value);
      });
    }
    NotificationValues nVal = results[5] as NotificationValues;
    notificationList = nVal.nList;
    notif = nVal.unread;
  }

  Future<List<Workday>> loadMyPeopleWorkdays() async {
    // if ((myPeopleWorkdays.isNotEmpty) && (mypeople.length > 1)) {
    //   return Future.value(myPeopleWorkdays);
    // }

    List<String> emails = mypeople.map((e) => e.email).toList();
    if (!emails.contains(user.email!)) {
      emails.add(user.email!);
    }
    myPeopleWorkdays = await Workday.byUser(emails);
    myPeopleWorkdays.sort((a, b) => b.startDate.compareTo(a.startDate));
    return myPeopleWorkdays;
  }

  void getNotifications() async {
    NotificationValues nVal = await getNotificationList(user.email);
    notificationList = nVal.nList;
    notif = nVal.unread;
    setState(() {});
  }

  // Future<int> updateHolidayDays() async {
  //   double factor = 1.0;
  //   currentEmployee ??= await Employee.byEmail(user.email!);
  //   DateTime altaDate = currentEmployee!.getAltaDate();
  //   DateTime bajaDate = currentEmployee!.getBajaDate();
  //   if ((altaDate.isBefore(DateTime(DateTime.now().year, 1, 1)) &&
  //       (bajaDate.isAfter(DateTime(DateTime.now().year + 1, 1, 1))))) {
  //     factor =
  //         1; // If the employee's start date is before the current year, return 0
  //   } else {
  //     if (bajaDate.isAfter(DateTime(DateTime.now().year + 1, 1, 1))) {
  //       bajaDate = DateTime(DateTime.now().year + 1, 1,
  //           1); // Calculate until the end of the year
  //     }
  //     int daysInYear = DateTime(DateTime.now().year + 1, 1, 1)
  //         .difference(DateTime(DateTime.now().year, 1, 1))
  //         .inDays;
  //     int daysWorked = bajaDate.difference(altaDate).inDays;
  //     factor = daysWorked /
  //         daysInYear; // Calculate the factor based on the days worked
  //   }

  //   int counter = 0;
  //   if (holCat == null) return 0;
  //   for (HolidaysCategory cat in holCat!) {
  //     if (!cat.retroactive) {
  //       counter += cat.days;
  //     }
  //   }
  //   if (myHolidays == null) return counter;
  //   for (HolidayRequest holiday in myHolidays!) {
  //     if (holiday.status != "Rechazado") {
  //       counter -= getWorkingDaysBetween(holiday.startDate, holiday.endDate);
  //       if (remainingHolidays
  //           .containsKey(holiday.getCategory(holCat ?? []).autoCode())) {
  //         remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()] =
  //             remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()]! -
  //                 getWorkingDaysBetween(holiday.startDate, holiday.endDate);
  //       } else {
  //         remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()] =
  //             holiday.getCategory(holCat ?? []).days -
  //                 getWorkingDaysBetween(holiday.startDate, holiday.endDate);
  //       }
  //     }
  //   }
  //   for (String key in remainingHolidays.keys) {
  //     if (remainingHolidays[key]! < 0) {
  //       remainingHolidays[key] = 0;
  //     } else if (remainingHolidays[key]! > 0) {
  //       remainingHolidays[key] = (remainingHolidays[key]! * factor).truncate();
  //     }
  //   }
  //   //
  //   int result = max(0, min((counter * factor).truncate() + 1, counter));
  //   return result;
  // }

  Widget loadMyPeopleWorkdaysWidget() {
    if (myPeopleWorkdays.isEmpty) {
      return const Center(
        child: Text("No hay registros de jornada para este usuario."),
      );
    }

    Map<String, Map<String, double>> workdayHours = {};
    DateTime currentMonthStart =
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime lastMonthStart =
        DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
    DateTime nextMonthStart = currentMonthStart.add(Duration(days: 35));
    nextMonthStart = DateTime(nextMonthStart.year, nextMonthStart.month, 1);
    DateTime currentWeekStart =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    DateTime lastWeekStart = currentWeekStart.subtract(Duration(days: 7));
    double currentYearHours = 0;
    double currentMonthHours = 0;
    double lastMonthHours = 0;
    double currentWeekHours = 0;
    double lastWeekHours = 0;
    for (Employee employee in mypeople) {
      // Calcular horas en el año actual, en el mes pasado, en el mes actual, en la semana pasada y en la semana actual
      List<Workday> employeeWorkdays =
          myPeopleWorkdays.where((wd) => wd.userId == employee.email).toList();

      for (var workday in employeeWorkdays) {
        if (workday.startDate.year == DateTime.now().year) {
          currentYearHours += workday.hours();
        }
        if ((workday.startDate.isAfter(currentMonthStart)) &&
            (workday.startDate.isBefore(nextMonthStart))) {
          currentMonthHours += workday.hours();
        }
        if ((workday.startDate.isAfter(lastMonthStart)) &&
            (workday.startDate.isBefore(currentMonthStart))) {
          lastMonthHours += workday.hours();
        }
        if (workday.startDate.isAfter(currentWeekStart)) {
          currentWeekHours += workday.hours();
        }
        if (workday.startDate.isAfter(lastWeekStart) &&
            workday.startDate.isBefore(currentWeekStart)) {
          lastWeekHours += workday.hours();
        }
      }

      // Calculate percentage of hours worked, assuming 40 hours per week
      currentYearHours = (currentYearHours / (40 * 52)) * 100.0;
      currentMonthHours = (currentMonthHours / (40 * 4)) * 100.0;
      lastMonthHours = (lastMonthHours / (40 * 4)) * 100.0;
      currentWeekHours = (currentWeekHours / (40)) * 100.0;
      lastWeekHours = (lastWeekHours / (40)) * 100.0;

      workdayHours[employee.email] = {
        "currentYear": currentYearHours,
        "currentMonth": currentMonthHours,
        "lastMonth": lastMonthHours,
        "currentWeek": currentWeekHours,
        "lastWeek": lastWeekHours,
      };
      currentYearHours = 0;
      currentMonthHours = 0;
      lastMonthHours = 0;
      currentWeekHours = 0;
      lastWeekHours = 0;
    }

    Widget listSummary = Container(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: const [
                  Expanded(
                      flex: 2,
                      child: Text(
                        "Nombre",
                        style: subTitleText,
                        textAlign: TextAlign.left,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        "Año actual",
                        style: subTitleText,
                        textAlign: TextAlign.right,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        "Mes pasado",
                        style: subTitleText,
                        textAlign: TextAlign.right,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        "Mes actual",
                        style: subTitleText,
                        textAlign: TextAlign.right,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        "Semana pasada",
                        style: subTitleText,
                        textAlign: TextAlign.right,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        "Semana actual",
                        style: subTitleText,
                        textAlign: TextAlign.right,
                      )),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey[300],
            ),
            for (var item in workdayHours.entries)
              ListTile(
                // title: Text(mypeople
                //     .firstWhere((e) => e.email == item.key)
                //     .getFullName()),
                subtitle: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(
                          mypeople
                              .firstWhere((e) => e.email == item.key)
                              .getFullName(),
                          style: normalText,
                        )),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "${item.value['currentYear']?.toStringAsFixed(2) ?? '0.00'} %",
                        style: normalText,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "${item.value['lastMonth']?.toStringAsFixed(2) ?? '0.00'} %",
                        style: normalText,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "${item.value['currentMonth']?.toStringAsFixed(2) ?? '0.00'} %",
                        style: normalText,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "${item.value['lastWeek']?.toStringAsFixed(2) ?? '0.00'} %",
                        style: normalText,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "${item.value['currentWeek']?.toStringAsFixed(2) ?? '0.00'} %",
                        style: normalText,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            if (workdayHours.isEmpty)
              const Center(
                child: Text("No hay registros de jornada para este usuario."),
              ),
          ],
        ));

    return SizedBox(
        height: 600,
        child: SingleChildScrollView(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(128),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(
                                0, 3), // changes position of shadow
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
                                    flex: 8,
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Text(
                                                    "Registro de jornada",
                                                    style: cardHeaderText,
                                                  )),
                                              Text(dateToES(DateTime.now()),
                                                  style: subTitleText),
                                            ]))),
                              ],
                            )),
                        listSummary,
                      ],
                    )))));
  }

  void initializeData() async {
    if (!mounted) return;
    final results = await Future.wait([
      HolidaysCategory.byOrganization(currentOrganization!),
      TasksStatus.all(),
      SProject.all(),
      loadMyPeopleWorkdays(),
      HolidayRequest.byUser(user.email!),
    ]);

    myHolidays = results[4] as List<HolidayRequest>;

    holCat = results[0] as List<HolidaysCategory>;
    for (HolidaysCategory cat in holCat!) {
      if (!cat.retroactive) {
        holidayDays += cat.days;
      }
    }

    // await loadMyHolidays();

    final tasksStatusList = results[1] as List<TasksStatus>;
    if (tasksStatusList.isNotEmpty) {
      for (var item in tasksStatusList) {
        hashStatus[item.id] = item;
        hashStatus[item.uuid] = item;
      }
    }
    final projectsList = results[2] as List<SProject>;
    if (projectsList.isNotEmpty) {
      for (var item in projectsList) {
        hashProjects[item.id] = item;
        hashProjects[item.uuid] = item;
      }
    }
    topButtonsPanel = topButtons(null);
    await loadMyData();
    contentHolidaysPanel = holidayPanel();

    myPeopleWorkdays = results[3] as List<Workday>;

    // autoStartWorkday(context);

    if (mounted) {
      setState(() {});
    }
  }

  Widget peopleCalendar() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(128),
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
                                    children: const [
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Solicitud de vacaciones",
                                            style: cardHeaderText,
                                          )),
                                      Row(
                                        children: [
                                          Text(
                                              "Calendario del personal a cargo ",
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
                CalendarWidget(
                  holidays: myPeopleHolidays,
                  categories: holCat ?? [],
                  onDateSelected: (date) {
                    print(date);
                    // Handle date selection
                  },
                  employees: mypeople,
                  height: 600,
                )
              ],
            )));
  }

  @override
  void initState() {
    super.initState();
    _currentPage = "home";
    hashStatus = {};
    hashProjects = {};
    topButtonsPanel = topButtons(context);
    mainMenuWidget = mainMenu(context, "/home");
    _profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _listener = () {
      if (!mounted) return;
      currentOrganization = _profileProvider.organization;

      profile = _profileProvider.profile;
      mainMenuWidget = mainMenu(context, "/home");
      if ((profile != null) && (currentOrganization != null)) {
        initializeData();
      } else {
        // If profile or organization is null, load profile again
        _profileProvider.loadProfile();
      }

      if (mounted) setState(() {});
    };
    _profileProvider.addListener(_listener);

    currentOrganization = _profileProvider.organization;
    profile = _profileProvider.profile;
    if ((profile == null) || (currentOrganization == null)) {
      _profileProvider.loadProfile();
    } else {
      initializeData();
    }
    // initializeData();
  }

  @override
  Widget build(BuildContext context) {
    mainMenuWidget = mainMenu(context, "/home");
    List<Widget> contents = [];
    if (_currentPage == "home") {
      contents = [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: contentWorkPanel),
            Expanded(flex: 1, child: contentHolidaysPanel),
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
      contents = [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: loadMyPeopleWorkdaysWidget()),
            Expanded(flex: 1, child: peopleCalendar()),
          ],
        ),
      ];
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

  Widget topButtons(context) {
    if (!mounted) return Container();
    List<Widget> buttons = [
      actionButton(context, "Dashboard", () {
        setState(() {
          _currentPage = "home";
        });
      }, Icons.dashboard, null,
          bgColor:
              (_currentPage == "home") ? Colors.green.shade50 : Colors.white),
      space(width: 10),
      actionButton(context, "Personal a cargo [${mypeople.length}]", () {
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
    if (!mounted) return;
    setState(() {});
    dev.log("printSummary");
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

    //loadMyWorkdays();
  }

  Widget workTimePanel() {
    myWorkdays ??= [];
    myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));

    List<String> idsToRemove = [];
    for (int index = 0; index < myWorkdays!.length; index++) {
      Workday item = myWorkdays!.elementAt(index);
      if (item.open) {
        if (truncDate(item.startDate) != truncDate(DateTime.now())) {
          item.endDate = truncDate(item.startDate)
              .add(Duration(hours: 23, minutes: 59, seconds: 59));
          item.open = false;
          item.save();
          myWorkdays![index] = item;
        } else {
          if (index != 0) {
            myWorkdays![0].open = true;
            myWorkdays![0].startDate = item.startDate;
            idsToRemove.add(item.id);
          }
        }
      }
    }
    for (String id in idsToRemove) {
      Workday item = myWorkdays!.firstWhere((item) => item.id == id);
      item.delete();
    }
    myWorkdays!.removeWhere((item) => idsToRemove.contains(item.id));
    currentWorkday = myWorkdays!.first;
    if (!currentWorkday!.open) {
      currentWorkday = Workday.getEmpty(email: user.email!, open: true);
      currentWorkday!.save();
      myWorkdays!.insert(0, currentWorkday!);
    }

    if (currentWorkday?.open == true) {
      workdayButton = actionButton(
          null, null, workdayAction, Icons.stop_circle_outlined, null,
          iconColor: dangerColor);
    } else {
      workdayButton = actionButton(
          null, null, workdayAction, Icons.play_circle_outline_sharp, null,
          iconColor: successColor);
    }
    Widget addWorkdayButton = actionButton(null, null, () {
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
                    color: Colors.grey.withAlpha(128),
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
                                      null,
                                      null,
                                      dialogPrintWorkday,
                                      Icons.print,
                                      null,
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
    myWorkdays ??= [];

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
                                    : (myWorkdays!.elementAt(index).hours())
                                        .toStringAsFixed(2),
                                style: (item.open)
                                    ? successText
                                    : (myWorkdays!.elementAt(index).hours() <
                                            10)
                                        ? normalText
                                        : warningText,
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
  void updateRemainingHolidays() {
    remainingHolidays = {};
    holidayDays = 0;
    if (currentEmployee == null || holCat == null || myHolidays == null) {
      return;
    }
    double factor = 1.0;
    DateTime altaDate = currentEmployee!.getAltaDate();
    DateTime bajaDate = currentEmployee!.getBajaDate();

    if ((altaDate.isBefore(DateTime(DateTime.now().year, 1, 1)) &&
        (bajaDate.isAfter(DateTime(DateTime.now().year + 1, 1, 1))))) {
      factor =
          1; // If the employee's start date is before the current year, return 0
    } else {
      if (bajaDate.isAfter(DateTime(DateTime.now().year + 1, 1, 1))) {
        bajaDate = DateTime(DateTime.now().year + 1, 1, 1);
      }
      int daysInYear = DateTime(DateTime.now().year + 1, 1, 1)
          .difference(DateTime(DateTime.now().year, 1, 1))
          .inDays;
      int daysWorked = bajaDate.difference(altaDate).inDays;
      factor = daysWorked /
          daysInYear; // Calculate the factor based on the days worked
    }
    for (HolidaysCategory cat in holCat!) {
      if (cat.retroactive) {
        remainingHolidays[cat.autoCode()] = cat.days;
      } else {
        remainingHolidays[cat.autoCode()] = (cat.days * factor).round();
      }
      if (cat.obligation) {
        holidayDays = (holidayDays + (cat.days * factor)).round();
      }
    }

    for (HolidaysCategory cat in holCat!) {
      if (cat.retroactive) {
        remainingHolidays[cat.autoCode()] = cat.days;
      } else {
        remainingHolidays[cat.autoCode()] = (cat.days * factor).round();
      }
    }

    for (HolidayRequest holiday in myHolidays!) {
      if (holiday.status != "Rechazado") {
        holidayDays -=
            getWorkingDaysBetween(holiday.startDate, holiday.endDate);
        if (remainingHolidays
            .containsKey(holiday.getCategory(holCat ?? []).autoCode())) {
          remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()] =
              remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()]! -
                  getWorkingDaysBetween(holiday.startDate, holiday.endDate);
        } else {
          remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()] =
              (holiday.getCategory(holCat ?? []).retroactive)
                  ? (holiday.getCategory(holCat ?? []).days * factor).round()
                  : holiday.getCategory(holCat ?? []).days;
          remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()] =
              remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()]! -
                  getWorkingDaysBetween(holiday.startDate, holiday.endDate);
        }
      }
    }
  }

  void addHolidayRequestDialog(context) {
    _addHolidayRequestDialog(context).then((value) {
      if (value == null) {
        currentHoliday = null;
        return;
      }
      if (value.id == "") {
        // Remove currentHoliday from myHolidays
        myHolidays!.removeWhere((holiday) => holiday.id == currentHoliday!.id);
        currentHoliday = null;
      } else {
        // Check if the new holiday request is already in myHolidays
        int index = myHolidays!.indexWhere((holiday) => holiday.id == value.id);
        if (index >= 0) {
          // Update existing holiday request
          myHolidays![index] = value;
        } else {
          // Add new holiday request
          myHolidays!.add(value);
        }
      }
      if (mounted) {
        setState(() {
          myHolidays = myHolidays;
          updateRemainingHolidays();
          // updateHolidayDays().then((value) => holidayDays = value);
        });
      }
    });
  }

  Future<HolidayRequest?> _addHolidayRequestDialog(context) {
    if (currentHoliday == null) {
      currentHoliday = HolidayRequest.getEmpty();
      currentHoliday!.userId = user.email!;
    }

    return showDialog<HolidayRequest>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context2) {
        updateRemainingHolidays();
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Solicitud de días libres', context),
          content: HolidayRequestForm(
              key: null,
              currentRequest: currentHoliday,
              user: user,
              profile: profile!,
              categories: holCat!,
              remainingHolidays: remainingHolidays,
              granted: myHolidays!
                  .where((element) =>
                      (element.status.toLowerCase() == "aprobado" ||
                          element.status.toLowerCase() == "concedido"))
                  .toList()),
        );
      },
    );
  }

  Widget btnDocuments(context, HolidayRequest holiday) {
    Widget btn = actionButton(
      context,
      null,
      () {
        HolidaysCategory? category = holCat!.firstWhere(
            (cat) => cat.id == holiday.category,
            orElse: () => HolidaysCategory.getEmpty());
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0),
              title: s4cTitleBar(
                  'Probatorios requeridos: ${category.docRequired}', context),
              content: HolidayDocumentsForm(
                  holidayRequest: holiday,
                  afterSave: () {
                    if (mounted) {
                      setState(() {
                        myHolidays = myHolidays;
                      });
                    }
                  }),
            );
          },
        );
      },
      Icons.document_scanner,
      null,
      scale: "sm",
    );

    HolidaysCategory? category = holCat!.firstWhere(
        (cat) => cat.id == holiday.category,
        orElse: () => HolidaysCategory.getEmpty());

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10),
      child: Tooltip(
        message: "Se requieren ${category.docRequired} documentos",
        child: (category.docRequired) > 0 ? btn : Text("NO REQUIERE"),
      ),
    );
  }

  Widget holidayRows() {
    return Container(
        height: 150,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        color: Colors.white,
        child: profile != null
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: myHolidays!.length,
                itemBuilder: (BuildContext context, int index) {
                  HolidayRequest holiday = myHolidays!.elementAt(index);
                  // return ListTile with info popup
                  return Row(children: [
                    Expanded(
                        flex: 8,
                        child: buildHolidayListItem(
                            context, holCat ?? [], holiday,
                            onTap: (holiday.status.toUpperCase() == 'PENDIENTE')
                                ? () {
                                    currentHoliday = holiday;
                                    //addHolidayRequestDialog(context);
                                  }
                                : null)),
                    Expanded(flex: 2, child: btnDocuments(context, holiday)),
                  ]);
                })
            : Center(
                child: Container(),
                // child: CircularProgressIndicator(),
              ));
  }

  Widget holidayPanel() {
    String remainingHolidaysMsg = "";

    if (remainingHolidays.isNotEmpty) {
      remainingHolidaysMsg = "";
      remainingHolidays.forEach((key, value) {
        if (value > 0) {
          remainingHolidaysMsg += "$key: $value días, ";
        }
      });
      if (remainingHolidaysMsg.endsWith(", ")) {
        remainingHolidaysMsg =
            remainingHolidaysMsg.substring(0, remainingHolidaysMsg.length - 2);
      }
    } else {
      remainingHolidaysMsg = "No hay días restantes";
    }
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(128),
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
                                      Container(
                                          padding: const EdgeInsets.all(10),
                                          color: Colors.grey[100],
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(remainingHolidaysMsg,
                                                style: subTitleText,
                                                textAlign: TextAlign.left),
                                          )),
                                    ]))),
                        Expanded(
                            flex: 3,
                            child: (mounted)
                                ? actionButton(
                                    context,
                                    "Solicitar días",
                                    addHolidayRequestDialog,
                                    Icons.play_circle_outline_sharp,
                                    context)
                                : Container()),
                      ],
                    )),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    color: Colors.white,
                    child: const Row(children: [
                      Expanded(
                          flex: 8,
                          child: ListTile(
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
                      Expanded(
                          flex: 2,
                          child: Text(
                            "Docs",
                            style: subTitleText,
                            textAlign: TextAlign.center,
                          ))
                    ])),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                holidayRows(),
              ],
            )));
  }

/////////// TASKS ///////////
  Widget taskRows() {
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
                          child:
                              statusCard((hashStatus.containsKey(task.status))
                                  ? (hashStatus[task.status] != null)
                                      ? hashStatus[task.status]!.getName()
                                      : "Not found"
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
                    color: Colors.grey.withAlpha(128),
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
                taskRows(),
              ],
            )));
  }

/////////// NOTIFICATIONS ///////////

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
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    color: (notify.readed)
                        ? WidgetStateColor.resolveWith((states) => Colors.white)
                        : WidgetStateColor.resolveWith((states) => greyColor),
                    cells: [
                      DataCell(Text(notify.msg)),
                      DataCell(Text(notify.sender)),
                      DataCell(
                        Text(DateFormat('yyyy-MM-dd').format(notify.date)),
                      ),
                      DataCell(Row(children: [
                        removeConfirmBtn(context, () {
                          notify.delete();
                          if (mounted) {
                            setState(() {
                              notificationList.remove(notify);
                            });
                          }
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
