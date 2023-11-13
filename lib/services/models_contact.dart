import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           CONTACTS
//--------------------------------------------------------------
CollectionReference dbContacts = db.collection("s4c_contacts");

class Contact {
  String id = "";
  String uuid = "";
  String name;
  String company;
  List<String> projects = [];
  String position;
  String email;
  String phone;

  Contact(this.name, this.company, this.position, this.email, this.phone);

  Contact.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        company = json['company'],
        projects = List.from(json['projects']),
        position = json["position"],
        email = json["email"],
        phone = json["phone"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'company': company,
        'projects': projects,
        'position': position,
        'email': email,
        'phone': phone,
      };

  Map<String, dynamic> toKeyValue() => {
        'key': uuid,
        'value': name,
      };

  Future<void> save() async {
    if (id == "") {
      //id = uuid;
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbContacts.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbContacts.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbContacts.doc(id).delete();
  }
}

Future<List> getContacts() async {
  List<Contact> items = [];
  QuerySnapshot query = await dbContacts.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Contact.fromJson(data));
  }
  return items;
}

Future<Contact> getContactByUuid(String uuid) async {
  QuerySnapshot query = await dbContacts.where("uuid", isEqualTo: uuid).get();
  final _dbResult = query.docs.first;
  final Map<String, dynamic> data = _dbResult.data() as Map<String, dynamic>;
  data["id"] = _dbResult.id;
  return Contact.fromJson(data);
}

Future<List> searchContacts(_name) async {
  List<Contact> items = [];
  QuerySnapshot? query;

  if (_name != "")
    query = await dbContacts.where("name", isEqualTo: _name).get();
  else
    query = await dbContacts.get();
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
CollectionReference dbComp = db.collection("s4c_companies");

class Company {
  String id = "";
  String uuid = "";
  String name;

  Company(this.name);

  Company.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  Future<void> save() async {
    if (id == "") {
      //id = uuid;
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbComp.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbComp.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbComp.doc(id).delete();
  }
}

Future<List> getCompanies() async {
  List<Company> items = [];
  QuerySnapshot query = await dbComp.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Company.fromJson(data));
  }
  return items;
}

//--------------------------------------------------------------
//                           POSITION
//--------------------------------------------------------------
CollectionReference dbPos = db.collection("s4c_positions");

class Position {
  String id = "";
  String uuid = "";
  String name;

  Position(this.name);

  Position.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  Future<void> save() async {
    if (id == "") {
      //id = uuid;
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbPos.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbPos.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbPos.doc(id).delete();
  }
}

Future<List> getPositions() async {
  List<Position> items = [];
  QuerySnapshot query = await dbPos.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Position.fromJson(data));
  }
  return items;
}
