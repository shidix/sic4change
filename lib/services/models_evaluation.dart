import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:uuid/uuid.dart';

class Evaluation extends Object {
  String id = "";
  String uuid = "";
  String projectUuid = "";

  List<dynamic> conclussions = [];
  List<dynamic> requirements = [];

  Evaluation(this.projectUuid);

  static Evaluation fromJson(Map<String, dynamic> json) {
    Evaluation item = Evaluation(json['projectUuid']);
    item.id = json["id"];
    item.uuid = json["uuid"];
    item.conclussions = json['conclussions'];
    item.requirements = json['requirements'];
    return item;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'projectUuid': projectUuid,
      'conclussions': conclussions,
      'requirements': requirements,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Future<void> save() async {
    // final dbEvaluation = db.collection('evaluations');
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection('evaluations').add(data);
      createLog(
          "Creada evaluación en la iniciativa '${SProject.getProjectName(projectUuid)}'");
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection('evaluations').doc(id).update(data);
      createLog(
          "Modificada evaluación en la iniciativa '${SProject.getProjectName(projectUuid)}'");
    }
  }

  Future<void> delete() async {
    // final dbEvaluation = db.collection('evaluations');
    await FirebaseFirestore.instance.collection('evaluations').doc(id).delete();
    createLog(
        "Borrada evaluación en la iniciativa '${SProject.getProjectName(projectUuid)}'");
  }

  static Future<Evaluation?> byProjectUuid(String uuid) async {
    // final dbEvaluation = db.collection('evaluations');
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('evaluations')
        .where('projectUuid', isEqualTo: uuid)
        .get();
    if (query.docs.isNotEmpty) {
      Evaluation item =
          Evaluation.fromJson(query.docs.first.data() as Map<String, dynamic>);
      item.id = query.docs.first.id;
      return item;
    }
    return null;
  }

  void updateRequirements(List<dynamic> requirements) {
    this.requirements = requirements;
    save();
  }

  void updateConclussions(List<dynamic> conclussions) {
    this.conclussions = conclussions;
    save();
  }
}
