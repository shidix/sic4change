import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           CONTACTS
//--------------------------------------------------------------
CollectionReference _collectionContact = db.collection("s4c_contacts");

Future<List> getContacts() async {
  List<Contact> items = [];
  QuerySnapshot? query;

  query = await _collectionContact.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Contact.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addContact(String name, String company, List<String> projects,
    String position, String email, String phone) async {
  var uuid = Uuid();
  await _collectionContact.add({
    "uuid": uuid.v4(),
    "name": name,
    "company": company,
    "projects": FieldValue.arrayUnion(projects),
    "position": position,
    "email": email,
    "phone": phone
  });
}

Future<void> updateContact(String id, String uuid, String name, String company,
    List<String> projects, String position, String email, String phone) async {
  await _collectionContact.doc(id).set({
    "uuid": uuid,
    "name": name,
    "company": company,
    "projects": FieldValue.arrayUnion(projects),
    "position": position,
    "email": email,
    "phone": phone
  });
}

Future<void> deleteContact(String id) async {
  await _collectionContact.doc(id).delete();
}

Future<List> searchContacts(_name) async {
  List<Contact> items = [];
  QuerySnapshot? query;

  if (_name != "")
    query = await _collectionContact.where("name", isEqualTo: _name).get();
  else
    query = await _collectionContact.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Contact.fromJson(data);
    items.add(_item);
  }
  return items;
}

//--------------------------------------------------------------
//                           COMPANIES
//--------------------------------------------------------------
CollectionReference _collectionComp = db.collection("s4c_companies");

Future<List> getCompanies() async {
  List<Company> items = [];
  QuerySnapshot? query;

  query = await _collectionComp.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Company.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addCompany(String name) async {
  var uuid = Uuid();
  await _collectionComp.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updateCompany(String id, String uuid, String name) async {
  await _collectionComp.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deleteCompany(String id) async {
  await _collectionComp.doc(id).delete();
}

//--------------------------------------------------------------
//                           POSITION
//--------------------------------------------------------------
CollectionReference _collectionPos = db.collection("s4c_positions");

Future<List> getPositions() async {
  List<Position> items = [];
  QuerySnapshot? query;

  query = await _collectionPos.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Position.fromJson(data);
    items.add(_item);
  }
  return items;
}

Future<void> addPosition(String name) async {
  var uuid = Uuid();
  await _collectionPos.add({
    "uuid": uuid.v4(),
    "name": name,
  });
}

Future<void> updatePosition(String id, String uuid, String name) async {
  await _collectionPos.doc(id).set({
    "uuid": uuid,
    "name": name,
  });
}

Future<void> deletePosition(String id) async {
  await _collectionPos.doc(id).delete();
}
