// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
CollectionReference dbProject = db.collection("s4c_projects");

//--------------------------------------------------------------
//                           TASKS
//--------------------------------------------------------------
final dbTasks = db.collection("s4c_tasks");

class STask {
  String id = "";
  String uuid = "";
  String name;
  String description = "";
  String comments = "";
  String status = "";
  String priority = "";
  String duration = "";
  DateTime dealDate = DateTime.now();
  DateTime deadLineDate = DateTime.now();
  DateTime newDeadLineDate = DateTime.now();
  String sender = ""; //Responsable
  String project = "";
  String folder = "";
  List<String> assigned = []; //Ejecutores
  List<String> receivers = []; //Destinatarios
  //List<String> programmes = [];
  bool public = false;
  bool revision = false;

  SProject projectObj = SProject("");
  TasksStatus statusObj = TasksStatus("");
  Profile? senderObj;
  Folder? folderObj;
  List<Contact> assignedObj = [];
  List<Contact> receiversObj = [];
  //List<Programme> programmesObj = [];

  STask(this.name);

  STask.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        comments = json['comments'],
        status = json['status'],
        priority = json['priority'],
        duration = json['duration'],
        dealDate = json['dealDate'].toDate(),
        deadLineDate = json['deadLineDate'].toDate(),
        newDeadLineDate = json['newDeadLineDate'].toDate(),
        sender = json['sender'],
        project = json['project'],
        folder = json['folder'],
        assigned =
            (json['assigned'] as List).map((item) => item as String).toList(),
        receivers =
            (json['receivers'] as List).map((item) => item as String).toList(),
        /*programmes =
            (json['programmes'] as List).map((item) => item as String).toList(),*/
        public = json['public'],
        revision = json['revision'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'comments': comments,
        'status': status,
        'priority': priority,
        'duration': duration,
        'dealDate': dealDate,
        'deadLineDate': deadLineDate,
        'newDeadLineDate': newDeadLineDate,
        'sender': sender,
        'project': project,
        'folder': folder,
        'assigned': assigned,
        'receivers': receivers,
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
      dbTasks.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbTasks.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbTasks.doc(id).delete();
  }

  Future<void> updateAssigned() async {
    await dbTasks.doc(id).update({"assigned": assigned});
  }

  /*Future<void> updateProgrammes() async {
    await dbTasks.doc(id).update({"programmes": programmes});
  }*/

  Future<STask> reload() async {
    DocumentSnapshot doc = await dbTasks.doc(id).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    STask.fromJson(data);
    await getProject();
    await getStatus();
    await getSender();
    await getAssigned();
    await getReceivers();
    //await getProgrammes();
    return this;
  }

  Future<void> getProject() async {
    if (project != "") {
      QuerySnapshot query =
          await dbProject.where("uuid", isEqualTo: project).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      projectObj = SProject.fromJson(data);
    }
  }

  Future<void> getStatus() async {
    if (status != "") {
      QuerySnapshot query =
          await dbTasksStatus.where("uuid", isEqualTo: status).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      statusObj = TasksStatus.fromJson(data);
    } else {
      statusObj = TasksStatus("Sin estado");
    }
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
    final dbProfile = db.collection("s4c_profiles");
    if (sender != "") {
      QuerySnapshot query =
          await dbProfile.where("email", isEqualTo: sender).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      senderObj = Profile.fromJson(data);
    }
  }

  Future<void> getAssigned() async {
    List<Contact> listAssigned = [];
    for (String item in assigned) {
      try {
        QuerySnapshot query =
            await dbContacts.where("uuid", isEqualTo: item).get();
        final doc = query.docs.first;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        Contact contact = Contact.fromJson(data);
        listAssigned.add(contact);
      } catch (e) {
        print(e);
      }
    }
    assignedObj = listAssigned;
  }

  String getAssignedStr() {
    String assignedStr = "";
    for (Contact item in assignedObj) {
      assignedStr += "${item.name},";
    }
    assignedStr = (assignedStr.length > 0)
        ? assignedStr.substring(0, assignedStr.length - 1)
        : assignedStr;
    return assignedStr;
  }

  static Future<List<STask>> getByAssigned(uuid) async {
    List<STask> items = [];
    final query = await dbTasks.where("assigned", arrayContains: uuid).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data();
      data["id"] = doc.id;
      STask task = STask.fromJson(data);
      task.getProject();
      await task.getStatus();
      await task.getSender();
      await task.getAssigned();
      //await task.getProgrammes();
      items.add(task);
    }
    return items;
  }

  static List<STask> getByAssigned2(uuid) {
    List<STask> items = [];
    dbTasks.where("assigned", arrayContains: uuid).snapshots().listen((event) {
      for (var doc in event.docs) {
        final Map<String, dynamic> data = doc.data();
        data["id"] = doc.id;
        STask task = STask.fromJson(data);
        task.getProject();
        task.getStatus();
        task.getSender();
        task.getAssigned();
        task.getReceivers();
        //task.getProgrammes();
        items.add(task);
      }
    });
    return items;
  }

  Future<void> getReceivers() async {
    List<Contact> listReceivers = [];
    for (String item in receivers) {
      try {
        QuerySnapshot query =
            await dbContacts.where("uuid", isEqualTo: item).get();
        final doc = query.docs.first;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        Contact contact = Contact.fromJson(data);
        listReceivers.add(contact);
      } catch (e) {}
    }
    receiversObj = listReceivers;
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

  /*Future<void> getProgrammes() async {
    List<Programme> listProgrammes = [];
    for (String item in programmes) {
      try {
        QuerySnapshot query =
            await dbProgramme.where("uuid", isEqualTo: item).get();
        final doc = query.docs.first;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        Programme programme = Programme.fromJson(data);
        listProgrammes.add(programme);
      } catch (e) {}
    }
    programmesObj = listProgrammes;
  }*/
}

Future<List> getTasks() async {
  List<STask> items = [];
  try {
    QuerySnapshot query = await dbTasks.get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      STask task = STask.fromJson(data);
      await task.getProject();
      await task.getStatus();
      await task.getSender();
      await task.getAssigned();
      await task.getReceivers();
      //await task.getProgrammes();
      items.add(task);
    }
  } catch (e) {
    print(e);
  }
  return items;
}

Future<List<KeyValue>> getTasksHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbTasks.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    STask task = STask.fromJson(data);
    items.add(task.toKeyValue());
  }
  return items;
}

Future<List> getTasksBySender(sender) async {
  List<STask> items = [];
  print("--1--");
  print(sender);
  QuerySnapshot query = await dbTasks.where("sender", isEqualTo: sender).get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    STask task = STask.fromJson(data);
    await task.getProject();
    await task.getStatus();
    await task.getSender();
    await task.getAssigned();
    await task.getReceivers();
    //await task.getProgrammes();
    items.add(task);
  }
  return items;
}

/*Future<List> getTasksByAssigned(user) async {
  List<STask> items = [];
  QuerySnapshot query =
      await dbTasks.where("assigned", arrayContains: user).get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    STask task = STask.fromJson(data);
    await task.getProject();
    await task.getStatus();
    await task.getSender();
    await task.getAssigned();
    await task.getProgrammes();
    items.add(task);
  }
  return items;
}*/

//--------------------------------------------------------------
//                           TASKS STATUS
//--------------------------------------------------------------
final dbTasksStatus = db.collection("s4c_tasks_status");

class TasksStatus {
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

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbTasksStatus.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbTasksStatus.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbTasksStatus.doc(id).delete();
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
}

Future<List> getTasksStatus() async {
  List<TasksStatus> items = [];
  QuerySnapshot query = await dbTasksStatus.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(TasksStatus.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getTasksStatusHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbTasksStatus.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(TasksStatus.fromJson(data).toKeyValue());
  }
  return items;
}
