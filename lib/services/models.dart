// import 'dart:ffi';
// import 'dart:html';

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/services/project_folders.dart';
import 'package:sic4change/services/utils.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
//--------------------------------------------------------------
//                           PROJECTS
//--------------------------------------------------------------
CollectionReference dbProject = db.collection("s4c_projects");

class SProject {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  String type = "";
  String status = "";
  String budget = "";
  String manager = "";
  String programme = "";
  String announcement = "";
  String ambit = "";
  String folder = "";
  bool audit = false;
  bool evaluation = false;
  List financiers = [];
  List partners = [];
  double execBudget = 0;
  double assignedBudget = 0;
  Ambit ambitObj = Ambit("");
  ProjectType typeObj = ProjectType("");
  ProjectStatus statusObj = ProjectStatus("");
  Contact managerObj = Contact("");
  Programme programmeObj = Programme("");
  List<Organization> financiersObj = [];
  List<Organization> partnersObj = [];
  ProjectDates datesObj = ProjectDates("");
  ProjectLocation locationObj = ProjectLocation("");
  Folder folderObj = Folder("", "");

  double dblbudget = 0;

  SProject(
    this.name,
  );
  /*SProject(this.uuid, this.name,
      [this.description = "",
      this.type = "",
      this.budget = "",
      this.manager = "",
      this.programme = "",
      this.announcement = "",
      this.ambit = "",
      this.audit = false,
      this.evaluation = false]);*/

  factory SProject.fromJson(Map<String, dynamic> json) {
    SProject item = SProject(json['name']);
    item.id = json["id"];
    item.uuid = json["uuid"];
    item.name = json['name'];
    item.description = json['description'];
    item.type = json['type'];
    item.status = json['status'];
    item.budget = json['budget'];
    item.manager = json['manager'];
    item.programme = json['programme'];
    item.announcement = json['announcement'];
    item.ambit = json['ambit'];
    item.audit = json['audit'];
    item.evaluation = json['evaluation'];
    item.financiers = json['financiers'];
    item.partners = json['partners'];
    item.folder = json['folder'];
    if (!json.containsKey("execBudget")) {
      item.execBudget = 0;
    } else {
      item.execBudget = json['execBudget'];
    }
    if (!json.containsKey("assignedBudget")) {
      item.assignedBudget = 0;
    } else {
      item.assignedBudget = json['assignedBudget'];
    }
    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'type': type,
        'status': status,
        'budget': budget,
        'manager': manager,
        'programme': programme,
        'announcement': announcement,
        'ambit': ambit,
        'audit': audit,
        'evaluation': evaluation,
        'financiers': financiers,
        'partners': partners,
        'execBudget': execBudget,
        'assignedBudget': assignedBudget,
        'folder': folder,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbProject.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProject.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProject.doc(id).delete();
  }

  Future<SProject> reload() async {
    DocumentSnapshot doc = await dbProject.doc(id).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    // SProject _project = SProject.fromJson(data);
    typeObj = await getProjectType();
    statusObj = await getProjectStatus();
    managerObj = await getManager();
    programmeObj = await getProgramme();
    financiersObj = await getFinanciers();
    partnersObj = await getPartners();
    datesObj = await getDates();
    locationObj = await getLocation();
    folderObj = await getFolder();
    //changeStatus();
    return this;
  }

  static Future<List<SProject>> getProjects({List<String>? uuids}) async {
    List<SProject> items = [];
    QuerySnapshot query;
    if (uuids != null) {
      query = await dbProject.where("uuid", whereIn: uuids).get();
    } else {
      query = await dbProject.get();
    }
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = SProject.fromJson(data);
      items.add(item);
    }
    return items;
  }

  Future<void> updateProjectFinanciers() async {
    await dbProject.doc(id).update({"financiers": financiers});
  }

  Future<void> updateProjectPartners() async {
    await dbProject.doc(id).update({"partners": partners});
  }

  int statusInt() {
    try {
      return int.parse(status);
    } catch (e) {
      return 0;
    }
  }

  String getStatus() {
    if (datesObj.approved == "") return "Sin aprobar";
    if (datesObj.start == "") return "Sin iniciar";
    if (datesObj.end == "") return "En proceso";
    try {
      /*DateTime _start = DateTime.parse(datesObj.start);
      DateTime _end = DateTime.parse(datesObj.end);
      DateTime _approved = DateTime.parse(datesObj.approved);*/
      DateTime today = DateTime.now();
      if (today.isBefore(datesObj.start)) return "Sin iniciar";
      if (today.isBefore(datesObj.approved)) return "Sin aprobar";
      if (today.isAfter(datesObj.end)) return "Finalizado";
      return "En proceso";
    } catch (e) {
      return "Finalizado";
    }
  }

  String getCode() {
    String code = "";
    if (financiersObj.isNotEmpty) code += "${financiersObj.first.name}_";
    code += "${datesObj.start.year}_";
    if (partnersObj.isNotEmpty) code += "${partnersObj.first.name}_";
    code += "${locationObj.countryObj.name}_";
    code += "${programmeObj.name}_";
    code += name;
    return code;
  }

  Future<double> totalBudget() async {
    final contribs = db.collection("s4c_finncontrib");
    final finns = db.collection("s4c_finns");
    dblbudget = 0;
    await finns
        .where("project", isEqualTo: uuid)
        .get()
        .then((list_finns) async {
      for (var finn in list_finns.docs) {
        await contribs
            .where("finn", isEqualTo: finn.data()["uuid"])
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            final Map<String, dynamic> data = doc.data();
            dblbudget += data["amount"];
          }
        });
      }
    });
    return dblbudget;
  }

  Future<ProjectDates> getDates() async {
    if (datesObj.project == "") {
      datesObj = await getProjectDatesByProject(uuid);
    }
    return datesObj;
  }

  Future<ProjectLocation> getLocation() async {
    if (locationObj.project == "") {
      locationObj = await getProjectLocationByProject(uuid);
    }
    return locationObj;
  }

  Future<Ambit> getAmbit() async {
    try {
      QuerySnapshot query = await dbAmbit.where("uuid", isEqualTo: ambit).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Ambit.fromJson(data);
    } catch (e) {
      return Ambit("");
    }
  }

  Future<ProjectType> getProjectType() async {
    //if (typeObj.name == "") {
    try {
      QuerySnapshot query =
          await dbProjectType.where("uuid", isEqualTo: type).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return ProjectType.fromJson(data);
    } catch (e) {
      return ProjectType("");
    }
    /*} else {
      return typeObj;
    }*/
  }

  Future<ProjectStatus> getProjectStatus() async {
    //if (statusObj.name == "") {
    try {
      QuerySnapshot query =
          await dbProjectStatus.where("uuid", isEqualTo: status).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return ProjectStatus.fromJson(data);
    } catch (e) {
      return ProjectStatus("");
    }
    /*} else {
      return statusObj;
    }*/
  }

  Future<Contact> getManager() async {
    try {
      QuerySnapshot query =
          await dbContacts.where("uuid", isEqualTo: manager).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Contact.fromJson(data);
    } catch (e) {
      return Contact("");
    }
    /*if (managerObj.name == "") {
      try {
        QuerySnapshot query =
            await dbContacts.where("uuid", isEqualTo: manager).get();
        final doc = query.docs.first;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        return Contact.fromJson(data);
      } catch (e) {
        return Contact("");
      }
    } else {
      return managerObj;
    }*/
  }

  Future<Programme> getProgramme() async {
    try {
      QuerySnapshot query =
          await dbProgramme.where("uuid", isEqualTo: programme).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Programme.fromJson(data);
    } catch (e) {
      print(e);
      return Programme("");
    }
    /*if (programmeObj.name == "") {
      try {
        QuerySnapshot query =
            await dbProgramme.where("uuid", isEqualTo: programme).get();
        final doc = query.docs.first;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        return Programme.fromJson(data);
      } catch (e) {
        return Programme("");
      }
    } else {
      return programmeObj;
    }*/
  }

  Future<List<Organization>> getFinanciers() async {
    /*List<Financier> finList = [];
    for (String fin in financiers) {
      try {
        QuerySnapshot query =
            await dbFinancier.where("uuid", isEqualTo: fin).get();
        final _doc = query.docs.first;
        final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
        data["id"] = _doc.id;
        Financier financier = Financier.fromJson(data);
        finList.add(financier);
      } catch (e) {}
    }
    return finList;*/
    if (financiersObj.isEmpty) {
      List<Organization> finList = [];
      for (String fin in financiers) {
        try {
          QuerySnapshot query = await dbOrg.where("uuid", isEqualTo: fin).get();
          final doc = query.docs.first;
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["id"] = doc.id;
          Organization financier = Organization.fromJson(data);
          finList.add(financier);
        } catch (e) {
          print(e);
        }
      }
      return finList;
    } else {
      return financiersObj;
    }
  }

  String getFinanciersStr() {
    String finList = "";
    for (Organization fin in financiersObj) {
      finList += ", ${fin.name}";
    }
    if (finList.length > 1) return finList.substring(2);
    return finList;
  }

  Future<List<SFinn>> getFinns() async {
    final List<SFinn> items = [];
    final database = db.collection("s4c_finns");
    await database
        .where("project", isEqualTo: uuid)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final item = SFinn.fromJson(data);
        items.add(item);
      }
    });
    return items;
  }

  //Future<List<Contact>> getPartners() async {
  Future<List<Organization>> getPartners() async {
    if (partnersObj.isEmpty) {
      List<Organization> parList = [];
      for (String par in partners) {
        try {
          QuerySnapshot query = await dbOrg.where("uuid", isEqualTo: par).get();
          final doc = query.docs.first;
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["id"] = doc.id;
          Organization org = Organization.fromJson(data);
          parList.add(org);
        } catch (e) {}
      }
      return parList;
    } else {
      return partnersObj;
    }
    // List<Contact> parList = [];
    // for (String par in partners) {
    //   try {
    //     QuerySnapshot query =
    //         await dbContacts.where("uuid", isEqualTo: par).get();
    //     final doc = query.docs.first;
    //     final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //     data["id"] = doc.id;
    //     Contact contact = Contact.fromJson(data);
    //     parList.add(contact);
    //   } catch (e) {}
    // }
    // return parList;
  }

  static Future<SProject> getByUuid(String uuid) async {
    //SProject item = SProject("", "", "", "", "", "", "", "", "", false, false);
    SProject item = SProject("");
    await dbProject.where("uuid", isEqualTo: uuid).get().then((value) {
      final _doc = value.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      item = SProject.fromJson(data);
    });
    return item;
  }

  Future<void> loadObjs() async {
    ambitObj = await getAmbit();
    typeObj = await getProjectType();
    statusObj = await getProjectStatus();
    managerObj = await getManager();
    programmeObj = await getProgramme();
    financiersObj = await getFinanciers();
    partnersObj = await getPartners();
    datesObj = await getDates();
    locationObj = await getLocation();
    folderObj = await getFolder();
    //changeStatus();
  }

  void setStatus(ProjectStatus st) {
    status = st.uuid;
    statusObj = st;
    save();
  }

  void changeStatus(dates) async {
    DateTime now = DateTime.now();
    /*if (now.compareTo(datesObj.delivery) > 0) {
      ProjectStatus st = await ProjectStatus.byUuid(statusDelivery);
      setStatus(st);
    } else if (now.compareTo(datesObj.justification) > 0) {*/

    if (now.compareTo(dates.reject) > 0) {
      ProjectStatus st = await ProjectStatus.byUuid(statusReject);
      setStatus(st);
    } else if (now.compareTo(dates.refuse) > 0) {
      ProjectStatus st = await ProjectStatus.byUuid(statusRefuse);
      setStatus(st);
    } else if (now.compareTo(dates.sended) > 0) {
      ProjectStatus st = await ProjectStatus.byUuid(statusSended);
      setStatus(st);
    } else if (now.compareTo(dates.justification) > 0) {
      ProjectStatus st = await ProjectStatus.byUuid(statusJustification);
      setStatus(st);
    } else if (now.compareTo(dates.end) > 0) {
      ProjectStatus st = await ProjectStatus.byUuid(statusEnds);
      setStatus(st);
    } else if (now.compareTo(dates.start) > 0) {
      ProjectStatus st = await ProjectStatus.byUuid(statusStart);
      setStatus(st);
    } else if (now.compareTo(dates.approved) > 0) {
      ProjectStatus st = await ProjectStatus.byUuid(statusApproved);
      setStatus(st);
    } else {
      ProjectStatus st = await ProjectStatus.byUuid(statusFormulation);
      setStatus(st);
    }
  }

  Color getStatusColor() {
    int color = int.parse("0xff${statusObj.color}");
    return Color(color);
  }

  Future<Folder> createFolder() async {
    Folder f = Folder(name, "");
    f.save();
    folder = f.uuid;
    save();
    createProjectFolders(f);
    return f;
  }

  Future<Folder> getFolder() async {
    if (folder == "") {
      return createFolder();
    }
    Folder? f = await getFolderByUuid(folder);
    if (f == null) {
      return createFolder();
    }
    return f;
  }

  double getExecVsAssigned() {
    double execVsAssigned =
        (assignedBudget != 0) ? execBudget / assignedBudget : 0;
    execVsAssigned = (execVsAssigned > 1) ? 1 : execVsAssigned;
    execVsAssigned = (execVsAssigned * 100).round() / 100;

    return execVsAssigned;
  }

  double getExecVsBudget() {
    double prjBudget = fromCurrency(budget);
    double execVsBudget = (prjBudget != 0) ? execBudget / prjBudget : 0;
    execVsBudget = (execVsBudget > 1) ? 1 : execVsBudget;
    execVsBudget = (execVsBudget * 100).round() / 100;

    return execVsBudget;
  }

  static Future<List<SProject>> listByUuid(List<String> uuids) async {
    List<SProject> items = [];
    QuerySnapshot query = await dbProject.where("uuid", whereIn: uuids).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = SProject.fromJson(data);
      items.add(item);
    }
    return items;
  }
}

Future<List> getProjects() async {
  List items = [];
  QuerySnapshot queryProject = await dbProject.get();
  for (var doc in queryProject.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = SProject.fromJson(data);
    try {
      /*item.ambitObj = await item.getAmbit();
      item.typeObj = await item.getProjectType();
      item.managerObj = await item.getManager();
      item.programmeObj = await item.getProgramme();
      item.financiersObj = await item.getFinanciers();
      item.partnersObj = await item.getPartners();
      item.datesObj = await item.getDates();*/
      // item.typeObj = await item.getProjectType();
      // item.managerObj = await item.getManager();
      // item.programmeObj = await item.getProgramme();
      // item.financiersObj = await item.getFinanciers();
      // item.partnersObj = await item.getPartners();
      // item.datesObj = await item.getDates();
    } catch (e) {}
    items.add(item);
  }
  return items;
}

Future<List<KeyValue>> getProjectsHash() async {
  List<KeyValue> items = [];
  QuerySnapshot queryProject = await dbProject.get();
  for (var doc in queryProject.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = SProject.fromJson(data);
    items.add(item.toKeyValue());
  }
  return items;
}

Future<SProject> getProjectById(String id) async {
  DocumentSnapshot _doc = await dbProject.doc(id).get();
  final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
  data["id"] = _doc.id;
  return SProject.fromJson(data);
}

Future<SProject?> getProjectByUuid(String uuid) async {
  QuerySnapshot query = await dbProject.where("uuid", isEqualTo: uuid).get();
  final doc = query.docs.first;
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  data["id"] = doc.id;
  return SProject.fromJson(data);
}

Future<List> getProjectsByType(String type) async {
  List items = [];
  QuerySnapshot query =
      await dbProjectType.where("name", isEqualTo: type).get();
  if (query.docs.isNotEmpty) {
    final doc = query.docs.first;
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    ProjectType pt = ProjectType.fromJson(data);

    query = await dbProject.where("type", isEqualTo: pt.uuid).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = SProject.fromJson(data);
      items.add(item);
    }
  }
  return items;
}

Future<List> getProjectsByProgramme(String programme) async {
  List items = [];
  QuerySnapshot query =
      await dbProject.where("programme", isEqualTo: programme).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = SProject.fromJson(data);
    items.add(item);
  }
  return items;
}

//--------------------------------------------------------------
//                       PROJECT TYPE
//--------------------------------------------------------------
CollectionReference dbProjectType = db.collection("s4c_project_type");

class ProjectType {
  String id = "";
  String uuid = "";
  String name = "";

  ProjectType(this.name);

  ProjectType.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  /*Map<String, String> toKeyValue() => {
        'key': uuid,
        'value': name,
      };*/
  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbProjectType.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProjectType.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProjectType.doc(id).delete();
  }
}

Future<List> getProjectTypes() async {
  List items = [];
  QuerySnapshot queryProjectType = await dbProjectType.get();

  for (var doc in queryProjectType.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = ProjectType.fromJson(data);
    items.add(_item);
  }

  return items;
}

Future<List<KeyValue>> getProjectTypesHash() async {
  List<KeyValue> items = [];
  QuerySnapshot queryProjectType = await dbProjectType.get();

  for (var doc in queryProjectType.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectType.fromJson(data);
    items.add(item.toKeyValue());
  }

  return items;
}

//--------------------------------------------------------------
//                       PROJECT STATUS
//--------------------------------------------------------------
CollectionReference dbProjectStatus = db.collection("s4c_project_status");

class ProjectStatus {
  String id = "";
  String uuid = "";
  String color = "";
  String name = "";

  ProjectStatus(this.name);

  ProjectStatus.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        color = json['color'],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'color': color,
        'name': name,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbProjectStatus.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProjectStatus.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProjectStatus.doc(id).delete();
  }

  static Future<ProjectStatus> byUuid(uuid) async {
    ProjectStatus item = ProjectStatus("");
    await dbProjectStatus.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = ProjectStatus.fromJson(data);
    });
    return item;
  }
}

Future<List> getProjectStatus() async {
  List items = [];
  QuerySnapshot queryProjectStatus = await dbProjectStatus.get();

  for (var doc in queryProjectStatus.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectStatus.fromJson(data);
    items.add(item);
  }

  return items;
}

Future<List<KeyValue>> getProjectStatusHash() async {
  List<KeyValue> items = [];
  QuerySnapshot queryProjectStatus = await dbProjectStatus.get();

  for (var doc in queryProjectStatus.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectStatus.fromJson(data);
    items.add(item.toKeyValue());
  }

  return items;
}

//--------------------------------------------------------------
//                       PROJECT DATES
//--------------------------------------------------------------
CollectionReference dbDates = db.collection("s4c_project_dates");
DateTime maxDate = DateTime(2100, 12, 31);
DateTime limitDate = DateTime(2100, 12, 30);

class ProjectDates {
  String id = "";
  String uuid = "";
  /*DateTime? approved;
  DateTime? start;
  DateTime? end;
  DateTime? justification;
  DateTime? delivery;
  DateTime? sended;
  DateTime? reject;*/
  /*DateTime approved = DateTime.now();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  DateTime justification = DateTime.now();
  DateTime delivery = DateTime.now();
  DateTime sended = DateTime.now();
  DateTime reject = DateTime.now();*/
  DateTime approved = maxDate;
  DateTime start = maxDate;
  DateTime end = maxDate;
  DateTime justification = maxDate;
  DateTime delivery = maxDate;
  DateTime sended = maxDate;
  DateTime reject = maxDate;
  DateTime refuse = maxDate;
  String project = "";

  ProjectDates(this.project);

  ProjectDates.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        approved = json["approved"].toDate(),
        start = json["start"].toDate(),
        end = json["end"].toDate(),
        justification = json["justification"].toDate(),
        delivery = json["delivery"].toDate(),
        sended = json["sended"].toDate(),
        reject = json["reject"].toDate(),
        refuse = json["refuse"].toDate(),

        /*approved = (json["approved"] != null) ? json["approved"].toDate() : "",
        start = (json["start"] != null) ? json["start"].toDate() : "",
        end = (json["end"] != null) ? json["end"].toDate() : "",
        justification = (json["justification"] != null)
            ? json["justification"].toDate()
            : "",
        delivery = (json["delivery"] != null) ? json["delivery"].toDate() : "",
        sended = (json["sended"] != null) ? json["sended"].toDate() : "",
        reject = (json["reject"] != null) ? json["reject"].toDate() : "",*/
        project = json["project"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'approved': approved,
        'start': start,
        'end': end,
        'justification': justification,
        'delivery': delivery,
        'sended': sended,
        'reject': reject,
        'refuse': refuse,
        'project': project,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbDates.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbDates.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbDates.doc(id).delete();
  }

  DateTime getApproved() {
    return approved.compareTo(limitDate) > 0 ? DateTime.now() : approved;
  }

  DateTime getStart() {
    return start.compareTo(limitDate) > 0 ? DateTime.now() : start;
  }

  DateTime getEnd() {
    return end.compareTo(limitDate) > 0 ? DateTime.now() : end;
  }

  DateTime getJustification() {
    return justification.compareTo(limitDate) > 0
        ? DateTime.now()
        : justification;
  }

  DateTime getDelivery() {
    return delivery.compareTo(limitDate) > 0 ? DateTime.now() : delivery;
  }

  DateTime getSended() {
    return sended.compareTo(limitDate) > 0 ? DateTime.now() : sended;
  }

  DateTime getReject() {
    return reject.compareTo(limitDate) > 0 ? DateTime.now() : reject;
  }

  DateTime getRefuse() {
    return refuse.compareTo(limitDate) > 0 ? DateTime.now() : refuse;
  }

  String getApprovedStr() {
    return approved.compareTo(limitDate) > 0
        ? ""
        : DateFormat("dd-MM-yyyy").format(approved);
  }

  String getStartStr() {
    return start.compareTo(limitDate) > 0
        ? ""
        : DateFormat("dd-MM-yyyy").format(start);
  }

  String getEndStr() {
    return end.compareTo(limitDate) > 0
        ? ""
        : DateFormat("dd-MM-yyyy").format(end);
  }

  String getJustificationStr() {
    return justification.compareTo(limitDate) > 0
        ? ""
        : DateFormat("dd-MM-yyyy").format(justification);
  }

  String getDeliveryStr() {
    return delivery.compareTo(limitDate) > 0
        ? ""
        : DateFormat("dd-MM-yyyy").format(delivery);
  }

  String getSendedStr() {
    return sended.compareTo(limitDate) > 0
        ? ""
        : DateFormat("dd-MM-yyyy").format(sended);
  }

  String getRejectStr() {
    return reject.compareTo(limitDate) > 0
        ? ""
        : DateFormat("dd-MM-yyyy").format(reject);
  }

  String getRefuseStr() {
    return refuse.compareTo(limitDate) > 0
        ? ""
        : DateFormat("dd-MM-yyyy").format(refuse);
  }
}

Future<List> getProjectDates() async {
  List items = [];
  QuerySnapshot query = await dbDates.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectDates.fromJson(data);
    items.add(item);
  }

  return items;
}

Future<ProjectDates> getProjectDatesById(String id) async {
  DocumentSnapshot doc = await dbDates.doc(id).get();
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  data["id"] = doc.id;
  return ProjectDates.fromJson(data);
}

Future<ProjectDates> getProjectDatesByProject(String project) async {
  QuerySnapshot query =
      await dbDates.where("project", isEqualTo: project).get();
  if (query.docs.isEmpty) {
    ProjectDates dates = ProjectDates(project);
    dates.save();
    return dates;
  }
  final dbRes = query.docs.first;
  final Map<String, dynamic> data = dbRes.data() as Map<String, dynamic>;
  data["id"] = dbRes.id;
  return ProjectDates.fromJson(data);
}

//--------------------------------------------------------------
//                       PROJECT DATES TRACING
//--------------------------------------------------------------
CollectionReference dbDatesTra = db.collection("s4c_project_dates_tracing");

class ProjectDatesTracing {
  String id = "";
  String uuid = "";
  DateTime date = DateTime.now();
  String project = "";

  ProjectDatesTracing(this.project);

  ProjectDatesTracing.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        date = json["date"].toDate(),
        project = json["project"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'date': date,
        'project': project,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbDatesTra.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbDatesTra.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbDatesTra.doc(id).delete();
  }
}

Future<List> getProjectDatesTracing() async {
  List items = [];
  QuerySnapshot query = await dbDatesTra.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectDatesTracing.fromJson(data);
    items.add(item);
  }

  return items;
}

/*Future<ProjectDatesTracing> getProjectDatesTracingById(String id) async {
  DocumentSnapshot doc = await dbDatesTra.doc(id).get();
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  data["id"] = doc.id;
  return ProjectDatesTracing.fromJson(data);
}*/

Future<List> getProjectDatesTracingByProject(String project) async {
  List items = [];
  QuerySnapshot query =
      await dbDatesTra.where("project", isEqualTo: project).get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectDatesTracing.fromJson(data);
    items.add(item);
  }

  return items;
}

//--------------------------------------------------------------
//                       PROJECT DATES AUDIT
//--------------------------------------------------------------
CollectionReference dbDatesAudit = db.collection("s4c_project_dates_audit");

class ProjectDatesAudit {
  String id = "";
  String uuid = "";
  DateTime date = DateTime.now();
  String project = "";

  ProjectDatesAudit(this.project);

  ProjectDatesAudit.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        date = json["date"].toDate(),
        project = json["project"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'date': date,
        'project': project,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbDatesAudit.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbDatesAudit.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbDatesAudit.doc(id).delete();
  }
}

Future<List> getProjectDatesAudit() async {
  List items = [];
  QuerySnapshot query = await dbDatesAudit.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectDatesAudit.fromJson(data);
    items.add(item);
  }

  return items;
}

Future<List> getProjectDatesAuditByProject(String project) async {
  List items = [];
  QuerySnapshot query =
      await dbDatesAudit.where("project", isEqualTo: project).get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectDatesAudit.fromJson(data);
    items.add(item);
  }

  return items;
}

//--------------------------------------------------------------
//                       PROJECT DATES EVALUATION
//--------------------------------------------------------------
CollectionReference dbDatesEval = db.collection("s4c_project_dates_eval");

class ProjectDatesEval {
  String id = "";
  String uuid = "";
  DateTime date = DateTime.now();
  String project = "";

  ProjectDatesEval(this.project);

  ProjectDatesEval.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        date = json["date"].toDate(),
        project = json["project"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'date': date,
        'project': project,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbDatesEval.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbDatesEval.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbDatesEval.doc(id).delete();
  }
}

Future<List> getProjectDatesEval() async {
  List items = [];
  QuerySnapshot query = await dbDatesEval.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectDatesEval.fromJson(data);
    items.add(item);
  }

  return items;
}

Future<List> getProjectDatesEvalByProject(String project) async {
  List items = [];
  QuerySnapshot query =
      await dbDatesEval.where("project", isEqualTo: project).get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectDatesEval.fromJson(data);
    items.add(item);
  }

  return items;
}

//--------------------------------------------------------------
//                       PROJECT LOCATION
//--------------------------------------------------------------
CollectionReference dbLocation = db.collection("s4c_project_location");

class ProjectLocation {
  String id = "";
  String uuid = "";

  String country = "";
  String province = "";
  String region = "";
  String town = "";
  String project = "";
  Country countryObj = Country("");
  Province provinceObj = Province("");
  Region regionObj = Region("");
  Town townObj = Town("");

  ProjectLocation(this.project);

  ProjectLocation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        country = json["country"],
        province = json["province"],
        region = json["region"],
        town = json["town"],
        project = json["project"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'country': country,
        'province': province,
        'region': region,
        'town': town,
        'project': project,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbLocation.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbLocation.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbLocation.doc(id).delete();
  }

  Future<Country> getCountry() async {
    try {
      QuerySnapshot query =
          await dbCountry.where("uuid", isEqualTo: country).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Country.fromJson(data);
    } catch (e) {
      return Country("");
    }
  }

  Future<Province> getProvince() async {
    try {
      QuerySnapshot query =
          await dbProvince.where("uuid", isEqualTo: province).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Province.fromJson(data);
    } catch (e) {
      return Province("");
    }
  }

  Future<Region> getRegion() async {
    try {
      QuerySnapshot query =
          await dbRegion.where("uuid", isEqualTo: region).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Region.fromJson(data);
    } catch (e) {
      return Region("");
    }
  }

  Future<Town> getTown() async {
    try {
      QuerySnapshot query = await dbTown.where("uuid", isEqualTo: town).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Town.fromJson(data);
    } catch (e) {
      return Town("");
    }
  }
}

Future<List> getProjectLocation() async {
  List items = [];
  QuerySnapshot query = await dbLocation.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProjectLocation.fromJson(data);
    items.add(item);
  }

  return items;
}

Future<ProjectLocation> getProjectLocationByProject(String _project) async {
  QuerySnapshot query =
      await dbLocation.where("project", isEqualTo: _project).get();

  if (query.docs.isEmpty) {
    ProjectLocation loc = ProjectLocation(_project);
    loc.save();
    return loc;
  }

  final dbRes = query.docs.first;
  final Map<String, dynamic> data = dbRes.data() as Map<String, dynamic>;
  data["id"] = dbRes.id;
  ProjectLocation pl = ProjectLocation.fromJson(data);
  pl.countryObj = await pl.getCountry();
  pl.provinceObj = await pl.getProvince();
  pl.regionObj = await pl.getRegion();
  pl.townObj = await pl.getTown();
  return pl;
}

//--------------------------------------------------------------
//                       PROJECT FINANCIER
//--------------------------------------------------------------
/*CollectionReference dbFinancier = db.collection("s4c_financier");

class Financier {
  String id = "";
  String uuid = "";
  String name = "";
  String organization = "";

  Financier(this.name);

  factory Financier.fromJson(Map<String, dynamic> json) {
    Financier item = Financier(json['name']);
    item.id = json["id"];
    item.uuid = json["uuid"];
    item.name = json['name'];
    try {
      item.organization = json['organization'];
    } catch (e) {
      Map<String, String> equivalencies = {
        "078bdde3-f409-41fb-8a10-f6840c199dca":
            "b1b0c5a8-d0f0-4b43-a50b-33aef2249d00",
        "4aa7eb9c-c780-49db-bdea-fc65ba1098b1":
            "0acabf09-b760-4ff2-b347-0facca7a9b13"
      };
      if (equivalencies.containsKey(item.uuid)) {
        item.organization = equivalencies[item.uuid]!;
        item.save();
      } else {
        item.organization = "";
      }
    }
    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbFinancier.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbFinancier.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbFinancier.doc(id).delete();
  }

  static Future<Financier> getByUuid(String uuid) async {
    Financier item = Financier("");
    await dbFinancier.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Financier.fromJson(data);
    });
    return item;
  }
}

Future<List> getFinanciers() async {
  List items = [];
  QuerySnapshot queryFinancier = await dbFinancier.get();

  for (var doc in queryFinancier.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Financier.fromJson(data);
    items.add(item);
  }

  return items;
}

Future<List<KeyValue>> getFinanciersHash() async {
  List<KeyValue> items = [];
  QuerySnapshot queryFinancier = await dbFinancier.get();

  for (var doc in queryFinancier.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Financier.fromJson(data);
    items.add(item.toKeyValue());
  }

  return items;
}*/

//--------------------------------------------------------------
//                       PROJECT REFORMULATION
//--------------------------------------------------------------
CollectionReference dbReformulation =
    db.collection("s4c_project_reformulation");

class Reformulation {
  String id = "";
  String uuid = "";
  //String reformulation = "";
  //String correction = "";
  //String request = "";
  String project = "";
  String financier = "";
  String type = "";
  String status = "";
  String description = "";
  String folder = "";
  DateTime presentationDate = maxDate;
  DateTime resolutionDate = maxDate;
  //SProject projectObj = SProject("", "");
  //Financier financierObj = Financier("");
  SProject projectObj = SProject("");
  Organization financierObj = Organization("");
  ReformulationType typeObj = ReformulationType();
  ReformulationStatus statusObj = ReformulationStatus();
  Folder folderObj = Folder("", "");

  Reformulation(this.project);

  Reformulation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        /*reformulation = json['reformulation'],
        correction = json['correction'],
        request = json['request'],*/
        type = json['type'],
        status = json['status'],
        description = json['description'],
        folder = json['folder'],
        presentationDate = json["presentationDate"].toDate(),
        resolutionDate = json["resolutionDate"].toDate(),
        project = json['project'],
        financier = json['financier'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        /*'reformulation': reformulation,
        'correction': correction,
        'request': request,*/
        'type': type,
        'status': status,
        'description': description,
        'folder': folder,
        'presentationDate': presentationDate,
        'resolutionDate': resolutionDate,
        'project': project,
        'financier': financier,
      };

  /*KeyValue toKeyValue() {
    return KeyValue(uuid, reformulation);
  }*/

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbReformulation.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbReformulation.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbReformulation.doc(id).delete();
  }

  Future<void> loadObjs() async {
    projectObj = await getProject();
    financierObj = await getFinancier();
    typeObj = await getType();
    statusObj = await getStatus();
    folderObj = await getFolder();
  }

  Future<SProject> getProject() async {
    try {
      QuerySnapshot query =
          await dbProject.where("uuid", isEqualTo: project).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return SProject.fromJson(data);
    } catch (e) {
      print(e);
      return SProject("");
    }
  }

  Future<Organization> getFinancier() async {
    try {
      QuerySnapshot query =
          await dbOrg.where("uuid", isEqualTo: financier).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Organization.fromJson(data);
    } catch (e) {
      return Organization("");
    }
  }

  Future<ReformulationType> getType() async {
    try {
      QuerySnapshot query =
          await dbReformulationType.where("uuid", isEqualTo: type).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return ReformulationType.fromJson(data);
    } catch (e) {
      return ReformulationType();
    }
  }

  Future<ReformulationStatus> getStatus() async {
    try {
      QuerySnapshot query =
          await dbReformulationStatus.where("uuid", isEqualTo: status).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return ReformulationStatus.fromJson(data);
    } catch (e) {
      return ReformulationStatus();
    }
  }

  DateTime getPresentation() {
    return presentationDate.compareTo(limitDate) > 0
        ? DateTime.now()
        : presentationDate;
  }

  DateTime getResolution() {
    return resolutionDate.compareTo(limitDate) > 0
        ? DateTime.now()
        : resolutionDate;
  }

  Future<Folder> createFolder() async {
    projectObj = await getProject();
    Folder f = Folder("Comunicacion-$uuid", projectObj.folder);
    f.save();
    folder = f.uuid;
    save();
    return f;
  }

  Future<Folder> getFolder() async {
    if (folder == "") {
      return createFolder();
    }
    Folder? f = await getFolderByUuid(folder);
    if (f == null) {
      return createFolder();
    }
    return f;
  }
}

Future<List> getReformulations() async {
  List items = [];
  QuerySnapshot query = await dbReformulation.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Reformulation.fromJson(data);
    /*item.projectObj = await item.getProject();
    item.financierObj = await item.getFinancier();
    item.typeObj = await item.getType();
    item.statusObj = await item.getStatus();
    item.folderObj = await item.getFolder();*/
    items.add(item);
  }

  return items;
}

Future<List> getReformulationsByProject(uuid) async {
  List items = [];
  QuerySnapshot query =
      await dbReformulation.where("project", isEqualTo: uuid).get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Reformulation.fromJson(data);
    item.projectObj = await item.getProject();
    item.financierObj = await item.getFinancier();
    item.typeObj = await item.getType();
    item.statusObj = await item.getStatus();
    item.folderObj = await item.getFolder();
    items.add(item);
  }

  return items;
}

//--------------------------------------------------------------
//                       PROJECT REFORMULATION TYPE
//--------------------------------------------------------------
CollectionReference dbReformulationType =
    db.collection("s4c_project_reformulation_type");

class ReformulationType {
  String id = "";
  String uuid = "";
  String name = "";

  ReformulationType();

  ReformulationType.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbReformulationType.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbReformulationType.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbReformulationType.doc(id).delete();
  }
}

Future<List> getReformulationTypes() async {
  List items = [];
  QuerySnapshot query = await dbReformulationType.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ReformulationType.fromJson(data);
    items.add(item);
  }

  return items;
}

Future<List<KeyValue>> getReformulationTypesHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbReformulationType.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    ReformulationType item = ReformulationType.fromJson(data);
    items.add(item.toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                       PROJECT REFORMULATION STATUS
//--------------------------------------------------------------
CollectionReference dbReformulationStatus =
    db.collection("s4c_project_reformulation_status");

class ReformulationStatus {
  String id = "";
  String uuid = "";
  String name = "";

  ReformulationStatus();

  ReformulationStatus.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbReformulationStatus.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbReformulationStatus.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbReformulationStatus.doc(id).delete();
  }
}

Future<List> getReformulationStatus() async {
  List items = [];
  QuerySnapshot query = await dbReformulationStatus.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ReformulationStatus.fromJson(data);
    items.add(item);
  }

  return items;
}

Future<List<KeyValue>> getReformulationStatusHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbReformulationStatus.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    ReformulationStatus item = ReformulationStatus.fromJson(data);
    items.add(item.toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                       PROGRAMME
//--------------------------------------------------------------
CollectionReference dbProgramme = db.collection("s4c_programmes");

class Programme {
  String id = "";
  String uuid = "";
  String name = "";
  String title = "";
  String description = "";
  String impact = "";
  String logo = "";
  int projects = 0;

  Programme(this.name);

  Programme.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        title = json['title'],
        description = json['description'],
        impact = json['impact'],
        logo = json['logo'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'title': title,
        'description': description,
        'impact': impact,
        'logo': logo,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbProgramme.add(data);
      createLog("Creado el programa: $name");
    } else {
      Map<String, dynamic> data = toJson();
      dbProgramme.doc(id).set(data);
      createLog("Modificado el programa: $name");
    }
  }

  Future<void> delete() async {
    await dbProgramme.doc(id).delete();
    createLog("Borrado el programa: $name");
  }

  Future<void> getProjects() async {
    QuerySnapshot query =
        await dbProject.where("programme", isEqualTo: uuid).get();
    projects = query.docs.length;
  }

  Future<int> getProjectsByStatus(status) async {
    QuerySnapshot query = await dbProject
        .where("programme", isEqualTo: uuid)
        .where("status", isEqualTo: status)
        .get();
    return query.docs.length;
  }

  static Future<Programme> byUuid(uuid) async {
    Programme item = Programme("");
    await dbProgramme.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Programme.fromJson(data);
    });
    return item;
  }
}

Future<List<Programme>> getProgrammes() async {
  List<Programme> items = [];
  QuerySnapshot queryProgramme = await dbProgramme.get();

  for (var doc in queryProgramme.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Programme.fromJson(data);
    await item.getProjects();
    items.add(item);
  }
  return items;
}

Future<List<KeyValue>> getProgrammesHash() async {
  List<KeyValue> items = [];
  QuerySnapshot queryProgramme = await dbProgramme.get();

  for (var doc in queryProgramme.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Programme.fromJson(data);
    item.getProjects();
    items.add(item.toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                       PROGRAMME INDICATORS
//--------------------------------------------------------------
CollectionReference dbProgrammeIndicators =
    db.collection("s4c_programmes_indicators");

class ProgrammeIndicators {
  String id = "";
  String uuid = "";
  String name = "";
  int order = 0;
  String programme;
  double expected = 0;
  double obtained = 0;

  ProgrammeIndicators(this.programme);

  ProgrammeIndicators.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        order = json['order'],
        programme = json['programme'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'order': order,
        'programme': programme,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbProgrammeIndicators.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProgrammeIndicators.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProgrammeIndicators.doc(id).delete();
  }

  Future<void> getSumValues() async {
    List goalIndicators = await getGoalIndicatorsByCode(uuid);
    for (GoalIndicator gi in goalIndicators) {
      try {
        expected += double.parse(gi.expected);
      } catch (e) {}
      try {
        obtained += double.parse(gi.obtained);
      } catch (e) {}
    }
  }
}

Future<List> getProgrammesIndicators(uuid) async {
  List items = [];
  try {
    QuerySnapshot queryProgrammeIndicators = await dbProgrammeIndicators
        .orderBy("order", descending: true)
        .where("programme", isEqualTo: uuid)
        .get();

    for (var doc in queryProgrammeIndicators.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProgrammeIndicators.fromJson(data);
      await item.getSumValues();
      items.add(item);
    }
  } catch (e) {
    print(e);
  }
  return items;
}

Future<List<KeyValue>> getProgrammesIndicatorsHash() async {
  List<KeyValue> items = [];
  QuerySnapshot queryProgrammeIndicators = await dbProgrammeIndicators.get();

  for (var doc in queryProgrammeIndicators.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = ProgrammeIndicators.fromJson(data);
    items.add(item.toKeyValue());
  }
  return items;
}
