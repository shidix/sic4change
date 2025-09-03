import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/models_profile.dart';

class ProjectsProvider with ChangeNotifier {
  Profile? _profile;
  Organization? _organization;
  User? user = FirebaseAuth.instance.currentUser;
  bool _loading = false;
  List<SProject> _projects = [];
  List<Ambit> _ambits = [];
  List<ProjectType> _projectTypes = [];
  List<Contact> _contacts = [];
  List<Country> _countries = [];
  List<Programme> _programmes = [];
  List<Organization> _organizations = [];
  List<ProjectDates> _projectDates = [];
  List<ProjectStatus> _projectStatuses = [];
  List<ProjectLocation> _projectLocations = [];
  List<Folder> _folders = [];

  Organization? get organization => _organization;
  set organization(Organization? value) {
    _organization = value;
    notifyListeners();
  }

  Profile? get profile => _profile;
  set profile(Profile? value) {
    _profile = value;
    notifyListeners();
  }

  List<SProject> get projects => _projects;
  set projects(List<SProject> value) {
    _projects = value;
    notifyListeners();
  }

  void addProject(SProject project) {
    _projects.add(project);
    notifyListeners();
  }

  void removeProject(SProject project) {
    _projects.remove(project);
    notifyListeners();
  }

  void initialize() async {
    if (_loading) return;
    _loading = true;
    final cacheData = await Future.wait([
      SProject.getProjects(),
      Ambit.getAmbits(),
      ProjectType.getProjectTypes(),
      Contact.getContacts(),
      Country.getCountries(),
      Programme.getProgrammes(),
      Organization.getOrganizations(),
      ProjectDates.getProjectDates(),
      ProjectStatus.getProjectStatus(),
      ProjectLocation.getProjectLocation(),
      Folder.getFolders(""),
    ]);
    _projects = cacheData[0] as List<SProject>;
    _ambits = cacheData[1] as List<Ambit>;
    _projectTypes = cacheData[2] as List<ProjectType>;
    _contacts = cacheData[3] as List<Contact>;
    _countries = cacheData[4] as List<Country>;
    _programmes = cacheData[5] as List<Programme>;
    _organizations = cacheData[6] as List<Organization>;
    _projectDates = cacheData[7] as List<ProjectDates>;
    _projectStatuses = cacheData[8] as List<ProjectStatus>;
    _projectLocations = cacheData[9] as List<ProjectLocation>;
    _folders = cacheData[10] as List<Folder>;

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
      if (_projectLocations.any((element) => element.project == project.uuid)) {
        project.locationObj = _projectLocations
            .firstWhere((element) => element.project == project.uuid);
      }
      // Check if folder exists
      if (!_folders.any((element) => element.uuid == project.folder)) {
        project.folder = "";
      } else {
        project.folderObj =
            _folders.firstWhere((element) => element.uuid == project.folder);
      }
      // project.typeObj =
      //     _projectTypes.firstWhere((element) => element.uuid == project.type);
      // project.managerObj =
      //     _contacts.firstWhere((element) => element.uuid == project.manager);
      // project.programmeObj = _programmes
      //     .firstWhere((element) => element.uuid == project.programme);
      // project.financiersObj = _organizations
      //     .where((element) => project.financiers.contains(element.uuid))
      //     .toList();
      // project.partnersObj = _organizations
      //     .where((element) => project.partners.contains(element.uuid))
      //     .toList();
      // project.datesObj = _projectDates
      //     .firstWhere((element) => element.project == project.uuid);
      // project.statusObj = _projectStatuses
      //     .firstWhere((element) => element.uuid == project.status);
      // project.locationObj = _projectLocations
      //     .firstWhere((element) => element.project == project.uuid);
      // // Check if folder exists
      // if (!_folders.any((element) => element.uuid == project.folder)) {
      //   project.folder = "";
      // } else {
      //   project.folderObj =
      //       _folders.firstWhere((element) => element.uuid == project.folder);
      // }
    }

    notifyListeners();
    _loading = false;
  }

  ProjectsProvider() {
    initialize();
  }
}
