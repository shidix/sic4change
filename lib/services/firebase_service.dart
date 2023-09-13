import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/pages/project.dart';

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
