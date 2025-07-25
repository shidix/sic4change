import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:uuid/uuid.dart';

class Transversal {
  final CollectionReference database;
  String id;
  String uuid;
  String project;
  String calification;
  List<TransversalQuestion> questions;

  Transversal(
      {required this.database,
      required this.id,
      required this.uuid,
      required this.project,
      required this.calification,
      required this.questions});

  void save() {
    if (id == "") {
      id = database.doc().id;
      createLog(
          "Creado transversal en la iniciativa '${SProject.getProjectName(project)}'");
    } else {
      createLog(
          "Modificado transversal en la iniciativa '${SProject.getProjectName(project)}'");
    }
    database.doc(id).set(toJson());
  }

  void delete() {
    database.doc(id).delete();
    createLog(
        "Borrado transversal en la iniciativa '${SProject.getProjectName(project)}'");
  }

  void addTransversalQuestion(TransversalQuestion question) {
    questions.add(question);
  }

  void removeTransversalQuestion(TransversalQuestion question) {
    questions.remove(question);
  }

  void updateTransversalQuestion(TransversalQuestion question) {
    questions[questions.indexWhere(
        (element) => element.subject == question.subject)] = question;
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

  static const tbName = "s4c_quality";

  Quality({
    required String id,
    required String uuid,
    required String project,
    required String calification,
    required List<TransversalQuestion> questions,
  }) : super(
          database: FirebaseFirestore.instance.collection(tbName),
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

  static Future<Quality> byProject(String project) async {
    return FirebaseFirestore.instance
        .collection(tbName)
        .where("project", isEqualTo: project)
        .get()
        .then((value) {
      Quality item = Quality.fromFirestore(value.docs.first);
      return item;
      // if (item.questions.isNotEmpty) {
      //   return item;
      // } else {
      //   return Quality.getEmpty();
      // }
    }).catchError((error) {
      Quality item = Quality.getEmpty();
      item.project = project;
      // item.save();
      return item;
    });
  }
}

class Transparency extends Transversal {
  static const String tbName = "s4c_transparency";

  Transparency({
    required String id,
    required String uuid,
    required String project,
    required String calification,
    required List<TransversalQuestion> questions,
  }) : super(
          database: FirebaseFirestore.instance.collection(tbName),
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

  static Future<Transparency> byProject(String project) {
    // get all the documents from the collection
    return FirebaseFirestore.instance.collection(tbName).get().then((value) {
      // get the first document that matches the project
      return value.docs.firstWhere((element) => element['project'] == project,
          orElse: () => throw "No document found");
    }).then((value) {
      // return the Transparency object from the document
      return Transparency.fromFirestore(value);
    }).catchError((error) {
      Transparency item = Transparency.getEmpty();
      item.project = project;
      // item.save();
      return item;
    });

    // return collection.where("project", isEqualTo: project).get().then((value) {
    //   return Transparency.fromFirestore(value.docs.first);
    // }).catchError((error) {
    //   print("Transparency.byProject :=> $error");
    //   Transparency item = Transparency.getEmpty();
    //   item.project = project;
    //   // item.save();
    //   return item;
    // });
  }
}

class Gender extends Transversal {
  static const String tbName = "s4c_gender";

  Gender({
    required String id,
    required String uuid,
    required String project,
    required String calification,
    required List<TransversalQuestion> questions,
  }) : super(
          database: FirebaseFirestore.instance.collection(tbName),
          id: id,
          uuid: uuid,
          project: project,
          calification: calification,
          questions: questions,
        );

  factory Gender.fromJson(Map data) {
    Gender item = Gender(
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

  factory Gender.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Gender.fromJson(data);
  }

  @override
  String toString() {
    return 'Gender{id: $id, uuid: $uuid, project: $project, calification: $calification, questions: $questions}';
  }

  factory Gender.getEmpty() {
    return Gender(
      id: "",
      uuid: const Uuid().v4(),
      project: "",
      calification: "",
      questions: [],
    );
  }

  static Future<Gender> byProject(String project) {
    return FirebaseFirestore.instance.collection(tbName).get().then((value
        // get the first document that matches the project
        ) {
      var item = value.docs.firstWhere(
          (element) => element['project'] == project,
          orElse: () => throw "No document found");
      return Gender.fromFirestore(item);
    }).then((value) {
      return value;
    }).catchError((error) {
      Gender item = Gender.getEmpty();
      item.project = project;
      return item;
    });

    // return
    // return db
    //     .collection(tableDB)
    //     .where("project", isEqualTo: project)
    //     .get()
    //     .then((value) {
    //   return Gender.fromFirestore(value.docs.first);
    // }).catchError((error) {
    //   print("Gender.byProject :=> $error");
    //   Gender item = Gender.getEmpty();
    //   item.project = project;
    //   // item.save();
    //   return item;
    // });
  }
}

class Environment extends Transversal {
  static const String tbName = "s4c_environment";

  Environment({
    required String id,
    required String uuid,
    required String project,
    required String calification,
    required List<TransversalQuestion> questions,
  }) : super(
          database: FirebaseFirestore.instance.collection(tbName),
          id: id,
          uuid: uuid,
          project: project,
          calification: calification,
          questions: questions,
        );

  factory Environment.fromJson(Map data) {
    Environment item = Environment(
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

  factory Environment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Environment.fromJson(data);
  }

  @override
  String toString() {
    return 'Environment{id: $id, uuid: $uuid, project: $project, calification: $calification, questions: $questions}';
  }

  factory Environment.getEmpty() {
    return Environment(
      id: "",
      uuid: const Uuid().v4(),
      project: "",
      calification: "",
      questions: [],
    );
  }

  static Future<Environment> byProject(String project) {
    return FirebaseFirestore.instance
        .collection(tbName)
        .where("project", isEqualTo: project)
        .get()
        .then((value) {
      return Environment.fromFirestore(value.docs.first);
    }).catchError((error) {
      Environment item = Environment.getEmpty();
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
  List<SFile> files = [];

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

  int compareTo(TransversalQuestion other) {
    List<String> aSlices = code.split(".");
    List<String> bSlices = other.code.split(".");
    //Remove empty strings from aSlices and bSlices
    aSlices.removeWhere((element) => element == "");
    bSlices.removeWhere((element) => element == "");
    for (int i = 0; i < aSlices.length; i++) {
      try {
        int a = int.parse(aSlices[i]);
        int b = 0;
        try {
          b = int.parse(bSlices[i]);
        } catch (e) {
          return 1;
        }
        if (a != b) {
          return a.compareTo(b);
        }
      } catch (e) {
        return aSlices[i].compareTo(bSlices[i]);
      }
    }
    return 0;
  }

  factory TransversalQuestion.fromJson(Map data) {
    TransversalQuestion item = TransversalQuestion(
      code: data['code'],
      subject: data['subject'],
      completed: data['completed'],
      comments: data['comments'],
      docs: data['docs'],
    );
    for (var loc in item.docs) {
      SFile.byLoc(loc).then((value) {
        item.files.add(value);
      });
    }
    return item;
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
