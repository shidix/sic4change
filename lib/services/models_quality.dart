import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class ModelsQuality {
  String id;
  String uuid;
  String project;
  String calification;
  List<QualityQuestion> qualityQuestions;

  final database = db.collection("s4c_quality");

  ModelsQuality({
    required this.id,
    required this.uuid,
    required this.project,
    required this.calification,
    required this.qualityQuestions,
  });

  factory ModelsQuality.fromJson(Map data) {
    return ModelsQuality(
      id: data['id'],
      uuid: data['uuid'],
      project: data['project'],
      calification: data['calification'],
      qualityQuestions: data['qualityQuestions'],
    );
  }

  factory ModelsQuality.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return ModelsQuality.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'project': project,
        'calification': calification,
        'qualityQuestions': qualityQuestions,
      };

  @override
  String toString() {
    return 'ModelsQuality{id: $id, uuid: $uuid, project: $project, calification: $calification, qualityQuestions: $qualityQuestions}';
  }

  factory ModelsQuality.getEmpty() {
    return ModelsQuality(
      id: "",
      uuid: "",
      project: "",
      calification: "",
      qualityQuestions: [],
    );
  }

  void save() {
    if (id == "") {
      id = database.doc().id;
    }
    database.doc(id).set(toJson());
  }

  void delete() {
    database.doc(id).delete();
  }

  void addQualityQuestion(QualityQuestion qualityQuestion) {
    qualityQuestions.add(qualityQuestion);
  }

  void removeQualityQuestion(QualityQuestion qualityQuestion) {
    qualityQuestions.remove(qualityQuestion);
  }

  void updateQualityQuestion(QualityQuestion qualityQuestion) {
    qualityQuestions[qualityQuestions.indexWhere(
            (element) => element.subject == qualityQuestion.subject)] =
        qualityQuestion;
  }

  static byProject(String project) {
    return db.collection("s4c_quality").where("project", isEqualTo: project);
  }
}

class QualityQuestion {
  String subject;
  bool completed;
  String comments;
  List<String> docs;

  QualityQuestion({
    required this.subject,
    required this.completed,
    required this.comments,
    required this.docs,
  });
}
