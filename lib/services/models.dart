// import 'dart:ffi';
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           PROJECTS
//--------------------------------------------------------------
CollectionReference dbProject = db.collection("s4c_projects");

class SProject {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  String type = "";
  String budget = "";
  String manager = "";
  String programme = "";
  String announcement = "";
  String ambit = "";
  bool audit = false;
  bool evaluation = false;
  List financiers = [];
  List partners = [];

  double dblbudget = 0;

  SProject(
    this.name,
  );

  SProject.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        type = json['type'],
        budget = json['budget'],
        manager = json['manager'],
        programme = json['programme'],
        announcement = json['announcement'],
        ambit = json['ambit'],
        audit = json['audit'],
        evaluation = json['evaluation'],
        financiers = json['financiers'],
        partners = json['partners'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'type': type,
        'budget': budget,
        'manager': manager,
        'programme': programme,
        'announcement': announcement,
        'ambit': ambit,
        'audit': audit.toString(),
        'evaluation': evaluation.toString(),
        'financiers': financiers.join(""),
        'partners': partners.join(""),
      };

  Map<String, String> toKeyValue() => {
        'key': uuid,
        'value': name,
      };

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbProject.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProject.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProject.doc(id).delete();
  }

  Future<SProject> reload() async {
    DocumentSnapshot _doc = await dbProject.doc(id).get();
    final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
    data["id"] = _doc.id;
    SProject.fromJson(data);
    return this;
  }

  Future<void> updateProjectFinanciers() async {
    await dbProject.doc(id).update({"financiers": financiers});
  }

  Future<void> updateProjectPartners() async {
    await dbProject.doc(id).update({"partners": partners});
  }

  String total_budget() {
    double aux = 24;
    return (aux.toString());
  }

  Future<double> totalBudget() async {
    final contribs = db.collection("s4c_finncontrib");
    final finns = db.collection("s4c_finns");
    dblbudget = 0;
    await finns
        .where("project", isEqualTo: uuid)
        .get()
        .then((list_finns) async {
      for (var finn in list_finns.docs) {
        await contribs
            .where("finn", isEqualTo: finn.data()["uuid"])
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            final Map<String, dynamic> data = doc.data();
            dblbudget += data["amount"];
          }
        });
      }
      ;
    });
    return dblbudget;
  }
}

Future<List> getProjects() async {
  List items = [];
  QuerySnapshot queryProject = await dbProject.get();
  for (var doc in queryProject.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = SProject.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<SProject> getProjectById(String id) async {
  DocumentSnapshot _doc = await dbProject.doc(id).get();
  final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
  data["id"] = _doc.id;
  return SProject.fromJson(data);
}

Future<SProject?> getProjectByUuid(String _uuid) async {
  QuerySnapshot query = await dbProject.where("uuid", isEqualTo: _uuid).get();
  final _doc = query.docs.first;
  final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
  data["id"] = _doc.id;
  return SProject.fromJson(data);
}

//--------------------------------------------------------------
//                       PROJECT TYPE
//--------------------------------------------------------------
class ProjectType {
  final String id;
  final String uuid;
  final String name;

  ProjectType(this.id, this.uuid, this.name);

  ProjectType.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}

//--------------------------------------------------------------
//                       PROJECT DATES
//--------------------------------------------------------------
class ProjectDates {
  final String id;
  final String uuid;
  final String approved;
  final String start;
  final String end;
  final String justification;
  final String delivery;
  final String project;

  ProjectDates(this.id, this.uuid, this.approved, this.start, this.end,
      this.justification, this.delivery, this.project);

  ProjectDates.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        approved = json["approved"],
        start = json["start"],
        end = json["end"],
        justification = json["justification"],
        delivery = json["delivery"],
        project = json["project"];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'approved': approved,
        'start': start,
        'end': end,
        'justification': justification,
        'delivery': delivery,
        'project': project,
      };
}

//--------------------------------------------------------------
//                       PROJECT LOCATION
//--------------------------------------------------------------
class ProjectLocation {
  final String id;
  final String uuid;
  final String country;
  final String province;
  final String region;
  final String town;
  final String project;

  ProjectLocation(this.id, this.uuid, this.country, this.province, this.region,
      this.town, this.project);

  ProjectLocation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        country = json["country"],
        province = json["province"],
        region = json["region"],
        town = json["town"],
        project = json["project"];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'country': country,
        'province': province,
        'region': region,
        'town': town,
        'project': project,
      };
}

//--------------------------------------------------------------
//                       PROJECT FINANCIER
//--------------------------------------------------------------
CollectionReference dbFinancier = db.collection("s4c_financier");

class Financier {
  String id = "";
  String uuid = "";
  String name = "";

  Financier(this.name);

  Financier.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbFinancier.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbFinancier.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProgramme.doc(id).delete();
  }
}

//--------------------------------------------------------------
//                       PROGRAMME
//--------------------------------------------------------------
CollectionReference dbProgramme = db.collection("s4c_programmes");

class Programme {
  String id = "";
  String uuid = "";
  String name = "";
  int projects = 0;

  Programme(this.name);

  Programme.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbProgramme.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProgramme.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProgramme.doc(id).delete();
  }

  Future<void> getProjects() async {
    QuerySnapshot query =
        await dbProject.where("programe", isEqualTo: uuid).get();
    projects = query.docs.length;
  }
}

Future<List> getProgrammes() async {
  List items = [];
  QuerySnapshot queryProgramme = await dbProgramme.get();

  for (var doc in queryProgramme.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Programme.fromJson(data);
    _item.getProjects();
    items.add(_item);
  }
  return items;
}
