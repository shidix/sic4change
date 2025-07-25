// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:uuid/uuid.dart';

//--------------------------------------------------------------
//                           COUNTRY
//--------------------------------------------------------------

class Country {
  String id = "";
  String uuid = "";
  String name = "";
  String code = "";

  static const String tbName = "s4c_country";

  Country(this.name);

  Country.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        code = json['code'],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'code': code,
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
      FirebaseFirestore.instance.collection(tbName).add(data).then((value) {
        id = value.id;
      });
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
  }

  static Future<Country?> byId(String id) {
    return FirebaseFirestore.instance.collection(tbName).doc(id).get().then(
        (value) => (value.exists)
            ? Country.fromJson(value.data() as Map<String, dynamic>)
            : null);
  }

  static Future<Country?> byUuid(String uuid) {
    return FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) => (value.docs.isNotEmpty)
            ? Country.fromJson(value.docs.first.data() as Map<String, dynamic>)
            : null);
  }

  static Future<List<Country>> getAll() async {
    List<Country> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Country.fromJson(data));
    }
    return items;
  }

  static Future<List> getCountries() async {
    List<Country> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Country.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getCountriesHash() async {
    List<KeyValue> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Country.fromJson(data).toKeyValue());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                           PROVINCE
//--------------------------------------------------------------

class Province {
  static const String tbName = "s4c_province";
  String id = "";
  String uuid = "";
  String name = "";

  Province(this.name);

  Province.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var _uuid = const Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_province").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_province").doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection('s4c_province')
        .doc(id)
        .delete();
  }

  /// Static methods
  ///
  static Future<Province> byId(String id) {
    return FirebaseFirestore.instance
        .collection(Province.tbName)
        .doc(id)
        .get()
        .then((value) => (value.exists)
            ? Province.fromJson(value.data() as Map<String, dynamic>)
            : Province(""));
  }

  static Future<Province> byUuid(String uuid) {
    return FirebaseFirestore.instance
        .collection(Province.tbName)
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) => (value.docs.isNotEmpty)
            ? Province.fromJson(value.docs.first.data() as Map<String, dynamic>)
            : Province(""));
  }

  static Future<List> getProvinces() async {
    List<Province> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Province.tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Province.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getProvincesHash() async {
    List<KeyValue> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Province.tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Province.fromJson(data).toKeyValue());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                           REGION
//--------------------------------------------------------------

class Region {
  String id = "";
  String uuid = "";
  String name = "";

  Region(this.name);

  Region.fromJson(Map<String, dynamic> json)
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
      var _uuid = const Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_region").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_region").doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection("s4c_region").doc(id).delete();
  }

  static Future<Region> byId(String id) {
    return FirebaseFirestore.instance
        .collection("s4c_region")
        .doc(id)
        .get()
        .then((value) => (value.exists)
            ? Region.fromJson(value.data() as Map<String, dynamic>)
            : Region(""));
  }

  static Future<Region> byUuid(String uuid) {
    return FirebaseFirestore.instance
        .collection('s4c_region')
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) => (value.docs.isNotEmpty)
            ? Region.fromJson(value.docs.first.data() as Map<String, dynamic>)
            : Region(""));
  }

  static Future<List> getRegions() async {
    List<Region> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection('s4c_region').get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Region.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getRegionsHash() async {
    List<KeyValue> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection('s4c_region').get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Region.fromJson(data).toKeyValue());
    }
    return items;
  }
}

//--------------------------------------------------------------
//                      TOWN
//--------------------------------------------------------------

class Town {
  String id = "";
  String uuid = "";
  String name = "";

  // static final CollectionReference dbTown = FirebaseFirestore.instance.collection("s4c_town");

  Town(this.name);

  Town.fromJson(Map<String, dynamic> json)
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
      var _uuid = const Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_town").add(data);
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection("s4c_town").doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection("s4c_town").doc(id).delete();
  }

  //byUuid
  static Future<Town> byId(String id) {
    return FirebaseFirestore.instance.collection("s4c_town").doc(id).get().then(
        (value) => (value.exists)
            ? Town.fromJson(value.data() as Map<String, dynamic>)
            : Town(""));
  }

  static Future<Town> byUuid(String uuid) {
    return FirebaseFirestore.instance
        .collection("s4c_town")
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) => (value.docs.isNotEmpty)
            ? Town.fromJson(value.docs.first.data() as Map<String, dynamic>)
            : Town(""));
  }

  static Future<List> getTowns() async {
    List<Town> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_town").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Town.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getTownsHash() async {
    List<KeyValue> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("s4c_town").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Town.fromJson(data).toKeyValue());
    }
    return items;
  }
}
