import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_tracking.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;

//--------------------------------------------------------------
//                           TASKS
//--------------------------------------------------------------

Map<String, dynamic> getOccupationCell(val) {
  Color col = Colors.green;
  if (val >= 30 && val <= 60) col = Colors.orange;
  if (val > 60) col = Colors.red;

  return {'color': col, 'text': val.toStringAsFixed(2)};
}

class STask {
  static const String tbName = "s4c_tasks";
  DocumentReference? docRef;
  Function? onChanged;

  String id = "";
  String uuid = "";
  String name;
  String description = "";
  String comments = "";
  String status = "";
  String priority = "";
  int duration = 0;
  int durationMin = 0;
  DateTime dealDate = DateTime.now();
  DateTime deadLineDate = DateTime.now();
  DateTime newDeadLineDate = DateTime.now();
  String sender = ""; //Responsable
  String project = "";
  String programme = "";
  String folder = "";
  List<String> assigned = []; //Ejecutores
  List<String> receivers = []; //Destinatarios
  List<String> receiversOrg = []; //Destinatarios
  //List<String> programmes = [];
  bool public = false;
  bool revision = false;

  SProject projectObj = SProject("");
  Programme programmeObj = Programme("");
  TasksStatus statusObj = TasksStatus("");
  Profile? senderObj;
  Folder? folderObj;
  List<Profile> assignedObj = [];
  List<Contact> receiversObj = [];
  List<Organization> receiversOrgObj = [];
  String rel = "";
  String assignedStr = "";
  StreamSubscription<DocumentSnapshot>? subscription;
  //List<Programme> programmesObj = [];

  List<KeyValue> progList = [];
  List<KeyValue> projList = [];

  STask(this.name);

  STask update(Map<String, dynamic> json) {
    if (json['id'] != id) return this;

    uuid = json["uuid"];
    name = json['name'] ?? "";
    description = json['description'] ?? "";
    comments = json['comments'] ?? "";
    status = json['status'] ?? "";
    priority = json['priority'] ?? "";
    duration = json['duration'] ?? 0;
    durationMin = json['durationMin'] ?? 0;
    dealDate = (json['dealDate'] != null)
        ? (json['dealDate'] as Timestamp).toDate()
        : DateTime.now();
    deadLineDate = (json['deadLineDate'] != null)
        ? (json['deadLineDate'] as Timestamp).toDate()
        : DateTime.now();
    newDeadLineDate = (json['newDeadLineDate'] != null)
        ? (json['newDeadLineDate'] as Timestamp).toDate()
        : DateTime.now();
    sender = json['sender'] ?? "";
    project = json['project'] ?? "";
    programme = json['programme'] ?? "";
    folder = json['folder'] ?? "";
    assigned =
        (json['assigned'] as List).map((item) => item as String).toList();
    receivers =
        (json['receivers'] as List).map((item) => item as String).toList();
    receiversOrg =
        (json['receiversOrg'] as List).map((item) => item as String).toList();
    // programmes = (json['programmes'] as List).map((item) => item as String).toList();
    public = json['public'] ?? false;
    revision = json['revision'] ?? false;

    return this;
  }

  // static STask fromJson(Map<String, dynamic> json) {
  static STask fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;

    STask task = STask(json['name']);
    task.docRef = doc.reference;
    // task.id = json["id"];
    if (doc.id != json["id"]) {
      doc.reference.update({"id": doc.id});
    }

    task.id = doc.id;
    task.uuid = json["uuid"];
    task.description = json['description'] ?? "";
    task.comments = json['comments'] ?? "";
    task.status = json['status'] ?? "";
    task.priority = json['priority'] ?? "";
    task.duration = json['duration'] ?? 0;
    task.durationMin = json['durationMin'] ?? 0;
    task.dealDate = (json['dealDate'] != null)
        ? (json['dealDate'] as Timestamp).toDate()
        : DateTime.now();
    task.deadLineDate = (json['deadLineDate'] != null)
        ? (json['deadLineDate'] as Timestamp).toDate()
        : DateTime.now();
    task.newDeadLineDate = (json['newDeadLineDate'] != null)
        ? (json['newDeadLineDate'] as Timestamp).toDate()
        : DateTime.now();
    task.sender = json['sender'] ?? "";
    task.project = json['project'] ?? "";
    task.programme = json['programme'] ?? "";
    task.folder = json['folder'] ?? "";
    task.assigned =
        (json['assigned'] as List).map((item) => item as String).toList();
    task.receivers =
        (json['receivers'] as List).map((item) => item as String).toList();
    task.receiversOrg =
        (json['receiversOrg'] as List).map((item) => item as String).toList();
    // task.programmes = (json['programmes'] as List).map((item) => item as String).toList();
    task.public = json['public'] ?? false;
    task.revision = json['revision'] ?? false;

    task.subscription = task.docRef!.snapshots().listen((event) async {
      task.docRef = event.reference;
      task.update(event.data() as Map<String, dynamic>);
      if (task.onChanged != null) task.onChanged!();
    });

    // id = json["id"],
    //   uuid = json["uuid"],
    //   name = json['name'],
    //   description = json['description'],
    //   comments = json['comments'],
    //   status = json['status'],
    //   priority = json['priority'],
    //   duration = json['duration'],
    //   durationMin = json['durationMin'],
    //   dealDate = json['dealDate'].toDate(),
    //   deadLineDate = json['deadLineDate'].toDate(),
    //   newDeadLineDate = json['newDeadLineDate'].toDate(),
    //   sender = json['sender'],
    //   project = json['project'],
    //   programme = json['programme'],
    //   folder = json['folder'],
    //   assigned =
    //       (json['assigned'] as List).map((item) => item as String).toList(),
    //   receivers =
    //       (json['receivers'] as List).map((item) => item as String).toList(),
    //   receiversOrg = (json['receiversOrg'] as List)
    //       .map((item) => item as String)
    //       .toList(),
    //   /*programmes =
    //       (json['programmes'] as List).map((item) => item as String).toList(),*/
    //   public = json['public'],
    //   revision = json['revision'];
    return task;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'comments': comments,
        'status': status,
        'priority': priority,
        'duration': duration,
        'durationMin': durationMin,
        'dealDate': dealDate,
        'deadLineDate': deadLineDate,
        'newDeadLineDate': newDeadLineDate,
        'sender': sender,
        'project': project,
        'programme': programme,
        'folder': folder,
        'assigned': assigned,
        'receivers': receivers,
        'receiversOrg': receiversOrg,
        //'programmes': programmes,
        'public': public,
        'revision': revision,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection(tbName)
          .add(data)
          .then((value) => id = value.id);
      FirebaseFirestore.instance.collection(tbName).doc(id).update({'id': id});
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
  }

  Future<void> updateAssigned() async {
    await FirebaseFirestore.instance
        .collection(tbName)
        .doc(id)
        .update({"assigned": assigned});
  }

  /*Future<void> updateProgrammes() async {
    await dbTasks.doc(id).update({"programmes": programmes});
  }*/

  Future<STask> reload() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection(tbName).doc(id).get();
    // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // data["id"] = doc.id;
    STask.fromJson(doc);

    await getProject();
    await getStatus();
    await getSender();
    await getAssigned();
    await getReceivers();
    await getReceiversOrg();
    //await getProgrammes();
    return this;
  }

  Future<void> loadObjs() async {
    await getStatus();
    await getAssigned();
    getAssignedStr();
    await getRelations();
  }

  Future<void> getProject() async {
    if (project != "") {
      // QuerySnapshot query =
      //     await dbProject.where("uuid", isEqualTo: project).get();
      // if (query.docs.isEmpty) {
      //   projectObj = SProject("");
      // } else {
      //   final doc = query.docs.first;
      //   final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      //   data["id"] = doc.id;
      //   projectObj = SProject.fromJson(data);
      // }
      projectObj = await SProject.byUuid(project);
    }
  }

  Future<void> getProgramme() async {
    if (programme != "") {
      // QuerySnapshot query =
      //     await dbProgramme.where("uuid", isEqualTo: programme).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // programmeObj = Programme.fromJson(data);
      programmeObj = await Programme.byUuid(programme);
    }
  }

  Future<void> getStatus() async {
    // if (status != "") {
    //   QuerySnapshot query =
    //       await dbTasksStatus.where("uuid", isEqualTo: status).get();
    //   final doc = query.docs.first;
    //   final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //   data["id"] = doc.id;
    //   statusObj = TasksStatus.fromJson(data);
    // } else {
    //   statusObj = TasksStatus("Sin estado");
    // }
    if (status != "") {
      statusObj = await TasksStatus.byUuid(status);
    }
  }

  KeyValue statusKeyValue(List statusList) {
    for (KeyValue kv in statusList) {
      if (kv.key == status) {
        return KeyValue(status, kv.value);
      }
    }
    return KeyValue("", "");
  }

  /*Future<void> getSender() async {
    if (sender != "") {
      QuerySnapshot query =
          await dbContacts.where("uuid", isEqualTo: sender).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      senderObj = Contact.fromJson(data);
    }
  }*/
  Future<void> getSender() async {
    // final dbProfile = db.collection("s4c_profiles");
    // if (sender != "") {
    //   QuerySnapshot query =
    //       await dbProfile.where("email", isEqualTo: sender).get();
    //   final doc = query.docs.first;
    //   final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //   data["id"] = doc.id;
    //   senderObj = Profile.fromJson(data);
    // }
    if (sender != "") {
      senderObj = await Profile.byEmail(sender);
    }
  }

  Future<void> getAssigned() async {
    List<Profile> listAssigned = [];
    for (String item in assigned) {
      try {
        // QuerySnapshot query =
        //     await dbProfile.where("email", isEqualTo: item).get();
        // final doc = query.docs.first;
        // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // data["id"] = doc.id;
        // Profile prof = Profile.fromJson(data);
        Profile prof = await Profile.byEmail(item);
        listAssigned.add(prof);
      } catch (e) {
        dev.log(e.toString());
      }
    }
    assignedObj = listAssigned;
  }

  //String getAssignedStr() {
  void getAssignedStr() {
    String assigStr = "";
    for (Profile item in assignedObj) {
      assigStr += "${item.name},";
    }
    assigStr = (assigStr.isNotEmpty)
        ? assigStr.substring(0, assigStr.length - 1)
        : assigStr;
    assignedStr = assigStr;
    //return assignedStr;
  }

  String getModelRelation(model) {
    if (model == "s4c_activities") return "Actividad";
    if (model == "s4c_contact_tracking") return "Seguimiento";
    return "";
  }

  Future<String> getObjRelation(model, objId) async {
    if (model == "s4c_activities") {
      // final q =
      //     await db.collection(model).where("uuid", isEqualTo: objId).get();
      // final d = q.docs.first;
      // final Map<String, dynamic> data = d.data();
      // data["id"] = d.id;
      // Activity act = Activity.fromJson(data);
      Activity act = await Activity.byUuid(objId);
      return act.name;
    } else {
      if (model == "s4c_contact_tracking") {
        // final q =
        //     await db.collection(model).where("uuid", isEqualTo: objId).get();
        // final d = q.docs.first;
        // final Map<String, dynamic> data = d.data();
        // data["id"] = d.id;
        // ContactTracking tracking = ContactTracking.fromJson(data);
        ContactTracking tracking = await ContactTracking.byUuid(objId);
        return tracking.name;
      }
    }
    return "";
  }

  Future<void> getRelations() async {
    String relations = "";
    // final query = await dbTasksRelation.where("task", isEqualTo: uuid).get();
    // for (var doc in query.docs) {
    //   final Map<String, dynamic> data = doc.data();
    //   data["id"] = doc.id;
    //   TasksRelation r = TasksRelation.fromJson(data);
    //   String objDesc = await getObjRelation(r.model, r.objId);
    //   relations += "$objDesc (${getModelRelation(r.model)});";
    // }
    List<TasksRelation> relationsList =
        await TasksRelation.getRelationsByTasks(uuid);
    for (TasksRelation r in relationsList) {
      String objDesc = await getObjRelation(r.model, r.objId);
      relations += "$objDesc (${getModelRelation(r.model)});";
    }
    rel = relations;
  }

  static Future<List<STask>> getByAssigned(uuid,
      {List<STask>? tasks, lazy = false}) async {
    List<STask> items = [];
    if (tasks != null) {
      return tasks.where((t) => t.assigned.contains(uuid)).toList();
    }
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("assigned", arrayContains: uuid)
        .get();
    for (var doc in query.docs) {
      // final Map<String, dynamic> data = doc.data();
      // // data["id"] = doc.id;
      STask task = STask.fromJson(doc);
      if (!lazy) {
        await task.getProject();
        await task.getStatus();
        await task.getSender();
        await task.getAssigned();
        await task.getReceivers();
        await task.getReceiversOrg();
        //await task.getProgrammes();
      }
      items.add(task);
    }
    return items;
  }

  Future<void> getReceivers() async {
    List<Contact> listReceivers = [];
    for (String item in receivers) {
      try {
        // QuerySnapshot query =
        //     await dbContacts.where("uuid", isEqualTo: item).get();
        // final doc = query.docs.first;
        // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // data["id"] = doc.id;
        // Contact contact = Contact.fromJson(data);
        Contact contact = await Contact.byUuid(item);
        listReceivers.add(contact);
      } catch (e) {
        dev.log(e.toString());
      }
    }
    receiversObj = listReceivers;
  }

  Future<void> getReceiversOrg() async {
    List<Organization> listReceivers = [];
    for (String item in receivers) {
      try {
        // QuerySnapshot query = await dbOrg.where("uuid", isEqualTo: item).get();
        // final doc = query.docs.first;
        // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // data["id"] = doc.id;
        // Organization org = Organization.fromJson(data);
        Organization org = await Organization.byUuid(item);
        listReceivers.add(org);
      } catch (e) {
        dev.log(e.toString());
      }
    }
    receiversOrgObj = listReceivers;
  }

  Future<void> getFolder() async {
    if ((folder != "") && (folderObj == null)) {
      folderObj = await Folder.byLoc(folder);
    }
  }

  KeyValue priorityKeyValue() {
    return KeyValue(priority, priority);
  }

  static List<KeyValue> priorityList() {
    return [
      KeyValue("Alta", "Alta"),
      KeyValue("Media", "Media"),
      KeyValue("Baja", "Baja")
    ];
  }

  static Future<Map<String, dynamic>> getOccupation(user,
      [List<STask>? tasks]) async {
    DateTime now = DateTime.now();
    //DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    Map<String, dynamic> row = {};
    double todayVal = 0;
    double tomorrowVal = 0;
    double weekVal = 0;
    double monthVal = 0;
    try {
      if (tasks == null) {
        tasks = [];
        final query = await FirebaseFirestore.instance
            .collection(tbName)
            .where("assigned", arrayContains: user.toString())
            .where("dealDate", isLessThanOrEqualTo: now)
            .get();

        for (var doc in query.docs) {
          // final Map<String, dynamic> data = doc.data();
          // data["id"] = doc.id;
          tasks.add(STask.fromJson(doc));
        }
      }
      for (STask task in tasks) {
        // STask task = STask.fromJson(data);
        if (task.dealDate.isBefore(now) && task.deadLineDate.isAfter(now)) {
          //Número de días
          double days =
              task.deadLineDate.difference(task.dealDate).inDays as double;
          //Horas por día
          double diff = (task.duration / days);
          todayVal += diff;
          if (days > 1) tomorrowVal += diff;
          if (days > 2) weekVal += diff;
          if (days > 7) monthVal += diff;
        }
      }
      if (todayVal != 0) todayVal = (todayVal * 100) / 8;
      if (tomorrowVal != 0) tomorrowVal = (tomorrowVal * 100) / 8;
      if (weekVal != 0) weekVal = (weekVal * 100) / 8;
      if (monthVal != 0) monthVal = (monthVal * 100) / 8;
      row = {
        'today': getOccupationCell(todayVal),
        'tomorrow': getOccupationCell(tomorrowVal),
        'week': getOccupationCell(weekVal),
        'month': getOccupationCell(monthVal)
      };
    } catch (e) {
      dev.log(e.toString());
    }
    return row;
  }

  KeyValue projectKeyValue() {
    for (KeyValue kv in projList) {
      if (kv.key == project) {
        return KeyValue(project, kv.value);
      }
    }
    return KeyValue("", "");
  }

  void initializeProjectList(projectList) {
    projList.add(KeyValue("", ""));
    for (SProject p in projectList) {
      projList.add(p.toKeyValue());
    }
  }

  KeyValue programmeKeyValue() {
    for (KeyValue kv in progList) {
      if (kv.key == programme) {
        return KeyValue(programme, kv.value);
      }
    }
    return KeyValue("", "");
  }

  void initializeProgrammeList(programmeList) {
    progList.add(KeyValue("", ""));
    for (Programme p in programmeList) {
      progList.add(p.toKeyValue());
    }
  }

  static Future<List> getTasks() async {
    List<STask> items = [];
    try {
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection(tbName).get();

      for (var doc in query.docs) {
        // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // data["id"] = doc.id;
        STask task = STask.fromJson(doc);
        // task.id = doc.id;
        /*await task.getProject();
        await task.getStatus();
        await task.getSender();
        await task.getAssigned();
        await task.getReceivers();
        await task.getReceiversOrg();*/
        //await task.getProgrammes();
        items.add(task);
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return items;
  }

  // static Future<List<KeyValue>> getTasksHash() async {
  //   List<KeyValue> items = [];
  //   QuerySnapshot query =
  //       await FirebaseFirestore.instance.collection(tbName).get();

  //   for (var doc in query.docs) {
  //     final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //     data["id"] = doc.id;
  //     STask task = STask.fromJson(data);
  //     items.add(task.toKeyValue());
  //   }
  //   return items;
  // }

  static Future<List> getTasksBySender(sender,
      [List<STask>? tasks, lazy = false]) async {
    if (tasks != null) {
      return tasks.where((t) => t.sender == sender).toList();
    }
    List<STask> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("sender", isEqualTo: sender)
        .get();

    for (var doc in query.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // STask task = STask.fromJson(data);
      STask task = STask.fromJson(doc);
      task.id = doc.id;

      if (!lazy) {
        await task.getProject();
        await task.getProgramme();
        await task.getStatus();
        await task.getSender();
        await task.getAssigned();
        await task.getReceivers();
        await task.getReceiversOrg();
      }
      //await task.getProgrammes();
      items.add(task);
    }
    return items;
  }

  static Future<List> searchTasks(name, [List<STask>? tasks]) async {
    if (tasks != null) {
      return tasks.where((t) => t.name == name).toList();
    }
    List<STask> items = [];
    QuerySnapshot? query;

    if (name != "") {
      query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("name", isEqualTo: name)
          .get();
    } else {
      query = await FirebaseFirestore.instance.collection(tbName).get();
    }
    for (var doc in query.docs) {
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // final item = STask.fromJson(data);
      items.add(STask.fromJson(doc));
    }
    return items;
  }
}

//--------------------------------------------------------------
//                           TASKS STATUS
//--------------------------------------------------------------

class TasksStatus {
  static const String tbName = "s4c_tasks_status";
  String id = "";
  String uuid = "";
  String name;

  //TasksStatus(this.id, this.uuid, this.name);
  TasksStatus(this.name);

  TasksStatus.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  static Future<List<TasksStatus>> all() async {
    List<TasksStatus> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(TasksStatus.fromJson(data));
    }
    return items;
  }

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var libuuid = const Uuid();
      uuid = libuuid.v4();
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

  String getName() {
    if (name != "") {
      return name;
    } else {
      return "Sin estado";
    }
  }

  Color getColor() {
    Color color = Colors.grey;
    switch (name) {
      case "En proceso":
        color = Colors.orange;
        break;
      case "Completado":
        color = Colors.green;
        break;
      case "Pendiente":
        color = Colors.red;
        break;
      case "Sin estado":
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }
    return color;
  }

  static Future<List<TasksStatus>> getTasksStatus({List<String>? uuids}) async {
    List<TasksStatus> items = [];
    QuerySnapshot query;
    if (uuids != null) {
      query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("uuid", whereIn: uuids)
          .get();
    } else {
      query = await FirebaseFirestore.instance.collection(tbName).get();
    }
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(TasksStatus.fromJson(data));
    }

    return items;
  }

  static Future<TasksStatus> byUuid(String uuid) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      return TasksStatus("Sin estado");
    } else {
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return TasksStatus.fromJson(data);
    }
  }

  static Future<List<KeyValue>> getTasksStatusHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(TasksStatus.fromJson(data).toKeyValue());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                       TASKS COMMENTS
//--------------------------------------------------------------

class TasksComments {
  String id = "";
  String uuid = "";
  String comment = "";
  String user = "";
  DateTime date = DateTime.now();
  String task;

  static const String tbName = "s4c_tasks_comments";

  Profile? userObj;

  //TasksStatus(this.id, this.uuid, this.name);
  TasksComments(this.task);

  TasksComments.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        comment = json['comment'],
        user = json['user'],
        date = json['date'].toDate(),
        task = json['task'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'comment': comment,
        'user': user,
        'date': date,
        'task': task,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, comment);
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

  Future<void> getUser() async {
    final dbProfile = FirebaseFirestore.instance.collection("s4c_profiles");
    if (user != "") {
      QuerySnapshot query =
          await dbProfile.where("email", isEqualTo: user).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      userObj = Profile.fromJson(data);
    }
  }

  static Future<List<TasksComments>> getCommentsByTasks(String uuid) async {
    List<TasksComments> items = [];
/*    QuerySnapshot query;
    query = await dbTasksComments
        .where("task", isEqualTo: uuid)
        .orderBy('date', descending: true)
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      TasksComments tc = TasksComments.fromJson(data);
      await tc.getUser();
      items.add(tc);*/
    try {
      QuerySnapshot query;
      query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("task", isEqualTo: uuid)
          .orderBy('date', descending: true)
          .get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        TasksComments tc = TasksComments.fromJson(data);
        await tc.getUser();
        items.add(tc);
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                       TASKS RELATION
//--------------------------------------------------------------

class TasksRelation {
  String id = "";
  String uuid = "";
  String objId = "";
  String model = "";
  String task;

  static const String tbName = "s4c_tasks_relation";

  TasksRelation(this.task);

  TasksRelation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        objId = json['objId'],
        model = json['model'],
        task = json['task'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'objId': objId,
        'model': model,
        'task': task,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, objId);
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

  static String getModelRelation(model) {
    if (model == "s4c_activities") return "Actividad";
    return "";
  }

  static Future<String> getObjRelation(model, objId) async {
    if (model == "s4c_activities") {
      Activity act = await Activity.byUuid(objId);
      return act.name;
    }
    return "";
  }

  static Future<List<TasksRelation>> getRelationsByTasks(String uuid) async {
    List<TasksRelation> items = [];
    QuerySnapshot query;
    query = await FirebaseFirestore.instance
        .collection(TasksRelation.tbName)
        .where("task", isEqualTo: uuid)
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(TasksRelation.fromJson(data));
    }
    return items;
  }
}
