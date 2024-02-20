import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/services/utils.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           CONTACTS
//--------------------------------------------------------------
CollectionReference dbContacts = db.collection("s4c_contacts");

class Contact {
  String id = "";
  String uuid = "";
  String name = "";
  String organization = "";
  String company = "";
  List<String> projects = [];
  String position = "";
  String email = "";
  String phone = "";
  Organization organizationObj = Organization("");
  Company companyObj = Company("");
  Position positionObj = Position("");
  List<SProject> projectsObj = [];

  /*Contact(this.name, this.company, this.position, this.email, this.phone,
      this.organization);*/
  Contact(this.name);

  Contact.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        company = json['company'],
        organization = json['organization'],
        projects = List.from(json['projects']),
        position = json["position"],
        email = json["email"],
        phone = json["phone"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'company': company,
        'organization': organization,
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

  Future<void> getOrganization() async {
    try {
      QuerySnapshot query =
          await dbOrg.where("uuid", isEqualTo: organization).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      organizationObj = Organization.fromJson(data);
      //return Organization.fromJson(data);
    } catch (e) {
      print(e);
      //return Organization("");
    }
  }

  Future<void> getCompany() async {
    try {
      QuerySnapshot query =
          await dbComp.where("uuid", isEqualTo: company).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      companyObj = Company.fromJson(data);
    } catch (e) {
      //return Company("");
    }
  }

  Future<void> getPosition() async {
    try {
      QuerySnapshot query =
          await dbPos.where("uuid", isEqualTo: position).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      positionObj = Position.fromJson(data);
    } catch (e) {
      //return Position("");
    }
  }

  Future<List<SProject>> getProjects() async {
    if (projects.isEmpty) {
      return [];
    }
    if (projectsObj.isNotEmpty) {
      bool isSync = projects.length == projectsObj.length;
      int id_prj = 0;
      while ((isSync) && (id_prj < projectsObj.length)) {
        isSync = (projects.contains(projectsObj[id_prj].uuid));
        id_prj++;
      }
      if (isSync) {
        return projectsObj;
      }
    }

    // List<SProject> projectList = [];
    for (String pr in projects) {
      try {
        QuerySnapshot query =
            await dbProject.where("uuid", isEqualTo: pr).get();
        final doc = query.docs.first;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        SProject projObj = SProject.fromJson(data);
        // await projObj.reload();
        projectsObj.add(projObj);
        projObj.reload();
      } catch (e) {
        print(showException(e));
      }
    }
    return projectsObj;
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
        // contactInfo.getOrganization().then((value) => contactInfo.orgObj = value);
        // contactInfo.getCharge().then((value) => contactInfo.chargeObj = value);
        // contactInfo.getCategory().then((value) => contactInfo.catObj = value);
        // contactInfo.getSubcategory().then((value) => contactInfo.subcatObj = value);
        // contactInfo.getZone().then((value) => contactInfo.zoneObj = value);
        // contactInfo.getSubzone().then((value) => contactInfo.subzoneObj = value);
        // contactInfo.getAmbit().then((value) => contactInfo.ambitObj = value);
        // contactInfo.getSector().then((value) => contactInfo.sectorObj = value);
        // contactInfo.getSkateholder().then((value) => contactInfo.stakeholderObj = value);
        // contactInfo.getDecision().then((value) => contactInfo.decisionObj = value);
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
    try {
      QuerySnapshot query =
          await dbContacts.where("email", isEqualTo: email).get();
      final dbResult = query.docs.first;
      final Map<String, dynamic> data = dbResult.data() as Map<String, dynamic>;
      data["id"] = dbResult.id;
      return Contact.fromJson(data);
    } catch (e) {
      print(e);
      return Contact("");
    }
  }

  static Future<Contact> getByUuid(String uuid) async {
    Contact item = Contact("");
    await dbContacts.where("uuid", isEqualTo: uuid).get().then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Contact.fromJson(data);
    });
    return item;
  }
}

Future<List> getContacts() async {
  List<Contact> items = [];
  QuerySnapshot query = await dbContacts.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Contact item = Contact.fromJson(data);
    await item.getOrganization();
    await item.getCompany();
    await item.getPosition();
    item.projectsObj = await item.getProjects();
    items.add(item);
    //items.add(Contact.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getContactsHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbContacts.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Contact item = Contact.fromJson(data);
    items.add(item.toKeyValue());
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
    item.getOrganization();
    item.getCompany();
    item.getPosition();
    item.getProjects();
    // item.companyObj = await item.getCompany();

    //item.projectsObj = item.getProjects();
    items.add(item);
  }
  return items;
}

Future<List> getContactsByOrg(org) async {
  List<Contact> items = [];
  QuerySnapshot? query =
      await dbContacts.where("organization", isEqualTo: org).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Contact.fromJson(data);
    item.getOrganization();
    item.getCompany();
    item.getPosition();
    item.getProjects();
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

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

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

Future<List<KeyValue>> getCompaniesHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbComp.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Company item = Company.fromJson(data);
    items.add(item.toKeyValue());
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

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

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

Future<List<KeyValue>> getPositionsHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbPos.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Position item = Position.fromJson(data);
    items.add(item.toKeyValue());
  }
  return items;
}
