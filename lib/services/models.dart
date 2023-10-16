import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';

class SProject {
  final String id;
  final String uuid;
  final String name;
  final String description;

  SProject(this.id, this.uuid, this.name, this.description);

  SProject.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
      };
}

class Folder {
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
}

class Contact {
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
}

class Goal {
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
}
