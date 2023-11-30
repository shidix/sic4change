import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact_info.dart';
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
  Company companyObj = Company("");
  List<SProject> projectsObj = [];

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

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
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

  Future<Company> getCompany() async {
    try {
      QuerySnapshot query =
          await dbComp.where("uuid", isEqualTo: company).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      return Company.fromJson(data);
    } catch (e) {
      return Company("");
    }
  }

  Future<List<SProject>> getProjects() async {
    List<SProject> projectList = [];
    for (String pr in projects) {
      try {
        QuerySnapshot query =
            await dbProject.where("uuid", isEqualTo: pr).get();
        final doc = query.docs.first;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        SProject projObj = SProject.fromJson(data);
        projectList.add(projObj);
      } catch (e) {}
    }
    return projectList;
  }

  Future<ContactInfo> getContactInfo() async {
    ContactInfo contactInfo = ContactInfo(uuid);

    try {
      QuerySnapshot query =
          await dbContactInfo.where("contact", isEqualTo: uuid).get();
      final dbResult = query.docs.first;
      final Map<String, dynamic> data = dbResult.data() as Map<String, dynamic>;
      if (data.isEmpty) {
        //contactInfo = ContactInfo(uuid);
        contactInfo.save();
      } else {
        data["id"] = dbResult.id;
        contactInfo = ContactInfo.fromJson(data);
        contactInfo.orgObj = await contactInfo.getOrganization();
        contactInfo.chargeObj = await contactInfo.getCharge();
        contactInfo.catObj = await contactInfo.getCategory();
        contactInfo.subcatObj = await contactInfo.getSubcategory();
        contactInfo.zoneObj = await contactInfo.getZone();
        contactInfo.subzoneObj = await contactInfo.getSubzone();
        contactInfo.ambitObj = await contactInfo.getAmbit();
        contactInfo.sectorObj = await contactInfo.getSector();
        contactInfo.stakeholderObj = await contactInfo.getSkateholder();
        contactInfo.decisionObj = await contactInfo.getDecision();
        //contactInfo.projectsObj = await contactInfo.getProjects();
      }
    } catch (exc) {
      print(exc);
    }

    return contactInfo;
  }

  static Future<Contact> byEmail(String email) async {
    QuerySnapshot query =
        await dbContacts.where("email", isEqualTo: email).get();
    final dbResult = query.docs.first;
    final Map<String, dynamic> data = dbResult.data() as Map<String, dynamic>;
    data["id"] = dbResult.id;
    return Contact.fromJson(data);
  }
}

Future<List> getContacts() async {
  List<Contact> items = [];
  QuerySnapshot query = await dbContacts.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Contact item = Contact.fromJson(data);
    item.companyObj = await item.getCompany();
    item.projectsObj = await item.getProjects();
    items.add(Contact.fromJson(data));
  }
  return items;
}

Future<Contact> getContactByUuid(String uuid) async {
  QuerySnapshot query = await dbContacts.where("uuid", isEqualTo: uuid).get();
  final dbResult = query.docs.first;
  final Map<String, dynamic> data = dbResult.data() as Map<String, dynamic>;
  data["id"] = dbResult.id;
  return Contact.fromJson(data);
}

Future<List> searchContacts(name) async {
  List<Contact> items = [];
  QuerySnapshot? query;

  if (name != "") {
    query = await dbContacts.where("name", isEqualTo: name).get();
  } else {
    query = await dbContacts.get();
  }
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Contact.fromJson(data);
    item.companyObj = await item.getCompany();
    item.projectsObj = await item.getProjects();
    items.add(item);
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
