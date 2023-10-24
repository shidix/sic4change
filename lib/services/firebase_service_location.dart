import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

CollectionReference _collectionProject = db.collection("s4c_projects");

//--------------------------------------------------------------
//                           COUNTRY
//--------------------------------------------------------------
CollectionReference _collectionCountry = db.collection("s4c_country");

Future<List> getCountries() async {
  List<Country> items = [];
  QuerySnapshot? query;

  query = await _collectionCountry.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Country.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addCountry(String name) async {
  var uuid = Uuid();
  await _collectionCountry.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updateCountry(String id, String uuid, String name) async {
  await _collectionCountry.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deleteCountry(String id) async {
  await _collectionCountry.doc(id).delete();
}

//--------------------------------------------------------------
//                           PROVINCE
//--------------------------------------------------------------
CollectionReference _collectionProvince = db.collection("s4c_province");

Future<List> getProvinces() async {
  List<Province> items = [];
  QuerySnapshot? query;

  query = await _collectionProvince.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Province.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addProvince(String name) async {
  var uuid = Uuid();
  await _collectionProvince.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updateProvince(
  String id,
  String uuid,
  String name,
) async {
  await _collectionProvince.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deleteProvince(String id) async {
  await _collectionProvince.doc(id).delete();
}

//--------------------------------------------------------------
//                           REGION
//--------------------------------------------------------------
CollectionReference _collectionRegion = db.collection("s4c_region");

Future<List> getRegions() async {
  List<Region> items = [];
  QuerySnapshot? query;

  query = await _collectionRegion.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Region.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addRegion(String name) async {
  var uuid = Uuid();
  await _collectionRegion.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updateRegion(String id, String uuid, String name) async {
  await _collectionRegion.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deleteRegion(String id) async {
  await _collectionRegion.doc(id).delete();
}

//--------------------------------------------------------------
//                      TOWN
//--------------------------------------------------------------
CollectionReference _collectionTown = db.collection("s4c_town");

Future<List> getTowns() async {
  List<Town> items = [];
  QuerySnapshot? query;

  query = await _collectionTown.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Town.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addTown(String name) async {
  var uuid = Uuid();
  await _collectionTown.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updateTown(
  String id,
  String uuid,
  String name,
) async {
  await _collectionTown.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deleteTown(String id) async {
  await _collectionTown.doc(id).delete();
}
