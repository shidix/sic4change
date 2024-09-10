//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  String code = "";
  String name;
  bool financier = false;
  bool partner = false;
  //String type = "";
  //OrganizationType typeObj = OrganizationType("");

  Organization(this.name);

  Organization.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        code = json["code"],
        financier = json["financier"],
        partner = json["partner"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'code': code,
        'financier': financier,
        'partner': partner,
        'name': name,
        //'type': type,
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

  IconData isFinancier() {
    if (financier == true) return Icons.check_circle_outline;
    return Icons.cancel_outlined;
  }

  IconData isPartner() {
    if (partner == true) return Icons.check_circle_outline;
    return Icons.cancel_outlined;
  }
  /*Future<void> getType() async {
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
  }*/

  static Future<List> getFinanciers() async {
    List<Organization> items = [];
    QuerySnapshot query = await dbOrg.get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data["financier"] == true) {
        data["id"] = doc.id;
        items.add(Organization.fromJson(data));
      }
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // items.add(Organization.fromJson(data));
    }
    return items;
  }

  static Organization byUuidNoSync(String uuid) {
    Organization item = Organization("None");
    QuerySnapshot query =
        dbOrg.where("uuid", isEqualTo: uuid).get() as QuerySnapshot;
    if (query.docs.isNotEmpty) {
      try {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data["id"] = query.docs.first.id;
        item = Organization.fromJson(data);
      } catch (e) {
        print("ERROR : $e");
      }
    }
    return item;
  }

  static Future<Organization> byUuid(String uuid) async {
    Organization item = Organization("None");
    QuerySnapshot query = await dbOrg.where("uuid", isEqualTo: uuid).get();

    if (query.docs.isNotEmpty) {
      try {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data["id"] = query.docs.first.id;
        item = Organization.fromJson(data);
      } catch (e) {
        print("ERROR : $e");
      }
    }
    return item;
  }

  Future<OrganizationBilling> getBilling() async {
    OrganizationBilling item = OrganizationBilling("");
    QuerySnapshot query =
        await dbOrgBill.where("organization", isEqualTo: uuid).get();

    if (query.docs.isNotEmpty) {
      try {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data["id"] = query.docs.first.id;
        item = OrganizationBilling.fromJson(data);
      } catch (e) {
        print("ERROR : $e");
      }
    } else {
      item.organization = uuid;
      item.save();
    }
    return item;
  }

  static Future<List<Organization>> getOrganizations(
      {List<String>? uuids, List<String>? ids}) async {
    List<Organization> items = [];
    if (uuids != null) {
      QuerySnapshot query = await dbOrg.where("uuid", whereIn: uuids).get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        items.add(Organization.fromJson(data));
      }
    } else if (ids != null) {
      QuerySnapshot query = await dbOrg.where("id", whereIn: ids).get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        items.add(Organization.fromJson(data));
      }
    } else {
      QuerySnapshot query = await dbOrg.get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        items.add(Organization.fromJson(data));
      }
    }
    return items;
  }

  factory Organization.getEmpty() {
    return Organization("");
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

Future<List<KeyValue>> getFinanciersHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbOrg.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Organization item = Organization.fromJson(data);
    if (item.financier) {
      items.add(item.toKeyValue());
    }
  }
  return items;
}

Future<List<KeyValue>> getPartnersHash() async {
  List<KeyValue> items = [];
  QuerySnapshot query = await dbOrg.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    Organization item = Organization.fromJson(data);
    if (item.partner) {
      items.add(item.toKeyValue());
    }
  }
  return items;
}

Future<List> searchOrganizations(name) async {
  List<Organization> items = [];
  QuerySnapshot? query;

  if (name != "") {
    query = await dbOrg.where("name", isEqualTo: name).get();
  } else {
    query = await dbOrg.get();
  }
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = Organization.fromJson(data);
    items.add(item);
  }
  return items;
}

//--------------------------------------------------------------
//                       ORGANIZATION BILLING
//--------------------------------------------------------------
CollectionReference dbOrgBill = db.collection("s4c_organization_billing");

class OrganizationBilling {
  String id = "";
  String uuid = "";
  String name;
  String account = "";
  String address = "";
  String cif = "";
  String organization = "";
  Organization org = Organization("");

  OrganizationBilling(this.name);

  OrganizationBilling.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        account = json['account'],
        address = json['address'],
        cif = json['cif'],
        organization = json['organization'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'account': account,
        'address': address,
        'cif': cif,
        'organization': organization,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbOrgBill.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbOrgBill.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbOrgBill.doc(id).delete();
  }

  Future<void> getOrganization() async {
    try {
      QuerySnapshot query =
          await dbOrg.where("uuid", isEqualTo: organization).get();
      final doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      org = Organization.fromJson(data);
    } catch (e) {
      //return Company("");
    }
  }

  static Future<OrganizationBilling> byOrganization(String uuid) async {
    OrganizationBilling item = OrganizationBilling("None");
    QuerySnapshot query =
        await dbOrgBill.where("organization", isEqualTo: uuid).get();

    if (query.docs.isNotEmpty) {
      try {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data["id"] = query.docs.first.id;
        item = OrganizationBilling.fromJson(data);
      } catch (e) {
        print("ERROR : $e");
      }
    }
    return item;
  }
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
      var newUuid = const Uuid();
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
      var newUuid = const Uuid();
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

//--------------------------------------------------------------
//                       NOTIFICATIONS
//--------------------------------------------------------------
CollectionReference dbNotifications = db.collection("s4c_notifications");

class SNotification {
  String id = "";
  String uuid = "";
  String sender;
  String receiver = "";
  String msg = "";
  bool readed = false;

  SNotification(this.sender);

  SNotification.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        sender = json['sender'],
        receiver = json['receiver'],
        readed = json['readed'],
        msg = json['msg'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'sender': sender,
        'receiver': receiver,
        'readed': readed,
        'msg': msg,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, msg);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbNotifications.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbNotifications.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbNotifications.doc(id).delete();
  }

  static Future<int> getUnreadNotificationsByReceiver(user) async {
    int notif = 0;
    QuerySnapshot query =
        await dbNotifications.where("receiver", isEqualTo: user).get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      SNotification item = SNotification.fromJson(data);
      if (!item.readed) notif += 1;
    }
    return notif;
  }

  static Future<List> getNotificationsByReceiver(user) async {
    List<SNotification> items = [];
    QuerySnapshot query =
        await dbNotifications.where("receiver", isEqualTo: user).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(SNotification.fromJson(data));
    }
    return items;
  }
}
