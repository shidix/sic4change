import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                       ORGANIZATIONS
//--------------------------------------------------------------
CollectionReference dbOrg = db.collection("s4c_organizations");

class Organization {
  String id = "";
  String uuid = "";
  String name;

  Organization(this.name);

  Organization.fromJson(Map<String, dynamic> json)
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
      dbOrg.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbOrg.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbOrg.doc(id).delete();
  }
}

Future<List> getOrganizations() async {
  List<Organization> items = [];
  QuerySnapshot query = await dbOrg.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(Organization.fromJson(data));
  }
  return items;
}
