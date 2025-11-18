import 'dart:collection';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/models_workday.dart';

class RRHHProvider with ChangeNotifier {
  late final Key key;
  User? user = FirebaseAuth.instance.currentUser;
  bool initialized = false;
  Profile? _profile;
  Organization? _organization;
  Contact? _contact;
  Employee? _employee;
  List<Employee> _employees = [];
  List<Organization> _organizations = [];
  List<HolidaysCategory> _holidaysCategories = [];
  List<HolidayRequest> _holidaysRequests = [];
  List<HolidaysConfig> _calendars = [];
  List<Workday> _workdays = [];
  List<Department> _departments = [];
  List<SNotification> _notifications = [];
  // List<STask> _tasks = [];
  Map<String, DateTime> updateAt = {};

  Profile? get profile => _profile;
  Organization? get organization => _organization;
  Employee? get employee => _employee;
  Contact? get contact => _contact;
  List<Employee> get employees => _employees;
  List<Organization> get organizations => _organizations;
  List<HolidaysCategory> get holidaysCategories => _holidaysCategories;

  List<HolidayRequest> get holidaysRequests {
    DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    if (updateAt.containsKey('holidaysRequests')) {
      lastUpdate = updateAt['holidaysRequests']!;
    }
    // Return holidaysRequests if lastUpdate is less than 5 minutes ago
    if (DateTime.now().difference(lastUpdate).inMinutes > 60) {
      loadHolidaysRequests(notify: true, fromServer: true);
    }
    return _holidaysRequests;
  }

  List<HolidaysConfig> get calendars => _calendars;
  List<Workday> get workdays => _workdays;
  List<Department> get departments => _departments;
  // List<STask> get tasks => _tasks;

  Queue<bool> isLoading = Queue();

  set profile(Profile? value) {
    _profile = value;
    sendNotify();
  }

  set organization(Organization? value) {
    _organization = value;
    sendNotify();
  }

  set employee(Employee? value) {
    _employee = value;
    sendNotify();
  }

  set employees(List<Employee> value) {
    _employees = value;
    sendNotify();
  }

  set organizations(List<Organization> value) {
    _organizations = value;
    sendNotify();
  }

  set holidaysCategories(List<HolidaysCategory> value) {
    _holidaysCategories = value;
    sendNotify();
  }

  set holidaysRequests(List<HolidayRequest> value) {
    _holidaysRequests = value;
    sendNotify();
  }

  set calendars(List<HolidaysConfig> value) {
    _calendars = value;
    sendNotify();
  }

  set workdays(List<Workday> value) {
    _workdays = value;
    sendNotify();
  }

  set departments(List<Department> value) {
    _departments = value;
    sendNotify();
  }

  set contact(Contact? value) {
    _contact = value;
    sendNotify();
  }

  // set tasks(List<STask> value) {
  //   _tasks = value;
  //   sendNotify();
  // }

  void addEmployee(Employee employee) {
    int index = _employees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      _employees[index] = employee;
    } else {
      _employees.add(employee);
    }

    sendNotify();
  }

  void removeEmployee(Employee employee) {
    if (_employees.any((element) => element.id == employee.id)) {
      _employees.removeWhere((element) => element.id == employee.id);
      sendNotify();
    }
  }

  void addHolidaysRequest(HolidayRequest request) {
    int index = _holidaysRequests.indexWhere((e) => e.id == request.id);
    if (index != -1) {
      _holidaysRequests[index] = request;
    } else {
      _holidaysRequests.add(request);
    }
    _holidaysRequests.sort((a, b) => b.startDate.compareTo(a.startDate));

    sendNotify();
  }

  void removeHolidaysRequest(HolidayRequest request) {
    if (_holidaysRequests.any((element) => element.id == request.id)) {
      _holidaysRequests.removeWhere((element) => element.id == request.id);
      notifyListeners();
    }
  }

  void addWorkday(Workday workday) {
    int index = _workdays.indexWhere((e) => e.id == workday.id);
    if (index != -1) {
      _workdays[index] = workday;
    } else {
      _workdays.add(workday);
    }
    _workdays.sort((a, b) => b.startDate.compareTo(a.startDate));

    sendNotify();
  }

  void removeWorkday(Workday workday) {
    if (_workdays.any((element) => element.id == workday.id)) {
      _workdays.removeWhere((element) => element.id == workday.id);
      sendNotify();
    }
  }

  void addCalendar(HolidaysConfig calendar) {
    int index = _calendars.indexWhere((e) => e.id == calendar.id);
    if (index != -1) {
      _calendars[index] = calendar;
    } else {
      _calendars.add(calendar);
    }
    sendNotify();
  }

  void removeCalendar(HolidaysConfig calendar) {
    if (_calendars.any((element) => element.id == calendar.id)) {
      _calendars.removeWhere((element) => element.id == calendar.id);
      sendNotify();
    }
  }

  void addHolidaysCategory(HolidaysCategory category) {
    int index = _holidaysCategories.indexWhere((e) => e.id == category.id);
    if (index != -1) {
      _holidaysCategories[index] = category;
    } else {
      _holidaysCategories.add(category);
    }
    sendNotify();
  }

  void removeHolidaysCategory(HolidaysCategory category) {
    if (_holidaysCategories.any((element) => element.id == category.id)) {
      _holidaysCategories.removeWhere((element) => element.id == category.id);
      sendNotify();
    }
  }

  void addOrganization(Organization organization) {
    int index = _organizations.indexWhere((e) => e.id == organization.id);
    if (index != -1) {
      _organizations[index] = organization;
    } else {
      _organizations.add(organization);
    }
    sendNotify();
  }

  void removeOrganization(Organization organization) {
    if (_organizations.any((element) => element.id == organization.id)) {
      _organizations.removeWhere((element) => element.id == organization.id);
      sendNotify();
    }
  }

  void addDepartment(Department department) {
    int index = _departments.indexWhere((e) => e.id == department.id);
    if (index != -1) {
      _departments[index] = department;
    } else {
      _departments.add(department);
    }
    sendNotify();
  }

  void removeDepartment(Department department) {
    if (_departments.any((element) => element.id == department.id)) {
      _departments.removeWhere((element) => element.id == department.id);
      sendNotify();
    }
  }

  // void addTask(STask? task) {
  //   if (task == null) return;

  //   int index = _tasks.indexWhere((e) => e.id == task.id);
  //   if (index != -1) {
  //     _tasks[index] = task;
  //   } else {
  //     _tasks.add(task);
  //   }
  //   sendNotify();
  // }

  // void removeTask(STask? task) {
  //   if (task == null) return;
  //   if (!_tasks.any((e) => e.id == task.id)) return;
  //   _tasks.removeWhere((e) => e.id == task.id);
  //   sendNotify();
  // }

  Future<void> loadDepartments({bool notify = true}) async {
    if (_organization != null) {
      isLoading.add(true);
      _departments = await Department.byOrganization(_organization!.id);
      isLoading.removeFirst();
      if (notify && isLoading.isEmpty) {
        sendNotify();
      }
    }
  }

  Future<void> loadOrganizations({bool notify = true}) async {
    isLoading.add(true);
    _organizations = await Organization.getOrganizations();
    // Remove organizations with organization != _organization.id
    // Extract one element from isLoading (queue)
    isLoading.removeFirst();
    if (notify && isLoading.isEmpty) {
      sendNotify();
    }
  }

  Future<void> loadEmployees(
      {bool includeInactive = true, bool notify = true}) async {
    if (_organization != null) {
      isLoading.add(true);
      _employees = await Employee.getEmployees(
          organization: _organization!.id, includeInactive: includeInactive);
      isLoading.removeFirst();
      if (notify && isLoading.isEmpty) {
        sendNotify();
      }
    }
  }

  Future<void> loadHolidaysCategories({bool notify = true}) async {
    if (_organization != null) {
      isLoading.add(true);
      _holidaysCategories =
          await HolidaysCategory.byOrganization(_organization!.uuid);
      // Sort by year, then by name
      _holidaysCategories.sort((a, b) {
        int yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) {
          return yearCompare;
        } else {
          return a.name.compareTo(b.name);
        }
      });
      isLoading.removeFirst();
      if (notify && isLoading.isEmpty) {
        sendNotify();
      }
    }
  }

  Future<void> loadHolidaysRequests(
      {DateTime? startDate,
      DateTime? endDate,
      bool notify = true,
      bool fromServer = false}) async {
    if (_organization != null) {
      isLoading.add(true);
      List<String> emailsEmployees =
          _employees.map((e) => e.email).toList(growable: false);
      _holidaysRequests = await HolidayRequest.byUser(
          emailsEmployees, startDate, endDate, fromServer);
      _holidaysRequests.sort((a, b) => b.startDate.compareTo(a.startDate));
      isLoading.removeFirst();
      if (fromServer) {
        updateAt['holidaysRequests'] = DateTime.now();
      }
      if (notify && isLoading.isEmpty) {
        notifyListeners();
      }
    }
  }

  Future<void> loadCalendars({bool notify = true}) async {
    if (_organization != null) {
      isLoading.add(true);
      _calendars = await HolidaysConfig.byOrganization(_organization!.id);
      isLoading.removeFirst();
      if (notify && isLoading.isEmpty) {
        sendNotify();
      }
    }
  }

  Future<void> loadWorkdays(
      {DateTime? fromDate, List<String>? userEmail, bool notify = true}) async {
    if (_organization != null) {
      isLoading.add(true);
      List<String> emailsEmployees = (userEmail != null)
          ? userEmail
          : _employees.map((e) => e.email).toList(growable: false);
      _workdays = await Workday.byUser(emailsEmployees, fromDate);
      _workdays.sort((a, b) => b.startDate.compareTo(a.startDate));
      isLoading.removeFirst();
      if (notify && isLoading.isEmpty) {
        sendNotify();
      }
    }
  }

  // Future<void> loadTasks({bool notify = true}) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;
  //   isLoading.add(true);
  //   _tasks = await STask.getByAssigned(user.email, lazy: true);
  //   isLoading.removeFirst();
  //   if (notify && isLoading.isEmpty) {
  //     sendNotify();
  //   }
  // }

  List<SNotification> get notifications {
    DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    if (updateAt.containsKey('notifications')) {
      lastUpdate = updateAt['notifications']!;
    }
    // Return notifications if lastUpdate is less than 5 minutes ago
    if (DateTime.now().difference(lastUpdate).inMinutes > 15) {
      loadNotifications(notify: true);
      updateAt['notifications'] = DateTime.now();
    }
    return _notifications;
  }

  set notifications(List<SNotification> value) {
    _notifications = value;
    sendNotify();
  }

  Future<void> addNotifications(SNotification? item) async {
    if (item == null) return;
    int index = _notifications.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _notifications[index] = item;
    } else {
      _notifications.add(item);
    }
    sendNotify();
  }

  Future<void> removeNotifications(SNotification? item) async {
    if (item == null) return;
    if (!_notifications.any((e) => e.id == item.id)) return;
    _notifications.removeWhere((e) => e.id == item.id);
    sendNotify();
  }

  Future<void> loadNotifications({bool notify = true}) async {
    // final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    isLoading.add(true);
    _notifications = await SNotification.getNotificationsByReceiver(user?.email)
        as List<SNotification>;
    isLoading.removeFirst();
    if (notify && isLoading.isEmpty) {
      sendNotify();
    }
  }

  void clear() {
    _profile = null;
    _organization = null;
    _employee = null;
    _employees = [];
    _organizations = [];
    _holidaysCategories = [];
    _holidaysRequests = [];
    _calendars = [];
    _workdays = [];
    _departments = [];
    _notifications = [];
    // _tasks = [];
    initialized = false;
    isLoading.clear();
    // sendNotify();
  }

  void sendNotify() {
    if (isLoading.isEmpty) {
      notifyListeners();
    }
  }

  void status() {
    dev.log("----- RRHHProvider Status -----");
    dev.log("Profile: ${_profile?.email}");
    dev.log("Organization: ${_organization?.name}");
    dev.log("Employee: ${_employee?.getFullName()}");
    dev.log("Employees: ${_employees.length}");
    dev.log("Organizations: ${_organizations.length}");
    dev.log("Holidays Categories: ${_holidaysCategories.length}");
    dev.log("Holidays Requests: ${_holidaysRequests.length}");
    dev.log("Calendars: ${_calendars.length}");
    dev.log("Workdays: ${_workdays.length}");
  }

  void initialize() {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (user != null && !initialized && isLoading.isEmpty) {
      Employee.byEmail(user!.email!).then((value) {
        _employee = value;
      });
      Contact.byEmail(user!.email!).then((value) {
        _contact = value;
      });
      Profile.getProfile(user!.email!).then((profile) {
        if (profile.id.isNotEmpty) {
          _profile = profile;
          if (profile.organization != null &&
              profile.organization!.isNotEmpty) {
            Organization.byId(profile.organization!).then((organization) {
              _organization = organization;
              loadOrganizations(notify: true);
              loadEmployees(notify: true).then((value) {
                loadHolidaysRequests(
                    startDate:
                        DateTime.now().subtract(const Duration(days: 770)),
                    endDate: DateTime.now().add(const Duration(days: 770)),
                    notify: true,
                    fromServer: true);
                List<String>? emailToFind =
                    (profile.isRRHH()) ? null : [user!.email!];
                loadWorkdays(
                    fromDate: DateTime.now().subtract(const Duration(days: 40)),
                    userEmail: emailToFind,
                    notify: true);
              });
              loadHolidaysCategories(notify: true);
              loadCalendars(notify: true);
              loadDepartments(notify: true);
              loadNotifications(notify: true);
              // loadTasks(notify: true);
              initialized = true;
              sendNotify();
            });
          }
        }
      });
    }
  }

  RRHHProvider() {
    key = UniqueKey();
    initialize();
  }
}
