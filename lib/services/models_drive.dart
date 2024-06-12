import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

String getRandomString(_length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      _length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

//--------------------------------------------------------------
//                           FOLDERS
//--------------------------------------------------------------
CollectionReference dbFolder = db.collection("s4c_folders");

class Folder {
  String id = "";
  String uuid = "";
  String name = "";
  String parent = "";

  Folder(this.name, this.parent);

  Folder.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        parent = json['parent'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'parent': parent,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbFolder.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbFolder.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbFolder.doc(id).delete();
  }

  Future<bool> haveChildren() async {
    List folders = await getFolders(uuid);
    List files = await getFiles(uuid);
    if ((folders.isNotEmpty) || (files.isNotEmpty)) {
      return true;
    } else {
      return false;
    }
  }
}

Future<List> getFolders(String parent_uuid) async {
  List folders = [];
  QuerySnapshot? queryFolders;

  if (parent_uuid != "") {
    queryFolders = await dbFolder.where("parent", isEqualTo: parent_uuid).get();
  } else {
    queryFolders = await dbFolder.where("parent", isEqualTo: "").get();
  }
  for (var doc in queryFolders.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final folder = Folder.fromJson(data);
    folders.add(folder);
  }
  return folders;
}

Future<Folder?> getFolderByUuid(String uuid) async {
  QuerySnapshot query = await dbFolder.where("uuid", isEqualTo: uuid).get();
  if (query.docs.isEmpty) {
    return null;
  }
  final doc = query.docs.first;
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  data["id"] = doc.id;
  return Folder.fromJson(data);
}

//--------------------------------------------------------------
//                           FILES
//--------------------------------------------------------------
CollectionReference dbFile = db.collection("s4c_files");

class SFile {
  String id = "";
  String uuid = "";
  String name = "";
  String folder = "";
  String link = "";
  String loc = "";

  SFile(this.name, this.folder, this.link);

  SFile.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        folder = json['folder'],
        loc = json['loc'],
        link = json['link'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'folder': folder,
        'loc': loc,
        'link': link,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      loc = await getLoc();
      Map<String, dynamic> data = toJson();
      dbFile.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbFile.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbFile.doc(id).delete();
  }

  Future<String> getLoc() async {
    QuerySnapshot? query;

    var loc = "";
    do {
      loc = getRandomString(4);
      query = await dbFile.where("loc", isEqualTo: loc).get();
    } while (query.size > 0);
    return loc;
  }

  static Future<SFile> byLoc(String loc) async {
    QuerySnapshot? query;

    query = await dbFile.where("loc", isEqualTo: loc).get();
    if (query.size == 0) {
      return SFile("", "", "");
    } else {
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return SFile.fromJson(data);
    }
  }
}

Future<List> getFiles(String folder) async {
  List files = [];
  QuerySnapshot? query;

  if (folder != "") {
    query = await dbFile.where("folder", isEqualTo: folder).get();
  } else {
    query = await dbFile.where("folder", isEqualTo: "").get();
  }
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final file = SFile.fromJson(data);
    files.add(file);
  }
  return files;
}

Future<String> getLoc() async {
  QuerySnapshot? query;

  var loc = "";
  do {
    loc = getRandomString(4);
    query = await dbFile.where("loc", isEqualTo: loc).get();
  } while (query.size > 0);
  return loc;
}
