import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           CONTACTS
//--------------------------------------------------------------
CollectionReference dbContactInfo = db.collection("s4c_contact_info");

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
  String project = "";
  String sector = "";
  String skateholder = "";
  String subcategory = "";
  String subzone = "";
  String twitter = "";
  String zone = "";

  ContactInfo(this.contact);

  ContactInfo.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        contact = json['contact'],
        ambit = json['ambit'],
        category = json['category'],
        charge = json['charge'],
        contactPerson = json['contact_person'],
        decision = json['decision'],
        email = json['email'],
        kol = json['kol'],
        linkedin = json['linkedin'],
        mobile = json['mobile'],
        networks = json['networks'],
        organization = json['organization'],
        phone = json['phone'],
        project = json['project'],
        sector = json['sector'],
        skateholder = json['skateholder'],
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
        'project': project,
        'sector': sector,
        'skateholder': skateholder,
        'subcategory': subcategory,
        'subzone': subzone,
        'twitter': twitter,
        'zone': zone,
      };

  Future<void> save() async {
    if (id == "") {
      //id = uuid;
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbContactInfo.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbContactInfo.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbContactInfo.doc(id).delete();
  }

  Future<ContactInfo> reload() async {
    DocumentSnapshot? _doc;

    _doc = await dbContactInfo.doc(id).get();
    final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
    data["id"] = _doc.id;
    return ContactInfo.fromJson(data);
  }
}

Future<ContactInfo> getContactInfoByContact(String uuid) async {
  ContactInfo contactInfo;

  try {
    QuerySnapshot query =
        await dbContactInfo.where("contact", isEqualTo: uuid).get();
    final _dbResult = query.docs.first;
    final Map<String, dynamic> data = _dbResult.data() as Map<String, dynamic>;
    data["id"] = _dbResult.id;
    contactInfo = ContactInfo.fromJson(data);
  } catch (exc) {
    contactInfo = ContactInfo(uuid);
    contactInfo.save();
  }
  return contactInfo;
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
CollectionReference dbContactCharge = db.collection("s4c_contact_charge");

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

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbContactCharge.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbContactCharge.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbContactCharge.doc(id).delete();
  }
}

Future<List> getContactCharges() async {
  List<ContactCharge> items = [];
  QuerySnapshot query = await dbContactCharge.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ContactCharge.fromJson(data));
  }
  return items;
}

//--------------------------------------------------------------
//                           CATEGORIES
//--------------------------------------------------------------
CollectionReference dbContactCategory = db.collection("s4c_contact_category");

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

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbContactCategory.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbContactCategory.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbContactCategory.doc(id).delete();
  }
}

Future<List> getContactCategories() async {
  List<ContactCategory> items = [];
  QuerySnapshot query = await dbContactCategory.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ContactCategory.fromJson(data));
  }
  return items;
}
