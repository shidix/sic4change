//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


//--------------------------------------------------------------
//                      FINN
//--------------------------------------------------------------
CollectionReference _collectionFinn = db.collection("s4c_finns");

Future<List> getFinns() async {
  List<SFinn> items = [];
  QuerySnapshot? query;

  query = await _collectionFinn.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = SFinn.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<List> getFinnsByProject(String _project) async {
  List<SFinn> items = [];
  QuerySnapshot? query;

  query = await _collectionFinn
      .orderBy("project")
      .orderBy("parent", descending: true)
      .where("project", isEqualTo: _project)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = SFinn.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addFinn(
    String name, String description, String parent, String project) async {
  var uuid = Uuid();
  await _collectionFinn.add({
    "uuid": uuid.v4(),
    "name": name,
    "description": description,
    "parent": parent,
    "project": project,
  });
}

Future<void> updateFinn(String id, String uuid, String name, String description,
    String parent, String project) async {
  await _collectionFinn.doc(id).set({
    "uuid": uuid,
    "name": name,
    "description": description,
    "parent": parent,
    "project": project,
  });
}

Future<void> deleteFinn(String id) async {
  await _collectionFinn.doc(id).delete();
}

CollectionReference _collectionFinnContrib = db.collection("s4c_finncontrib");

Future<List> getFinnContrib() async {
  List<FinnContribution> items = [];
  QuerySnapshot? query;

  query = await _collectionFinnContrib.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = FinnContribution.fromJson(data);
    items.add(item);
  }
  return items;
}

Future<List> getContribByFinn(String finnuuid) async {
  List<FinnContribution> items = [];
  QuerySnapshot? query;

  query = await _collectionFinnContrib
      .orderBy("owner")
      .where("finn", isEqualTo: finnuuid)
      .get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = FinnContribution.fromJson(data);
    items.add(item);
  }
  return items;
}

List<FinnContribution> _getContribByFinn(String finnuuid)  {
  List<FinnContribution> items = [];
  final database = db.collection("s4c_finncontrib");
  final query = database.where("finn", isEqualTo: finnuuid).get().then(
    (querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final item = FinnContribution.fromJson(data);
        items.add(item);
      }
    }
  );
  return items;
}

Future<void> addFinnContrib(String owner, String amount, String finn) async {
  var uuid = Uuid();
  await _collectionFinnContrib.add({
    "uuid": uuid.v4(),
    "owner": owner,
    "finn": finn,
    "amount": double.parse(amount.replaceAll(",", ".")),
  });
}

Future<void> updateFinnContrib(
    String id, String uuid, String owner, String amount, String finn) async {
  await _collectionFinnContrib.doc(id).set({
    "uuid": uuid,
    "owner": owner,
    "finn": finn,
    "amount": double.parse(amount.replaceAll(",", ".")),
  });
}

Future<void> deleteFinnContrib(String id) async {
  await _collectionFinnContrib.doc(id).delete();
}
