class Country {
  final String id;
  final String uuid;
  final String name;

  Country(this.id, this.uuid, this.name);

  Country.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}

class Province {
  final String id;
  final String uuid;
  final String name;

  Province(this.id, this.uuid, this.name);

  Province.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}

class Region {
  final String id;
  final String uuid;
  final String name;

  Region(this.id, this.uuid, this.name);

  Region.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}

class Town {
  final String id;
  final String uuid;
  final String name;

  Town(this.id, this.uuid, this.name);

  Town.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };
}
