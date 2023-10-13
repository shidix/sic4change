//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           PROJECTS
//--------------------------------------------------------------
CollectionReference _collectionProject = db.collection("s4c_projects");

Future<List> getProjects() async {
  List items = [];
  QuerySnapshot queryProject = await _collectionProject.get();
  for (var doc in queryProject.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = SProject.fromJson(data);
    items.add(_item);
  }
  ;

  return items;
}

Future<void> addProject(String name) async {
  await _collectionProject.add({"name": name});
}

Future<void> updateProject(String uid, String name) async {
  await _collectionProject.doc(uid).set({"name": name});
}

Future<void> deleteProject(String uid) async {
  await _collectionProject.doc(uid).delete();
}

//--------------------------------------------------------------
//                           FOLDERS
//--------------------------------------------------------------
CollectionReference _collectionFolder = db.collection("s4c_folders");

Future<List> getFolders(String _parent_uuid) async {
  List folders = [];
  QuerySnapshot? queryFolders;

  if (_parent_uuid != "") {
    queryFolders =
        await _collectionFolder.where("parent", isEqualTo: _parent_uuid).get();
  } else {
    queryFolders = await _collectionFolder.where("parent", isEqualTo: "").get();
  }
  for (var doc in queryFolders.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final folder = Folder.fromJson(data);
    folders.add(folder);
  }
  return folders;
}

Future<Folder?> getFolderByUuid(String _uuid) async {
  Folder? folder;
  QuerySnapshot? queryFolders;

  queryFolders = await _collectionFolder.where("uuid", isEqualTo: _uuid).get();
  for (var doc in queryFolders.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    folder = Folder.fromJson(data);
    break;
  }
  return folder;
}

Future<void> addFolder(String name, String parent) async {
  var uuid = Uuid();
  await _collectionFolder
      .add({"uuid": uuid.v4(), "name": name, "parent": parent});
}

Future<void> updateFolder(
    String id, String uuid, String name, String parent) async {
  await _collectionFolder
      .doc(id)
      .set({"uuid": uuid, "name": name, "parent": parent});
}

Future<void> deleteFolder(String id) async {
  await _collectionFolder.doc(id).delete();
}

//--------------------------------------------------------------
//                           FILES
//--------------------------------------------------------------
CollectionReference _collectionFile = db.collection("s4c_files");

Future<List> getFiles(String _folder) async {
  List files = [];
  QuerySnapshot? query;

  if (_folder != "") {
    query = await _collectionFile.where("folder", isEqualTo: _folder).get();
  } else {
    query = await _collectionFile.where("folder", isEqualTo: "").get();
  }
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _file = SFile.fromJson(data);
    files.add(_file);
  }
  return files;
}

Future<void> addFile(String name, String folder, String link) async {
  var uuid = Uuid();
  await _collectionFile
      .add({"uuid": uuid.v4(), "name": name, "folder": folder, "link": link});
}

Future<void> updateFile(
    String id, String uuid, String name, String folder, String link) async {
  await _collectionFile
      .doc(id)
      .set({"uuid": uuid, "name": name, "folder": folder, "link": link});
}

Future<void> deleteFile(String id) async {
  await _collectionFile.doc(id).delete();
}

//--------------------------------------------------------------
//                           CONTACTS
//--------------------------------------------------------------
CollectionReference _collectionContact = db.collection("s4c_contacts");

Future<List> getContacts() async {
  List<Contact> items = [];
  QuerySnapshot? query;

  query = await _collectionContact.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Contact.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addContact(String name, String company, List<String> projects,
    String position, String email, String phone) async {
  var uuid = Uuid();
  await _collectionContact.add({
    "uuid": uuid.v4(),
    "name": name,
    "company": company,
    "projects": FieldValue.arrayUnion(projects),
    "position": position,
    "email": email,
    "phone": phone
  });
}

Future<void> updateContact(String id, String uuid, String name, String company,
    List<String> projects, String position, String email, String phone) async {
  await _collectionContact.doc(id).set({
    "uuid": uuid,
    "name": name,
    "company": company,
    "projects": FieldValue.arrayUnion(projects),
    "position": position,
    "email": email,
    "phone": phone
  });
}

Future<void> deleteContact(String id) async {
  await _collectionContact.doc(id).delete();
}

Future<List> searchContacts(_name) async {
  List<Contact> items = [];
  QuerySnapshot? query;

  if (_name != "")
    query = await _collectionContact.where("name", isEqualTo: _name).get();
  else
    query = await _collectionContact.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Contact.fromJson(data);
    items.add(_item);
  }
  return items;
}

//--------------------------------------------------------------
//                           COMPANIES
//--------------------------------------------------------------
CollectionReference _collectionComp = db.collection("s4c_companies");

Future<List> getCompanies() async {
  List<Company> items = [];
  QuerySnapshot? query;

  query = await _collectionComp.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Company.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addCompany(String name) async {
  var uuid = Uuid();
  await _collectionComp.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updateCompany(String id, String uuid, String name) async {
  await _collectionComp.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deleteCompany(String id) async {
  await _collectionComp.doc(id).delete();
}

//--------------------------------------------------------------
//                           POSITION
//--------------------------------------------------------------
CollectionReference _collectionPos = db.collection("s4c_positions");

Future<List> getPositions() async {
  List<Position> items = [];
  QuerySnapshot? query;

  query = await _collectionPos.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Position.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addPosition(String name) async {
  var uuid = Uuid();
  await _collectionPos.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updatePosition(String id, String uuid, String name) async {
  await _collectionPos.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deletePosition(String id) async {
  await _collectionPos.doc(id).delete();
}

//--------------------------------------------------------------
//                           GOAL
//--------------------------------------------------------------
CollectionReference _collectionGoal = db.collection("s4c_goals");

Future<List> getGoals() async {
  List<Goal> items = [];
  QuerySnapshot? query;

  query = await _collectionGoal.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Goal.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<List> getGoalsByProject(String _project) async {
  List<Goal> items = [];
  QuerySnapshot? query;

  query = await _collectionGoal
      .orderBy("project")
      .orderBy("main", descending: true)
      .where("project", isEqualTo: _project)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Goal.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addGoal(
    String name, String description, bool main, String project) async {
  var uuid = Uuid();
  await _collectionGoal.add({
    "uuid": uuid.v4(),
    "name": name,
    "description": description,
    "main": main,
    "project": project,
  });
}

Future<void> updateGoal(String id, String uuid, String name, String description,
    bool main, String project) async {
  await _collectionGoal.doc(id).set({
    "uuid": uuid,
    "name": name,
    "description": description,
    "main": main,
    "project": project,
  });
}

Future<void> deleteGoal(String id) async {
  await _collectionGoal.doc(id).delete();
}

//--------------------------------------------------------------
//                           RESULTS
//--------------------------------------------------------------
CollectionReference _collectionResult = db.collection("s4c_results");

Future<List> getResults() async {
  List<Result> items = [];
  QuerySnapshot? query;

  query = await _collectionResult.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Result.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<List> getResultsByGoal(String _goal) async {
  List<Result> items = [];
  QuerySnapshot? query;

  query = await _collectionResult
      //.orderBy("goal")
      //.orderBy("main", descending: true)
      .where("goal", isEqualTo: _goal)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Result.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addResult(String name, String description, String indicator_text,
    String indicator_percent, String source, String goal) async {
  var uuid = Uuid();
  await _collectionResult.add({
    "uuid": uuid.v4(),
    "name": name,
    "description": description,
    "indicator_text": indicator_text,
    "indicator_percent": indicator_percent,
    "source": source,
    "goal": goal,
  });
}

Future<void> updateResult(
    String id,
    String uuid,
    String name,
    String description,
    String indicator_text,
    String indicator_percent,
    String source,
    String goal) async {
  await _collectionResult.doc(id).set({
    "uuid": uuid,
    "name": name,
    "description": description,
    "indicator_text": indicator_text,
    "indicator_percent": indicator_percent,
    "source": source,
    "goal": goal,
  });
}

Future<void> deleteResult(String id) async {
  await _collectionResult.doc(id).delete();
}

//--------------------------------------------------------------
//                           ACTIVITIES
//--------------------------------------------------------------
CollectionReference _collectionActivity = db.collection("s4c_activities");

Future<List> getActivities() async {
  List<Activity> items = [];
  QuerySnapshot? query;

  query = await _collectionActivity.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Activity.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<List> getActivitiesByResult(String _result) async {
  List<Activity> items = [];
  QuerySnapshot? query;

  query = await _collectionActivity.where("result", isEqualTo: _result).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Activity.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addActivity(String name, String result) async {
  var uuid = Uuid();
  await _collectionActivity.add({
    "uuid": uuid.v4(),
    "name": name,
    "result": result,
  });
}

Future<void> updateActivity(
    String id, String uuid, String name, String result) async {
  await _collectionActivity.doc(id).set({
    "uuid": uuid,
    "name": name,
    "result": result,
  });
}

Future<void> deleteActivity(String id) async {
  await _collectionActivity.doc(id).delete();
}

//--------------------------------------------------------------
//                      ACTIVITY INDICATORS
//--------------------------------------------------------------
CollectionReference _collectionActivityIndicator =
    db.collection("s4c_activity_indicators");

Future<List> getActivityIndicators() async {
  List<ActivityIndicator> items = [];
  QuerySnapshot? query;

  query = await _collectionActivityIndicator.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = ActivityIndicator.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<List> getActivityIndicatorsByActivity(String _activity) async {
  List<ActivityIndicator> items = [];
  QuerySnapshot? query;

  query = await _collectionActivityIndicator
      .where("activity", isEqualTo: _activity)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = ActivityIndicator.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addActivityIndicator(
    String name, String percent, String source, String activity) async {
  var uuid = Uuid();
  await _collectionActivityIndicator.add({
    "uuid": uuid.v4(),
    "name": name,
    "percent": percent,
    "source": source,
    "activity": activity,
  });
}

Future<void> updateActivityIndicator(String id, String uuid, String name,
    String percent, String source, String activity) async {
  await _collectionActivityIndicator.doc(id).set({
    "uuid": uuid,
    "name": name,
    "percent": percent,
    "source": source,
    "activity": activity,
  });
}

Future<void> deleteActivityIndicator(String id) async {
  await _collectionActivityIndicator.doc(id).delete();
}

//--------------------------------------------------------------
//                      FINN
//--------------------------------------------------------------
CollectionReference _collectionFinn = db.collection("s4c_finns");

Future<List> getFinns() async {
  List<SFinn> items = [];
  QuerySnapshot? query;

  query = await _collectionFinn.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = SFinn.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<List> getFinnsByProject(String _project) async {
  List<SFinn> items = [];
  QuerySnapshot? query;

  query = await _collectionFinn
      .orderBy("project")
      .orderBy("parent", descending: true)
      .where("project", isEqualTo: _project)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = SFinn.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addFinn(
    String name, String description, String parent, String project) async {
  var uuid = Uuid();
  await _collectionFinn.add({
    "uuid": uuid.v4(),
    "name": name,
    "description": description,
    "parent": parent,
    "project": project,
  });
}

Future<void> updateFinn(String id, String uuid, String name, String description,
    String parent, String project) async {
  await _collectionFinn.doc(id).set({
    "uuid": uuid,
    "name": name,
    "description": description,
    "parent": parent,
    "project": project,
  });
}

Future<void> deleteFinn(String id) async {
  await _collectionFinn.doc(id).delete();
}

CollectionReference _collectionFinnContrib = db.collection("s4c_finncontrib");

Future<List> getFinnContrib() async {
  List<FinnContribution> items = [];
  QuerySnapshot? query;

  query = await _collectionFinnContrib.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = FinnContribution.fromJson(data);
    items.add(item);
  }
  return items;
}

Future<List> getContribByFinn(String finnuuid) async {
  List<FinnContribution> items = [];
  QuerySnapshot? query;

  query = await _collectionFinnContrib
      .orderBy("owner")
      .where("finn", isEqualTo: finnuuid)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = FinnContribution.fromJson(data);
    items.add(item);
  }
  return items;
}

Future<void> addFinnContrib(String owner, String amount, String finn) async {
  var uuid = Uuid();
  await _collectionFinnContrib.add({
    "uuid": uuid.v4(),
    "owner": owner,
    "finn": finn,
    "amount": double.parse(amount.replaceAll(",", ".")),
  });
}

Future<void> updateFinnContrib(
    String id, String uuid, String owner, String amount, String finn) async {
  await _collectionFinnContrib.doc(id).set({
    "uuid": uuid,
    "owner": owner,
    "finn": finn,
    "amount": double.parse(amount.replaceAll(",", ".")),
  });
}

Future<void> deleteFinnContrib(String id) async {
  await _collectionFinnContrib.doc(id).delete();
}
