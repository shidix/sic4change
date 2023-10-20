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

Future<SProject?> getProjectByUuid(String _uuid) async {
  SProject? project;
  QuerySnapshot? queryProjects;

  queryProjects = await _collectionProject.where("uuid", isEqualTo: _uuid).get();
  for (var doc in queryProjects.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    project = SProject.fromJson(data);
    break;
  }
  return project;
}


Future<void> addProject(String name, String desc, String type, String budget,
    String manager, String programme, String country) async {
  var uuid = Uuid();
  await _collectionProject.add({
    "uuid": uuid,
    "name": name,
    "description": desc,
    "type": type,
    "budget": budget,
    "manager": manager,
    "programme": programme,
    "country": country,
    "financiers": [],
    "partners": []
  });
}

Future<void> updateProject(
    String id,
    String uuid,
    String name,
    String desc,
    String type,
    String budget,
    String manager,
    String programme,
    String country,
    List financiers,
    List partners) async {
  await _collectionProject.doc(id).set({
    "uuid": uuid,
    "name": name,
    "description": desc,
    "type": type,
    "budget": budget,
    "manager": manager,
    "programme": programme,
    "country": country,
    "financiers": financiers,
    "partners": partners
  });
}

Future<void> deleteProject(String uid) async {
  await _collectionProject.doc(uid).delete();
}

Future<void> updateProjectFinanciers(String id, List financiers) async {
  await _collectionProject.doc(id).update({"financiers": financiers});
}

Future<void> updateProjectPartners(String id, List partners) async {
  await _collectionProject.doc(id).update({"partners": partners});
}

//--------------------------------------------------------------
//                           PROJECT TYPES
//--------------------------------------------------------------
CollectionReference _collectionProjectType = db.collection("s4c_project_type");

Future<List> getProjectTypes() async {
  List items = [];
  QuerySnapshot queryProjectType = await _collectionProjectType.get();

  for (var doc in queryProjectType.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = ProjectType.fromJson(data);
    items.add(_item);
  }

  return items;
}

Future<void> addProjectType(String name) async {
  var uuid = Uuid();
  await _collectionProjectType.add({"uuid": uuid.v4(), "name": name});
}

Future<void> updateProjectType(String id, String uuid, String name) async {
  await _collectionProjectType.doc(id).set({"uuid": uuid, "name": name});
}

Future<void> deleteProjectType(String uid) async {
  await _collectionProjectType.doc(uid).delete();
}

//--------------------------------------------------------------
//                           FINANCIER
//--------------------------------------------------------------
CollectionReference _collectionFinancier = db.collection("s4c_financier");

Future<List> getFinanciers() async {
  List items = [];
  QuerySnapshot queryFinancier = await _collectionFinancier.get();

  for (var doc in queryFinancier.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Financier.fromJson(data);
    items.add(_item);
  }

  return items;
}

Future<void> addFinancier(String name) async {
  var uuid = Uuid();
  await _collectionFinancier.add({"uuid": uuid.v4(), "name": name});
}

Future<void> updateFinancier(String id, String uuid, String name) async {
  await _collectionFinancier.doc(id).set({"uuid": uuid, "name": name});
}

Future<void> deleteFinancier(String id) async {
  await _collectionFinancier.doc(id).delete();
}

//--------------------------------------------------------------
//                           PROGRAMME
//--------------------------------------------------------------
CollectionReference _collectionProgramme = db.collection("s4c_programmes");

Future<List> getProgrammes() async {
  List items = [];
  QuerySnapshot queryProgramme = await _collectionProgramme.get();

  for (var doc in queryProgramme.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Programme.fromJson(data);
    items.add(_item);
  }

  return items;
}

Future<void> addProgramme(String name) async {
  var uuid = Uuid();
  await _collectionProgramme.add({"uuid": uuid.v4(), "name": name});
}

Future<void> updateProgramme(String id, String uuid, String name) async {
  await _collectionProgramme.doc(id).set({"uuid": uuid, "name": name});
}

Future<void> deleteProgramme(String id) async {
  await _collectionProgramme.doc(id).delete();
}

//--------------------------------------------------------------
//                           FOLDERS
//--------------------------------------------------------------
/*CollectionReference _collectionFolder = db.collection("s4c_folders");

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
}*/

//--------------------------------------------------------------
//                           CONTACTS
//--------------------------------------------------------------
/*CollectionReference _collectionContact = db.collection("s4c_contacts");

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
*/
//--------------------------------------------------------------
//                           GOAL
//--------------------------------------------------------------
/*CollectionReference _collectionGoal = db.collection("s4c_goals");

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
}*/

//--------------------------------------------------------------
//                           RESULTS
//--------------------------------------------------------------
/*CollectionReference _collectionResult = db.collection("s4c_results");

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

Future<String> getProjectByResult(String _uuid) async {
  Goal _goal;
  SProject _project;
  QuerySnapshot? query;
  QuerySnapshot? query_p;

  query = await _collectionGoal.where("uuid", isEqualTo: _uuid).get();
  final _dbGoal = query.docs.first;
  final Map<String, dynamic> data = _dbGoal.data() as Map<String, dynamic>;
  data["id"] = _dbGoal.id;
  _goal = Goal.fromJson(data);

  query_p =
      await _collectionProject.where("uuid", isEqualTo: _goal.project).get();
  final _dbProject = query_p.docs.first;
  final Map<String, dynamic> dataProject =
      _dbProject.data() as Map<String, dynamic>;
  dataProject["id"] = _dbProject.id;
  _project = SProject.fromJson(dataProject);

  return _project.name;
  //return _project.name + " > " + _goal.name;
}*/

//--------------------------------------------------------------
//                           ACTIVITIES
//--------------------------------------------------------------
/*CollectionReference _collectionActivity = db.collection("s4c_activities");

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

//Future<SProject> getProjectByActivity(String _uuid) async {
Future<String> getProjectByActivity(String _uuid) async {
  Result _result;
  Goal _goal;
  SProject _project;
  QuerySnapshot? query;
  QuerySnapshot? query_g;
  QuerySnapshot? query_p;

  query = await _collectionResult.where("uuid", isEqualTo: _uuid).get();
  final _dbResult = query.docs.first;
  final Map<String, dynamic> data = _dbResult.data() as Map<String, dynamic>;
  data["id"] = _dbResult.id;
  _result = Result.fromJson(data);

  query_g = await _collectionGoal.where("uuid", isEqualTo: _result.goal).get();
  final _dbGoal = query_g.docs.first;
  final Map<String, dynamic> dataGoal = _dbGoal.data() as Map<String, dynamic>;
  dataGoal["id"] = _dbGoal.id;
  _goal = Goal.fromJson(dataGoal);

  query_p =
      await _collectionProject.where("uuid", isEqualTo: _goal.project).get();
  final _dbProject = query_p.docs.first;
  final Map<String, dynamic> dataProject =
      _dbProject.data() as Map<String, dynamic>;
  dataProject["id"] = _dbProject.id;
  _project = SProject.fromJson(dataProject);

  return _project.name + " > " + _goal.name + " > " + _result.name;
}*/

//--------------------------------------------------------------
//                      ACTIVITY INDICATORS
//--------------------------------------------------------------
/*CollectionReference _collectionActivityIndicator =
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

Future<String> getProjectByActivityIndicator(String _uuid) async {
  Activity _activity;
  Result _result;
  Goal _goal;
  SProject _project;
  QuerySnapshot? query;
  QuerySnapshot? query_r;
  QuerySnapshot? query_g;
  QuerySnapshot? query_p;

  query = await _collectionActivity.where("uuid", isEqualTo: _uuid).get();
  final _dbActivity = query.docs.first;
  final Map<String, dynamic> data = _dbActivity.data() as Map<String, dynamic>;
  data["id"] = _dbActivity.id;
  _activity = Activity.fromJson(data);

  query_r =
      await _collectionResult.where("uuid", isEqualTo: _activity.result).get();
  final _dbResult = query_r.docs.first;
  final Map<String, dynamic> dataResult =
      _dbResult.data() as Map<String, dynamic>;
  dataResult["id"] = _dbResult.id;
  _result = Result.fromJson(dataResult);

  query_g = await _collectionGoal.where("uuid", isEqualTo: _result.goal).get();
  final _dbGoal = query_g.docs.first;
  final Map<String, dynamic> dataGoal = _dbGoal.data() as Map<String, dynamic>;
  dataGoal["id"] = _dbGoal.id;
  _goal = Goal.fromJson(dataGoal);

  query_p =
      await _collectionProject.where("uuid", isEqualTo: _goal.project).get();
  final _dbProject = query_p.docs.first;
  final Map<String, dynamic> dataProject =
      _dbProject.data() as Map<String, dynamic>;
  dataProject["id"] = _dbProject.id;
  _project = SProject.fromJson(dataProject);

  return _project.name +
      " > " +
      _goal.name +
      " > " +
      _result.name +
      " > " +
      _activity.name;
}*/

//--------------------------------------------------------------
//                           TASKS
//--------------------------------------------------------------
/*CollectionReference _collectionTask = db.collection("s4c_tasks");

Future<List> getTasks() async {
  List<Task> items = [];
  QuerySnapshot? query;

  query = await _collectionTask.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Task.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<List> getTasksByResult(String _result) async {
  List<Task> items = [];
  QuerySnapshot? query;

  query = await _collectionTask.where("result", isEqualTo: _result).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Task.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addTask(String name, String result) async {
  var uuid = Uuid();
  await _collectionTask.add({
    "uuid": uuid.v4(),
    "name": name,
    "result": result,
  });
}

Future<void> updateTask(
    String id, String uuid, String name, String result) async {
  await _collectionTask.doc(id).set({
    "uuid": uuid,
    "name": name,
    "result": result,
  });
}

Future<void> deleteTask(String id) async {
  await _collectionTask.doc(id).delete();
}

Future<String> getProjectByTask(String _uuid) async {
  Result _result;
  Goal _goal;
  SProject _project;
  QuerySnapshot? query;
  QuerySnapshot? query_g;
  QuerySnapshot? query_p;

  query = await _collectionResult.where("uuid", isEqualTo: _uuid).get();
  final _dbResult = query.docs.first;
  final Map<String, dynamic> dataResult =
      _dbResult.data() as Map<String, dynamic>;
  dataResult["id"] = _dbResult.id;
  _result = Result.fromJson(dataResult);

  query_g = await _collectionGoal.where("uuid", isEqualTo: _result.goal).get();
  final _dbGoal = query_g.docs.first;
  final Map<String, dynamic> dataGoal = _dbGoal.data() as Map<String, dynamic>;
  dataGoal["id"] = _dbGoal.id;
  _goal = Goal.fromJson(dataGoal);

  query_p =
      await _collectionProject.where("uuid", isEqualTo: _goal.project).get();
  final _dbProject = query_p.docs.first;
  final Map<String, dynamic> dataProject =
      _dbProject.data() as Map<String, dynamic>;
  dataProject["id"] = _dbProject.id;
  _project = SProject.fromJson(dataProject);

  return _project.name + " > " + _goal.name + " > " + _result.name;
}*/

//--------------------------------------------------------------
//                      FINN
//--------------------------------------------------------------
