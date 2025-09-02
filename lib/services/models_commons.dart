//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:uuid/uuid.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'dart:developer' as dev;

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

class Organization {
  static String tbName = "s4c_organizations";

  String id = "";
  String uuid = "";
  String code = "";
  String name;
  String country = "";
  bool financier = false;
  bool partner = false;
  bool public = false;
  String domain = "";
  // Billing fields
  String account = "";
  String address = "";
  String cif = "";
  String billingName = "";

  Country? countryObj = Country("");

  Organization(this.name);

  Organization.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        code = json["code"],
        financier = json["financier"],
        partner = json["partner"],
        public = (json.containsKey("public")) ? json["public"] : false,
        country = (json.containsKey("country")) ? json["country"] : "España",
        domain = (json.containsKey("domain")) ? json["domain"] : "",
        account = (json.containsKey("account")) ? json["account"] : "",
        address = (json.containsKey("address")) ? json["address"] : "",
        cif = (json.containsKey("cif")) ? json["cif"] : "",
        billingName =
            (json.containsKey("billingName")) ? json["billingName"] : "",
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'code': code,
        'financier': financier,
        'partner': partner,
        'public': public,
        'country': country,
        'name': name,
        'domain': domain,
        'account': account,
        'address': address,
        'cif': cif,
        'billingName': billingName,
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
      FirebaseFirestore.instance.collection(tbName).add(data).then(
        (value) {
          id = value.id;
          FirebaseFirestore.instance
              .collection(tbName)
              .doc(id)
              .update({"id": id, "uuid": uuid});
        },
      );
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  static Future<Organization?> byId(String id) async {
    Organization? item;
    await FirebaseFirestore.instance
        .collection(tbName)
        .doc(id)
        .get()
        .then((doc) {
      if (doc.exists) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        item = Organization.fromJson(data);
      }
    });
    return item;
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
  }

  IconData isFinancier() {
    if (financier == true) return Icons.check_circle_outline;
    return Icons.cancel_outlined;
  }

  IconData isPartner() {
    if (partner == true) return Icons.check_circle_outline;
    return Icons.cancel_outlined;
  }

  IconData isPublic() {
    if (public == true) return Icons.check_circle_outline;
    return Icons.cancel_outlined;
  }

  /*Future<void> getType() async {
    try {
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection("s4c_organizations")Type.where("uuid", isEqualTo: type).get();
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
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
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

  Future<Country?> getCountry() async {
    try {
      // QuerySnapshot query =
      //     await dbCountry.where("uuid", isEqualTo: country).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // return Country.fromJson(data);
      return await Country.byUuid(country);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Organization byUuidNoSync(String uuid) {
    Organization item = Organization("None");
    QuerySnapshot query = FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get() as QuerySnapshot;
    if (query.docs.isNotEmpty) {
      try {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data["id"] = query.docs.first.id;
        item = Organization.fromJson(data);
      } catch (e) {
//        print("ERROR : $e");
      }
    }
    return item;
  }

  static Future<Organization> byDomain(String email) async {
    Organization item = Organization("None");
    String domain = email.split("@").last;
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("domain", isEqualTo: domain)
          .get();

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
    } catch (e) {
      print("ERROR : $e");
    }
    return item;
  }

  static Future<Organization> byUuid(String uuid) async {
    Organization item = Organization("None");
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get();

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

  // Future<OrganizationBilling> getBilling() async {
  //   OrganizationBilling item = OrganizationBilling("");

  //   item = await OrganizationBilling.byOrganization(uuid);

  //   // QuerySnapshot query =
  //   //     await FirebaseFirestore.instance.collection("s4c_organizations")Bill.where("organization", isEqualTo: uuid).get();

  //   // if (query.docs.isNotEmpty) {
  //   //   try {
  //   //     Map<String, dynamic> data =
  //   //         query.docs.first.data() as Map<String, dynamic>;
  //   //     data["id"] = query.docs.first.id;
  //   //     item = OrganizationBilling.fromJson(data);
  //   //   } catch (e) {
  //   //     print("ERROR : $e");
  //   //   }
  //   // } else {
  //   //   item.organization = uuid;
  //   //   item.save();
  //   // }
  //   return item;
  // }

  static Future<List<Organization>> getOrganizations(
      {List<String>? uuids, List<String>? ids}) async {
    List<Organization> items = [];
    if (uuids != null) {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection(Organization.tbName)
          .where("uuid", whereIn: uuids)
          .get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        items.add(Organization.fromJson(data));
      }
    } else if (ids != null) {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection(Organization.tbName)
          .where("id", whereIn: ids)
          .get();
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        items.add(Organization.fromJson(data));
      }
    } else {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection(Organization.tbName)
          .get();
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

  static Future<List<KeyValue>> getOrganizationsHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Organization.tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Organization item = Organization.fromJson(data);
      items.add(item.toKeyValue());
    }
    return items;
  }

  static Future<List<KeyValue>> getFinanciersHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Organization.tbName).get();
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

  static Future<List<KeyValue>> getPartnersHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Organization.tbName).get();
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

  static Future<List> searchOrganizations(name) async {
    List<Organization> items = [];
    QuerySnapshot? query;

    if (name != "") {
      query = await FirebaseFirestore.instance
          .collection(Organization.tbName)
          .where("name", isEqualTo: name)
          .get();
    } else {
      query = await FirebaseFirestore.instance
          .collection(Organization.tbName)
          .get();
    }
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      final item = Organization.fromJson(data);
      items.add(item);
    }
    return items;
  }
}

//--------------------------------------------------------------
//                       ORGANIZATION BILLING
//--------------------------------------------------------------

// class OrganizationBilling {
//   String id = "";
//   String uuid = "";
//   String name;
//   String account = "";
//   String address = "";
//   String cif = "";
//   String organization = "";
//   Organization org = Organization("");

//   OrganizationBilling(this.name);

//   OrganizationBilling.fromJson(Map<String, dynamic> json)
//       : id = json["id"],
//         uuid = json["uuid"],
//         name = json['name'],
//         account = json['account'],
//         address = json['address'],
//         cif = json['cif'],
//         organization = json['organization'];

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'uuid': uuid,
//         'name': name,
//         'account': account,
//         'address': address,
//         'cif': cif,
//         'organization': organization,
//       };

//   KeyValue toKeyValue() {
//     return KeyValue(uuid, name);
//   }

//   Future<void> save() async {
//     if (id == "") {
//       var newUuid = const Uuid();
//       uuid = newUuid.v4();
//       Map<String, dynamic> data = toJson();
//       FirebaseFirestore.instance
//           .collection("s4c_organizations_billing")
//           .add(data);
//     } else {
//       Map<String, dynamic> data = toJson();
//       FirebaseFirestore.instance
//           .collection("s4c_organizations_billing")
//           .doc(id)
//           .set(data);
//     }
//   }

//   Future<void> delete() async {
//     await FirebaseFirestore.instance
//         .collection("s4c_organizations_billing")
//         .doc(id)
//         .delete();
//   }

//   static Future<OrganizationBilling> byOrganization(String uuid) async {
//     OrganizationBilling item = OrganizationBilling("None");
//     QuerySnapshot query = await FirebaseFirestore.instance
//         .collection("s4c_organizations_billing")
//         .where("organization", isEqualTo: uuid)
//         .get();

//     if (query.docs.isNotEmpty) {
//       try {
//         Map<String, dynamic> data =
//             query.docs.first.data() as Map<String, dynamic>;
//         data["id"] = query.docs.first.id;
//         item = OrganizationBilling.fromJson(data);
//       } catch (e) {
//         print("ERROR : $e");
//       }
//     }
//     return item;
//   }
// }

//--------------------------------------------------------------
//                   ORGANIZATIONS TYPES
//--------------------------------------------------------------

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
      FirebaseFirestore.instance.collection("s4c_organization_types").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_organization_types")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_organization_types")
        .doc(id)
        .delete();
  }

  static Future<List> getOrganizationsType() async {
    List<OrganizationType> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_organization_types")
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(OrganizationType.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getOrganizationsTypeHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_organization_types")
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      OrganizationType item = OrganizationType.fromJson(data);
      items.add(item.toKeyValue());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                       ZONE
//--------------------------------------------------------------

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
      FirebaseFirestore.instance.collection("s4c_zones").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_zones").doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection("s4c_zones").doc(id).delete();
  }

  static Future<Zone> byUuid(String uuid) async {
    Zone item = Zone("None");
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_zones")
        .where("uuid", isEqualTo: uuid)
        .get();

    if (query.docs.isNotEmpty) {
      try {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data["id"] = query.docs.first.id;
        item = Zone.fromJson(data);
      } catch (e) {
        print("ERROR : $e");
      }
    }
    return item;
  }

  static Future<List> getZones() async {
    List<Zone> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_zones").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Zone.fromJson(data));
    }
    return items;
  }
}
//--------------------------------------------------------------
//                       AMBIT
//--------------------------------------------------------------

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
      FirebaseFirestore.instance.collection("s4c_ambits").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_ambits").doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection("s4c_ambits").doc(id).delete();
  }

  static Future<Ambit> byUuid(String uuid) async {
    Ambit item = Ambit("None");
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_ambits")
        .where("uuid", isEqualTo: uuid)
        .get();

    if (query.docs.isNotEmpty) {
      try {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data["id"] = query.docs.first.id;
        item = Ambit.fromJson(data);
      } catch (e) {
        print("ERROR : $e");
      }
    }
    return item;
  }

  static Future<List> getAmbits() async {
    List<Ambit> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_ambits").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Ambit.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getAmbitsHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_ambits").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Ambit.fromJson(data).toKeyValue());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                       SECTOR
//--------------------------------------------------------------

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
      FirebaseFirestore.instance.collection("s4c_sectors").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_sectors").doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection("s4c_sectors").doc(id).delete();
  }

  static Future<Sector> byUuid(String uuid) async {
    Sector item = Sector("None");
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_sectors")
        .where("uuid", isEqualTo: uuid)
        .get();

    if (query.docs.isNotEmpty) {
      try {
        Map<String, dynamic> data =
            query.docs.first.data() as Map<String, dynamic>;
        data["id"] = query.docs.first.id;
        item = Sector.fromJson(data);
      } catch (e) {
        print("ERROR : $e");
      }
    }
    return item;
  }

  static Future<List> getSectors() async {
    List<Sector> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_sectors").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Sector.fromJson(data));
    }
    return items;
  }
}

//--------------------------------------------------------------
//                       NOTIFICATIONS
//--------------------------------------------------------------

class SNotification {
  String id = "";
  String uuid = "";
  String sender;
  String receiver = "";
  String msg = "";
  String objId = "";
  String objType = "";
  bool readed = false;
  DateTime date = DateTime.now();
  DateTime readDate = DateTime(2100, 12, 31);

  SNotification(this.sender);

  SNotification.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        sender = json['sender'],
        receiver = json['receiver'],
        readed = json['readed'],
        date = json['date'].toDate(),
        readDate = json['readDate'].toDate(),
        msg = json['msg'],
        objId = (json.containsKey('objId')) ? json['objId'] : "",
        objType = (json.containsKey('objType')) ? json['objType'] : "";

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'sender': sender,
        'receiver': receiver,
        'readed': readed,
        'date': date,
        'readDate': readDate,
        'msg': msg,
        'objId': objId,
        'objType': objType,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, msg);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      var item = await FirebaseFirestore.instance
          .collection("s4c_notifications")
          .add(data);
      id = item.id;
      await item.update({'id': item.id}).catchError((onError) {
        dev.log("Error updating document: $onError");
      });
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection("s4c_notifications")
          .doc(id)
          .set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection("s4c_notifications")
        .doc(id)
        .delete();
  }

  static Future<int> getUnreadNotificationsByReceiver(user) async {
    int notif = 0;
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_notifications")
        .where("receiver", isEqualTo: user)
        .get();

    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      SNotification item = SNotification.fromJson(data);
      if (!item.readed) notif += 1;
    }
    return notif;
  }

  static Future<List> getNotificationsByReceiver(user) async {
    if (user == null || user.isEmpty) {
      return []; // Return empty list if user is not provided
    }
    List<SNotification> items = [];
    if (user.isEmpty) {
      return items; // Return empty list if user is not provided
    }
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("s4c_notifications")
        .where("receiver", isEqualTo: user)
        .get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      SNotification item = SNotification.fromJson(data);
      items.add(item);
    }
    return items;
  }
}

//--------------------------------------------------------------
//                       LOGS
//--------------------------------------------------------------

class SLogs {
  String id = "";
  String uuid = "";
  String ip = "";
  String user;
  String msg = "";
  DateTime date = DateTime.now();

  SLogs(this.user);

  SLogs.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        ip = json["ip"],
        user = json['user'],
        date = json['date'].toDate(),
        msg = json['msg'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'ip': ip,
        'user': user,
        'date': date,
        'msg': msg,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, msg);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      var ipAddress = IpAddress();
      ip = await ipAddress.getIpAddress();
      Map<String, dynamic> data = toJson();
      var item =
          await FirebaseFirestore.instance.collection('s4c_logs').add(data);
      id = item.id;
      await item.update({'id': item.id});
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection('s4c_logs').doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('s4c_logs').doc(id).delete();
  }

  static Future<List> getLogs() async {
    List<SLogs> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection('s4c_logs').get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(SLogs.fromJson(data));
    }
    return items;
  }
}
