import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

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
  SProject projectObj =
      SProject("", "", "", "", "", "", "", "", "", "", false, false, [], []);
  TasksStatus statusObj = TasksStatus("");
  Contact senderObj = Contact("", "", "", "", "");

  STask(
    this.name,
  );

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
    DocumentSnapshot _doc = await dbTasks.doc(id).get();
    final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
    data["id"] = _doc.id;
    STask.fromJson(data);
    getProject();
    getStatus();
    getSender();
    return this;
  }

  Future<void> getProject() async {
    QuerySnapshot query =
        await dbProject.where("uuid", isEqualTo: project).get();
    final _doc = query.docs.first;
    final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
    data["id"] = _doc.id;
    projectObj = SProject.fromJson(data);
  }

  Future<void> getStatus() async {
    QuerySnapshot query =
        await dbTasksStatus.where("uuid", isEqualTo: status).get();
    final _doc = query.docs.first;
    final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
    data["id"] = _doc.id;
    statusObj = TasksStatus.fromJson(data);
  }

  Future<void> getSender() async {
    QuerySnapshot query =
        await dbContacts.where("uuid", isEqualTo: sender).get();
    final _doc = query.docs.first;
    final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
    data["id"] = _doc.id;
    senderObj = Contact.fromJson(data);
  }
}

Future<List> getTasks() async {
  List<STask> items = [];
  QuerySnapshot query = await dbTasks.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    STask _task = STask.fromJson(data);
    _task.getProject();
    _task.getStatus();
    _task.getSender();
    items.add(_task);
  }
  return items;
}

//--------------------------------------------------------------
//                           TASKS
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

  Map<String, dynamic> toKeyValue() => {
        'key': uuid,
        'value': name,
      };

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
