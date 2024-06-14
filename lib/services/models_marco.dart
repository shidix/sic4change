import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_drive.dart';
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
    Goal goal;
    SProject project;

    QuerySnapshot query = await dbGoal.where("uuid", isEqualTo: uuid).get();
    final db = query.docs.first;
    final Map<String, dynamic> data = db.data() as Map<String, dynamic>;
    data["id"] = db.id;
    goal = Goal.fromJson(data);

    QuerySnapshot queryP =
        await dbProject.where("uuid", isEqualTo: goal.project).get();
    final dbP = queryP.docs.first;
    final Map<String, dynamic> dataProject = dbP.data() as Map<String, dynamic>;
    dataProject["id"] = dbP.id;
    project = SProject.fromJson(dataProject);

    return project.name;
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

Future<List> getGoalsByProject(String project) async {
  List<Goal> items = [];

  QuerySnapshot query = await dbGoal
      .orderBy("project")
      .orderBy("main", descending: true)
      .orderBy("name", descending: false)
      .where("project", isEqualTo: project)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Goal.fromJson(data));
  }
  return items;
}

//--------------------------------------------------------------
//                     GOALS INDICATOR
//--------------------------------------------------------------
CollectionReference dbGoalIndicator = db.collection("s4c_goals_indicators");

class GoalIndicator {
  String id = "";
  String uuid = "";
  String name = "";
  String source = "";
  String base = "";
  String expected = "";
  String obtained = "";
  String folder = "";
  String order = "";
  String goal = "";
  Folder? folderObj;

  GoalIndicator(this.goal);

  GoalIndicator.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        source = json['source'],
        base = json['base'],
        expected = json['expected'],
        obtained = json['obtained'],
        folder = json['folder'],
        order = json['order'],
        goal = json['goal'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'source': source,
        'base': base,
        'expected': expected,
        'obtained': obtained,
        'folder': folder,
        'order': order,
        'goal': goal,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbGoalIndicator.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbGoalIndicator.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbGoalIndicator.doc(id).delete();
  }

  Future<void> getFolder() async {
    if ((folder != "") && (folderObj == null)) {
      folderObj = await Folder.byLoc(folder);
    }
  }
}

Future<List> getGoalIndicators() async {
  List<GoalIndicator> items = [];

  QuerySnapshot query = await dbGoalIndicator.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    GoalIndicator item = GoalIndicator.fromJson(data);
    item.getFolder();
    items.add(item);
  }
  return items;
}

Future<List> getGoalIndicatorsByGoal(String goal) async {
  List<GoalIndicator> items = [];

  //QuerySnapshot query =
  //    await dbGoalIndicator.where("goal", isEqualTo: goal).get();
  QuerySnapshot query = await dbGoalIndicator
      .orderBy("goal")
      .orderBy("order", descending: true)
      .where("goal", isEqualTo: goal)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    GoalIndicator item = GoalIndicator.fromJson(data);
    await item.getFolder();
    items.add(item);
    //items.add(GoalIndicator.fromJson(data));
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
  //String indicatorText = "";
  //String indicatorPercent = "";
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
        //indicatorText = json['indicatorText'],
        //indicatorPercent = json['indicatorPercent'],
        source = json['source'],
        goal = json['goal'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        //'indicatorText': indicatorText,
        //'indicatorPercent': indicatorPercent,
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
//                     RESULT INDICATOR
//--------------------------------------------------------------
CollectionReference dbResultIndicator = db.collection("s4c_result_indicators");

class ResultIndicator {
  String id = "";
  String uuid = "";
  String name = "";
  String source = "";
  String base = "";
  String expected = "";
  String obtained = "";
  String result = "";

  ResultIndicator(this.result);

  ResultIndicator.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        source = json['source'],
        expected = json['expected'],
        obtained = json['obtained'],
        base = json['base'],
        result = json['result'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'source': source,
        'base': base,
        'expected': expected,
        'obtained': obtained,
        'result': result,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbResultIndicator.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbResultIndicator.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbResultIndicator.doc(id).delete();
  }
}

Future<List> getResultIndicators() async {
  List<ResultIndicator> items = [];

  QuerySnapshot query = await dbResultIndicator.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    // final _item = ActivityIndicator.fromJson(data);
    items.add(ResultIndicator.fromJson(data));
  }
  return items;
}

Future<List> getResultIndicatorsByResult(String result) async {
  List<ResultIndicator> items = [];

  QuerySnapshot query =
      await dbResultIndicator.where("result", isEqualTo: result).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ResultIndicator.fromJson(data));
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
  String users = "";
  DateTime iniDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Activity(this.result);

  Activity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        users = json['users'],
        iniDate = json["iniDate"].toDate(),
        endDate = json["endDate"].toDate(),
        result = json['result'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'users': users,
        'iniDate': iniDate,
        'endDate': endDate,
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
  String source = "";
  String base = "";
  String expected = "";
  String obtained = "";
  String activity = "";

  ActivityIndicator(this.activity);

  ActivityIndicator.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        source = json['source'],
        base = json['base'],
        expected = json['expected'],
        obtained = json['obtained'],
        activity = json['activity'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'source': source,
        'base': base,
        'expected': expected,
        'obtained': obtained,
        'activity': activity,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
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
  final dbAct = query.docs.first;
  final Map<String, dynamic> data = dbAct.data() as Map<String, dynamic>;
  data["id"] = dbAct.id;
  Activity activity = Activity.fromJson(data);

  QuerySnapshot queryR =
      await dbResult.where("uuid", isEqualTo: activity.result).get();
  final dbRes = queryR.docs.first;
  final Map<String, dynamic> dataResult = dbRes.data() as Map<String, dynamic>;
  dataResult["id"] = dbRes.id;
  Result result = Result.fromJson(dataResult);

  QuerySnapshot queryG =
      await dbGoal.where("uuid", isEqualTo: result.goal).get();
  final dbG = queryG.docs.first;
  final Map<String, dynamic> dataGoal = dbG.data() as Map<String, dynamic>;
  dataGoal["id"] = dbG.id;
  Goal goal = Goal.fromJson(dataGoal);

  QuerySnapshot queryP =
      await dbProject.where("uuid", isEqualTo: goal.project).get();
  final dbProj = queryP.docs.first;
  final Map<String, dynamic> dataProject =
      dbProj.data() as Map<String, dynamic>;
  dataProject["id"] = dbProj.id;
  SProject project = SProject.fromJson(dataProject);

  return "${project.name} > ${goal.name} > ${result.name} > ${activity.name}";
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
