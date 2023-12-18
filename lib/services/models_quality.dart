import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class Transversal {
  CollectionReference database;
  String id;
  String uuid;
  String project;
  String calification;
  List<TransversalQuestion> questions;


  Transversal( 
      {
      required this.database,
      required this.id,
      required this.uuid,
      required this.project,
      required this.calification,
      required this.questions});

  
  void save() {
    if (id == "") {
      id = database.doc().id;
    }
    database.doc(id).set(toJson());
  }

  void delete() {
    database.doc(id).delete();
  }

  void addTransversalQuestion(TransversalQuestion question) {
    questions.add(question);
  }

  void removeTransversalQuestion(TransversalQuestion question) {
    questions.remove(question);
  }

  void updateTransversalQuestion(TransversalQuestion question) {
    questions[questions.indexWhere(
            (element) => element.subject == question.subject)] =
        question;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'id': id,
      'uuid': uuid,
      'project': project,
      'calification': calification,
      'questions': [],
    };
    for (var element in questions) {
      if (element.code != "") {
        data['questions'].add(element.toJson());
      }
    }
    return data;

  }

}

class Quality extends Transversal {
  // String id;
  // String uuid;
  // String project;
  // String calification;
  // List<TransversalQuestion> qualityQuestions;

  static final collection = db.collection("s4c_quality");

  Quality({
    required String id,
    required String uuid,
    required String project,
    required String calification,
    required List<TransversalQuestion> questions,
  }) : super(
          database: db.collection("s4c_quality"),
          id: id,
          uuid: uuid,
          project: project,
          calification: calification,
          questions: questions,
        );

  factory Quality.fromJson(Map data) {
    Quality item = Quality(
      id: data['id'],
      uuid: data['uuid'],
      project: data['project'],
      calification: data['calification'],
      questions: List<TransversalQuestion>.empty(growable: true),
    );
    data['questions'].forEach((element) {
      item.questions.add(TransversalQuestion.fromJson(element));
    });

    return item;

  }

  factory Quality.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Quality.fromJson(data);
  }


  @override
  String toString() {
    return 'Quality{id: $id, uuid: $uuid, project: $project, calification: $calification, questions: $questions}';
  }

  factory Quality.getEmpty() {
    return Quality(
      id: "",
      uuid: const Uuid().v4(),
      project: "",
      calification: "",
      questions: [],
    );
  }


  static Future<Quality> byProject(String project) {
    return collection.where("project", isEqualTo: project).get().then((value) {
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

class Transparency extends Transversal {
  static final collection = db.collection("s4c_transparency");

  Transparency ({
    required String id,
    required String uuid,
    required String project,
    required String calification,
    required List<TransversalQuestion> questions,
  }) : super(
          database: db.collection("s4c_transparency"),
          id: id,
          uuid: uuid,
          project: project,
          calification: calification,
          questions: questions,
        ); 

  factory Transparency.fromJson(Map data) {
    Transparency item = Transparency(
      id: data['id'],
      uuid: data['uuid'],
      project: data['project'],
      calification: data['calification'],
      questions: List<TransversalQuestion>.empty(growable: true),
    );
    data['questions'].forEach((element) {
      item.questions.add(TransversalQuestion.fromJson(element));
    });

    return item;
  }

  factory Transparency.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Transparency.fromJson(data);
  }

  @override
  String toString() {
    return 'Transparency{id: $id, uuid: $uuid, project: $project, calification: $calification, questions: $questions}';
  }

  factory Transparency.getEmpty() {
    return Transparency(
      id: "",
      uuid: const Uuid().v4(),
      project: "",
      calification: "",
      questions: [],
    );
  }

  static Future<Transparency> byProject (String project) 
  {
    return collection.where("project", isEqualTo: project).get().then((value) {
      return Transparency.fromFirestore(value.docs.first);
    }).catchError((error) {
      print("Transparency.byProject :=> $error");
      Transparency item = Transparency.getEmpty();
      item.project = project;
      // item.save();
      return item;
    });
  }

}

class TransversalQuestion {
  String code;
  String subject;
  bool completed;
  String comments;
  List docs;

  TransversalQuestion({
    required this.code,
    required this.subject,
    required this.completed,
    required this.comments,
    required this.docs,
  });

  bool isMain() {
    return (!code.contains("."));
  }

  factory TransversalQuestion.fromJson(Map data) {
    return TransversalQuestion(
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
    return 'TransversalQuestion{code: $code, subject: $subject, completed: $completed, comments: $comments, docs: $docs}';
  }

  factory TransversalQuestion.getEmpty() {
    return TransversalQuestion(
      code: "",
      subject: "",
      completed: false,
      comments: "",
      docs: [],
    );
  }
}
