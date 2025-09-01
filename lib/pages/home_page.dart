// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:html' as html;
// import "dart:developer" as dev;
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
import 'package:sic4change/services/reports_utils.dart';
import 'package:sic4change/services/workday_form.dart';
import 'package:sic4change/widgets/calendar_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
// import 'package:sic4change/widgets/holidays_widgets.dart';
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
  HolidaysConfig? myCalendar;

  Workday? currentWorkday;
  Widget workdayButton = Container();
  List<Workday>? myWorkdays = [];
  Widget mainMenuWidget = Container();
  List<Employee> mypeople = [];
  List<Employee> myManagers = [];
  List<HolidayRequest> myPeopleHolidays = [];
  List<Workday> myPeopleWorkdays = [];
  Map<String, HolidaysConfig> myPeopleCalendars = {};

  Widget contentHolidaysPanel = Container();
  Widget contentWorkPanel = Container();
  Widget contentTasksPanel = Container();
  Widget contentProjectsPanel = Container();
  Widget topButtonsPanel = Container();

  List<SProject>? myProjects;

  List notificationList = [];
  //List logList = [];

  bool onHolidays(String userEmail, DateTime date,
      {bool acceptedOnly = false}) {
    if (myHolidays == null) return false;

    for (HolidayRequest holiday in myHolidays!) {
      bool inRange = (date.isAfter(holiday.startDate) &&
              date.isBefore(
                  truncDate(holiday.endDate.add(Duration(days: 1))))) ||
          (holiday.startDate.isAtSameMomentAs(date) ||
              holiday.endDate.isAtSameMomentAs(date));
      if (holiday.userId == userEmail && inRange) {
        if ((!acceptedOnly) || (acceptedOnly && (holiday.isAproved()))) {
          return true;
        }
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

  Future<void> loadMyProjects() async {
    await Contact.byEmail(user.email!).then((value) {
      contact = value;
      contact!.getProjects().then((value) {
        myProjects = value;
        setState(() {});
      });
    });
  }

  Future<List<Workday>> loadMyWorkdays() async {
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
    if (currentWorkday!.open) {
      // Check if the current workday is from today; if not, close it and create a new one
      bool beClosed =
          truncDate(currentWorkday!.startDate) != truncDate(DateTime.now()) &&
              DateTime.now().difference(currentWorkday!.startDate).inHours > 12;
      if (beClosed) {
        currentWorkday!.endDate = currentWorkday!.startDate.add(
            Duration(hours: 11, minutes: 59, seconds: 59)); // Maximo 12 horas
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
          workday.endDate = workday.startDate.add(
              Duration(hours: 11, minutes: 59, seconds: 59)); // Maximo 12 horas
          workday.save();
        }
      }
    }

    // Remove duplicate workdays (check userId, startDate, endDate)
    for (Workday element in myWorkdays!) {
      element.startDate = DateTime(
          element.startDate.year,
          element.startDate.month,
          element.startDate.day,
          element.startDate.hour,
          element.startDate.minute);
      element.endDate = DateTime(element.endDate.year, element.endDate.month,
          element.endDate.day, element.endDate.hour, element.endDate.minute);
      if (!element.isValid()) {
        String idsToRemove = element.id;
        element.delete();
        myWorkdays!.removeWhere((e) => e.id == idsToRemove);
        // If so, set the endDate to the startDate
      }
    }

    Queue<Workday> workdayQueue = Queue<Workday>.from(myWorkdays!);

    List<Workday> uniques = [];
    while (workdayQueue.isNotEmpty) {
      Workday current = workdayQueue.removeFirst();
      uniques.add(current);
      workdayQueue.removeWhere((element) =>
          element.userId == current.userId &&
          element.startDate == current.startDate &&
          element.endDate == current.endDate &&
          element.id != current.id);
    }

    //Get elements from myWorkdays that are not in uniques using id to compare
    List<Workday> toRemove = [];
    for (Workday element in myWorkdays!) {
      if (!uniques.any((e) => e.id == element.id)) {
        toRemove.add(element);
      }
    }
    for (Workday element in toRemove) {
      element.delete();
    }
    myWorkdays = uniques;

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
    return myWorkdays!;
  }

  Future<void> loadMyData() async {
    contact ??= await Contact.byEmail(user.email!);
    currentEmployee ??= await Employee.byEmail(user.email!);
    if (currentEmployee!.organization == null) {
      currentEmployee!.organization = currentOrganization!.id;
      currentEmployee!.save();
    }
    myCalendar ??= await HolidaysConfig.byEmployee(currentEmployee!);
    final results = await Future.wait([
      contact!.getProjects(),
      STask.getByAssigned(user.email!, lazy: true),
      HolidayRequest.byUser(user.email!),
      //Workday.byUser(user.email!),
      loadMyWorkdays(),
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
    updateRemainingHolidays();

    contentWorkPanel = workTimePanel();

    mypeople = results[4] as List<Employee>;

    currentEmployee ??= await Employee.byEmail(user.email!);
    mypeople.add(currentEmployee!);

    for (Employee emp in mypeople) {
      myPeopleCalendars[emp.email!] = await HolidaysConfig.byEmployee(emp);
    }

    if (profile!.mainRole == Profile.RRHH) {
      // Load all employees
      Employee.getAll().then((value) {
        mypeople = value;
        mypeople = mypeople.where((element) => element.isActive()).toList();
        if (mounted) setState(() {});
      });
    }
    loadMyPeopleWorkdays().then((value) {
      myPeopleWorkdays = value;
      myPeopleWorkdays.sort((a, b) => b.startDate.compareTo(a.startDate));
    });

    for (Employee element in mypeople) {
      HolidayRequest.byUser(element.email).then((value) {
        // Check if value is not in myPeopleHolidays using id to compare
        myPeopleHolidays.addAll(value.where(
            (holiday) => !myPeopleHolidays.any((h) => h.id == holiday.id)));
      });
    }
    NotificationValues nVal = results[5] as NotificationValues;
    notificationList = nVal.nList;
    notif = nVal.unread;
  }

  Future<List<Workday>> loadMyPeopleWorkdays() async {
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
    DateTime currentWeekStart = truncDate(
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
    DateTime lastWeekStart =
        truncDate(currentWeekStart.subtract(Duration(days: 7)));

    for (Employee employee in mypeople) {
      double currentYearHours = 0;
      double currentMonthHours = 0;
      double lastMonthHours = 0;
      double currentWeekHours = 0;
      double lastWeekHours = 0;
      // Calcular horas en el año actual, en el mes pasado, en el mes actual, en la semana pasada y en la semana actual
      double balanceYearsHours = 0;
      double balanceLastMonthHours = 0;
      double balanceCurrentMonthHours = 0;
      double balanceLastWeekHours = 0;
      double balanceCurrentWeekHours = 0;

      HolidaysConfig employeeCalendar =
          myPeopleCalendars[employee.email] ?? HolidaysConfig.getEmpty();
      DateTime currentDate = DateTime(DateTime.now().year, 1, 1);

      while (currentDate.isBefore(DateTime.now())) {
        Shift currentShift = employee.getShift(date: currentDate);
        if ((!onHolidays(employee.email, currentDate, acceptedOnly: true)) &&
            (employeeCalendar.isWorkingDay(currentDate)) &&
            (currentDate.isAfter(truncDate(employee.getAltaDate())))) {
          balanceYearsHours += currentShift.hours[currentDate.weekday - 1];
          if (currentDate.month == DateTime.now().month - 1) {
            balanceLastMonthHours +=
                currentShift.hours[currentDate.weekday - 1];
          }
          if (currentDate.month == DateTime.now().month) {
            balanceCurrentMonthHours +=
                currentShift.hours[currentDate.weekday - 1];
          }
          if (dateInRange(currentDate, lastWeekStart,
              currentWeekStart.subtract(Duration(seconds: 1)))) {
            balanceLastWeekHours += currentShift.hours[currentDate.weekday - 1];
          }

          if (dateInRange(
              currentDate,
              currentWeekStart,
              currentWeekStart
                  .add(Duration(days: 7))
                  .subtract(Duration(seconds: 1)))) {
            balanceCurrentWeekHours +=
                currentShift.hours[currentDate.weekday - 1];
          }
        }
        currentDate = currentDate.add(Duration(days: 1));
      }

      List<Workday> employeeWorkdays =
          myPeopleWorkdays.where((wd) => wd.userId == employee.email).toList();

      for (var workday in employeeWorkdays) {
        if (workday.startDate.year == DateTime.now().year) {
          currentYearHours += workday.hours();
        }
        if (workday.startDate.year == DateTime.now().year &&
            workday.startDate.month == DateTime.now().month) {
          currentMonthHours += workday.hours();
        }
        if (workday.startDate.year == lastMonthStart.year &&
            workday.startDate.month == lastMonthStart.month) {
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
      // currentYearHours = (currentYearHours / (40 * 52)) * 100.0;
      // currentMonthHours = (currentMonthHours / (40 * 4)) * 100.0;
      // lastMonthHours = (lastMonthHours / (40 * 4)) * 100.0;
      // currentWeekHours = (currentWeekHours / (40)) * 100.0;
      // lastWeekHours = (lastWeekHours / (40)) * 100.0;

      currentYearHours = currentYearHours - balanceYearsHours;
      currentMonthHours = currentMonthHours - balanceCurrentMonthHours;
      lastMonthHours = lastMonthHours - balanceLastMonthHours;
      currentWeekHours = currentWeekHours - balanceCurrentWeekHours;
      lastWeekHours = lastWeekHours - balanceLastWeekHours;

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
                        (item.value['currentYear']! < 0 ? '-' : '') +
                            toDuration(item.value['currentYear']!,
                                format: 'hm'),
                        style: normalText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        (item.value['lastMonth']! < 0 ? '-' : '') +
                            toDuration(item.value['lastMonth']!, format: 'hm'),
                        style: normalText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        (item.value['currentMonth']! < 0 ? '-' : '') +
                            toDuration(item.value['currentMonth']!,
                                format: 'hm'),
                        style: normalText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Expanded(
                    //   flex: 1,
                    //   child: Text(
                    //     (item.value['lastWeek']! < 0 ? '-' : '') +
                    //         toDuration(item.value['lastWeek']!, format: 'hm'),
                    //     style: normalText,
                    //     textAlign: TextAlign.right,
                    //   ),
                    // ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        (item.value['currentWeek']! < 0 ? '-' : '') +
                            toDuration(item.value['currentWeek']!,
                                format: 'hm'),
                        style: normalText,
                        textAlign: TextAlign.center,
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

    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(0),
            child: Column(children: [
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
                                  Icon(Icons.access_time, color: Colors.black),
                            )),
                          )),
                      Expanded(
                          flex: 8,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  )),
              ListTile(
                title: Row(
                  children: [
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
                          DateTime.now().year.toString(),
                          style: subTitleText,
                          textAlign: TextAlign.center,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          MonthsNamesES[DateTime.now().month - 2]
                              .substring(0, 3),
                          style: subTitleText,
                          textAlign: TextAlign.center,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          MonthsNamesES[DateTime.now().month - 1]
                              .substring(0, 3),
                          style: subTitleText,
                          textAlign: TextAlign.center,
                        )),
                    // Expanded(
                    //     flex: 1,
                    //     child: Text(
                    //       "Semana previa",
                    //       style: subTitleText,
                    //       textAlign: TextAlign.right,
                    //     )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          "Semana actual",
                          style: subTitleText,
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(2),
                              child: Column(
                                children: [
                                  listSummary,
                                ],
                              )))))
            ])));
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
                                            "Solicitud de permisos",
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
    // Remove duplicate from mypeople
    // mypeople = mypeople.toSet().toList();
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
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                        color: Colors.white,
                        elevation: 2,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "Personal a cargo: ${mypeople.map((e) => '${e.getFullName()} [${e.aka()}]').join(', ')}",
                              style: subTitleText,
                              textAlign: TextAlign.center,
                            ))))),
          ],
        ),
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
  }

  void workdayAction(dynamic context) {
    _workdayAction(context);
  }

  void _workdayAction(dynamic context) async {
    // Sort myWorkdays by startDate in descending order
    if (myWorkdays == null || myWorkdays!.isEmpty) {
      await loadMyWorkdays();
    }
    if (myWorkdays == null || myWorkdays!.isEmpty) {
      currentWorkday = Workday.getEmpty(email: user.email!, open: true);
      currentWorkday!.save();
      myWorkdays = [currentWorkday!];
    } else {
      myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));
      currentWorkday = myWorkdays!.first;

      if (currentWorkday!.open) {
        currentWorkday!.endDate = DateTime.now();
        currentWorkday!.open = false;
        currentWorkday!.save().then((value) {
          if (value != null) {
            myWorkdays![0] = value;
          }
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
          if (value != null) {
            myWorkdays!.insert(0, value);
          }
          if (mounted) {
            setState(() {
              myWorkdays = myWorkdays;
              contentWorkPanel = workTimePanel();
            });
          }
        });
      }
    }

    //loadMyWorkdays();
  }

  Widget workTimePanel() {
    myWorkdays ??= [];
    myWorkdays!.sort((a, b) => b.startDate.compareTo(a.startDate));

    currentWorkday = myWorkdays!.first;

    if (currentWorkday?.open == true) {
      workdayButton = actionButton(
          null, null, workdayAction, Icons.stop_circle_outlined, [],
          iconColor: dangerColor);
    } else {
      workdayButton = actionButton(
          null, null, workdayAction, Icons.play_circle_outline_sharp, [],
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
                                      [],
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
                  "${MonthsNamesES[date.month - 1]} ${date.year}",
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
    currentOrganization ??= _profileProvider.organization;
    currentEmployee ??= await Employee.byEmail(user.email!);
    myCalendar ??= await HolidaysConfig.byEmployee(currentEmployee!);

    ReportPDF reportPDF = ReportPDF();

    DateTime month = DateTime(DateTime.now().year, DateTime.now().month, 1);
    try {
      month = args['month'];
    } catch (e) {
      month = month;
    }

    List<Workday> workdays = [];
    workdays = await Workday.byUser(user.email!, month).catchError((e) {
      // dev.log("Error loading workdays: $e");
      return [] as List<Workday>;
    });

    DateTime checkDay = DateTime(month.year, month.month, 1);
    while (checkDay.month == month.month) {
      // check if there is any workday in that day
      if (!(workdays.any((w) => truncDate(w.startDate) == checkDay))) {
        // if not, add an empty workday
        workdays.add(Workday(
            id: '',
            userId: user.email!,
            open: false,
            startDate: DateTime(checkDay.year, checkDay.month, checkDay.day, 9),
            endDate: DateTime(checkDay.year, checkDay.month, checkDay.day, 9)));
      }
      checkDay = checkDay.add(const Duration(days: 1));
    }

    if (workdays.length > 200) {
      workdays = workdays.sublist(0, 200);
    }

    List<double> hoursInWeekEmployeeList = [];
    double hoursInWeekEmployee = 0.0;

    workdays.sort((a, b) => b.startDate.compareTo(a.startDate));
    workdays = workdays.reversed.toList();
    Map<String, double> hoursDict = {};
    Map<String, DateTime> inDict = {};
    Map<String, DateTime> outDict = {};
    double normalHoursTotal = 0.0;
    double extraHoursTotal = 0.0;
    Map<DateTime, double> hoursByDay = {};

    List<List<String>> fullRows = [];
    double balanceHours = 0.0;
    DateTime previousDate = truncDate(DateTime(1970, 1, 1));

    for (Workday workday in workdays) {
      try {
        Shift currentShift =
            currentEmployee!.getShift(date: workday.startDate)!;
        hoursInWeekEmployeeList = currentShift.hours;
      } catch (e) {
        hoursInWeekEmployeeList = [7.5, 7.5, 7.5, 7.5, 7.5, 0.0, 0.0];
        // dev.log("Error loading shift: $e");
      }
      hoursInWeekEmployee =
          hoursInWeekEmployeeList[workday.startDate.weekday - 1];

      if (hoursInWeekEmployee != 0) {
        if ((myCalendar!.isHoliday(truncDate(workday.startDate))) ||
            (onHolidays(currentEmployee!.email, workday.startDate,
                acceptedOnly: true))) {
          hoursInWeekEmployee = 0.0;
          if (onHolidays(currentEmployee!.email, workday.startDate,
              acceptedOnly: true)) {
            workday.id = 'FREE';
          }
        }
      }

      if (workday.startDate.month == month.month &&
          workday.startDate.year == month.year) {
        if (truncDate(workday.startDate) != previousDate) {
          balanceHours = balanceHours - hoursInWeekEmployee;
          previousDate = truncDate(workday.startDate);
        }
        balanceHours = balanceHours + workday.hours();
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

        DateTime keyDate = truncDate(workday.startDate);

        double normalHours = workday.hours();
        double extraHours = 0.0;

        if (hoursByDay.containsKey(keyDate)) {
          normalHours =
              min(workday.hours(), hoursInWeekEmployee - hoursByDay[keyDate]!);
        } else {
          hoursByDay[keyDate] = 0.0;
          normalHours = min(workday.hours(), hoursInWeekEmployee);
        }
        hoursByDay[keyDate] = hoursByDay[keyDate]! + normalHours;
        extraHours = workday.hours() - normalHours;
        normalHoursTotal += normalHours;
        extraHoursTotal += extraHours;

        if ((normalHours > 0) ||
            (extraHours > 0) ||
            (workday.id != '') ||
            (hoursInWeekEmployee > 0)) {
          fullRows.add([
            DateFormat('dd-MM-yyyy').format(workday.startDate),
            (workday.id != '')
                ? (workday.id == 'FREE')
                    ? 'PERMISO'
                    : DateFormat('HH:mm').format(workday.startDate)
                : '-',
            (workday.id != '')
                ? (workday.id == 'FREE')
                    ? 'PERMISO'
                    : DateFormat('HH:mm').format(workday.endDate)
                : '-',
            toDuration(normalHours, format: 'hm'),
            toDuration(extraHours, format: 'hm'),
            if (balanceHours >= 0)
              toDuration(balanceHours, format: 'hm')
            else
              '-${toDuration(-balanceHours, format: 'hm')}'
          ]);
        }
      }
    }

    // Crea un nuevo documento PDF
    pw.TextStyle headerPdf = pw.TextStyle(
        fontSize: 8,
        color: PdfColors.black,
        fontWeight: pw.FontWeight.bold,
        background: pw.BoxDecoration(color: PdfColors.grey300));
    pw.TextStyle normalPdf =
        const pw.TextStyle(fontSize: 8, color: PdfColors.black);

    List<pw.TableRow> rows = [];

    List<String> keysSorted = hoursDict.keys.toList();
    keysSorted.sort((a, b) => a.compareTo(b));

    final pdf = pw.Document();
    const pdfFormat = PdfPageFormat.a4;

    for (var row in fullRows) {
      rows.add(reportPDF.getRow(row,
          styles: [normalPdf],
          padding: const pw.EdgeInsets.all(5),
          height: 20,
          aligns: [
            pw.TextAlign.center,
            pw.TextAlign.center,
            pw.TextAlign.center,
            pw.TextAlign.center,
            pw.TextAlign.center
          ]));
    }

    List<pw.Widget> tables = [];
    int rowsPerPage = 25;
    int currentPage = 0;
    for (int i = 0; i < rows.length; i += rowsPerPage) {
      int end = (i + rowsPerPage < rows.length) ? i + rowsPerPage : rows.length;
      List<pw.TableRow> pageRows = rows.sublist(i, end);
      tables.add(pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FlexColumnWidth(0.16),
          1: pw.FlexColumnWidth(0.13),
          2: pw.FlexColumnWidth(0.11),
          3: pw.FlexColumnWidth(0.2),
          4: pw.FlexColumnWidth(0.2),
          5: pw.FlexColumnWidth(0.2),
        },
        children: [
          reportPDF.getRow([
            "FECHA",
            "ENTRADA",
            "SALIDA",
            "HORAS ORDINARIAS",
            "HORAS EXTRA\nCOMPLEMENTARIAS",
            "BALANCE DE HORAS"
          ], aligns: [
            pw.TextAlign.center,
            pw.TextAlign.center,
            pw.TextAlign.center,
            pw.TextAlign.center,
            pw.TextAlign.center
          ], styles: [
            headerPdf
          ], height: 30),
          ...pageRows,
        ],
      ));
      currentPage = currentPage + 1;
    }

    // Añade una cabecera al documento
    pdf.addPage(pw.MultiPage(
        pageFormat: pdfFormat,
        //margin: const pw.EdgeInsets.all(5),
        header: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              children: [
                pw.Text(
                  "Listado Resumen mensual del registro de jornada (detalle horario)",
                  style: headerPdf.copyWith(
                      background: pw.BoxDecoration(color: PdfColors.white)),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.SizedBox(height: 5),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(0.5),
                    1: pw.FlexColumnWidth(0.5),
                  },
                  children: [
                    reportPDF.getRow([
                      'Empresa : ${(currentOrganization!.billingName.isNotEmpty) ? currentOrganization!.billingName : currentOrganization!.name}',
                      'Trabajador : ${currentEmployee!.getFullName()}'
                    ], styles: [
                      normalPdf
                    ], height: 20),
                    reportPDF.getRow([
                      'C.I.F.:   ${currentOrganization?.cif ?? ''}',
                      'N.I.F.:  ${currentEmployee!.code}'
                    ], styles: [
                      normalPdf
                    ], height: 20),
                    reportPDF.getRow([
                      'Centro de Trabajo : ${currentEmployee!.workplace.name}',
                      'Mes y año : ${MonthsNamesES[month.month - 1]} / ${month.year}'
                    ], styles: [
                      normalPdf
                    ], height: 20),
                  ],
                ),
                pw.SizedBox(height: 5),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Column(children: [
            pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text('Firma del trabajador',
                    style: const pw.TextStyle(fontSize: 9))),
            pw.SizedBox(height: 40),
            pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text('________________________________',
                    style: const pw.TextStyle(fontSize: 9))),
            pw.SizedBox(height: 10),
            pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                    'Página ${context.pageNumber} de ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 9))),
          ]);
        },
        build: (pw.Context context) {
          return [
            pw.Container(
              child: pw.Column(
                children: [
                  ...tables,
                  pw.SizedBox(height: 5),
                  pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: pw.FlexColumnWidth(0.4),
                        1: pw.FlexColumnWidth(0.2),
                        2: pw.FlexColumnWidth(0.2),
                        3: pw.FlexColumnWidth(0.2),
                      },
                      defaultVerticalAlignment:
                          pw.TableCellVerticalAlignment.middle,
                      children: [
                        pw.TableRow(
                            children: [
                              reportPDF.getCell("TOTAL HORAS",
                                  style: headerPdf, align: pw.TextAlign.center),
                              reportPDF.getCell(
                                  toDuration(normalHoursTotal, format: 'hm'),
                                  style: normalPdf,
                                  align: pw.TextAlign.center),
                              reportPDF.getCell(
                                  toDuration(extraHoursTotal, format: 'hm'),
                                  style: normalPdf,
                                  align: pw.TextAlign.center),
                              reportPDF.getCell(
                                  (balanceHours >= 0)
                                      ? toDuration(balanceHours, format: 'hm')
                                      : '-${toDuration(-balanceHours, format: 'hm')}',
                                  style: normalPdf,
                                  align: pw.TextAlign.center),
                            ],
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey300,
                            )),
                      ]),
                  pw.SizedBox(height: 5),
                ],
              ),
            )
          ];
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

  Future<void> _dialogPrintWorkday(List<dynamic>? args) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
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
        holidayDays -= getWorkingDaysBetween(
            holiday.startDate, holiday.endDate, myCalendar);
        if (remainingHolidays
            .containsKey(holiday.getCategory(holCat ?? []).autoCode())) {
          remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()] =
              remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()]! -
                  getWorkingDaysBetween(
                      holiday.startDate, holiday.endDate, myCalendar);
        } else {
          remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()] =
              (holiday.getCategory(holCat ?? []).retroactive)
                  ? (holiday.getCategory(holCat ?? []).days * factor).round()
                  : holiday.getCategory(holCat ?? []).days;
          remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()] =
              remainingHolidays[holiday.getCategory(holCat ?? []).autoCode()]! -
                  getWorkingDaysBetween(
                      holiday.startDate, holiday.endDate, myCalendar);
        }
      }
    }
  }

  void addHolidayRequestDialog(context) async {
    currentHoliday = await _addHolidayRequestDialog(context);
    if (currentHoliday == null) {
      return;
    }

    // Check if the new holiday request is already in myHolidays
    int index =
        myHolidays!.indexWhere((holiday) => holiday.id == currentHoliday!.id);
    if (index >= 0) {
      // Update existing holiday request
      myHolidays![index] = currentHoliday!;
    } else {
      // Add new holiday request
      myHolidays!.add(currentHoliday!);
    }
    // updateRemainingHolidays();

    if (mounted) {
      setState(() {
        myHolidays = myHolidays;
        updateRemainingHolidays();
        // updateHolidayDays().then((value) => holidayDays = value);
      });
    }
  }

  Future<HolidayRequest?> _addHolidayRequestDialog(context) async {
    String currentHolidayId = '';

    currentHoliday = HolidayRequest.getEmpty();
    currentHoliday!.userId = user.email!;

    HolidayRequest? item = await showDialog<HolidayRequest>(
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
              calendar: myCalendar!,
              remainingHolidays: remainingHolidays,
              granted: myHolidays!
                  .where((element) =>
                      (element.status.toLowerCase() == "aprobado" ||
                          element.status.toLowerCase() == "concedido"))
                  .toList()),
        );
      },
    );

    if (item != null) {
      // Check if the new holiday request is already in myHolidays
      if (item.id == "--remove--") {
        myHolidays!.removeWhere((holiday) => holiday.id == currentHolidayId);
        currentHoliday = null;
      } else {
        int index = myHolidays!.indexWhere((holiday) => holiday.id == item.id);
        if (index != -1) {
          myHolidays![index] = item; // Update existing request
        } else {
          myHolidays!.add(item); // Add new request
        }
      }
      updateRemainingHolidays();
      if (mounted) {
        setState(() {
          myHolidays = myHolidays;
          contentHolidaysPanel = holidayPanel();
        });
      }
    }
    return item;
  }

  Future<HolidayRequest?> _editHolidayRequestDialog(int index) async {
    currentHoliday = myHolidays!.elementAt(index);
    String currentHolidayId = currentHoliday!.id;
    HolidayRequest? item = await showDialog<HolidayRequest>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context2) {
        HolidayRequest holiday = myHolidays!.elementAt(index);
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Editar solicitud de días libres', context),
          content: HolidayRequestForm(
              key: null,
              currentRequest: holiday,
              user: user,
              profile: profile!,
              categories: holCat!,
              remainingHolidays: remainingHolidays,
              calendar: myCalendar!,
              granted: myHolidays!
                  .where((element) =>
                      (element.status.toLowerCase() == "aprobado" ||
                          element.status.toLowerCase() == "concedido"))
                  .toList()),
        );
      },
    );
    if (item != null) {
      if (item.id == "--remove--") {
        myHolidays!.removeWhere((test) => test.id == currentHolidayId);
        currentHoliday = null;
      } else {
        // If the item is the same as the current holiday, update it
        myHolidays![index] = item;
      }
      if (mounted) {
        updateRemainingHolidays();

        setState(() {
          myHolidays = myHolidays;
          contentHolidaysPanel = holidayPanel();
        });
      }
    }
    return item;
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
                  categories: holCat!,
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

  Widget holidayRows(context) {
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
                        child: ListTile(
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
                                            holiday.getCategory(holCat!).name,
                                            style: normalText,
                                          )),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
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
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        getWorkingDaysBetween(holiday.startDate,
                                                holiday.endDate, myCalendar)
                                            .toString(),
                                        style: normalText,
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Card(
                                          color: holidayStatusColors[
                                              holiday.status.toLowerCase()]!,
                                          child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                holiday.status
                                                    .substring(0, 3)
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                textAlign: TextAlign.center,
                                              )))),
                                ),
                              ],
                            )
                          ]),
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (holiday.status.toLowerCase() == 'pendiente') {
                                _editHolidayRequestDialog(index);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return infoDialog(
                                        context,
                                        Icon(Icons.info),
                                        "Solicitud de ${holiday.getCategory(holCat!).name}",
                                        "Esta solicitud ya ha sido aprobada o denegada. No se puede editar.",
                                      );
                                    });
                              }
                            });
                          },
                        )),
                    Expanded(
                        flex: 2,
                        child: (mounted)
                            ? btnDocuments(context, holiday)
                            : Container()),
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
                                            "Solicitud de permisos",
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
                mounted ? holidayRows(context) : Container(),
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
