class SProject {
  final String name;
  final String description;

  SProject(this.name, this.description);

  SProject.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'];

  Map<String, String> toJson() => {
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
