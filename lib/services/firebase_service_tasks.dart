import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           TASKS
//--------------------------------------------------------------
CollectionReference _collectionTask = db.collection("s4c_tasks");

Future<List> getTasks() async {
  List<STask> items = [];
  QuerySnapshot? query;

  query = await _collectionTask.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = STask.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<STask> getTaskById(String id) async {
  DocumentSnapshot? _doc;

  _doc = await _collectionTask.doc(id).get();
  final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
  data["id"] = _doc.id;
  return STask.fromJson(data);
}

Future<void> addTask(
    String name,
    String description,
    String comments,
    String status,
    String deal_date,
    String deadline_date,
    String new_deadline_date,
    String sender,
    String project,
    List<String> assigned,
    List<String> programmes,
    bool public) async {
  var uuid = Uuid();
  await _collectionTask.add({
    "uuid": uuid.v4(),
    "name": name,
    "description": description,
    "comments": comments,
    "status": status,
    "deal_date": deal_date,
    "deadline_date": deadline_date,
    "new_deadline_date": new_deadline_date,
    "sender": sender,
    "project": project,
    "assigned": FieldValue.arrayUnion(assigned),
    "programmes": FieldValue.arrayUnion(programmes),
    "public": public,
  });
}

Future<void> updateTask(
    String id,
    String uuid,
    String name,
    String description,
    String comments,
    String status,
    String deal_date,
    String deadline_date,
    String new_deadline_date,
    String sender,
    String project,
    List<String> assigned,
    List<String> programmes,
    bool public) async {
  await _collectionTask.doc(id).set({
    "uuid": uuid,
    "name": name,
    "description": description,
    "comments": comments,
    "status": status,
    "deal_date": deal_date,
    "deadline_date": deadline_date,
    "new_deadline_date": new_deadline_date,
    "sender": sender,
    "project": project,
    "assigned": FieldValue.arrayUnion(assigned),
    "programmes": FieldValue.arrayUnion(programmes),
    "public": public,
  });
}

Future<void> deleteTask(String id) async {
  await _collectionTask.doc(id).delete();
}

Future<void> updateTaskAssigned(String id, List assigned) async {
  await _collectionTask.doc(id).update({"assigned": assigned});
}

Future<void> updateTaskProgrammes(String id, List programmes) async {
  await _collectionTask.doc(id).update({"programmes": programmes});
}

//--------------------------------------------------------------
//                           STATUS
//--------------------------------------------------------------
CollectionReference _collectionTasksStatus = db.collection("s4c_tasks_status");

Future<List> getTasksStatus() async {
  List<TasksStatus> items = [];
  QuerySnapshot? query;

  query = await _collectionTasksStatus.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = TasksStatus.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addTasksStatus(
  String name,
) async {
  var uuid = Uuid();
  await _collectionTasksStatus.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updateTasksStatus(
  String id,
  String uuid,
  String name,
) async {
  await _collectionTasksStatus.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deleteTasksStatus(String id) async {
  await _collectionTask.doc(id).delete();
}
