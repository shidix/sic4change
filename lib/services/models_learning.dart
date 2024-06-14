import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/utils.dart';
import 'package:uuid/uuid.dart';

class LearningInfo extends Object {
  String id = "";
  String uuid;
  String project;
  List<Learning> items = [];

  LearningInfo(this.uuid, this.project);

  static LearningInfo fromJson(Map<String, dynamic> json) {
    LearningInfo info = LearningInfo("", "");
    info.id = json['id'];
    info.uuid = json['uuid'];
    info.project = json['project'];

    for (var item in json['items']) {
      Learning learning = Learning.fromJson(item);

      info.items.add(learning);
    }

    return info;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'project': project,
        'items': items.map(
          (e) => e.toJson(),
        )
      };

  void save() async {
    final db = FirebaseFirestore.instance;
    final database = db.collection("s4c_learnings");
    if (uuid == "") {
      uuid = const Uuid().v4();
      Map<String, dynamic> data = toJson();
      await database.add(data).then((value) {
        id = value.id;
        database.doc(id).update(toJson());
      });
    } else {
      if (id == "") {
        await database.where("uuid", isEqualTo: uuid).get().then((value) {
          if (value.docs.isNotEmpty) {
            id = value.docs.first.id;
          }
        });
      }
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
    }
  }

  void delete() async {
    final db = FirebaseFirestore.instance;
    final database = db.collection("s4c_learnings");
    if (id != "") {
      await database.doc(id).delete();
    } else {
      await database.where("uuid", isEqualTo: uuid).get().then((value) {
        if (value.docs.isNotEmpty) {
          id = value.docs.first.id;
          database.doc(id).delete();
        }
      });
    }
  }

  void updateLearning(Learning learning) {
    int itemPos = items.indexWhere((element) => element.uuid == learning.uuid);
    if (itemPos != -1) {
      items[itemPos] = learning;
    } else {
      items.add(learning);
    }
    save();
  }

  void removeLearning(Learning learning) {
    items.removeWhere((element) => element.uuid == learning.uuid);
    save();
  }

  static Future<LearningInfo?> byProject(String projectUuid) async {
    final db = FirebaseFirestore.instance;
    final database = db.collection("s4c_learnings");
    LearningInfo? learningInfo;
    await database.where("project", isEqualTo: projectUuid).get().then((value) {
      if (value.docs.isNotEmpty) {
        learningInfo = LearningInfo.fromJson(value.docs.first.data());
      } else {
        learningInfo = LearningInfo("", projectUuid);
        learningInfo!.save();
      }
    });
    return learningInfo;
  }
}

class Learning extends Object {
  String uuid;
  String project;
  String description;
  String kind;
  DateTime date;

  Learning(this.uuid, this.project, this.description, this.kind, this.date);

  static Learning fromJson(Map<String, dynamic> json) {
    DateTime date = getDate(json['date']);
    Learning learning = Learning(
        json['uuid'], json['project'], json['description'], json['kind'], date);
    return learning;
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'project': project,
        'description': description,
        'kind': kind,
        'date': date,
      };
}
