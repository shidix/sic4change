import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                      CONTACTS CLAIM
//--------------------------------------------------------------
CollectionReference dbContactClaim = db.collection("s4c_contact_claim");

class ContactClaim {
  String id = "";
  String uuid = "";
  String contact;

  String name = "";
  String date = "";
  String manager = "";
  String description = "";
  String motivation = "";
  String resolutionDate = "";
  String agree = "";
  String actions = "";

  ContactClaim(this.contact);

  ContactClaim.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        contact = json['contact'],
        name = json['name'],
        date = json['date'],
        manager = json['manager'],
        description = json['description'],
        motivation = json['motivation'],
        resolutionDate = json['resolutionDate'],
        agree = json['agree'],
        actions = json['actions'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'contact': contact,
        'name': name,
        'date': date,
        'manager': manager,
        'description': description,
        'motivation': motivation,
        'resolutionDate': resolutionDate,
        'agree': agree,
        'actions': actions,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbContactClaim.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbContactClaim.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbContactClaim.doc(id).delete();
  }

  Future<ContactClaim> reload() async {
    DocumentSnapshot doc = await dbContactClaim.doc(id).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    ContactClaim contactClaim = ContactClaim.fromJson(data);

    return contactClaim;
  }
}

Future<List> getContactClaims() async {
  List<ContactClaim> items = [];
  QuerySnapshot query = await dbContactClaim.get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ContactClaim.fromJson(data));
  }
  return items;
}

Future<List> getClaimsByContact(String contact) async {
  List<ContactClaim> items = [];

  QuerySnapshot query =
      await dbContactClaim.where("contact", isEqualTo: contact).get();
  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    items.add(ContactClaim.fromJson(data));
  }
  return items;
}
