import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class Quality {
  String id;
  String uuid;
  String project;
  String calification;
  List<QualityQuestion> qualityQuestions;

  final database = db.collection("s4c_quality");

  Quality({
    required this.id,
    required this.uuid,
    required this.project,
    required this.calification,
    required this.qualityQuestions,
  });

  factory Quality.fromJson(Map data) {
    Quality item = Quality(
      id: data['id'],
      uuid: data['uuid'],
      project: data['project'],
      calification: data['calification'],
      qualityQuestions: List<QualityQuestion>.empty(growable: true),
    );
    data['qualityQuestions'].forEach((element) {
      item.qualityQuestions.add(QualityQuestion.fromJson(element));
    });

    return item;

  }

  factory Quality.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Quality.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'id': id,
      'uuid': uuid,
      'project': project,
      'calification': calification,
      'qualityQuestions': [],
    };
    for (var element in qualityQuestions) {
      if (element.code != "") {
        data['qualityQuestions'].add(element.toJson());
      }
    }
    return data;

  }

  @override
  String toString() {
    return 'Quality{id: $id, uuid: $uuid, project: $project, calification: $calification, qualityQuestions: $qualityQuestions}';
  }

  factory Quality.getEmpty() {
    return Quality(
      id: "",
      uuid: const Uuid().v4(),
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

  static Future<Quality> byProject(String project) {
    return db.collection("s4c_quality").where("project", isEqualTo: project).get().then((value) {
      return Quality.fromFirestore(value.docs.first);
    }).catchError((error) {
      print("Quality.byProject :=> $error");
      Quality item = Quality.getEmpty();
      item.project = project;
      // item.save();
      return item;
    });
  }
}

class QualityQuestion {
  String code;
  String subject;
  bool completed;
  String comments;
  List docs;

  QualityQuestion({
    required this.code,
    required this.subject,
    required this.completed,
    required this.comments,
    required this.docs,
  });

  bool isMain() {
    return (!code.contains("."));
  }

  factory QualityQuestion.fromJson(Map data) {
    return QualityQuestion(
      code: data['code'],
      subject: data['subject'],
      completed: data['completed'],
      comments: data['comments'],
      docs: data['docs'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'subject': subject,
        'completed': completed,
        'comments': comments,
        'docs': docs,
      };

  @override
  String toString() {
    return 'QualityQuestion{code: $code, subject: $subject, completed: $completed, comments: $comments, docs: $docs}';
  }

  factory QualityQuestion.getEmpty() {
    return QualityQuestion(
      code: "",
      subject: "",
      completed: false,
      comments: "",
      docs: [],
    );
  }
}
