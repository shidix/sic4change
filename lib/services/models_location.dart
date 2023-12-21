import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                           COUNTRY
//--------------------------------------------------------------
CollectionReference dbCountry = db.collection("s4c_country");

class Country {
  String id = "";
  String uuid = "";
  String name = "";

  Country(this.name);

  Country.fromJson(Map<String, dynamic> json)
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
      dbCountry.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbCountry.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbCountry.doc(id).delete();
  }
}

Future<List> getCountries() async {
  List<Country> items = [];

  QuerySnapshot query = await dbCountry.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Country.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getCountriesHash() async {
  List<KeyValue> items = [];

  QuerySnapshot query = await dbCountry.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Country.fromJson(data).toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                           PROVINCE
//--------------------------------------------------------------
CollectionReference dbProvince = db.collection("s4c_province");

class Province {
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
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbProvince.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProvince.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProvince.doc(id).delete();
  }
}

Future<List> getProvinces() async {
  List<Province> items = [];

  QuerySnapshot query = await dbProvince.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Province.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getProvincesHash() async {
  List<KeyValue> items = [];

  QuerySnapshot query = await dbProvince.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Province.fromJson(data).toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                           REGION
//--------------------------------------------------------------
CollectionReference dbRegion = db.collection("s4c_region");

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
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbRegion.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbRegion.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbRegion.doc(id).delete();
  }
}

Future<List> getRegions() async {
  List<Region> items = [];

  QuerySnapshot query = await dbRegion.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Region.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getRegionsHash() async {
  List<KeyValue> items = [];

  QuerySnapshot query = await dbRegion.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Region.fromJson(data).toKeyValue());
  }
  return items;
}

//--------------------------------------------------------------
//                      TOWN
//--------------------------------------------------------------
CollectionReference dbTown = db.collection("s4c_town");

class Town {
  String id = "";
  String uuid = "";
  String name = "";

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
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbTown.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbTown.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbTown.doc(id).delete();
  }
}

Future<List> getTowns() async {
  List<Town> items = [];

  QuerySnapshot query = await dbTown.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Town.fromJson(data));
  }
  return items;
}

Future<List<KeyValue>> getTownsHash() async {
  List<KeyValue> items = [];

  QuerySnapshot query = await dbTown.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Town.fromJson(data).toKeyValue());
  }
  return items;
}
