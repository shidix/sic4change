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
      var item = await FirebaseFirestore.instance.collection(tbName).add(data);
      id = item.id;
      item.update({'id': id});
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
            ? Country.fromJson(value.docs.first.data())
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

  static Future<List<KeyValue>> getCountriesHash(
      List<Country>? countries) async {
    List<KeyValue> items = [];

    if (countries != null) {
      for (var country in countries) {
        items.add(country.toKeyValue());
      }
      return items;
    }

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
  String region = "";

  Province(this.name, {this.region = ""});

  Province.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        region = json['region'] ?? "";

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'region': region,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var _uuid = const Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      var item = await FirebaseFirestore.instance
          .collection(Province.tbName)
          .add(data);
      id = item.id;
      FirebaseFirestore.instance
          .collection(Province.tbName)
          .doc(id)
          .update({'id': id});
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(Province.tbName).doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection(Province.tbName)
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

  static Future<Province> byUuid(String uuid) async {
    var query = await FirebaseFirestore.instance
        .collection(Province.tbName)
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      return Province("");
    }
    Map<String, dynamic> data = query.docs.first.data();
    if (data["id"] != query.docs.first.id) {
      data["id"] = query.docs.first.id;
      FirebaseFirestore.instance
          .collection(Province.tbName)
          .doc(query.docs.first.id)
          .update({'id': data["id"]});
    }
    return Province.fromJson(data);
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

  static Future<List<KeyValue>> getProvincesHash(
      List<Province>? provinces) async {
    List<KeyValue> items = [];

    if (provinces != null) {
      for (var province in provinces) {
        items.add(province.toKeyValue());
      }
      return items;
    }

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
  static const String tbName = "s4c_region";
  String id = "";
  String uuid = "";
  String name = "";
  String country = "";

  Region(this.name, {this.country = ""});

  Region.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        country = json['country'] ?? "";

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'country': country,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var _uuid = const Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      var item =
          await FirebaseFirestore.instance.collection(Region.tbName).add(data);
      id = item.id;
      FirebaseFirestore.instance
          .collection(Region.tbName)
          .doc(id)
          .update({'id': id});
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(Region.tbName).doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(Region.tbName).doc(id).delete();
  }

  static Future<Region> byId(String id) {
    return FirebaseFirestore.instance
        .collection(Region.tbName)
        .doc(id)
        .get()
        .then((value) => (value.exists)
            ? Region.fromJson(value.data() as Map<String, dynamic>)
            : Region(""));
  }

  static Future<Region> byUuid(String uuid) async {
    var query = await FirebaseFirestore.instance
        .collection(Region.tbName)
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      return Region("");
    }
    Map<String, dynamic> data = query.docs.first.data();
    if (data["id"] != query.docs.first.id) {
      data["id"] = query.docs.first.id;
      FirebaseFirestore.instance
          .collection(Region.tbName)
          .doc(query.docs.first.id)
          .update({'id': data["id"]});
    }
    return Region.fromJson(data);
  }

  static Future<List> getRegions() async {
    List<Region> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Region.tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Region.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getRegionsHash(List<Region>? regions) async {
    List<KeyValue> items = [];

    if (regions != null) {
      for (var region in regions) {
        items.add(region.toKeyValue());
      }
      return items;
    }

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Region.tbName).get();
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
  static const String tbName = "s4c_town";
  String id = "";
  String uuid = "";
  String name = "";
  String province = "";

  // static final CollectionReference dbTown = FirebaseFirestore.instance.collection("s4c_town");

  Town(this.name, {this.province = ""});

  Town.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        province = json['province'] ?? "";

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'province': province,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var _uuid = const Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      var item =
          await FirebaseFirestore.instance.collection(Town.tbName).add(data);
      id = item.id;
      FirebaseFirestore.instance
          .collection(Town.tbName)
          .doc(id)
          .update({'id': id});
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(Town.tbName).doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(Town.tbName).doc(id).delete();
  }

  //byUuid
  static Future<Town> byId(String id) {
    return FirebaseFirestore.instance
        .collection(Town.tbName)
        .doc(id)
        .get()
        .then((value) => (value.exists)
            ? Town.fromJson(value.data() as Map<String, dynamic>)
            : Town(""));
  }

  static Future<Town> byUuid(String uuid) {
    return FirebaseFirestore.instance
        .collection(Town.tbName)
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        Map<String, dynamic> data = value.docs.first.data();
        if (data["id"] != value.docs.first.id) {
          data["id"] = value.docs.first.id;
          FirebaseFirestore.instance
              .collection(Town.tbName)
              .doc(value.docs.first.id)
              .update({'id': data["id"]});
        }
        return Town.fromJson(value.docs.first.data());
      } else {
        return Town("");
      }
    });
  }

  static Future<List> getTowns() async {
    List<Town> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Town.tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data["id"] != doc.id) {
        data["id"] = doc.id;
        FirebaseFirestore.instance
            .collection(Town.tbName)
            .doc(doc.id)
            .update({'id': data["id"]});
      }
      data["id"] = doc.id;
      items.add(Town.fromJson(data));
    }
    return items;
  }

  static Future<List<KeyValue>> getTownsHash(List<Town>? towns) async {
    List<KeyValue> items = [];

    if (towns != null) {
      for (var town in towns) {
        items.add(town.toKeyValue());
      }
      return items;
    }

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Town.tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(Town.fromJson(data).toKeyValue());
    }
    return items;
  }
}
