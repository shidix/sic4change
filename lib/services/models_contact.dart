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
