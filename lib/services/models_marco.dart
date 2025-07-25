// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           GOAL
//--------------------------------------------------------------

class Goal {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  bool main = false;
  String project = "";
  double indicatorsPercent = 0;

  static final CollectionReference dbGoal = db.collection("s4c_goals");

  String projectName = "";

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
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbGoal.add(data).then((value) => id = value.id);
      createLog(
          "Creado el objetivo '$name' en la iniciativa '${SProject.getProjectName(project)}'");
    } else {
      Map<String, dynamic> data = toJson();
      dbGoal.doc(id).set(data);
      createLog(
          "Modificado el objetivo '$name' de la iniciativa '${SProject.getProjectName(project)}'");
    }
  }

  Future<void> delete() async {
    await dbGoal.doc(id).delete();
    createLog(
        "Borrado el objetivo '$name' de la iniciativa '${SProject.getProjectName(project)}'");
  }

  /*Future<String> getProjectByGoal() async {
    SProject proj = SProject("");
    QuerySnapshot query =
        await dbProject.where("uuid", isEqualTo: project).get();
    final dbP = query.docs.first;
    final Map<String, dynamic> data = dbP.data() as Map<String, dynamic>;
    data["id"] = dbP.id;
    proj = SProject.fromJson(data);
    return proj.name;
  }*/

  static Future<double> getIndicatorsPercent(uuid) async {

    double totalExpected = 0;
    double totalObtained = 0;
    double total = 0;
    List<GoalIndicator> indicators = await GoalIndicator.getGoalIndicatorsByGoal(uuid);
    for (GoalIndicator indicator in indicators) {
      try {
        totalExpected += double.parse(indicator.expected);
        // ignore: empty_catches
      } catch (e) {}
      try {
        totalObtained += double.parse(indicator.obtained);
        // ignore: empty_catches
      } catch (e) {}
    }
    if (totalExpected > 0) total = totalObtained / totalExpected;
    if (total > 1) total = 1;
    //indicatorsPercent = total;
    return total;
  }

  static Future<void> checkOE0(String project, String programme) async {
    Goal item;
    Programme prog = await Programme.byUuid(programme);
    try {
      QuerySnapshot query = await dbGoal
          .where("project", isEqualTo: project)
          .where("name", isEqualTo: "OE0")
          .get();
      final db = query.docs.first;

      final Map<String, dynamic> data = db.data() as Map<String, dynamic>;
      data["id"] = db.id;
      item = Goal.fromJson(data);
      if (item.description != prog.impact) {
        item.description == prog.impact;
        item.save();
      }
    } catch (e) {
      item = Goal(project);
      item.name = "OE0";
      item.description = prog.impact;
      item.save();
    }
    List indicators = await getProgrammesIndicators(programme);
    List goalIndicators = await GoalIndicator.getGoalIndicatorsByGoal(item.uuid);
    for (ProgrammeIndicators indicator in indicators) {
      bool exist = false;
      for (GoalIndicator gi in goalIndicators) {
        if (gi.code == indicator.uuid) {
          exist = true;
          if (gi.name != indicator.name) {
            gi.name = indicator.name;
            gi.save();
          }
        }
      }
      if (exist == false) {
        GoalIndicator gi = GoalIndicator(item.uuid);
        gi.code = indicator.uuid;
        gi.name = indicator.name;
        gi.order = indicator.order.toString();
        gi.save();
      }
    }
  }

  static Future<Goal> byUuid(uuid) async {
    Goal item = Goal("");
    await dbGoal.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Goal.fromJson(data);
    });
    return item;
  }


  static Future<List> getGoals() async {
    List<Goal> items = [];

    QuerySnapshot query = await dbGoal.get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Goal.fromJson(data));
    }
    return items;
  }

  static Future<List> getGoalsByProject(String project) async {
    List<Goal> items = [];

    try {
      QuerySnapshot query = await dbGoal
          .orderBy("project")
          .orderBy("main", descending: true)
          .orderBy("name", descending: false)
          .where("project", isEqualTo: project)
          .get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        Goal item = Goal.fromJson(data);
        //await item.getIndicatorsPercent();
        items.add(item);
      }
    } catch (e) {
      print(e);
    }
    return items;
  }
}


//--------------------------------------------------------------
//                     GOALS INDICATOR
//--------------------------------------------------------------

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
  String code = "";
  String unit = "";
  String goal = "";
  Folder? folderObj;

  static final CollectionReference dbGoalIndicator =
      db.collection("s4c_goal_indicators");

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
        code = json['code'],
        unit = json['unit'],
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
        'code': code,
        'unit': unit,
        'goal': goal,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbGoalIndicator.add(data).then((value) => id = value.id);
      createLog(
          "Creado el indicador '$name' en el objetivo '${getGoalName()}'");
    } else {
      Map<String, dynamic> data = toJson();
      dbGoalIndicator.doc(id).set(data);
      createLog(
          "Modificado el indicador '$name' en el objetivo '${getGoalName()}'");
    }
  }

  Future<void> delete() async {
    await dbGoalIndicator.doc(id).delete();
    createLog(
        "Eliminado el indicador '$name' en el objetivo '${getGoalName()}'");
  }

  Future<void> getFolder() async {
    if ((folder != "") && (folderObj == null)) {
      folderObj = await Folder.byLoc(folder);
    }
  }

  Future<String> getGoalName() async {
    // Goal g = Goal("");
    // QuerySnapshot query = await dbGoal.where("uuid", isEqualTo: goal).get();
    // final dbP = query.docs.first;
    // final Map<String, dynamic> data = dbP.data() as Map<String, dynamic>;
    // data["id"] = dbP.id;
    // g = Goal.fromJson(data);
    Goal g = await Goal.byUuid(goal);
    return g.name;
  }


  static Future<List> getGoalIndicators() async {
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

  static Future<List<GoalIndicator>> getGoalIndicatorsByGoal(String goal) async {
    List<GoalIndicator> items = [];

    //QuerySnapshot query =
    //    await dbGoalIndicator.where("goal", isEqualTo: goal).get();
    try {
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
    } catch (e) {
      print(e);
    }
    return items;
  }

  static Future<List> getGoalIndicatorsByCode(String code) async {
    List<GoalIndicator> items = [];

    try {
      QuerySnapshot query =
          await dbGoalIndicator.where("code", isEqualTo: code).get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        GoalIndicator item = GoalIndicator.fromJson(data);
        await item.getFolder();
        items.add(item);
      }
    } catch (e) {
      print(e);
    }
    return items;
  }

}

//--------------------------------------------------------------
//                           RESULT
//--------------------------------------------------------------

class Result {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  //String indicatorText = "";
  //String indicatorPercent = "";
  String source = "";
  String goal = "";
  double indicatorsPercent = 0;

  static final CollectionReference dbResult = db.collection("s4c_results");

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
      dbResult.add(data).then((value) => id = value.id);
      createLog(
          "Creado el resultado '$name' en el objetivo '${getGoalName()}'");
    } else {
      Map<String, dynamic> data = toJson();
      dbResult.doc(id).set(data);
      createLog(
          "Modificado el resultado '$name' en el objetivo '${getGoalName()}'");
    }
  }

  Future<void> delete() async {
    await dbResult.doc(id).delete();
    createLog(
        "Eliminado el resultado '$name' en el objetivo '${getGoalName()}'");
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

    // queryG = await dbGoal.where("uuid", isEqualTo: result.goal).get();
    // final dbG = queryG.docs.first;
    // final Map<String, dynamic> dataGoal = dbG.data() as Map<String, dynamic>;
    // dataGoal["id"] = dbG.id;
    // goal = Goal.fromJson(dataGoal);
    goal = await Goal.byUuid(result.goal);

    // queryP = await dbProject.where("uuid", isEqualTo: goal.project).get();
    // final dbProj = queryP.docs.first;
    // final Map<String, dynamic> dataProject =
    //     dbProj.data() as Map<String, dynamic>;
    // dataProject["id"] = dbProj.id;
    // project = SProject.fromJson(dataProject);
    project = await SProject.byUuid(goal.project);

    return "${project.name} > ${goal.name} > ${result.name}";
  }

  static Future<double> getIndicatorsPercent(uuid) async {
    double totalExpected = 0;
    double totalObtained = 0;
    double total = 0;
    // try {
    //   QuerySnapshot query =
    //       await dbResultIndicator.where("result", isEqualTo: uuid).get();
    //   for (var doc in query.docs) {
    //     final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //     data["id"] = doc.id;
    //     ResultIndicator indicator = ResultIndicator.fromJson(data);
    //     try {
    //       totalExpected += double.parse(indicator.expected);
    //       // ignore: empty_catches
    //     } catch (e) {}
    //     try {
    //       totalObtained += double.parse(indicator.obtained);
    //       // ignore: empty_catches
    //     } catch (e) {}
    //   }
    // } catch (e) {
    //   print(e);
    // }
    List<ResultIndicator> indicators =
        await ResultIndicator.getResultIndicatorsByResult(uuid);
    if (totalExpected > 0) total = totalObtained / totalExpected;
    if (total > 1) total = 1;
    //indicatorsPercent = total;
    return total;
  }

  Future<String> getGoalName() async {
    // Goal g = Goal("");
    // QuerySnapshot query = await dbGoal.where("uuid", isEqualTo: goal).get();
    // final dbP = query.docs.first;
    // final Map<String, dynamic> data = dbP.data() as Map<String, dynamic>;
    // data["id"] = dbP.id;
    // g = Goal.fromJson(data);
    Goal g = await Goal.byUuid(goal);
    return g.name;
  }

  static Future<Result> byUuid(uuid) async {
    Result item = Result("");
    await dbResult.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Result.fromJson(data);
    });
    return item;
  }

  static Future<List> getResults() async {
    List<Result> items = [];

    QuerySnapshot query = await dbResult.get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Result.fromJson(data));
    }
    return items;
  }

  static Future<List<Result>> getResultsByGoal(String goal) async {
    List<Result> items = [];

    try {
      QuerySnapshot query = await dbResult
          //.orderBy("goal")
          //.orderBy("main", descending: true)
          .where("goal", isEqualTo: goal)
          .get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        Result item = Result.fromJson(data);
        //await item.getIndicatorsPercent();
        items.add(item);
      }
    } catch (e) {
      print(e);
    }
    return items;
  }

}


//--------------------------------------------------------------
//                     RESULT INDICATOR
//--------------------------------------------------------------

class ResultIndicator {
  String id = "";
  String uuid = "";
  String name = "";
  String source = "";
  String base = "";
  String expected = "";
  String obtained = "";
  String unit = "";
  String result = "";

  static final CollectionReference dbResultIndicator =
      db.collection("s4c_result_indicators");

  ResultIndicator(this.result);

  ResultIndicator.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        source = json['source'],
        expected = json['expected'],
        obtained = json['obtained'],
        base = json['base'],
        unit = json['unit'],
        result = json['result'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'source': source,
        'base': base,
        'expected': expected,
        'obtained': obtained,
        'unit': unit,
        'result': result,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbResultIndicator.add(data).then((value) => id = value.id);
      createLog(
          "Creado el indicador '$name' en el resultado '${getResultName()}'");
    } else {
      Map<String, dynamic> data = toJson();
      dbResultIndicator.doc(id).set(data);
      createLog(
          "Modificado el indicador '$name' en el resultado '${getResultName()}'");
    }
  }

  Future<void> delete() async {
    await dbResultIndicator.doc(id).delete();
    createLog(
        "Borrado el indicador '$name' en el resultado '${getResultName()}'");
  }

  Future<String> getResultName() async {
    // Result r = Result("");
    // QuerySnapshot query = await dbResult.where("uuid", isEqualTo: result).get();
    // final dbP = query.docs.first;
    // final Map<String, dynamic> data = dbP.data() as Map<String, dynamic>;
    // data["id"] = dbP.id;
    // r = Result.fromJson(data);
    Result r = await Result.byUuid(result);
    return r.name;
  }

  static Future<ResultIndicator> byUuid(uuid) async {
    ResultIndicator item = ResultIndicator("");
    await dbResultIndicator.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = ResultIndicator.fromJson(data);
    });
    return item;
  }

  static Future<List<ResultIndicator>> getResultIndicators() async {
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

  static Future<List<ResultIndicator>> getResultIndicatorsByResult(String result) async {
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
}


//--------------------------------------------------------------
//                           ACTIVITY
//--------------------------------------------------------------

class Activity {
  String id = "";
  String uuid = "";
  String name = "";
  String result = "";
  String users = "";
  DateTime iniDate = DateTime.now();
  DateTime endDate = DateTime.now();
  double indicatorsPercent = 0;

  static final CollectionReference dbActivity = db.collection("s4c_activities");

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
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbActivity.add(data).then((value) => id = value.id);
      createLog(
          "Creada la actividad '$name' en el resultado '${getResultName()}'");
    } else {
      Map<String, dynamic> data = toJson();
      dbActivity.doc(id).set(data);
      createLog(
          "Modificada la actividad '$name' en el resultado '${getResultName()}'");
    }
  }

  Future<void> delete() async {
    await dbActivity.doc(id).delete();
    createLog(
        "Borrada la actividad '$name' en el resultado '${getResultName()}'");
  }

  static Future<double> getIndicatorsPercent(uuid) async {
    // QuerySnapshot query =
    //     await dbActivityIndicator.where("activity", isEqualTo: uuid).get();
    // double totalExpected = 0;
    // double totalObtained = 0;
    // double total = 0;
    // for (var doc in query.docs) {
    //   final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //   data["id"] = doc.id;
    //   ActivityIndicator indicator = ActivityIndicator.fromJson(data);
    //   try {
    //     totalExpected += double.parse(indicator.expected);
    //     // ignore: empty_catches
    //   } catch (e) {}
    //   try {
    //     totalObtained += double.parse(indicator.obtained);
    //     // ignore: empty_catches
    //   } catch (e) {}
    // }
    double totalExpected = 0;
    double totalObtained = 0;
    double total = 0;
    List<ActivityIndicator> indicators =
        await ActivityIndicator.getActivityIndicatorsByActivity(uuid);
    if (totalExpected > 0) total = totalObtained / totalExpected;
    if (total > 1) total = 1;
    //indicatorsPercent = total;
    return total;
  }

  Future<String> getResultName() async {
    // Result r = Result("");
    // QuerySnapshot query = await dbResult.where("uuid", isEqualTo: result).get();
    // final dbP = query.docs.first;
    // final Map<String, dynamic> data = dbP.data() as Map<String, dynamic>;
    // data["id"] = dbP.id;
    // r = Result.fromJson(data);
    Result r = await Result.byUuid(result);
    return r.name;
  }

  static Future<Activity> byUuid(uuid) async {
    Activity item = Activity("");
    await dbActivity.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Activity.fromJson(data);
    });
    return item;
  }


  static Future<List> getActivities() async {
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

  static Future<List> getActivitiesByResult(result) async {
    List<Activity> items = [];

    QuerySnapshot query =
        await dbActivity.where("result", isEqualTo: result).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Activity item = Activity.fromJson(data);
      //await item.getIndicatorsPercent();
      items.add(item);
    }
    return items;
  }

}

//--------------------------------------------------------------
//                     ACTIVITY INDICATOR
//--------------------------------------------------------------


class ActivityIndicator {
  String id = "";
  String uuid = "";
  String name = "";
  String source = "";
  String base = "";
  String expected = "";
  String obtained = "";
  String unit = "";
  String activity = "";

  static final CollectionReference dbActivityIndicator =
      db.collection("s4c_activity_indicators");

  ActivityIndicator(this.activity);

  ActivityIndicator.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        source = json['source'],
        base = json['base'],
        expected = json['expected'],
        obtained = json['obtained'],
        unit = json['unit'],
        activity = json['activity'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'source': source,
        'base': base,
        'expected': expected,
        'obtained': obtained,
        'unit': unit,
        'activity': activity,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbActivityIndicator.add(data).then((value) => id = value.id);
      createLog(
          "Creado el indicador '$name' en la actividad '${getActivityName()}'");
    } else {
      Map<String, dynamic> data = toJson();
      dbActivityIndicator.doc(id).set(data);
      createLog(
          "Modificado el indicador '$name' en la actividad '${getActivityName()}'");
    }
  }

  Future<void> delete() async {
    await dbActivityIndicator.doc(id).delete();
    createLog(
        "Borrado el indicador '$name' en la actividad '${getActivityName()}'");
  }

  Future<String> getActivityName() async {
    // Activity a = Activity("");
    // QuerySnapshot query =
    //     await dbActivity.where("uuid", isEqualTo: activity).get();
    // final dbP = query.docs.first;
    // final Map<String, dynamic> data = dbP.data() as Map<String, dynamic>;
    // data["id"] = dbP.id;
    // a = Activity.fromJson(data);
    Activity a = await Activity.byUuid(activity);
    return a.name;
  }

  static Future<List> getActivityIndicators() async {
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

  static Future<List<ActivityIndicator>> getActivityIndicatorsByActivity(String _activity) async {
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

}


Future<String> getProjectByActivityIndicator(String _uuid) async {
  // QuerySnapshot query = await dbActivity.where("uuid", isEqualTo: _uuid).get();
  // final dbAct = query.docs.first;
  // final Map<String, dynamic> data = dbAct.data() as Map<String, dynamic>;
  // data["id"] = dbAct.id;
  // Activity activity = Activity.fromJson(data);
  Activity activity = await Activity.byUuid(_uuid);

  // QuerySnapshot queryR =
  //     await dbResult.where("uuid", isEqualTo: activity.result).get();
  // final dbRes = queryR.docs.first;
  // final Map<String, dynamic> dataResult = dbRes.data() as Map<String, dynamic>;
  // dataResult["id"] = dbRes.id;
  // Result result = Result.fromJson(dataResult);
  Result result = await Result.byUuid(activity.result);

  // QuerySnapshot queryG =
  //     await dbGoal.where("uuid", isEqualTo: result.goal).get();
  // final dbG = queryG.docs.first;
  // final Map<String, dynamic> dataGoal = dbG.data() as Map<String, dynamic>;
  // dataGoal["id"] = dbG.id;
  // Goal goal = Goal.fromJson(dataGoal);

  Goal goal = await Goal.byUuid(result.goal);

  // QuerySnapshot queryP =
  //     await dbProject.where("uuid", isEqualTo: goal.project).get();
  // final dbProj = queryP.docs.first;
  // final Map<String, dynamic> dataProject =
  //     dbProj.data() as Map<String, dynamic>;
  // dataProject["id"] = dbProj.id;
  // SProject project = SProject.fromJson(dataProject);
  SProject project = await SProject.byUuid(goal.project);

  return "${project.name} > ${goal.name} > ${result.name} > ${activity.name}";
}

//--------------------------------------------------------------
//                       RESULT TASK
//--------------------------------------------------------------

class ResultTask {
  String id = "";
  String uuid = "";
  String name = "";
  String result = "";

  static final CollectionReference dbResultTask =
      db.collection("s4c_result_tasks");

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
      var _uuid = const Uuid();
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


  static Future<List> getResultTasks() async {
    List<ResultTask> items = [];

    QuerySnapshot query = await dbResultTask.get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(ResultTask.fromJson(data));
    }
    return items;
  }

  static Future<List> getResultTasksByResult(String _result) async {
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

}

Future<String> getProjectByResultTask(String _uuid) async {
  // QuerySnapshot query = await dbResult.where("uuid", isEqualTo: _uuid).get();
  // final _dbResult = query.docs.first;
  // final Map<String, dynamic> dataResult =
  //     _dbResult.data() as Map<String, dynamic>;
  // dataResult["id"] = _dbResult.id;
  // Result _result = Result.fromJson(dataResult);
  Result _result = await Result.byUuid(_uuid);

  // QuerySnapshot queryG =
  //     await dbGoal.where("uuid", isEqualTo: _result.goal).get();
  // final _dbGoal = queryG.docs.first;
  // final Map<String, dynamic> dataGoal = _dbGoal.data() as Map<String, dynamic>;
  // dataGoal["id"] = _dbGoal.id;
  // Goal _goal = Goal.fromJson(dataGoal);

  Goal _goal = await Goal.byUuid(_result.goal);

  // QuerySnapshot queryP =
  //     await dbProject.where("uuid", isEqualTo: _goal.project).get();
  // final _dbProject = queryP.docs.first;
  // final Map<String, dynamic> dataProject =
  //     _dbProject.data() as Map<String, dynamic>;
  // dataProject["id"] = _dbProject.id;
  // SProject _project = SProject.fromJson(dataProject);
  SProject _project = await SProject.byUuid(_goal.project);

  return "${_project.name} > ${_goal.name} > ${_result.name}";
}
