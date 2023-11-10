// import 'dart:ffi';
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


class SProject {
  final String id;
  final String uuid;
  final String name;
  final String description;
  final String type;
  final String budget;
  final String manager;
  final String programme;
  final String announcement;
  final String ambit;
  final bool audit;
  final bool evaluation;
  final List financiers;
  final List partners;

  double dblbudget=0;

  SProject(
      this.id,
      this.uuid,
      this.name,
      this.description,
      this.type,
      this.budget,
      this.manager,
      this.programme,
      this.announcement,
      this.ambit,
      this.audit,
      this.evaluation,
      this.financiers,
      this.partners);

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

  Map<String, String> toJson() => {
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

  Future<double> totalBudget() async {
    final contribs = db.collection("s4c_finncontrib");
    final finns = db.collection("s4c_finns");
    dblbudget = 0;
    await finns.where("project", isEqualTo: uuid).get().then((list_finns) async
    {
      for (var finn in list_finns.docs)
      {
        await contribs.where("finn", isEqualTo: finn.data()["uuid"]).get().then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            final Map<String, dynamic> data = doc.data();
            dblbudget += data["amount"];
          }
        });
      };
    });
    return dblbudget;
  }
}

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

class Financier {
  final String id;
  final String uuid;
  final String name;

  Financier(this.id, this.uuid, this.name);

  Financier.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}

class Programme {
  final String id;
  final String uuid;
  final String name;

  Programme(this.id, this.uuid, this.name);

  Programme.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}

/*class Folder {
  final String id;
  final String uuid;
  final String name;
  final String parent;

  Folder(this.id, this.uuid, this.name, this.parent);

  Folder.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        parent = json['parent'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'parent': parent,
      };
}

class SFile {
  final String id;
  final String uuid;
  final String name;
  final String folder;
  final String link;

  SFile(this.id, this.uuid, this.name, this.folder, this.link);

  SFile.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        folder = json['folder'],
        link = json['link'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'folder': folder,
        'link': link,
      };
}*/

/*class Contact {
  final String id;
  final String uuid;
  final String name;
  final String company;
  final List<String> projects;
  final String position;
  final String email;
  final String phone;

  Contact(this.id, this.uuid, this.name, this.company, this.projects,
      this.position, this.email, this.phone);

  Contact.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        company = json['company'],
        projects = List.from(json['projects']),
        position = json["position"],
        email = json["email"],
        phone = json["phone"];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'company': company,
        'projects': projects.join(","),
        'position': position,
        'email': email,
        'phone': phone,
      };
}

class Company {
  final String id;
  final String uuid;
  final String name;

  Company(this.id, this.uuid, this.name);

  Company.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}

class Position {
  final String id;
  final String uuid;
  final String name;

  Position(this.id, this.uuid, this.name);

  Position.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}*/

/*class Goal {
  final String id;
  final String uuid;
  final String name;
  final String description;
  final bool main;
  final String project;

  Goal(
      this.id, this.uuid, this.name, this.description, this.main, this.project);

  Goal.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        main = json['main'],
        project = json['project'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'main': main.toString(),
        'project': project,
      };
}

class Result {
  final String id;
  final String uuid;
  final String name;
  final String description;
  final String indicator_text;
  final String indicator_percent;
  final String source;
  final String goal;

  Result(this.id, this.uuid, this.name, this.description, this.indicator_text,
      this.indicator_percent, this.source, this.goal);

  Result.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        indicator_text = json['indicator_text'],
        indicator_percent = json['indicator_percent'],
        source = json['source'],
        goal = json['goal'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'indicator_text': indicator_text,
        'indicator_percent': indicator_percent,
        'source': source,
        'goal': goal,
      };
}

class Activity {
  final String id;
  final String uuid;
  final String name;
  final String result;

  Activity(this.id, this.uuid, this.name, this.result);

  Activity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        result = json['result'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'result': result,
      };
}

class ActivityIndicator {
  final String id;
  final String uuid;
  final String name;
  final String percent;
  final String source;
  final String activity;

  ActivityIndicator(
      this.id, this.uuid, this.name, this.percent, this.source, this.activity);

  ActivityIndicator.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        percent = json['percent'],
        source = json['source'],
        activity = json['activity'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'percent': percent,
        'source': source,
        'activity': activity,
      };
}

class Task {
  final String id;
  final String uuid;
  final String name;
  final String result;

  Task(this.id, this.uuid, this.name, this.result);

  Task.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        result = json['result'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'result': result,
      };
}*/

// Financiera

// class SFinn {
//   final String id;
//   final String uuid;
//   final String name;
//   final String description;
//   final String parent;
//   final String project;

//   SFinn(this.id, this.uuid, this.name, this.description, this.parent,
//       this.project);

//   SFinn.fromJson(Map<String, dynamic> json)
//       : id = json["id"],
//         uuid = json["uuid"],
//         name = json['name'],
//         description = json['description'],
//         parent = json['parent'],
//         project = json['project'];

//   Map<String, String> toJson() => {
//         'id': id,
//         'uuid': uuid,
//         'name': name,
//         'description': description,
//         'parent': parent,
//         'project': project,
//       };
// }

// class FinnContribution {
//   final String id;
//   final String owner;
//   final double amount;
//   final String finn;

//   FinnContribution(this.id, this.owner, this.amount, this.finn);

//   FinnContribution.fromJson(Map<String, dynamic> json)
//       : id = json["id"],
//         owner = json["owner"],
//         amount = json["amout"],
//         finn = json["finn"];

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'owner': owner,
//         'amount': amount,
//         'finn': finn,
//       };
// }
