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

class ResultTask {
  final String id;
  final String uuid;
  final String name;
  final String result;

  ResultTask(this.id, this.uuid, this.name, this.result);

  ResultTask.fromJson(Map<String, dynamic> json)
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
