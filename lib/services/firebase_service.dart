import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/pages/models.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getProjects() async {
  List projects = [];
  //CollectionReference collectionReferenceProjects =
  //    db.collection('testfirebase_project');
  //QuerySnapshot queryProject = await collectionReferenceProjects.get();
  //queryProject.docs.forEach((element) {
  QuerySnapshot queryProject =
      await db.collection('testfirebase_project').get();
  for (var doc in queryProject.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final project = SProject.fromJson(data);
    /*final project = {
      "name": data["name"],
      "desc": data["description"],
      "uid": doc.id,
    };*/
    projects.add(project);
  }
  ;
  return projects;
}

Future<void> addProject(String name) async {
  await db.collection("testfirebase_project").add({"name": name});
}

Future<void> updateProject(String uid, String name) async {
  await db.collection("testfirebase_project").doc(uid).set({"name": name});
}

Future<void> deleteProject(String uid) async {
  await db.collection('testfirebase_project').doc(uid).delete();
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

Future<void> addFile(String name, String folder, String link) async {
  var uuid = Uuid();
  await _collectionFile
      .add({"uuid": uuid.v4(), "name": name, "folder": folder, "link": link});
}

Future<void> updateFile(
    String id, String uuid, String name, String folder, String link) async {
  await _collectionFile
      .doc(id)
      .set({"uuid": uuid, "name": name, "folder": folder, "link": link});
}

Future<void> deleteFile(String id) async {
  await _collectionFile.doc(id).delete();
}
