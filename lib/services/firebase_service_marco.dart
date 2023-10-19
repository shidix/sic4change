import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

CollectionReference _collectionProject = db.collection("s4c_projects");

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
}

//--------------------------------------------------------------
//                           TASKS
//--------------------------------------------------------------
CollectionReference _collectionTask = db.collection("s4c_tasks");

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
}
