import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'dart:developer' as dev;
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:uuid/uuid.dart';

//--------------------------------------------------------------
//                           CONTACTS
//--------------------------------------------------------------

class Contact {
  static const tbName = "s4c_contacts";
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

  static Contact getEmpty() {
    return Contact("");
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_contacts")
          .add(data)
          .then((value) => id = value.id);

      createLog("Creado el contacto: $name");
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_contacts").doc(id).set(data);
      createLog("Modificado el contacto: $name");
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_contacts")
        .doc(id)
        .delete();
    createLog("Borrado el contacto: $name");
  }

  Future<Organization> getOrganization() async {
    try {
      // QuerySnapshot query =
      //     await dbOrg.where("uuid", isEqualTo: organization).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // organizationObj = Organization.fromJson(data);
      //return Organization.fromJson(data);
      return Organization.byUuid(organization);
    } catch (e) {
      dev.log("Error [model contact - getOrganization]: $e");
      return Organization("");
    }
  }

  Future<void> getCompany() async {
    try {
      // QuerySnapshot query =
      //     await dbComp.where("uuid", isEqualTo: company).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // companyObj = Company.fromJson(data);
      companyObj = await Company.byUuid(company);
    } catch (e) {
      //return Company("");
    }
  }

  Future<void> getPosition() async {
    try {
      // QuerySnapshot query =
      //     await dbPos.where("uuid", isEqualTo: position).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // positionObj = Position.fromJson(data);
      positionObj = await Position.byUuid(position);
    } catch (e) {
      dev.log(e.toString());
      //return Position("");
    }
  }

  Future<List<SProject>> getProjects() async {
    if (projects.isEmpty) {
      return [];
    }
    if (projectsObj.isNotEmpty) {
      bool isSync = projects.length == projectsObj.length;
      int idPrj = 0;
      while ((isSync) && (idPrj < projectsObj.length)) {
        try {
          isSync = (projects.contains(projectsObj[idPrj].uuid));
        } catch (e) {
          dev.log(e.toString());
        }
        idPrj++;
      }
      if (isSync) {
        return projectsObj;
      }
    }

    // List<SProject> projectList = [];
    for (String pr in projects) {
      try {
        // QuerySnapshot query =
        //     await dbProject.where("uuid", isEqualTo: pr).get();
        // if (query.docs.isEmpty) {
        //   continue;
        // }
        // final doc = query.docs.first;
        // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // data["id"] = doc.id;
        // SProject projObj = SProject.fromJson(data);
        // // await projObj.reload();
        SProject projObj = await SProject.byUuid(pr);
        projectsObj.add(projObj);
        projObj.reload();
      } catch (e, stacktrace) {
        dev.log(e.toString());
        dev.log(stacktrace.toString());
      }
    }
    return projectsObj;
  }

  static Future<List<Contact>> getContacts(
      {List<String>? uuids, List<String>? ids}) async {
    List<Contact> items = [];
    QuerySnapshot query;
    if (uuids != null) {
      query = await FirebaseFirestore.instance
          .collection("s4c_contacts")
          .where("uuid", whereIn: uuids)
          .get();
    } else if (ids != null) {
      query = await FirebaseFirestore.instance
          .collection("s4c_contacts")
          .where("id", whereIn: ids)
          .get();
    } else {
      query = await FirebaseFirestore.instance.collection("s4c_contacts").get();
    }
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Contact item = Contact.fromJson(data);
      items.add(item);
    }
    return items;
  }

  Future<ContactInfo> getContactInfo() async {
    ContactInfo contactInfo = ContactInfo(uuid);

    try {
      contactInfo = await ContactInfo.byUuid(uuid);
      // QuerySnapshot query =
      //     await dbContactInfo.where("contact", isEqualTo: uuid).get();
      // final dbResult = query.docs.first;
      // final Map<String, dynamic> data = dbResult.data() as Map<String, dynamic>;
      // if (data.isEmpty) {
      //   //contactInfo = ContactInfo(uuid);
      //   contactInfo.save();
      // } else {
      //   data["id"] = dbResult.id;
      //   contactInfo = ContactInfo.fromJson(data);
      //   // contactInfo.getOrganization().then((value) => contactInfo.orgObj = value);
      //   // contactInfo.getCharge().then((value) => contactInfo.chargeObj = value);
      //   // contactInfo.getCategory().then((value) => contactInfo.catObj = value);
      //   // contactInfo.getSubcategory().then((value) => contactInfo.subcatObj = value);
      //   // contactInfo.getZone().then((value) => contactInfo.zoneObj = value);
      //   // contactInfo.getSubzone().then((value) => contactInfo.subzoneObj = value);
      //   // contactInfo.getAmbit().then((value) => contactInfo.ambitObj = value);
      //   // contactInfo.getSector().then((value) => contactInfo.sectorObj = value);
      //   // contactInfo.getSkateholder().then((value) => contactInfo.stakeholderObj = value);
      //   // contactInfo.getDecision().then((value) => contactInfo.decisionObj = value);
      //   contactInfo.orgObj = await contactInfo.getOrganization();
      //   contactInfo.chargeObj = await contactInfo.getCharge();
      //   contactInfo.catObj = await contactInfo.getCategory();
      //   contactInfo.subcatObj = await contactInfo.getSubcategory();
      //   contactInfo.zoneObj = await contactInfo.getZone();
      //   contactInfo.subzoneObj = await contactInfo.getSubzone();
      //   contactInfo.ambitObj = await contactInfo.getAmbit();
      //   contactInfo.sectorObj = await contactInfo.getSector();
      //   contactInfo.stakeholderObj = await contactInfo.getSkateholder();
      //   contactInfo.decisionObj = await contactInfo.getDecision();
      //   //contactInfo.projectsObj = await contactInfo.getProjects();
      // }
    } catch (exc) {
      // Handle error
    }

    return contactInfo;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Contact: $name ($email)";
  }

  static Future<Contact> byEmail(String email) async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection("s4c_contacts")
          .where("email", isEqualTo: email)
          .get();
      final dbResult = query.docs.first;
      final Map<String, dynamic> data = dbResult.data() as Map<String, dynamic>;
      data["id"] = dbResult.id;
      return Contact.fromJson(data);
    } catch (e) {
      return Contact("");
    }
  }

  static Future<Contact> getByUuid(String uuid) async {
    Contact item = Contact("");
    await FirebaseFirestore.instance
        .collection("s4c_contacts")
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Contact.fromJson(data);
    });
    return item;
  }

  static Future<List<Contact>> getAll() async {
    List<Contact> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_contacts").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Contact.fromJson(data));
    }
    return items;
  }

  static Future<String> getContactName(String uuid) async {
    Contact item = Contact("");
    await FirebaseFirestore.instance
        .collection("s4c_contacts")
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Contact.fromJson(data);
    });
    return item.name;
  }

  Future<void> loadObjs() async {
    await getOrganization();
    await getCompany();
    await getPosition();
    projectsObj = await getProjects();
  }

  static Future<Contact> byUuid(String uuid) async {
    return await getByUuid(uuid);
  }

  static Future<List<KeyValue>> getContactsHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_contacts").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Contact item = Contact.fromJson(data);
      items.add(item.toKeyValue());
    }
    return items;
  }

  static Future<List<KeyValue>> getContactsProfilesHash() async {
    List<KeyValue> items = [];
    List<String> emailList = [];

    // QuerySnapshot queryPro = await FirebaseFirestore.instance
    //     .collection("s4c_profiles")
    //     .get();
    // for (var doc in queryPro.docs) {
    //   final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //   data["id"] = doc.id;
    //   Profile item = Profile.fromJson(data);

    //   emailList.add(item.email);
    //   emailList.add(item.email);
    // }
    List<Profile> profiles = await Profile.getProfiles();
    for (var profile in profiles) {
      emailList.add(profile.email);
    }

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Contact item = Contact.fromJson(data);
      if (emailList.contains(item.email)) {
        items.add(item.toKeyValue());
      }
    }
    return items;
  }

  static Future<Contact> getContactByUuid(String uuid) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contacts")
        .where("uuid", isEqualTo: uuid)
        .get();
    final dbResult = query.docs.first;
    final Map<String, dynamic> data = dbResult.data() as Map<String, dynamic>;
    data["id"] = dbResult.id;
    return Contact.fromJson(data);
  }

  static Future<List> searchContacts(name) async {
    List<Contact> items = [];
    QuerySnapshot? query;

    if (name != "") {
      query = await FirebaseFirestore.instance
          .collection("s4c_contacts")
          .where("name", isEqualTo: name)
          .get();
    } else {
      query = await FirebaseFirestore.instance.collection("s4c_contacts").get();
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

  static Future<List> getContactsByOrg(org) async {
    List<Contact> items = [];
    QuerySnapshot? query = await FirebaseFirestore.instance
        .collection("s4c_contacts")
        .where("organization", isEqualTo: org)
        .get();
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

  static Future<List<KeyValue>> getContactsByOrgHash(org) async {
    List<KeyValue> items = [];
    QuerySnapshot? query = await FirebaseFirestore.instance
        .collection("s4c_contacts")
        .where("organization", isEqualTo: org)
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Contact item = Contact.fromJson(data);
      items.add(item.toKeyValue());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                           COMPANIES
//--------------------------------------------------------------

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
      var _uuid = const Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_companies").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_companies").doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_companies")
        .doc(id)
        .delete();
  }

  static Future<Company> byUuid(String uuid) async {
    Company item = Company("");
    await FirebaseFirestore.instance
        .collection("s4c_companies")
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      item = Company.fromJson(data);
    });
    return item;
  }

  static Future<List> getCompanies() async {
    List<Company> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_companies").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Company.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getCompaniesHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_companies").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Company item = Company.fromJson(data);
      items.add(item.toKeyValue());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                           POSITION
//--------------------------------------------------------------

class Position {
  static const tbName = "s4c_positions";

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
      var _uuid = const Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(data)
          .then((value) => id = value.id);
    } else {
      Map<String, dynamic> data = toJson();
      await FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
  }

  static Future<Position> byUuid(String uuid) async {
    Position item = Position("");
    await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      final doc = value.docs.first;
      final Map<String, dynamic> data = doc.data();
      data["id"] = doc.id;
      item = Position.fromJson(data);
    });
    return item;
  }

  static Future<List> getPositions() async {
    List<Position> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Position.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getPositionsHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Position item = Position.fromJson(data);
      items.add(item.toKeyValue());
    }
    return items;
  }
}
