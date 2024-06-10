import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

CollectionReference dbEvaluation = db.collection("s4c_evaluation");

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
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbEvaluation.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbEvaluation.doc(id).update(data);
    }
  }

  Future<void> delete() async {
    dbEvaluation.doc(id).delete();
  }

  static Future<Evaluation?> byProjectUuid(String uuid) async {
    QuerySnapshot query = await dbEvaluation.where('projectUuid', isEqualTo: uuid).get();
    if (query.docs.isNotEmpty) {
      Evaluation item = Evaluation.fromJson(query.docs.first.data() as Map<String, dynamic>);
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

// class EvaluationConclussion extends Object {
//   int index;
//   String description = "";
//   bool isRefML = false;
//   String unit = "";
//   int relevance = 0;
//   int feasibility = 0;
//   String recipientResponse =""; 
//   String improvementAction = "";
//   DateTime deadline = DateTime.now();
//   String verificationMethod = "";
//   String followUp = "";
//   DateTime followUpDate = DateTime.now();
//   String supervision = "";
//   String observations = "";

//   EvaluationConclussion(this.index);

//   Map<String, dynamic> toJson() {
//     return {
//       'description': description,
//       'isRefML': isRefML,
//       'unit': unit,
//       'relevance': relevance,
//       'feasibility': feasibility,
//       'recipientResponse': recipientResponse,
//       'improvementAction': improvementAction,
//       'deadline': deadline,
//       'verificationMethod': verificationMethod,
//       'followUp': followUp,
//       'followUpDate': followUpDate,
//       'supervision': supervision,
//       'observations': observations,
//     };
//   }

//   // fromJson
//   EvaluationConclussion.fromJson(Map<String, dynamic> json, this.index) {
//     description = json['description'];
//     isRefML = json['isRefML'];
//     unit = json['unit'];
//     relevance = json['relevance'];
//     feasibility = json['feasibility'];
//     recipientResponse = json['recipientResponse'];
//     improvementAction = json['improvementAction'];
//     deadline = json['deadline'].toDate();
//     verificationMethod = json['verificationMethod'];
//     followUp = json['followUp'];
//     followUpDate = json['followUpDate'].toDate();
//     supervision = json['supervision'];
//     observations = json['observations'];
//   }


//   @override
//   String toString() {
//     return toJson().toString();
//   }
// }

// class EvaluationRequirement extends Object {
//   int index;
//   String stakeholder = "";
//   String description = "";
//   bool isRefML = false;
//   String unit = "";
//   int relevance = 0;
//   int feasibility = 0;
//   String recipientResponse =""; 
//   String improvementAction = "";
//   DateTime deadline = DateTime.now();
//   String verificationMethod = "";
//   String followUp = "";
//   DateTime followUpDate = DateTime.now();
//   String supervision = "";
//   String observations = "";

//   EvaluationRequirement(this.index);

//   Map<String, dynamic> toJson() {
//     return {
//       'stakeholder': stakeholder,
//       'description': description,
//       'isRefML': isRefML,
//       'unit': unit,
//       'relevance': relevance,
//       'feasibility': feasibility,
//       'recipientResponse': recipientResponse,
//       'improvementAction': improvementAction,
//       'deadline': deadline,
//       'verificationMethod': verificationMethod,
//       'followUp': followUp,
//       'followUpDate': followUpDate,
//       'supervision': supervision,
//       'observations': observations,
//     };
//   }

//   // fromJson
//   EvaluationRequirement.fromJson(Map<String, dynamic> json, this.index) {
//     stakeholder = json['stakeholder'];
//     description = json['description'];
//     isRefML = json['isRefML'];
//     unit = json['unit'];
//     relevance = json['relevance'];
//     feasibility = json['feasibility'];
//     recipientResponse = json['recipientResponse'];
//     improvementAction = json['improvementAction'];
//     deadline = json['deadline'].toDate();
//     verificationMethod = json['verificationMethod'];
//     followUp = json['followUp'];
//     followUpDate = json['followUpDate'].toDate();
//     supervision = json['supervision'];
//     observations = json['observations'];
//   }


//   @override
//   String toString() {
//     return toJson().toString();
//   }
// }