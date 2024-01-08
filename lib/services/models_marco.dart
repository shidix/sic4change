import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
CollectionReference dbProject = db.collection("s4c_projects");

//--------------------------------------------------------------
//                           GOAL
//--------------------------------------------------------------
CollectionReference dbGoal = db.collection("s4c_goals");

class Goal {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  bool main = false;
  String project = "";

  /*Goal(
      this.id, this.uuid, this.name, this.description, this.main, this.project);*/
  Goal(this.project);

  Goal.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        main = json['main'],
        project = json['project'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'main': main,
        'project': project,
      };

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbGoal.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbGoal.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbGoal.doc(id).delete();
  }

  Future<String> getProjectByGoal() async {
    Goal _goal;
    SProject _project;

    QuerySnapshot query = await dbGoal.where("uuid", isEqualTo: uuid).get();
    final _dbGoal = query.docs.first;
    final Map<String, dynamic> data = _dbGoal.data() as Map<String, dynamic>;
    data["id"] = _dbGoal.id;
    _goal = Goal.fromJson(data);

    QuerySnapshot query_p =
        await dbProject.where("uuid", isEqualTo: _goal.project).get();
    final _dbProject = query_p.docs.first;
    final Map<String, dynamic> dataProject =
        _dbProject.data() as Map<String, dynamic>;
    dataProject["id"] = _dbProject.id;
    _project = SProject.fromJson(dataProject);

    return _project.name;
    //return _project.name + " > " + _goal.name;
  }
}

Future<List> getGoals() async {
  List<Goal> items = [];

  QuerySnapshot query = await dbGoal.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Goal.fromJson(data));
  }
  return items;
}

Future<List> getGoalsByProject(String _project) async {
  List<Goal> items = [];

  QuerySnapshot query = await dbGoal
      .orderBy("project")
      .orderBy("main", descending: true)
      .where("project", isEqualTo: _project)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Goal.fromJson(data));
  }
  return items;
}

//--------------------------------------------------------------
//                           RESULT
//--------------------------------------------------------------
CollectionReference dbResult = db.collection("s4c_results");

class Result {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  String indicatorText = "";
  String indicatorPercent = "";
  String source = "";
  String goal = "";

  /*Result(this.id, this.uuid, this.name, this.description, this.indicator_text,
      this.indicator_percent, this.source, this.goal);*/
  Result(this.goal);

  Result.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        indicatorText = json['indicatorText'],
        indicatorPercent = json['indicatorPercent'],
        source = json['source'],
        goal = json['goal'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'indicatorText': indicatorText,
        'indicatorPercent': indicatorPercent,
        'source': source,
        'goal': goal,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbResult.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbResult.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbResult.doc(id).delete();
  }

  Future<String> getProjectByActivity() async {
    Result result;
    Goal goal;
    SProject project;
    QuerySnapshot? query;
    QuerySnapshot? queryG;
    QuerySnapshot? queryP;

    query = await dbResult.where("uuid", isEqualTo: uuid).get();
    final dbRes = query.docs.first;
    final Map<String, dynamic> data = dbRes.data() as Map<String, dynamic>;
    data["id"] = dbRes.id;
    result = Result.fromJson(data);

    queryG = await dbGoal.where("uuid", isEqualTo: result.goal).get();
    final dbG = queryG.docs.first;
    final Map<String, dynamic> dataGoal = dbG.data() as Map<String, dynamic>;
    dataGoal["id"] = dbG.id;
    goal = Goal.fromJson(dataGoal);

    queryP = await dbProject.where("uuid", isEqualTo: goal.project).get();
    final dbProj = queryP.docs.first;
    final Map<String, dynamic> dataProject =
        dbProj.data() as Map<String, dynamic>;
    dataProject["id"] = dbProj.id;
    project = SProject.fromJson(dataProject);

    return project.name + " > " + goal.name + " > " + result.name;
  }
}

Future<List> getResults() async {
  List<Result> items = [];

  QuerySnapshot query = await dbResult.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Result.fromJson(data));
  }
  return items;
}

Future<List> getResultsByGoal(String goal) async {
  List<Result> items = [];

  QuerySnapshot query = await dbResult
      //.orderBy("goal")
      //.orderBy("main", descending: true)
      .where("goal", isEqualTo: goal)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Result.fromJson(data));
  }
  return items;
}

//--------------------------------------------------------------
//                           ACTIVITY
//--------------------------------------------------------------
CollectionReference dbActivity = db.collection("s4c_activities");

class Activity {
  String id = "";
  String uuid = "";
  String name = "";
  String result = "";

  Activity(this.result);

  Activity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        result = json['result'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'result': result,
      };

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbActivity.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbActivity.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbActivity.doc(id).delete();
  }
}

Future<List> getActivities() async {
  List<Activity> items = [];

  QuerySnapshot query = await dbActivity.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    // final _item = Activity.fromJson(data);
    items.add(Activity.fromJson(data));
  }
  return items;
}

Future<List> getActivitiesByResult(result) async {
  List<Activity> items = [];

  QuerySnapshot query =
      await dbActivity.where("result", isEqualTo: result).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Activity.fromJson(data));
  }
  return items;
}

//--------------------------------------------------------------
//                     ACTIVITY INDICATOR
//--------------------------------------------------------------
CollectionReference dbActivityIndicator =
    db.collection("s4c_activity_indicators");

class ActivityIndicator {
  String id = "";
  String uuid = "";
  String name = "";
  String percent = "";
  String source = "";
  String activity = "";

  ActivityIndicator(this.activity);

  ActivityIndicator.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        percent = json['percent'],
        source = json['source'],
        activity = json['activity'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'percent': percent,
        'source': source,
        'activity': activity,
      };

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbActivityIndicator.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbActivityIndicator.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbActivityIndicator.doc(id).delete();
  }
}

Future<List> getActivityIndicators() async {
  List<ActivityIndicator> items = [];

  QuerySnapshot query = await dbActivityIndicator.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    // final _item = ActivityIndicator.fromJson(data);
    items.add(ActivityIndicator.fromJson(data));
  }
  return items;
}

Future<List> getActivityIndicatorsByActivity(String _activity) async {
  List<ActivityIndicator> items = [];

  QuerySnapshot query =
      await dbActivityIndicator.where("activity", isEqualTo: _activity).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ActivityIndicator.fromJson(data));
  }
  return items;
}

Future<String> getProjectByActivityIndicator(String _uuid) async {
  QuerySnapshot query = await dbActivity.where("uuid", isEqualTo: _uuid).get();
  final _dbActivity = query.docs.first;
  final Map<String, dynamic> data = _dbActivity.data() as Map<String, dynamic>;
  data["id"] = _dbActivity.id;
  Activity _activity = Activity.fromJson(data);

  QuerySnapshot query_r =
      await dbResult.where("uuid", isEqualTo: _activity.result).get();
  final _dbResult = query_r.docs.first;
  final Map<String, dynamic> dataResult =
      _dbResult.data() as Map<String, dynamic>;
  dataResult["id"] = _dbResult.id;
  Result _result = Result.fromJson(dataResult);

  QuerySnapshot query_g =
      await dbGoal.where("uuid", isEqualTo: _result.goal).get();
  final _dbGoal = query_g.docs.first;
  final Map<String, dynamic> dataGoal = _dbGoal.data() as Map<String, dynamic>;
  dataGoal["id"] = _dbGoal.id;
  Goal _goal = Goal.fromJson(dataGoal);

  QuerySnapshot query_p =
      await dbProject.where("uuid", isEqualTo: _goal.project).get();
  final _dbProject = query_p.docs.first;
  final Map<String, dynamic> dataProject =
      _dbProject.data() as Map<String, dynamic>;
  dataProject["id"] = _dbProject.id;
  SProject _project = SProject.fromJson(dataProject);

  return _project.name +
      " > " +
      _goal.name +
      " > " +
      _result.name +
      " > " +
      _activity.name;
}

//--------------------------------------------------------------
//                       RESULT TASK
//--------------------------------------------------------------
CollectionReference dbResultTask = db.collection("s4c_result_tasks");

class ResultTask {
  String id = "";
  String uuid = "";
  String name = "";
  String result = "";

  ResultTask(this.result);

  ResultTask.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        result = json['result'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'result': result,
      };

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbResultTask.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbResultTask.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbResultTask.doc(id).delete();
  }
}

Future<List> getResultTasks() async {
  List<ResultTask> items = [];

  QuerySnapshot query = await dbResultTask.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ResultTask.fromJson(data));
  }
  return items;
}

Future<List> getResultTasksByResult(String _result) async {
  List<ResultTask> items = [];

  QuerySnapshot query =
      await dbResultTask.where("result", isEqualTo: _result).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ResultTask.fromJson(data));
  }
  return items;
}

Future<String> getProjectByResultTask(String _uuid) async {
  QuerySnapshot query = await dbResult.where("uuid", isEqualTo: _uuid).get();
  final _dbResult = query.docs.first;
  final Map<String, dynamic> dataResult =
      _dbResult.data() as Map<String, dynamic>;
  dataResult["id"] = _dbResult.id;
  Result _result = Result.fromJson(dataResult);

  QuerySnapshot query_g =
      await dbGoal.where("uuid", isEqualTo: _result.goal).get();
  final _dbGoal = query_g.docs.first;
  final Map<String, dynamic> dataGoal = _dbGoal.data() as Map<String, dynamic>;
  dataGoal["id"] = _dbGoal.id;
  Goal _goal = Goal.fromJson(dataGoal);

  QuerySnapshot query_p =
      await dbProject.where("uuid", isEqualTo: _goal.project).get();
  final _dbProject = query_p.docs.first;
  final Map<String, dynamic> dataProject =
      _dbProject.data() as Map<String, dynamic>;
  dataProject["id"] = _dbProject.id;
  SProject _project = SProject.fromJson(dataProject);

  return _project.name + " > " + _goal.name + " > " + _result.name;
}
