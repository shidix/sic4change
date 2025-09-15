import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:uuid/uuid.dart';

//--------------------------------------------------------------
//                           RISKS
//--------------------------------------------------------------

class Risk {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  String occur = "No";
  String project = "";
  Map<String, dynamic> extraInfo = {};

  Risk(this.project);

  void checkExtraInfo() {
    if (!extraInfo.keys.contains("impact")) {
      extraInfo["impact"] = "";
    }
    if (!extraInfo.keys.contains("probability")) {
      extraInfo["probability"] = "";
    }
    if (!extraInfo.keys.contains("mitigations")) {
      extraInfo["mitigations"] = [];
    }
    if (!extraInfo.keys.contains("risk")) {
      extraInfo["risk"] = "";
    }
    if (!extraInfo.keys.contains("history")) {
      extraInfo["history"] = "";
    }
    if (!extraInfo.keys.contains("observations")) {
      extraInfo["observations"] = "";
    }
    if (!extraInfo.keys.contains("marco_logico")) {
      extraInfo["marco_logico"] = "No";
    }
    if (!extraInfo.keys.contains("objetivo")) {
      extraInfo["objetivo"] = "";
    }
    if (!extraInfo.keys.contains("fixed")) {
      extraInfo["fixed"] = "No";
    }
  }

  static Risk fromJson(Map<String, dynamic> json) {
    Risk item = Risk(json['project']);
    item.id = json["id"];
    item.uuid = json["uuid"];
    item.name = json['name'];
    item.description = json['description'];
    item.occur = json['occur'];
    item.project = json['project'];
    item.extraInfo = json['extraInfo'];
    item.checkExtraInfo();
    return item;
  }

  Map<String, dynamic> toJson() {
    if (extraInfo.isEmpty) {
      extraInfo = {
        "impact": "",
        "probability": "",
        "mitigations": [],
        "risk": "",
        "history": "",
        "observations": ""
      };
    }

    checkExtraInfo();

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
    final dbRisk = FirebaseFirestore.instance.collection("risks");
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbRisk.add(data);
      createLog(
          "Creado el riesgo '$name' en la iniciativa '${SProject.getProjectName(project)}'");
    } else {
      Map<String, dynamic> data = toJson();
      dbRisk.doc(id).set(data);
      createLog(
          "Modificado el riesgo '$name' en la iniciativa '${SProject.getProjectName(project)}'");
    }
  }

  Future<void> delete() async {
    final dbRisk = FirebaseFirestore.instance.collection("risks");
    if (id == "") {
      return;
    }
    await dbRisk.doc(id).delete();
    createLog(
        "Borrado el riesgo '$name' en la iniciativa '${SProject.getProjectName(project)}'");
  }

  static Future<List> getRisks() async {
    final dbRisk = FirebaseFirestore.instance.collection("risks");
    List<Risk> items = [];

    QuerySnapshot query = await dbRisk.get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Risk.fromJson(data));
    }
    return items;
  }

  static Future<List> getRisksByProject(String project) async {
    final dbRisk = FirebaseFirestore.instance.collection("risks");
    List<Risk> items = [];

    QuerySnapshot query =
        await dbRisk.where("project", isEqualTo: project).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Risk.fromJson(data));
    }
    return items;
  }
}
