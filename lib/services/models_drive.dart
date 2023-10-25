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
  final String loc;

  SFile(this.id, this.uuid, this.name, this.folder, this.link, this.loc);

  SFile.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        folder = json['folder'],
        loc = json['loc'],
        link = json['link'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'folder': folder,
        'loc': loc,
        'link': link,
      };
}
