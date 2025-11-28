// import 'dart:ffi';
// import 'dart:html';
import 'dart:developer' as dev;

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

// Generate a abstract class for common methods with id, tbName, toJson, fromJson, reload, save, delete, static byId

//--------------------------------------------------------------
//                           PROJECTS
//--------------------------------------------------------------

class SProject {
  static const String tbName = "s4c_projects";
  DocumentReference? docRef;
  Function? onChanged;

  String id = "";
  String uuid = "";
  String name = "";
  String code = "";
  String description = "";
  String type = "";
  String status = "";
  String budget = "";
  String manager = "";
  String programme = "";
  String announcement = "";
  String announcementYear = "";
  String announcementCode = "";
  String ambit = "";
  String folder = "";
  List<Map<String, dynamic>> locations = [];
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
  List<ProjectDatesAudit> datesAudit = [];
  Folder folderObj = Folder("", "");

  double dblbudget = 0;

  SProject(
    this.name,
  );

  SProject update(Map<String, dynamic> json) {
    if (json["id"] != id) return this;

    if (json.containsKey("locations")) {
      locations = List<Map<String, dynamic>>.from(json['locations']);
    }

    if (json.containsKey("id")) id = json["id"];
    if (json.containsKey("uuid")) uuid = json["uuid"];
    if (json.containsKey("name")) name = json['name'];
    if (json.containsKey("code")) code = json['code'];
    if (json.containsKey("description")) description = json['description'];
    if (json.containsKey("type")) type = json['type'];
    if (json.containsKey("status")) status = json['status'];
    if (json.containsKey("budget")) budget = json['budget'];
    if (json.containsKey("manager")) manager = json['manager'];
    if (json.containsKey("programme")) programme = json['programme'];
    if (json.containsKey("announcement")) announcement = json['announcement'];
    if (json.containsKey("ambit")) ambit = json['ambit'];
    if (json.containsKey("audit")) audit = json['audit'];
    if (json.containsKey("evaluation")) evaluation = json['evaluation'];
    if (json.containsKey("financiers")) financiers = json['financiers'];
    if (json.containsKey("partners")) partners = json['partners'];
    if (json.containsKey("folder")) folder = json['folder'];
    if (json.containsKey("execBudget")) execBudget = json['execBudget'];
    if (json.containsKey("announcementYear")) {
      announcementYear = json['announcementYear'];
    }
    if (json.containsKey("announcementCode")) {
      announcementCode = json['announcementCode'];
    }
    if (json.containsKey("assignedBudget")) {
      assignedBudget = json['assignedBudget'];
    }
    return this;
  }

  factory SProject.fromJson(DocumentSnapshot doc) {
    final Map<String, dynamic> json = doc.data() as Map<String, dynamic>;

    SProject item = SProject(json['name']);
    item.docRef = doc.reference;

    item.id = json["id"];
    if ((item.id == "") && (doc.id != "")) {
      item.id = doc.id;
      FirebaseFirestore.instance
          .collection(SProject.tbName)
          .doc(item.id)
          .update({"id": item.id});
    }
    item.uuid = json["uuid"];
    item.name = json['name'];
    item.description = json['description'];
    item.type = json['type'];
    item.code = (json.containsKey("code")) ? json['code'] : "";
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
    item.announcementYear = json['announcementYear'] ?? "";
    item.announcementCode = json['announcementCode'] ?? "";
    item.locations = (json.containsKey("locations"))
        ? List<Map<String, dynamic>>.from(json['locations'])
        : [];
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

    if (item.uuid != "") {
      ProjectDatesAudit.getProjectDatesAuditByProject(item.uuid).then((list) {
        if (list.isNotEmpty) {
          item.datesAudit = list as List<ProjectDatesAudit>;
        }
      });
    }

    item.docRef!.snapshots().listen((snapshot) {
      if (item.onChanged != null) {
        item.update(snapshot.data() as Map<String, dynamic>);
        item.onChanged?.call();
      }
    });
    return item;
  }

  SProject clone() {
    SProject newProject = SProject(name);
    newProject.id = id;
    newProject.uuid = uuid;
    newProject.code = code;
    newProject.description = description;
    newProject.type = type;
    newProject.status = status;
    newProject.budget = budget;
    newProject.manager = manager;
    newProject.programme = programme;
    newProject.announcement = announcement;
    newProject.announcementYear = announcementYear;
    newProject.announcementCode = announcementCode;
    newProject.ambit = ambit;
    newProject.audit = audit;
    newProject.evaluation = evaluation;
    newProject.financiers = List.from(financiers);
    newProject.partners = List.from(partners);
    newProject.execBudget = execBudget;
    newProject.assignedBudget = assignedBudget;
    newProject.folder = folder;
    return newProject;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'code': code,
        'description': description,
        'type': type,
        'status': status,
        'budget': budget,
        'manager': manager,
        'programme': programme,
        'announcement': announcement,
        'announcementYear': announcementYear,
        'announcementCode': announcementCode,
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

  String code_calculated() {
    return "$name ($uuid)";
  }

  Future<void> save() async {
    List<ProjectLocation> locList =
        await ProjectLocation.getProjectLocationByProject(uuid);
    if (locList.isNotEmpty) {
      locations = locList.map((loc) => loc.toJson()).toList();
    } else {
      locations = [];
    }
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();

      data["locations"] = locations;
      var item = await FirebaseFirestore.instance
          .collection(SProject.tbName)
          .add(data);
      id = item.id;
      FirebaseFirestore.instance
          .collection(SProject.tbName)
          .doc(id)
          .update({"id": id});
      createLog("Creada la iniciativa: $name");
    } else {
      Map<String, dynamic> data = toJson();
      data["locations"] = locations;
      FirebaseFirestore.instance.collection(SProject.tbName).doc(id).set(data);
      createLog("Modificada la iniciativa: $name");
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection(SProject.tbName)
        .doc(id)
        .delete();
    createLog("Borrada la iniciativa: $name");
  }

  Future<SProject> reload() async {
    if (id.isEmpty) return this; // No ID provided
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(SProject.tbName)
        .doc(id)
        .get();
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

  static Future<List<SProject>> all() async {
    List<SProject> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(SProject.tbName).get();
    for (var doc in query.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      final item = SProject.fromJson(doc);
      items.add(item);
    }
    return items;
  }

  static Future<List<SProject>> getProjects(
      {List<String>? uuids, bool cache = true}) async {
    List<SProject> items = [];
    Query query;
    QuerySnapshot querySnapshot;
    if (uuids != null) {
      if (uuids.isEmpty) return items;
      query = FirebaseFirestore.instance
          .collection(SProject.tbName)
          .where("uuid", whereIn: uuids);
    } else {
      query = FirebaseFirestore.instance.collection(SProject.tbName);
    }

    if (cache) {
      dev.log("Projects: Loading from cache");
    } else {
      dev.log("Projects: Loading from server");
    }

    querySnapshot = await query
        .get(GetOptions(source: cache ? Source.cache : Source.server));
    if ((cache) && (querySnapshot.docs.isEmpty)) {
      dev.log("Projects: Cache miss - loading from server");
      querySnapshot = await query.get(const GetOptions(source: Source.server));
    }
    for (var doc in querySnapshot.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      final item = SProject.fromJson(doc);
      items.add(item);
    }
    return items;
  }

  static Future<List<SProject>> byProjectType(List<ProjectType> ptList) async {
    List<SProject> items = [];
    if (ptList.isEmpty) return items;
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(SProject.tbName)
        .where("type", whereIn: ptList.map((e) => e.uuid).toList())
        .get();
    for (var doc in query.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      final item = SProject.fromJson(doc);
      items.add(item);
    }
    return items;
  }

  Future<void> updateProjectFinanciers() async {
    await FirebaseFirestore.instance
        .collection(SProject.tbName)
        .doc(id)
        .update({"financiers": financiers});
  }

  Future<void> updateProjectPartners() async {
    await FirebaseFirestore.instance
        .collection(SProject.tbName)
        .doc(id)
        .update({"partners": partners});
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
    final contribs = FirebaseFirestore.instance.collection("s4c_finncontrib");
    final finns = FirebaseFirestore.instance.collection("s4c_finns");
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
      datesObj = await ProjectDates.getProjectDatesByProject(uuid);
    }
    return datesObj;
  }

  Future<ProjectLocation> getLocation(
      [List<ProjectLocation>? locationList]) async {
    if (locationObj.project == "") {
      locationList ??= await ProjectLocation.getProjectLocation();
      locationObj = locationList.firstWhere((loc) => loc.project == uuid,
          orElse: () => ProjectLocation(uuid));
    }
    return locationObj;
  }

  Future<Ambit> getAmbit() async {
    try {
      return await Ambit.byUuid(ambit);
    } catch (e) {
      return Ambit("");
    }
  }

  Future<ProjectType> getProjectType() async {
    //if (typeObj.name == "") {
    try {
      // QuerySnapshot query =
      //     await dbProjectType.where("uuid", isEqualTo: type).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return ProjectType.fromJson(data);
      return await ProjectType.byUuid(type);
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
      // QuerySnapshot query =
      //     await dbProjectStatus.where("uuid", isEqualTo: status).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return ProjectStatus.fromJson(data);
      return await ProjectStatus.byUuid(status);
    } catch (e) {
      return ProjectStatus("");
    }
    /*} else {
      return statusObj;
    }*/
  }

  Future<Contact> getManager() async {
    try {
      // QuerySnapshot query =
      //     await dbContacts.where("uuid", isEqualTo: manager).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Contact.fromJson(data);
      return Contact.byUuid(manager);
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
      // QuerySnapshot query =
      //     await dbProgramme.where("uuid", isEqualTo: programme).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Programme.fromJson(data);
      return await Programme.byUuid(programme);
    } catch (e) {
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
          // QuerySnapshot query = await dbOrg.where("uuid", isEqualTo: fin).get();
          // final doc = query.docs.first;
          // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // data["id"] = doc.id;
          // Organization financier = Organization.fromJson(data);
          Organization financier = await Organization.byUuid(fin);
          finList.add(financier);
        } catch (e) {
          //
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
    await FirebaseFirestore.instance
        .collection("s4c_finns")
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
          // QuerySnapshot query = await dbOrg.where("uuid", isEqualTo: par).get();
          // final doc = query.docs.first;
          // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // data["id"] = doc.id;
          // Organization org = Organization.fromJson(data);
          Organization org = await Organization.byUuid(par);
          parList.add(org);
        } catch (e) {
          // Handle error, e.g., log it or show a message
        }
      }
      return parList;
    } else {
      return partnersObj;
    }
  }

  static Future<SProject> getByUuid(String uuid) async {
    //SProject item = SProject("", "", "", "", "", "", "", "", "", false, false);
    SProject item = SProject("");
    if (uuid.isEmpty) return item; // No UUID provided
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_projects")
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      query = await FirebaseFirestore.instance
          .collection("s4c_projects")
          .where("id", isEqualTo: uuid)
          .get(); // No project found with this UUID
    }
    if (query.docs.isEmpty) {
      return item;
    }
    final _doc = query.docs.first;

    // final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
    // data["id"] = _doc.id;
    item = SProject.fromJson(_doc);
    return item;
  }

  static Future<SProject> byUuid(String uuid) async {
    return await getByUuid(uuid);
  }

  Future<void> loadObjs2() async {
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
    String objColor = statusObj.color.replaceAll("#", "");
    int color = int.parse("0xff$objColor");
    //int color = int.parse("0xff${statusObj.color}");
    return Color(color);
  }

  Future<Folder> createFolder() async {
    Folder f = Folder(name, "");
    f.loc = await f.getLoc();
    f.save();
    folder = f.uuid;
    folderObj = f;

    save();
    createProjectFolders(f);
    return f;
  }

  Future<Folder> getFolder() async {
    if (folder == "") {
      return createFolder();
    }
    Folder? f = await Folder.getFolderByUuid(folder);
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
    if (uuids.isEmpty) return items;
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_projects")
        .where("uuid", whereIn: uuids)
        .get();
    for (var doc in query.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      final item = SProject.fromJson(doc);
      items.add(item);
    }
    return items;
  }

  static Future<String> getProjectName(String uuid) async {
    SProject proj = SProject("");
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_projects")
        .where("uuid", isEqualTo: uuid)
        .get();
    final dbP = query.docs.first;
    // final Map<String, dynamic> data = dbP.data() as Map<String, dynamic>;
    // data["id"] = dbP.id;
    proj = SProject.fromJson(dbP);
    return proj.name;
  }

  // static Future<List> getProjects() async {
  //   List items = [];
  //   QuerySnapshot queryProject = await dbProject.get();
  //   for (var doc in queryProject.docs) {
  //     final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //     data["id"] = doc.id;
  //     final item = SProject.fromJson(data);
  //     try {
  //       /*item.ambitObj = await item.getAmbit();
  //       item.typeObj = await item.getProjectType();
  //       item.managerObj = await item.getManager();
  //       item.programmeObj = await item.getProgramme();
  //       item.financiersObj = await item.getFinanciers();
  //       item.partnersObj = await item.getPartners();
  //       item.datesObj = await item.getDates();*/
  //       // item.typeObj = await item.getProjectType();
  //       // item.managerObj = await item.getManager();
  //       // item.programmeObj = await item.getProgramme();
  //       // item.financiersObj = await item.getFinanciers();
  //       // item.partnersObj = await item.getPartners();
  //       // item.datesObj = await item.getDates();
  //     } catch (e) {}
  //     items.add(item);
  //   }
  //   return items;
  // }

  static Future<List<KeyValue>> getProjectsHash() async {
    List<KeyValue> items = [];
    QuerySnapshot queryProject =
        await FirebaseFirestore.instance.collection("s4c_projects").get();
    for (var doc in queryProject.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      final item = SProject.fromJson(doc);
      items.add(item.toKeyValue());
    }
    return items;
  }

  static Future<SProject> getProjectById(String id) async {
    DocumentSnapshot query = await FirebaseFirestore.instance
        .collection("s4c_projects")
        .doc(id)
        .get();
    // final Map<String, dynamic> data = query.data() as Map<String, dynamic>;
    // data["id"] = query.id;
    return SProject.fromJson(query);
  }

  static Future<SProject?> getProjectByUuid(String uuid) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_projects")
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // data["id"] = doc.id;
    return SProject.fromJson(doc);
  }

  static Future<List<SProject>> getProjectsByType(String type) async {
    List<SProject> items = [];
    ProjectType pt = await ProjectType.byName(type);
    if (pt.id == "") {
      return items; // No project type found
    }
    items = await SProject.byProjectType([pt]);
    // QuerySnapshot query =
    //     await dbProjectType.where("name", isEqualTo: type).get();
    // if (query.docs.isNotEmpty) {
    //   final doc = query.docs.first;
    //   final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //   data["id"] = doc.id;
    //   ProjectType pt = ProjectType.fromJson(data);

    //   query = await dbProject.where("type", isEqualTo: pt.uuid).get();
    //   for (var doc in query.docs) {
    //     final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //     data["id"] = doc.id;
    //     final item = SProject.fromJson(data);
    //     items.add(item);
    //   }
    // }
    return items;
  }

  static Future<List<SProject>> getProjectsByProgramme(String programme) async {
    List<SProject> items = <SProject>[];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_projects")
        .where("programme", isEqualTo: programme)
        .get();
    for (var doc in query.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      final item = SProject.fromJson(doc);
      items.add(item);
    }
    return items;
  }
}

//--------------------------------------------------------------
//                       PROJECT TYPE
//--------------------------------------------------------------

class ProjectType {
  static const String tbName = "s4c_project_type";
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
      FirebaseFirestore.instance.collection(tbName).add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
  }

  static Future<ProjectType> byUuid(uuid) async {
    ProjectType item = ProjectType("");
    await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data();
      data["id"] = doc.id;
      item = ProjectType.fromJson(data);
    });
    return item;
  }

  static Future<ProjectType> byName(name) async {
    ProjectType item = ProjectType("");
    await FirebaseFirestore.instance
        .collection(tbName)
        .where("name", isEqualTo: name)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data();
      data["id"] = doc.id;
      item = ProjectType.fromJson(data);
    });
    return item;
  }

  static Future<List<ProjectType>> getProjectTypes() async {
    List<ProjectType> items = <ProjectType>[];
    Query query = FirebaseFirestore.instance.collection(ProjectType.tbName);

    QuerySnapshot queryProjectType = await query.get(
      const GetOptions(source: Source.cache),
    );

    if (queryProjectType.docs.isEmpty) {
      queryProjectType = await query.get();
    }

    for (var doc in queryProjectType.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey("id") || (data["id"] != doc.id)) {
        FirebaseFirestore.instance
            .collection(ProjectType.tbName)
            .doc(doc.id)
            .update({"id": doc.id});
      }
      data["id"] = doc.id;
      final item = ProjectType.fromJson(data);
      items.add(item);
    }

    return items;
  }

  static Future<List<KeyValue>> getProjectTypesHash() async {
    List<KeyValue> items = [];
    QuerySnapshot queryProjectType =
        await FirebaseFirestore.instance.collection(ProjectType.tbName).get();

    for (var doc in queryProjectType.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectType.fromJson(data);
      items.add(item.toKeyValue());
    }

    return items;
  }
}

//--------------------------------------------------------------
//                       PROJECT STATUS
//--------------------------------------------------------------

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
      // dbProjectStatus.add(data);
      FirebaseFirestore.instance.collection("s4c_project_status").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_project_status")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_project_status")
        .doc(id)
        .delete();
  }

  static Future<ProjectStatus> byUuid(uuid) async {
    ProjectStatus item = ProjectStatus("");
    await FirebaseFirestore.instance
        .collection("s4c_project_status")
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data();
      data["id"] = doc.id;
      item = ProjectStatus.fromJson(data);
    });
    return item;
  }

  static Future<List<ProjectStatus>> getProjectStatus() async {
    List<ProjectStatus> items = [];
    QuerySnapshot queryProjectStatus =
        await FirebaseFirestore.instance.collection("s4c_project_status").get();

    for (var doc in queryProjectStatus.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectStatus.fromJson(data);
      items.add(item);
    }

    return items;
  }

  static Future<List<KeyValue>> getProjectStatusHash() async {
    List<KeyValue> items = [];
    // QuerySnapshot queryProjectStatus = await dbProjectStatus.get();
    QuerySnapshot queryProjectStatus = await FirebaseFirestore.instance
        .collection("s4c_project_status")
        .orderBy("name")
        .get();

    for (var doc in queryProjectStatus.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectStatus.fromJson(data);
      items.add(item.toKeyValue());
    }

    return items;
  }
}

//--------------------------------------------------------------
//                       PROJECT DATES
//--------------------------------------------------------------
DateTime maxDate = DateTime(2100, 12, 31);
DateTime limitDate = DateTime(2100, 12, 30);

class ProjectDates {
  static String tbName = "s4c_project_dates";
  DocumentReference? docRef;
  Function? onChanged;

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

  ProjectDates update(Map<String, dynamic> data) {
    if (data.containsKey("approved")) {
      approved = getDate(data["approved"]);
    }
    if (data.containsKey("start")) {
      start = getDate(data["start"]);
    }
    if (data.containsKey("end")) {
      end = getDate(data["end"]);
    }
    if (data.containsKey("justification")) {
      justification = getDate(data["justification"]);
    }
    if (data.containsKey("delivery")) {
      delivery = getDate(data["delivery"]);
    }
    if (data.containsKey("sended")) {
      sended = getDate(data["sended"]);
    }
    if (data.containsKey("reject")) {
      reject = getDate(data["reject"]);
    }
    if (data.containsKey("refuse")) {
      refuse = getDate(data["refuse"]);
    }

    return this;
  }

  static ProjectDates fromJson(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return ProjectDates("");
    }
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    ProjectDates item = ProjectDates(data["project"]);
    item.docRef = doc.reference;
    item.id = doc.id;
    item.uuid = data["uuid"];
    item.approved = getDate(data["approved"]);
    item.start = getDate(data["start"]);
    item.end = getDate(data["end"]);
    item.justification = getDate(data["justification"]);
    item.delivery = getDate(data["delivery"]);
    item.sended = getDate(data["sended"]);
    item.reject = getDate(data["reject"]);
    item.refuse = getDate(data["refuse"]);
    item.docRef?.snapshots().listen((event) {
      if (event.data() == null) {
        return;
      }
      final Map<String, dynamic> data = event.data() as Map<String, dynamic>;
      item.update(data);
      item.onChanged?.call();
    });

    return item;
  }

  // ProjectDates.fromJson(Map<String, dynamic> json)
  //     : id = json["id"],
  //       uuid = json["uuid"],
  //       approved = json["approved"].toDate(),
  //       start = json["start"].toDate(),
  //       end = json["end"].toDate(),
  //       justification = json["justification"].toDate(),
  //       delivery = json["delivery"].toDate(),
  //       sended = json["sended"].toDate(),
  //       reject = json["reject"].toDate(),
  //       refuse = json["refuse"].toDate(),

  //       /*approved = (json["approved"] != null) ? json["approved"].toDate() : "",
  //       start = (json["start"] != null) ? json["start"].toDate() : "",
  //       end = (json["end"] != null) ? json["end"].toDate() : "",
  //       justification = (json["justification"] != null)
  //           ? json["justification"].toDate()
  //           : "",
  //       delivery = (json["delivery"] != null) ? json["delivery"].toDate() : "",
  //       sended = (json["sended"] != null) ? json["sended"].toDate() : "",
  //       reject = (json["reject"] != null) ? json["reject"].toDate() : "",*/
  //       project = json["project"];

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
      FirebaseFirestore.instance.collection(tbName).add(data).then((value) {
        id = value.id;
        docRef = value;
        docRef?.update({'id': id});
        docRef?.snapshots().listen((event) {
          final Map<String, dynamic> data =
              event.data() as Map<String, dynamic>;
          update(data);
          onChanged?.call();
        });
      });
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
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
    try {
      return approved.compareTo(limitDate) > 0
          ? ""
          : DateFormat("dd-MM-yyyy").format(approved);
    } catch (e) {
      return "";
    }
  }

  String getStartStr() {
    try {
      return start.compareTo(limitDate) > 0
          ? ""
          : DateFormat("dd-MM-yyyy").format(start);
    } catch (e) {
      return "";
    }
  }

  String getEndStr() {
    try {
      return end.compareTo(limitDate) > 0
          ? ""
          : DateFormat("dd-MM-yyyy").format(end);
    } catch (e) {
      return "";
    }
  }

  String getJustificationStr() {
    try {
      return justification.compareTo(limitDate) > 0
          ? ""
          : DateFormat("dd-MM-yyyy").format(justification);
    } catch (e) {
      return "";
    }
  }

  String getDeliveryStr() {
    try {
      return delivery.compareTo(limitDate) > 0
          ? ""
          : DateFormat("dd-MM-yyyy").format(delivery);
    } catch (e) {
      return "";
    }
  }

  String getSendedStr() {
    try {
      return sended.compareTo(limitDate) > 0
          ? ""
          : DateFormat("dd-MM-yyyy").format(sended);
    } catch (e) {
      return "";
    }
  }

  String getRejectStr() {
    try {
      return reject.compareTo(limitDate) > 0
          ? ""
          : DateFormat("dd-MM-yyyy").format(reject);
    } catch (e) {
      return "";
    }
  }

  String getRefuseStr() {
    try {
      return refuse.compareTo(limitDate) > 0
          ? ""
          : DateFormat("dd-MM-yyyy").format(refuse);
    } catch (e) {
      return "";
    }
  }

  static Future<List<ProjectDates>> getProjectDates() async {
    List<ProjectDates> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(ProjectDates.tbName).get();

    for (var doc in query.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      final item = ProjectDates.fromJson(doc);
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['id'].isEmpty) {
        doc.reference.update({'id': doc.id});
      }
      items.add(item);
    }

    return items;
  }

  static Future<ProjectDates> getProjectDatesById(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(ProjectDates.tbName)
        .doc(id)
        .get();
    // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // data["id"] = doc.id;
    return ProjectDates.fromJson(doc);
  }

  static Future<ProjectDates> getProjectDatesByProject(String project) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(ProjectDates.tbName)
        .where("project", isEqualTo: project)
        .get();
    if (query.docs.isEmpty) {
      ProjectDates dates = ProjectDates(project);
      dates.save();
      return dates;
    }
    final dbRes = query.docs.first;
    // final Map<String, dynamic> data = dbRes.data() as Map<String, dynamic>;
    // data["id"] = dbRes.id;
    return ProjectDates.fromJson(dbRes);
  }
}

//--------------------------------------------------------------
//                       PROJECT DATES TRACING
//--------------------------------------------------------------

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
    CollectionReference dbDatesTra =
        FirebaseFirestore.instance.collection("s4c_project_dates_tracing");
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
    // CollectionReference dbDatesTra = db.collection("s4c_project_dates_tracing");
    await FirebaseFirestore.instance
        .collection("s4c_project_dates_tracing")
        .doc(id)
        .delete();
  }

  static Future<List> getProjectDatesTracing() async {
    List items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_project_dates_tracing")
        .get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectDatesTracing.fromJson(data);
      items.add(item);
    }

    return items;
  }

  static Future<List> getProjectDatesTracingByProject(String project) async {
    List items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_project_dates_tracing")
        .where("project", isEqualTo: project)
        .get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectDatesTracing.fromJson(data);
      items.add(item);
    }

    return items;
  }
}

//--------------------------------------------------------------
//                       PROJECT DATES AUDIT
//--------------------------------------------------------------

class ProjectDatesAudit {
  static String tbName = "s4c_project_dates_audit";

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
    // CollectionReference dbDatesAudit = FirebaseFirestore.instance.collection("s4c_project_dates_audit");
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(ProjectDatesAudit.tbName).add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection(ProjectDatesAudit.tbName)
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    // CollectionReference dbDatesAudit = FirebaseFirestore.instance.collection("s4c_project_dates_audit");
    await FirebaseFirestore.instance
        .collection(ProjectDatesAudit.tbName)
        .doc(id)
        .delete();
  }

  static Future<List<ProjectDatesAudit>> getProjectDatesAudit() async {
    // CollectionReference dbDatesAudit = FirebaseFirestore.instance.collection("s4c_project_dates_audit");
    List<ProjectDatesAudit> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(ProjectDatesAudit.tbName)
        .get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectDatesAudit.fromJson(data);
      items.add(item);
    }

    return items;
  }

  static Future<List<ProjectDatesAudit>> getProjectDatesAuditByProject(
      String project) async {
    // CollectionReference dbDatesAudit = FirebaseFirestore.instance.collection("s4c_project_dates_audit");
    List<ProjectDatesAudit> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(ProjectDatesAudit.tbName)
        .where("project", isEqualTo: project)
        .get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectDatesAudit.fromJson(data);
      items.add(item);
    }

    return items;
  }
}

//--------------------------------------------------------------
//                       PROJECT DATES EVALUATION
//--------------------------------------------------------------

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
    // CollectionReference dbDatesEval = db.collection("s4c_project_dates_eval");
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_project_dates_eval").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_project_dates_eval")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    // CollectionReference dbDatesEval = db.collection("s4c_project_dates_eval");
    await FirebaseFirestore.instance
        .collection("s4c_project_dates_eval")
        .doc(id)
        .delete();
  }

  static Future<List> getProjectDatesEval() async {
    // CollectionReference dbDatesEval = db.collection("s4c_project_dates_eval");
    List items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_project_dates_eval")
        .get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectDatesEval.fromJson(data);
      items.add(item);
    }

    return items;
  }

  static Future<List> getProjectDatesEvalByProject(String project) async {
    // CollectionReference dbDatesEval = db.collection("s4c_project_dates_eval");
    List items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_project_dates_eval")
        .where("project", isEqualTo: project)
        .get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectDatesEval.fromJson(data);
      items.add(item);
    }

    return items;
  }
}

//--------------------------------------------------------------
//                       PROJECT LOCATION
//--------------------------------------------------------------

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
    // CollectionReference dbLocation = db.collection("s4c_project_location");
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      var item = await FirebaseFirestore.instance
          .collection("s4c_project_location")
          .add(data);
      id = item.id;
      item.update({'id': id});
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_project_location")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    // CollectionReference dbLocation = db.collection("s4c_project_location");
    await FirebaseFirestore.instance
        .collection("s4c_project_location")
        .doc(id)
        .delete();
  }

  Future<Country> getCountry() async {
    try {
      // QuerySnapshot query =
      //     await dbCountry.where("uuid", isEqualTo: country).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Country.fromJson(data);
      Country? countryObj = await Country.byUuid(country);
      return countryObj ?? Country("");
    } catch (e) {
      return Country("");
    }
  }

  Future<Province> getProvince() async {
    try {
      // QuerySnapshot query =
      //     await dbProvince.where("uuid", isEqualTo: province).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Province.fromJson(data);
      return await Province.byUuid(province);
    } catch (e) {
      return Province("");
    }
  }

  Future<Region> getRegion() async {
    try {
      //if (region != "") {
      // QuerySnapshot query =
      //     await dbRegion.where("uuid", isEqualTo: region).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Region.fromJson(data);
      //}
      return await Region.byUuid(region);
    } catch (e) {}
    return Region("");
  }

  Future<Town> getTown() async {
    try {
      // //if (town != "") {
      // QuerySnapshot query = await dbTown.where("uuid", isEqualTo: town).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Town.fromJson(data);
      // //}
      return await Town.byUuid(town);
    } catch (e) {}
    return Town("");
  }

  static Future<List<ProjectLocation>> getProjectLocation() async {
    // CollectionReference dbLocation = db.collection("s4c_project_location");
    List<ProjectLocation> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_project_location")
        .get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectLocation.fromJson(data);
      items.add(item);
    }

    return items;
  }

  static Future<List<ProjectLocation>> getProjectLocationByProject(
      String _project) async {
    // CollectionReference dbLocation = db.collection("s4c_project_location");
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_project_location")
        .where("project", isEqualTo: _project)
        .get();

    List<ProjectLocation> items = [];

    if (query.docs.isEmpty) {
      ProjectLocation loc = ProjectLocation(_project);
      loc.save();
      return [loc];
    }

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = ProjectLocation.fromJson(data);
      item.countryObj = await item.getCountry();
      item.provinceObj = await item.getProvince();
      item.regionObj = await item.getRegion();
      item.townObj = await item.getTown();
      items.add(item);
    }

    return items;

    // final dbRes = query.docs.first;
    // final Map<String, dynamic> data = dbRes.data() as Map<String, dynamic>;
    // data["id"] = dbRes.id;
    // ProjectLocation pl = ProjectLocation.fromJson(data);
    // pl.countryObj = await pl.getCountry();
    // pl.provinceObj = await pl.getProvince();
    // pl.regionObj = await pl.getRegion();
    // pl.townObj = await pl.getTown();
    // return pl;
  }
}

//--------------------------------------------------------------
//                       PROJECT REFORMULATION
//--------------------------------------------------------------

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
    // CollectionReference dbReformulation = db.collection("s4c_reformulation");
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_reformulation").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_reformulation")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    // CollectionReference dbReformulation = db.collection("s4c_reformulation");
    await FirebaseFirestore.instance
        .collection("s4c_reformulation")
        .doc(id)
        .delete();
  }

  Future<void> loadObjs2() async {
    projectObj = await getProject();
    financierObj = await getFinancier();
    typeObj = await getType();
    statusObj = await getStatus();
    folderObj = await getFolder();
  }

  Future<SProject> getProject() async {
    try {
      // QuerySnapshot query =
      //     await dbProject.where("uuid", isEqualTo: project).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return SProject.fromJson(data);
      return await SProject.byUuid(project);
    } catch (e) {
      return SProject("");
    }
  }

  Future<Organization> getFinancier() async {
    try {
      // QuerySnapshot query =
      //     await dbOrg.where("uuid", isEqualTo: financier).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Organization.fromJson(data);
      return await Organization.byUuid(financier);
    } catch (e) {
      return Organization("");
    }
  }

  Future<ReformulationType> getType() async {
    try {
      // QuerySnapshot query =
      //     await dbReformulationType.where("uuid", isEqualTo: type).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return ReformulationType.fromJson(data);
      return await ReformulationType.byUuid(type);
    } catch (e) {
      return ReformulationType();
    }
  }

  Future<ReformulationStatus> getStatus() async {
    try {
      // QuerySnapshot query =
      //     await dbReformulationStatus.where("uuid", isEqualTo: status).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return ReformulationStatus.fromJson(data);
      return await ReformulationStatus.byUuid(status);
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
    Folder? f = await Folder.getFolderByUuid(folder);
    if (f == null) {
      return createFolder();
    }
    return f;
  }

  static Future<List> getReformulations() async {
    // CollectionReference dbReformulation = db.collection("s4c_reformulation");
    List items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_reformulation").get();

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

  static Future<List> getReformulationsByProject(uuid) async {
    // CollectionReference dbReformulation = db.collection("s4c_reformulation");
    List items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_reformulation")
        .where("project", isEqualTo: uuid)
        .get();

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
}

//--------------------------------------------------------------
//                       PROJECT REFORMULATION TYPE
//--------------------------------------------------------------

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
    final dbReformulationType =
        FirebaseFirestore.instance.collection("s4c_project_reformulation_type");
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
    final dbReformulationType =
        FirebaseFirestore.instance.collection("s4c_project_reformulation_type");
    await dbReformulationType.doc(id).delete();
  }

  static Future<ReformulationType> byUuid(uuid) async {
    final dbReformulationType =
        FirebaseFirestore.instance.collection("s4c_project_reformulation_type");
    ReformulationType item = ReformulationType();
    await dbReformulationType
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data();
      data["id"] = doc.id;
      item = ReformulationType.fromJson(data);
    });
    return item;
  }

  static Future<List> getReformulationTypes() async {
    CollectionReference dbReformulationType =
        FirebaseFirestore.instance.collection("s4c_project_reformulation_type");
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

  static Future<List<KeyValue>> getReformulationTypesHash() async {
    CollectionReference dbReformulationType =
        FirebaseFirestore.instance.collection("s4c_project_reformulation_type");
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
}

//--------------------------------------------------------------
//                       PROJECT REFORMULATION STATUS
//--------------------------------------------------------------

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
    CollectionReference dbReformulationStatus = FirebaseFirestore.instance
        .collection("s4c_project_reformulation_status");
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
    CollectionReference dbReformulationStatus = FirebaseFirestore.instance
        .collection("s4c_project_reformulation_status");
    await dbReformulationStatus.doc(id).delete();
  }

  static Future<ReformulationStatus> byUuid(uuid) async {
    CollectionReference dbReformulationStatus = FirebaseFirestore.instance
        .collection("s4c_project_reformulation_status");
    ReformulationStatus item = ReformulationStatus();
    await dbReformulationStatus
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = ReformulationStatus.fromJson(data);
    });
    return item;
  }

  static Future<List> getReformulationStatus() async {
    CollectionReference dbReformulationStatus = FirebaseFirestore.instance
        .collection("s4c_project_reformulation_status");
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

  static Future<List<KeyValue>> getReformulationStatusHash() async {
    CollectionReference dbReformulationStatus = FirebaseFirestore.instance
        .collection("s4c_project_reformulation_status");
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
}

//--------------------------------------------------------------
//                       PROGRAMME
//--------------------------------------------------------------

class Programme {
  static const tbName = "s4c_programme";

  String id = "";
  String uuid = "";
  String name = "";
  String title = "";
  String code = "";
  String description = "";
  String impact = "";
  String logo = "";
  int projects = 0;

  Programme(this.name);

  Programme.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        code = (json.containsKey("code") ? json["code"] : ""),
        uuid = json["uuid"],
        name = json['name'],
        title = json['title'],
        description = json['description'],
        impact = json['impact'],
        logo = json['logo'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'code': code,
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
    CollectionReference dbProgramme =
        FirebaseFirestore.instance.collection(tbName);
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
    CollectionReference dbProgramme =
        FirebaseFirestore.instance.collection(tbName);
    await dbProgramme.doc(id).delete();
    createLog("Borrado el programa: $name");
  }

  Future<void> getProjects() async {
    List<SProject> projectsList = await SProject.getProjectsByProgramme(uuid);
    if (projectsList.isEmpty) {
      projects = 0;
    } else {
      projects = projectsList.length;
    }
  }

  Future<int> getProjectsByStatus(status) async {
    if (status == "") {
      return 0;
    }
    List<SProject> projectsList = await SProject.getProjectsByProgramme(uuid);
    if (projectsList.isEmpty) {
      return 0;
    }
    return projectsList.where((project) => project.status == status).length;

    // QuerySnapshot query = await dbProject
    //     .where("programme", isEqualTo: uuid)
    //     .where("status", isEqualTo: status)
    //     .get();
    // return query.docs.length;
  }

  static Future<Programme> byUuid(uuid) async {
    Programme item = Programme("");
    final dbProgramme = FirebaseFirestore.instance.collection(Programme.tbName);
    await dbProgramme.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data();
      data["id"] = doc.id;
      item = Programme.fromJson(data);
    });
    return item;
  }

  static Future<List<Programme>> getProgrammes() async {
    CollectionReference dbProgramme =
        FirebaseFirestore.instance.collection(Programme.tbName);
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

  static Future<List<KeyValue>> getProgrammesHash() async {
    CollectionReference dbProgramme =
        FirebaseFirestore.instance.collection(Programme.tbName);
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
}

//--------------------------------------------------------------
//                       PROGRAMME INDICATORS
//--------------------------------------------------------------

class ProgrammeIndicators {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  String unit = "";
  int order = 0;
  String programme;
  double expected = 0;
  double obtained = 0;

  ProgrammeIndicators(this.programme);

  ProgrammeIndicators.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        unit = json['unit'],
        order = json['order'],
        programme = json['programme'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'unit': unit,
        'order': order,
        'programme': programme,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    final dbProgrammeIndicators =
        FirebaseFirestore.instance.collection("s4c_programme_indicators");
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
    final dbProgrammeIndicators =
        FirebaseFirestore.instance.collection("s4c_programme_indicators");
    await dbProgrammeIndicators.doc(id).delete();
  }

  Future<void> getSumValues() async {
    List goalIndicators = await GoalIndicator.getGoalIndicatorsByCode(uuid);
    for (GoalIndicator gi in goalIndicators) {
      try {
        expected += double.parse(gi.expected);
      } catch (e) {}
      try {
        obtained += double.parse(gi.obtained);
      } catch (e) {}
    }
  }

  double getResultPercent() {
    if (expected > 0) {
      return obtained / expected;
    } else {
      return 1;
    }
  }

  static Future<List<ProgrammeIndicators>> getProgrammesIndicators(uuid) async {
    final dbProgrammeIndicators =
        FirebaseFirestore.instance.collection("s4c_programme_indicators");
    List<ProgrammeIndicators> items = [];
    try {
      QuerySnapshot queryProgrammeIndicators = await dbProgrammeIndicators
          // .orderBy("order", descending: true)
          .where("programme", isEqualTo: uuid)
          .get();

      for (var doc in queryProgrammeIndicators.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        final item = ProgrammeIndicators.fromJson(data);
        await item.getSumValues();
        items.add(item);
      }
      items.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      print(e);
    }
    return items;
  }

  static Future<List<ProgrammeIndicators>> all() async {
    final dbProgrammeIndicators =
        FirebaseFirestore.instance.collection("s4c_programme_indicators");
    List<ProgrammeIndicators> items = [];
    await dbProgrammeIndicators.get().then((value) {
      for (var doc in value.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        final item = ProgrammeIndicators.fromJson(data);
        items.add(item);
      }
    });
    return items;
  }

  static Future<List<KeyValue>> getProgrammesIndicatorsHash() async {
    final dbProgrammeIndicators =
        FirebaseFirestore.instance.collection("s4c_programme_indicators");
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
}
