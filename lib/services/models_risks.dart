import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
CollectionReference dbProject = db.collection("s4c_projects");

//--------------------------------------------------------------
//                           RISKS
//--------------------------------------------------------------
CollectionReference dbRisk = db.collection("s4c_risks");

class Risk {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  String occur = "No";
  String project = "";
  Map<String, dynamic> extraInfo = {};

  Risk(this.project);

  static Risk fromJson(Map<String, dynamic> json) {
    Risk item = Risk(json['project']);
    item.id = json["id"];
    item.uuid = json["uuid"];
    item.name = json['name'];
    item.description = json['description'];
    item.occur = json['occur'];
    item.project = json['project'];
    item.extraInfo = json['extraInfo'];
    if (!item.extraInfo.keys.contains("impact")) {
      item.extraInfo["impact"] = "";
    }
    if (!item.extraInfo.keys.contains("probability")) {
      item.extraInfo["probability"] = "";
    }
    if (!item.extraInfo.keys.contains("mitigations")) {
      item.extraInfo["mitigations"] = {};
    }
    if (!item.extraInfo.keys.contains("risk")) {
      item.extraInfo["risk"] = "";
    }
    if (!item.extraInfo.keys.contains("history")) {
      item.extraInfo["history"] = "";
    }
    if (!item.extraInfo.keys.contains("observations")) {
      item.extraInfo["observations"] = "";
    }
    return item;
  }

  Map<String, dynamic> toJson() {
    if (extraInfo.isEmpty) {
      extraInfo = {
        "impact": "",
        "probability": "",
        "mitigations": {},
        "risk": "",
        "history": "",
        "observations": ""
      };
    }

    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'description': description,
      'occur': occur,
      'project': project,
      'extraInfo': extraInfo,
    };
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbRisk.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbRisk.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbRisk.doc(id).delete();
  }

  /*Future<String> getProjectByGoal() async {
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
  }*/
}

Future<List> getRisks() async {
  List<Risk> items = [];

  QuerySnapshot query = await dbRisk.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Risk.fromJson(data));
  }
  return items;
}

Future<List> getRisksByProject(String project) async {
  List<Risk> items = [];

  QuerySnapshot query = await dbRisk.where("project", isEqualTo: project).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Risk.fromJson(data));
  }
  return items;
}
