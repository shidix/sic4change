import 'package:firebase_storage/firebase_storage.dart';

class STask {
  final String id;
  final String uuid;
  final String name;
  final String description;
  final String comments;
  final String status;
  final String deal_date;
  final String deadline_date;
  final String new_deadline_date;
  final String sender;
  final String project;
  final List assigned;
  final List programmes;
  final bool public;

  STask(
      this.id,
      this.uuid,
      this.name,
      this.description,
      this.comments,
      this.status,
      this.deal_date,
      this.deadline_date,
      this.new_deadline_date,
      this.sender,
      this.project,
      this.assigned,
      this.programmes,
      this.public);

  STask.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        comments = json['comments'],
        status = json['status'],
        deal_date = json['deal_date'],
        deadline_date = json['deadline_date'],
        new_deadline_date = json['new_deadline_date'],
        sender = json['sender'],
        project = json['project'],
        assigned = json['assigned'],
        programmes = json['programmes'],
        public = json['public'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'comments': comments,
        'status': status,
        'deal_date': deal_date,
        'deadline_date': deadline_date,
        'new_deadline_date': new_deadline_date,
        'sender': sender,
        'project': project,
        'assigned': assigned.join(","),
        'programmes': programmes.join(","),
        'public': public.toString(),
      };
}

class TasksStatus {
  final String id;
  final String uuid;
  final String name;

  TasksStatus(this.id, this.uuid, this.name);

  TasksStatus.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}
