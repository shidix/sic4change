import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_drive.dart';
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
CollectionReference _collectionFolder = db.collection("s4c_folders");

Future<List> getFolders(String _parent_uuid) async {
  List folders = [];
  QuerySnapshot? queryFolders;

  if (_parent_uuid != "") {
    queryFolders =
        await _collectionFolder.where("parent", isEqualTo: _parent_uuid).get();
  } else {
    queryFolders = await _collectionFolder.where("parent", isEqualTo: "").get();
  }
  for (var doc in queryFolders.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final folder = Folder.fromJson(data);
    folders.add(folder);
  }
  return folders;
}

Future<Folder?> getFolderByUuid(String _uuid) async {
  Folder? folder;
  QuerySnapshot? queryFolders;

  queryFolders = await _collectionFolder.where("uuid", isEqualTo: _uuid).get();
  for (var doc in queryFolders.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    folder = Folder.fromJson(data);
    break;
  }
  return folder;
}

Future<void> addFolder(String name, String parent) async {
  var uuid = Uuid();
  await _collectionFolder
      .add({"uuid": uuid.v4(), "name": name, "parent": parent});
}

Future<void> updateFolder(
    String id, String uuid, String name, String parent) async {
  await _collectionFolder
      .doc(id)
      .set({"uuid": uuid, "name": name, "parent": parent});
}

Future<void> deleteFolder(String id) async {
  await _collectionFolder.doc(id).delete();
}

//--------------------------------------------------------------
//                           FILES
//--------------------------------------------------------------
CollectionReference _collectionFile = db.collection("s4c_files");

Future<List> getFiles(String _folder) async {
  List files = [];
  QuerySnapshot? query;

  if (_folder != "") {
    query = await _collectionFile.where("folder", isEqualTo: _folder).get();
  } else {
    query = await _collectionFile.where("folder", isEqualTo: "").get();
  }
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _file = SFile.fromJson(data);
    files.add(_file);
  }
  return files;
}

Future<String> getLoc() async {
  QuerySnapshot? query;

  var loc = "";
  do {
    loc = getRandomString(4);
    query = await _collectionFile.where("loc", isEqualTo: loc).get();
  } while (query.size > 0);
  return loc;
}

Future<void> addFile(String name, String folder, String link) async {
  await getLoc().then((value) async {
    var uuid = Uuid();
    await _collectionFile.add({
      "uuid": uuid.v4(),
      "name": name,
      "folder": folder,
      "link": link,
      "loc": value
    });
  });
}

Future<void> updateFile(String id, String uuid, String name, String folder,
    String link, String loc) async {
  await _collectionFile.doc(id).set(
      {"uuid": uuid, "name": name, "folder": folder, "link": link, "loc": loc});
}

Future<void> deleteFile(String id) async {
  await _collectionFile.doc(id).delete();
}
