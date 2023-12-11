// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
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
  String deal_date = "";
  String deadline_date = "";
  String new_deadline_date = "";
  String sender = "";
  String project = "";
  List<String> assigned = [];
  List<String> programmes = [];
  bool public = false;

  SProject projectObj = SProject("", "");
  TasksStatus statusObj = TasksStatus("");
  Contact senderObj = Contact("", "", "", "", "");
  List<Contact> assignedObj = [];

  STask(this.name,
      [this.description = "",
      this.deal_date = "",
      this.deadline_date = "",
      this.status = ""]);

  STask.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        comments = json['comments'],
        status = json['status'],
        deal_date = json['deal_date'],
        deadline_date = json['deadline_date'],
        new_deadline_date = json['new_deadline_date'],
        sender = json['sender'],
        project = json['project'],
        assigned =
            (json['assigned'] as List).map((item) => item as String).toList(),
        programmes =
            (json['programmes'] as List).map((item) => item as String).toList(),
        public = json['public'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'comments': comments,
        'status': status,
        'deal_date': deal_date,
        'deadline_date': deadline_date,
        'new_deadline_date': new_deadline_date,
        'sender': sender,
        'project': project,
        'assigned': assigned,
        'programmes': programmes,
        'public': public,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      //id = uuid;
      var _uuid = Uuid();
      uuid = _uuid.v4();
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

  Future<void> updateProgrammes() async {
    await dbTasks.doc(id).update({"programmes": programmes});
  }

  Future<STask> reload() async {
    DocumentSnapshot doc = await dbTasks.doc(id).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    STask.fromJson(data);
    await getProject();
    await getStatus();
    await getSender();
    await getAssigned();
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

  Future<void> getSender() async {
    if (sender != "") {
      QuerySnapshot query =
          await dbContacts.where("uuid", isEqualTo: sender).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      senderObj = Contact.fromJson(data);
    }
  }

  Future<void> getAssigned() async {
    for (String item in assigned) {
      try {
        QuerySnapshot query =
            await dbContacts.where("uuid", isEqualTo: item).get();
        final doc = query.docs.first;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        Contact contact = Contact.fromJson(data);
        assignedObj.add(contact);
      } catch (e) {}
    }
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
        items.add(task);
      }
    });
    return items;
  }
}

Future<List> getTasks() async {
  List<STask> items = [];
  QuerySnapshot query = await dbTasks.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    STask task = STask.fromJson(data);
    await task.getProject();
    await task.getStatus();
    await task.getSender();
    await task.getAssigned();
    items.add(task);
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
  QuerySnapshot query = await dbTasks.where("sender", isEqualTo: sender).get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    STask task = STask.fromJson(data);
    await task.getProject();
    await task.getStatus();
    await task.getSender();
    await task.getAssigned();
    items.add(task);
  }
  return items;
}

Future<List> getTasksByAssigned(user) async {
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
    items.add(task);
  }
  return items;
}

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
