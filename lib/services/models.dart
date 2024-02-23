// import 'dart:ffi';
// import 'dart:html';

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_location.dart';
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
  List<Financier> financiersObj = [];
  List<Contact> partnersObj = [];
  ProjectDates datesObj = ProjectDates("");
  ProjectLocation locationObj = ProjectLocation("");

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
    return this;
  }

  Future<void> updateProjectFinanciers() async {
    await dbProject.doc(id).update({"financiers": financiers});
  }

  Future<void> updateProjectPartners() async {
    await dbProject.doc(id).update({"partners": partners});
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
      ;
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
    if (typeObj.name == "") {
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
    } else {
      return typeObj;
    }
  }

  Future<ProjectStatus> getProjectStatus() async {
    if (statusObj.name == "") {
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
    } else {
      return statusObj;
    }
  }

  Future<Contact> getManager() async {
    /*try {
      QuerySnapshot query =
          await dbContacts.where("uuid", isEqualTo: manager).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Contact.fromJson(data);
    } catch (e) {
      return Contact("", "", "", "", "");*/
    if (managerObj.name == "") {
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
    }
  }

  Future<Programme> getProgramme() async {
    /*try {
      QuerySnapshot query =
          await dbProgramme.where("uuid", isEqualTo: programme).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Programme.fromJson(data);
    } catch (e) {
      return Programme("");*/
    if (programmeObj.name == "") {
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
    }
  }

  Future<List<Financier>> getFinanciers() async {
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
      List<Financier> finList = [];
      for (String fin in financiers) {
        try {
          QuerySnapshot query =
              await dbFinancier.where("uuid", isEqualTo: fin).get();
          final doc = query.docs.first;
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data["id"] = doc.id;
          Financier financier = Financier.fromJson(data);
          finList.add(financier);
        } catch (e) {}
      }
      return finList;
    } else {
      return financiersObj;
    }
  }

  String getFinanciersStr() {
    String finList = "";
    for (Financier fin in financiersObj) {
      finList += ", ${fin.name}";
    }
    if (finList.length > 1) return finList.substring(2);
    return finList;
  }

  Future<List<Contact>> getPartners() async {
    if (partnersObj.isEmpty) {
      List<Contact> parList = [];
      for (String par in partners) {
        try {
          QuerySnapshot query =
              await dbContacts.where("uuid", isEqualTo: par).get();
          final _doc = query.docs.first;
          final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
          data["id"] = _doc.id;
          Contact _contact = Contact.fromJson(data);
          parList.add(_contact);
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
  }

  Color getStatusColor() {
    int color = int.parse("0xff${statusObj.color}");
    return Color(color);
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
  QuerySnapshot query =
      await dbProjectType.where("name", isEqualTo: type).get();
  final doc = query.docs.first;
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  data["id"] = doc.id;
  ProjectType pt = ProjectType.fromJson(data);

  List items = [];
  query = await dbProject.where("type", isEqualTo: pt.uuid).get();
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

class ProjectDates {
  String id = "";
  String uuid = "";
  DateTime approved = DateTime.now();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  DateTime justification = DateTime.now();
  DateTime delivery = DateTime.now();
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
        project = json["project"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'approved': approved,
        'start': start,
        'end': end,
        'justification': justification,
        'delivery': delivery,
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
  DocumentSnapshot _doc = await dbDates.doc(id).get();
  final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
  data["id"] = _doc.id;
  return ProjectDates.fromJson(data);
}

Future<ProjectDates> getProjectDatesByProject(String _project) async {
  QuerySnapshot query =
      await dbDates.where("project", isEqualTo: _project).get();
  if (query.docs.isEmpty) {
    ProjectDates dates = ProjectDates(_project);
    dates.save();
    return dates;
  }
  final dbRes = query.docs.first;
  final Map<String, dynamic> data = dbRes.data() as Map<String, dynamic>;
  data["id"] = dbRes.id;
  return ProjectDates.fromJson(data);
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
CollectionReference dbFinancier = db.collection("s4c_financier");

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
}

//--------------------------------------------------------------
//                       PROJECT REFORMULATION
//--------------------------------------------------------------
CollectionReference dbReformulation =
    db.collection("s4c_project_reformulation");

class Reformulation {
  String id = "";
  String uuid = "";
  String reformulation = "";
  String correction = "";
  String request = "";
  String project = "";
  String financier = "";
  //SProject projectObj = SProject("", "");
  SProject projectObj = SProject("");
  Financier financierObj = Financier("");

  Reformulation(this.project);

  Reformulation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        reformulation = json['reformulation'],
        correction = json['correction'],
        request = json['request'],
        project = json['project'],
        financier = json['financier'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'reformulation': reformulation,
        'correction': correction,
        'request': request,
        'project': project,
        'financier': financier,
      };

  /*KeyValue toKeyValue() {
    return KeyValue(uuid, reformulation);
  }*/

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
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

  Future<SProject> getProject() async {
    try {
      QuerySnapshot query =
          await dbProject.where("uuid", isEqualTo: project).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return SProject.fromJson(data);
    } catch (e) {
      return SProject("");
    }
  }

  Future<Financier> getFinancier() async {
    try {
      QuerySnapshot query =
          await dbFinancier.where("uuid", isEqualTo: financier).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Financier.fromJson(data);
    } catch (e) {
      return Financier("");
    }
  }
}

Future<List> getReformulations() async {
  List items = [];
  QuerySnapshot query = await dbReformulation.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Reformulation.fromJson(data);
    item.projectObj = await item.getProject();
    item.financierObj = await item.getFinancier();
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
    final _item = Reformulation.fromJson(data);
    _item.projectObj = await _item.getProject();
    _item.financierObj = await _item.getFinancier();
    items.add(_item);
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
  String logo = "";
  int projects = 0;

  Programme(this.name);

  Programme.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        logo = json['logo'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
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
    } else {
      Map<String, dynamic> data = toJson();
      dbProgramme.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProgramme.doc(id).delete();
  }

  Future<void> getProjects() async {
    QuerySnapshot query =
        await dbProject.where("programe", isEqualTo: uuid).get();
    projects = query.docs.length;
  }
}

Future<List> getProgrammes() async {
  List items = [];
  QuerySnapshot queryProgramme = await dbProgramme.get();

  for (var doc in queryProgramme.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Programme.fromJson(data);
    _item.getProjects();
    items.add(_item);
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
