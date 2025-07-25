import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:uuid/uuid.dart';

//--------------------------------------------------------------
//                           CONTACTS
//--------------------------------------------------------------

class ContactInfo {
  String id = "";
  String uuid = "";
  String contact;

  String ambit = "";
  String category = "";
  String charge = "";
  String contactPerson = "";
  String decision = "";
  String email = "";
  String kol = "";
  String linkedin = "";
  String mobile = "";
  String networks = "";
  String organization = "";
  String phone = "";
  String sector = "";
  String stakeholder = "";
  String subcategory = "";
  String subzone = "";
  String twitter = "";
  String zone = "";
  List projects = [];

  Organization orgObj = Organization("");
  ContactCharge chargeObj = ContactCharge("");
  ContactCategory catObj = ContactCategory("");
  ContactCategory subcatObj = ContactCategory("");
  ContactDecision decisionObj = ContactDecision("");
  Zone zoneObj = Zone("");
  Zone subzoneObj = Zone("");
  Ambit ambitObj = Ambit("");
  Sector sectorObj = Sector("");
  ContactStakeholder stakeholderObj = ContactStakeholder("");
  List<SProject> projectsObj = [];

  ContactInfo(this.contact);

  ContactInfo.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        contact = json['contact'],
        ambit = json['ambit'],
        category = json['category'],
        charge = json['charge'],
        contactPerson = json['contactPerson'],
        decision = json['decision'],
        email = json['email'],
        kol = json['kol'],
        linkedin = json['linkedin'],
        mobile = json['mobile'],
        networks = json['networks'],
        organization = json['organization'],
        phone = json['phone'],
        projects = json['projects'],
        sector = json['sector'],
        stakeholder = json['stakeholder'],
        subcategory = json['subcategory'],
        subzone = json['subzone'],
        twitter = json['twitter'],
        zone = json['zone'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'contact': contact,
        'ambit': ambit,
        'category': category,
        'charge': charge,
        'contactPerson': contactPerson,
        'decision': decision,
        'email': email,
        'kol': kol,
        'linkedin': linkedin,
        'mobile': mobile,
        'networks': networks,
        'organization': organization,
        'phone': phone,
        'projects': projects,
        'sector': sector,
        'stakeholder': stakeholder,
        'subcategory': subcategory,
        'subzone': subzone,
        'twitter': twitter,
        'zone': zone,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_contact_info").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_contact_info")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_contact_info")
        .doc(id)
        .delete();
  }

  Future<void> updateProjects() async {
    await FirebaseFirestore.instance
        .collection("s4c_contact_info")
        .doc(id)
        .update({"projects": projects});
  }

  Future<ContactInfo> reload() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("s4c_contact_info")
        .doc(id)
        .get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    ContactInfo contactInfo = ContactInfo.fromJson(data);
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

    return contactInfo;
  }

  Future<Organization> getOrganization() async {
    try {
      // QuerySnapshot query =
      //     await dbOrg.where("uuid", isEqualTo: organization).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Organization.fromJson(data);
      return await Organization.byDomain(organization);
    } catch (e) {
      return Organization("");
    }
  }

  Future<ContactCharge> getCharge() async {
    try {
      // QuerySnapshot query =
      //     await dbContactCharge.where("uuid", isEqualTo: charge).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return ContactCharge.fromJson(data);
      return await ContactCharge.byUuid(charge);
    } catch (e) {
      return ContactCharge("");
    }
  }

  Future<ContactCategory> getCategory() async {
    try {
      // QuerySnapshot query =
      //     await dbContactCategory.where("uuid", isEqualTo: category).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return TasksStatus.fromJson(data);
      return await ContactCategory.byUuid(category);
    } catch (e) {
      return ContactCategory("");
    }
  }

  Future<ContactCategory> getSubcategory() async {
    try {
      // QuerySnapshot query =
      //     await dbContactCategory.where("uuid", isEqualTo: subcategory).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return TasksStatus.fromJson(data);
      return await ContactCategory.byUuid(subcategory);
    } catch (e) {
      return ContactCategory("");
    }
  }

  Future<ContactDecision> getDecision() async {
    try {
      return await ContactDecision.byUuid(decision);
      // QuerySnapshot query =
      //     await dbContactDecision.where("uuid", isEqualTo: decision).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return ContactDecision.fromJson(data);
    } catch (e) {
      return ContactDecision("");
    }
  }

  Future<Zone> getZone() async {
    try {
      return await Zone.byUuid(zone);
      // QuerySnapshot query = await dbZone.where("uuid", isEqualTo: zone).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Zone.fromJson(data);
    } catch (e) {
      return Zone("");
    }
  }

  Future<Zone> getSubzone() async {
    try {
      // QuerySnapshot query =
      //     await dbZone.where("uuid", isEqualTo: subzone).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Zone.fromJson(data);
      return await Zone.byUuid(subzone);
    } catch (e) {
      return Zone("");
    }
  }

  Future<Ambit> getAmbit() async {
    try {
      // QuerySnapshot query = await dbAmbit.where("uuid", isEqualTo: ambit).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Ambit.fromJson(data);
      return await Ambit.byUuid(ambit);
    } catch (e) {
      return Ambit("");
    }
  }

  Future<ContactStakeholder> getSkateholder() async {
    try {
      return await ContactStakeholder.byUuid(stakeholder);
      // QuerySnapshot query =
      //     await dbContactSkatehoder.where("uuid", isEqualTo: stakeholder).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return ContactStakeholder.fromJson(data);
    } catch (e) {
      return ContactStakeholder("");
    }
  }

  Future<Sector> getSector() async {
    try {
      // QuerySnapshot query =
      //     await dbSector.where("uuid", isEqualTo: sector).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Sector.fromJson(data);
      return await Sector.byUuid(sector);
    } catch (e) {
      return Sector("");
    }
  }

  Future<List<SProject>> getProjects() async {
    List<SProject> prList =
        await SProject.getProjects(uuids: projects as List<String>);
    // for (String pr in projects) {

    // try {
    //   QuerySnapshot query =
    //       await dbProject.where("uuid", isEqualTo: pr).get();
    //   final doc = query.docs.first;
    //   final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //   data["id"] = doc.id;
    //   SProject project = SProject.fromJson(data);
    //   prList.add(project);
    // } catch (e) {}
    // }
    return prList;
  }

  static Future<ContactInfo> byUuid(String uuid) async {
    ContactInfo contactInfo = ContactInfo(uuid);
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contact_info")
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      contactInfo.save();
    }
    contactInfo.reload();
    return contactInfo;
  }

  static Future<ContactInfo> getContactInfoByContact(String uuid) async {
    ContactInfo contactInfo = ContactInfo(uuid);
    try {
      // QuerySnapshot query =
      //     await dbContactInfo.where("contact", isEqualTo: uuid).get();
      // final dbResult = query.docs.first;
      // final Map<String, dynamic> data = dbResult.data() as Map<String, dynamic>;
      // if (data.isEmpty) {
      //   contactInfo.save();
      // } else {
      //   data["id"] = dbResult.id;
      //   contactInfo = ContactInfo.fromJson(data);
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
      // }
      contactInfo = await ContactInfo.byUuid(uuid);
      // await contactInfo.reload();
      return contactInfo;
    } catch (exc) {}

    return contactInfo;
  }
}

/*Future<List> getContactInfos() async {
  List<ContactInfo> items = [];
  QuerySnapshot query = await dbContactInfo.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ContactInfo.fromJson(data));
  }
  return items;
}*/

//--------------------------------------------------------------
//                           CHARGES
//--------------------------------------------------------------

class ContactCharge {
  String id = "";
  String uuid = "";
  String name;

  ContactCharge(this.name);

  ContactCharge.fromJson(Map<String, dynamic> json)
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
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_contact_charge").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_contact_charge")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_contact_charge")
        .doc(id)
        .delete();
  }

  static Future<List> getContactCharges() async {
    List<ContactCharge> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_contact_charge").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(ContactCharge.fromJson(data));
    }
    return items;
  }

  static Future<ContactCharge> byUuid(String uuid) async {
    ContactCharge contactCharge = ContactCharge(uuid);
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contact_charge")
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      contactCharge.save();
    } else {
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      contactCharge = ContactCharge.fromJson(data);
    }
    return contactCharge;
  }
}

//--------------------------------------------------------------
//                           CATEGORIES
//--------------------------------------------------------------

class ContactCategory {
  String id = "";
  String uuid = "";
  String name;

  ContactCategory(this.name);

  ContactCategory.fromJson(Map<String, dynamic> json)
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
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_contact_category").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_contact_category")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_contact_category")
        .doc(id)
        .delete();
  }

  static Future<List> getContactCategories() async {
    List<ContactCategory> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contact_category")
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(ContactCategory.fromJson(data));
    }
    return items;
  }

  static Future<ContactCategory> byUuid(String uuid) async {
    ContactCategory tasksStatus = ContactCategory(uuid);
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contact_category")
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      tasksStatus.save();
    } else {
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      tasksStatus = ContactCategory.fromJson(data);
    }
    return tasksStatus;
  }
}

//--------------------------------------------------------------
//                           DECISION
//--------------------------------------------------------------

class ContactDecision {
  String id = "";
  String uuid = "";
  String name;

  ContactDecision(this.name);

  ContactDecision.fromJson(Map<String, dynamic> json)
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
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_contact_decision").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_contact_decision")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_contact_decision")
        .doc(id)
        .delete();
  }

  static Future<List> getContactDecisions() async {
    List<ContactDecision> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contact_decision")
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(ContactDecision.fromJson(data));
    }
    return items;
  }

  static Future<ContactDecision> byUuid(String uuid) async {
    ContactDecision contactDecision = ContactDecision(uuid);
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contact_decision")
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      contactDecision.save();
    } else {
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      contactDecision = ContactDecision.fromJson(data);
    }
    return contactDecision;
  }
}

//--------------------------------------------------------------
//                           SKATEHOLDER
//--------------------------------------------------------------

class ContactStakeholder {
  String id = "";
  String uuid = "";
  String name;

  ContactStakeholder(this.name);

  ContactStakeholder.fromJson(Map<String, dynamic> json)
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
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_contact_stakeholder")
          .add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_contact_stakeholder")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_contact_stakeholder")
        .doc(id)
        .delete();
  }

  static Future<List> getContactStakeholders() async {
    List<ContactStakeholder> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contact_stakeholder")
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(ContactStakeholder.fromJson(data));
    }
    return items;
  }

  static Future<ContactStakeholder> byUuid(String uuid) async {
    ContactStakeholder contactStakeholder = ContactStakeholder(uuid);
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_contact_stakeholder")
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      contactStakeholder.save();
    } else {
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      contactStakeholder = ContactStakeholder.fromJson(data);
    }
    return contactStakeholder;
  }
}
