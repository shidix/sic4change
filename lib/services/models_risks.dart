import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
CollectionReference dbProject = db.collection("s4c_projects");

//--------------------------------------------------------------
//                           RISKS
//--------------------------------------------------------------
CollectionReference dbRisk = db.collection("s4c_risks");

class MitigationTracking {
  String description = "";
  DateTime date = DateTime.now();

  MitigationTracking();

  MitigationTracking.fromJson(Map<String, dynamic> json)
      : 
        description = json['description'],
        date = json['date'].toDate();
        

  Map<String, dynamic> toJson() => {
        'description': description,
        'date': date,
      };
}


class Mitigation {
  String name = "";
  String description = "";
  String responsible = "";
  DateTime date = DateTime.now();
  String status = "No implementada";
  List trackings = [];

  Mitigation();

  Mitigation.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        responsible = json['responsible'],
        date = json['date'],
        status = json['status'],
        trackings = json['trackings'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'responsible': responsible,
        'date': date,
        'status': status,
        'trackings': [ for (MitigationTracking tracking in trackings) tracking.toJson() ],
      };
}


class Risk {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  String occur = "No";
  String project = "";
  Map<String, dynamic> extraInfo = {};
  

  Risk(this.project);

  Risk.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        occur = json['occur'],
        project = json['project'],
        extraInfo = json['extraInfo'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'occur': occur,
        'project': project,
        'extraInfo': extraInfo,
      };

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
