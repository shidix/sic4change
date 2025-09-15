import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';

class ProjectsProvider with ChangeNotifier {
  bool _initialized = false;
  late final Key key;

  Profile? _profile;
  User? user = FirebaseAuth.instance.currentUser;
  // bool _loading = false;
  List<SProject> _projects = [];
  List<Ambit> _ambits = [];
  List<ProjectType> _projectTypes = [];
  List<Contact> _contacts = [];
  List<Country> _countries = [];
  List<Programme> _programmes = [];
  List<Organization> _organizations = [];
  List<ProjectDates> _projectDates = [];
  List<ProjectStatus> _projectStatuses = [];
  List<ProjectLocation> _locations = [];
  List<Folder> _folders = [];
  List<STask> _tasks = [];
  List<TasksStatus> _taskStatuses = [];
  List<Profile> _profiles = [];

  final Queue<bool> _isLoading = Queue();

  void sendNotify() {
    notifyListeners();
  }

  // Organization? get organization => _organization;
  // set organization(Organization? value) {
  //   _organization = value;
  //   sendNotify();
  // }

  List<Region> get regions => _regions;
  set regions(List<Region> value) {
    _regions = value;
    sendNotify();
  }

  List<Province> get provinces => _provinces;
  set provinces(List<Province> value) {
    _provinces = value;
    sendNotify();
  }

  List<Town> get towns => _towns;
  set towns(List<Town> value) {
    _towns = value;
    sendNotify();
  }

  List<ProjectLocation> get locations => _locations;
  set locations(List<ProjectLocation> value) {
    _locations = value;
    sendNotify();
  }

  Profile? get profile => _profile;
  set profile(Profile? value) {
    _profile = value;
    sendNotify();
  }

  List<SProject> get projects => _projects;
  set projects(List<SProject> value) {
    _projects = value;
    sendNotify();
  }

  List<Contact> get contacts => _contacts;
  set contacts(List<Contact> value) {
    _contacts = value;
    sendNotify();
  }

  void addProject(SProject project) {
    _projects.add(project);
    sendNotify();
  }

  void removeProject(SProject project) {
    _projects.remove(project);
    sendNotify();
  }

  List<STask> get tasks => _tasks;
  set tasks(List<STask> value) {
    _tasks = value;
    sendNotify();
  }

  List<TasksStatus> get taskStatuses => _taskStatuses;
  set taskStatuses(List<TasksStatus> value) {
    _taskStatuses = value;
    sendNotify();
  }

  List<Profile> get profiles => _profiles;
  set profiles(List<Profile> value) {
    _profiles = value;
    sendNotify();
  }

  List<Programme> get programmes => _programmes;
  set programmes(List<Programme> value) {
    _programmes = value;
    sendNotify();
  }

  void addProfile(Profile? profile) {
    if (profile == null) return;
    int index = _profiles.indexWhere((element) => element.id == profile.id);
    if (index != -1) {
      _profiles[index] = profile;
    } else {
      _profiles.add(profile);
    }
    sendNotify();
  }

  void removeProfile(Profile? profile) {
    if (profile == null) return;
    if (!_profiles.any((element) => element.id == profile.id)) return;
    _profiles.remove(profile);
    sendNotify();
  }

  void loadProfiles(User user) async {
    isLoading = true;
    _profiles =
        await Profile.byOrganization(organization: _profile!.organization);
    isLoading = false;
    sendNotify();
  }

  void addTask(STask? task, {bool notify = true}) {
    if (task == null) return;
    _isLoading.add(true);
    int index = _tasks.indexWhere((element) => element.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  void removeTask(STask? task) {
    if (task == null) return;
    if (!_tasks.any((element) => element.id == task.id)) return;
    _isLoading.add(true);
    _tasks.remove(task);
    _isLoading.removeFirst();
    sendNotify();
  }

  void addProgramme(Programme? programme) {
    if (programme == null) return;
    _isLoading.add(true);
    int index = _programmes.indexWhere((element) => element.id == programme.id);
    if (index != -1) {
      _programmes[index] = programme;
    } else {
      _programmes.add(programme);
    }
    _isLoading.removeFirst();
    sendNotify();
  }

  void removeProgramme(Programme? programme) {
    if (programme == null) return;
    if (!_programmes.any((element) => element.id == programme.id)) return;
    _isLoading.add(true);
    _programmes.remove(programme);
    _isLoading.removeFirst();
    sendNotify();
  }

  Future<void> loadProjects({bool notify = false}) async {
    _isLoading.add(true);
    await Future.wait(
      [
        loadAmbits(),
        loadProjectTypes(),
        loadContacts(),
        loadCountries(),
        loadProgrammes(),
        loadOrganizations(),
        loadProjectDates(),
        loadProjectStatus(),
        loadProjectLocation(),
        loadFolders(),
        loadProvinces(),
        loadRegions(),
        loadTowns(),
      ],
    );
    _projects = await SProject.getProjects();
    for (var project in _projects) {
      // check and assign related objects
      if (_ambits.any((element) => element.uuid == project.ambit)) {
        project.ambitObj =
            _ambits.firstWhere((element) => element.uuid == project.ambit);
      }
      // typeObj
      if (_projectTypes.any((element) => element.uuid == project.type)) {
        project.typeObj =
            _projectTypes.firstWhere((element) => element.uuid == project.type);
      }
      // managerObj
      if (_contacts.any((element) => element.uuid == project.manager)) {
        project.managerObj =
            _contacts.firstWhere((element) => element.uuid == project.manager);
      }
      // programmeObj
      if (_programmes.any((element) => element.uuid == project.programme)) {
        project.programmeObj = _programmes
            .firstWhere((element) => element.uuid == project.programme);
      }
      // financiersObj
      project.financiersObj = _organizations
          .where((element) => project.financiers.contains(element.uuid))
          .toList();
      // partnersObj
      project.partnersObj = _organizations
          .where((element) => project.partners.contains(element.uuid))
          .toList();
      // datesObj
      if (_projectDates.any((element) => element.project == project.uuid)) {
        project.datesObj = _projectDates
            .firstWhere((element) => element.project == project.uuid);
      }
      // statusObj
      if (_projectStatuses.any((element) => element.uuid == project.status)) {
        project.statusObj = _projectStatuses
            .firstWhere((element) => element.uuid == project.status);
      }
      // locationObj
      if (_locations.any((element) => element.project == project.uuid)) {
        project.locationObj =
            _locations.firstWhere((element) => element.project == project.uuid);
        project.locationObj.countryObj = _countries.firstWhere(
            (element) => element.uuid == project.locationObj.country,
            orElse: () => Country("Unknown"));
      }
      // Check if folder exists
      if (!_folders.any((element) => element.uuid == project.folder)) {
        project.folder = "";
      } else {
        project.folderObj =
            _folders.firstWhere((element) => element.uuid == project.folder);
      }
    }
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadAmbits({bool notify = false}) async {
    _isLoading.add(true);
    _ambits = await Ambit.getAmbits();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadProjectTypes({bool notify = false}) async {
    _isLoading.add(true);
    _projectTypes = await ProjectType.getProjectTypes();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadContacts({bool notify = false}) async {
    _isLoading.add(true);
    _contacts = await Contact.getContacts();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadCountries({bool notify = false}) async {
    _isLoading.add(true);
    _countries = await Country.getCountries() as List<Country>;
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadProgrammes({bool notify = false}) async {
    _isLoading.add(true);
    _programmes = await Programme.getProgrammes();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadOrganizations({bool notify = false}) async {
    _isLoading.add(true);
    _organizations = await Organization.getOrganizations();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadProjectDates({bool notify = false}) async {
    _isLoading.add(true);
    _projectDates = await ProjectDates.getProjectDates();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadProjectStatus({bool notify = false}) async {
    _isLoading.add(true);
    _projectStatuses = await ProjectStatus.getProjectStatus();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadProjectLocation({bool notify = false}) async {
    _isLoading.add(true);
    _locations = await ProjectLocation.getProjectLocation();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadFolders({bool notify = false}) async {
    _isLoading.add(true);
    _folders = await Folder.getFolders("");
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  Future<void> loadTasks({bool notify = false}) async {
    _isLoading.add(true);
    await loadTaskStatuses();
    _tasks = await STask.getTasks() as List<STask>;
    for (var task in _tasks) {
      // statusObj
      if (_taskStatuses.any((element) => element.uuid == task.status)) {
        task.statusObj =
            _taskStatuses.firstWhere((element) => element.uuid == task.status);
      }
      if (_profiles.any((element) => element.email == task.sender)) {
        task.senderObj =
            _profiles.firstWhere((element) => element.email == task.sender);
      }
      // projectObj
      if (_projects.any((element) => element.uuid == task.project)) {
        task.projectObj =
            _projects.firstWhere((element) => element.uuid == task.project);
      }
      // assignedObj is List
      task.assignedObj = _profiles
          .where((element) => task.assigned.contains(element.email))
          .toList();
      // receiversObj is List
      task.receiversObj = _contacts
          .where((element) => task.receivers.contains(element.email))
          .toList();
      // receiversOrgObj is List
      task.receiversOrgObj = _organizations
          .where((element) => task.receiversOrg.contains(element.uuid))
          .toList();
      // programmeObj is Programme
      if (_programmes.any((element) => element.uuid == task.programme)) {
        task.programmeObj =
            _programmes.firstWhere((element) => element.uuid == task.programme);
      }
    }
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  void reloadTaskInfo(STask? task, {bool notify = false}) {
    if (task == null) return;
    // statusObj
    if (_taskStatuses.any((element) => element.uuid == task.status)) {
      task.statusObj =
          _taskStatuses.firstWhere((element) => element.uuid == task.status);
    }
    if (_profiles.any((element) => element.email == task.sender)) {
      task.senderObj =
          _profiles.firstWhere((element) => element.email == task.sender);
    }
    // projectObj
    if (_projects.any((element) => element.uuid == task.project)) {
      task.projectObj =
          _projects.firstWhere((element) => element.uuid == task.project);
    }
    // assignedObj is List
    task.assignedObj = _profiles
        .where((element) => task.assigned.contains(element.email))
        .toList();
    // receiversObj is List
    task.receiversObj = _contacts
        .where((element) => task.receivers.contains(element.email))
        .toList();
    // receiversOrgObj is List
    task.receiversOrgObj = _organizations
        .where((element) => task.receiversOrg.contains(element.uuid))
        .toList();
    // programmeObj is Programme
    if (_programmes.any((element) => element.uuid == task.programme)) {
      task.programmeObj =
          _programmes.firstWhere((element) => element.uuid == task.programme);
    }
    addTask(task, notify: notify);
  }

  Future<void> loadTaskStatuses({bool notify = false}) async {
    _isLoading.add(true);
    _taskStatuses = await TasksStatus.getTasksStatus();
    _isLoading.removeFirst();
    if (notify) sendNotify();
  }

  void initialize() async {
    if (_isLoading.isNotEmpty) return;
    _isLoading.add(true);
    if (_initialized) return;
    if (user == null) return;
    profile = await Profile.byEmail(user!.email!);
    await loadProjects();
    await loadTasks();
    _isLoading.removeFirst();
    sendNotify();
    _initialized = true;
  }

  ProjectsProvider() {
    key = UniqueKey();
    initialize();
  }
}
