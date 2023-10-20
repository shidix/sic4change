class SFinn {
  final String id;
  final String uuid;
  final String name;
  final String description;
  final String parent;
  final String project;

  SFinn(this.id, this.uuid, this.name, this.description, this.parent,
      this.project);

  SFinn.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        parent = json['parent'],
        project = json['project'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'parent': parent,
        'project': project,
      };
}

class FinnContribution {
  final String id;
  final String financier;
  final double amount;
  final String finn;
  final String subject;

  FinnContribution(this.id, this.financier, this.amount, this.finn, this.subject);

  FinnContribution.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        financier = json["financier"],
        amount = json["amout"],
        subject = json["subject"],
        finn = json["finn"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'financer': financier,
        'amount': amount,
        'subject': subject,
        'finn': finn,
      };
}
