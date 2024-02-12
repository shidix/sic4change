import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                       KEY VALUE
//--------------------------------------------------------------
class KeyValue {
  String key;
  String value;

  KeyValue(this.key, this.value);

  KeyValue.fromJson(Map<String, dynamic> json)
      : key = json["key"],
        value = json['value'];

  Map<String, dynamic> toJson() => {
        'uuid': key,
        'name': value,
      };
}

//--------------------------------------------------------------
//                       ORGANIZATIONS
//--------------------------------------------------------------
CollectionReference dbOrg = db.collection("s4c_organizations");

class Organization {
  String id = "";
  String uuid = "";
  String name;
  String type = "";
  OrganizationType typeObj = OrganizationType("");

  Organization(this.name);

  Organization.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        type = json['type'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'type': type,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbOrg.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbOrg.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbOrg.doc(id).delete();
  }

  Future<void> getType() async {
    try {
      QuerySnapshot query =
          await dbOrgType.where("uuid", isEqualTo: type).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      typeObj = OrganizationType.fromJson(data);
    } catch (e) {
      //return Company("");
    }
  }
}

Future<List> getOrganizations() async {
  List<Organization> items = [];
  QuerySnapshot query = await dbOrg.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Organization item = Organization.fromJson(data);
    //await item.getType();
    items.add(item);
    //items.add(Organization.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getOrganizationsHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbOrg.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Organization item = Organization.fromJson(data);
    items.add(item.toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                   ORGANIZATIONS TYPES
//--------------------------------------------------------------
CollectionReference dbOrgType = db.collection("s4c_organizations_type");

class OrganizationType {
  String id = "";
  String uuid = "";
  String name;

  OrganizationType(this.name);

  OrganizationType.fromJson(Map<String, dynamic> json)
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
      dbOrgType.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbOrgType.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbOrgType.doc(id).delete();
  }
}

Future<List> getOrganizationsType() async {
  List<OrganizationType> items = [];
  QuerySnapshot query = await dbOrgType.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(OrganizationType.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getOrganizationsTypeHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbOrgType.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    OrganizationType item = OrganizationType.fromJson(data);
    items.add(item.toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                       ZONE
//--------------------------------------------------------------
CollectionReference dbZone = db.collection("s4c_zone");

class Zone {
  String id = "";
  String uuid = "";
  String name;

  Zone(this.name);

  Zone.fromJson(Map<String, dynamic> json)
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
      dbZone.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbZone.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbZone.doc(id).delete();
  }
}

Future<List> getZones() async {
  List<Zone> items = [];
  QuerySnapshot query = await dbZone.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Zone.fromJson(data));
  }
  return items;
}

//--------------------------------------------------------------
//                       AMBIT
//--------------------------------------------------------------
CollectionReference dbAmbit = db.collection("s4c_ambits");

class Ambit {
  String id = "";
  String uuid = "";
  String name;

  Ambit(this.name);

  Ambit.fromJson(Map<String, dynamic> json)
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
      dbAmbit.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbAmbit.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbAmbit.doc(id).delete();
  }
}

Future<List> getAmbits() async {
  List<Ambit> items = [];
  QuerySnapshot query = await dbAmbit.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Ambit.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getAmbitsHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbAmbit.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Ambit.fromJson(data).toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                       SECTOR
//--------------------------------------------------------------
CollectionReference dbSector = db.collection("s4c_sectors");

class Sector {
  String id = "";
  String uuid = "";
  String name;

  Sector(this.name);

  Sector.fromJson(Map<String, dynamic> json)
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
      dbSector.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbSector.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbSector.doc(id).delete();
  }
}

Future<List> getSectors() async {
  List<Sector> items = [];
  QuerySnapshot query = await dbAmbit.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Sector.fromJson(data));
  }
  return items;
}
