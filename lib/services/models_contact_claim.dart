import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                      CONTACTS CLAIM
//--------------------------------------------------------------

class ContactClaim {
  String id = "";
  String uuid = "";
  String contact;
  String task = "";

  String name = "";
  String manager = "";
  String description = "";
  String motivation = "";
  String agree = "";
  String actions = "";
  DateTime date = DateTime.now();
  DateTime resolutionDate = DateTime.now();
  Contact contactObj = Contact("");
  Contact managerObj = Contact("");

  static final dbContactClaim = db.collection("contact_claims");

  ContactClaim(this.contact);

  ContactClaim.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        contact = json['contact'],
        task = json['task'],
        name = json['name'],
        date = json['date'].toDate(),
        manager = json['manager'],
        description = json['description'],
        motivation = json['motivation'],
        resolutionDate = json['resolutionDate'].toDate(),
        agree = json['agree'],
        actions = json['actions'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'contact': contact,
        'task': task,
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
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbContactClaim.add(data);
      createLog(
          "Creada reclamación $name en el contacto: ${Contact.getContactName(contact)}");
    } else {
      Map<String, dynamic> data = toJson();
      dbContactClaim.doc(id).set(data);
      createLog(
          "Modificada reclamación $name en el contacto: ${Contact.getContactName(contact)}");
    }
  }

  Future<void> delete() async {
    await dbContactClaim.doc(id).delete();
    createLog(
        "Borrada reclamación $name en el contacto: ${Contact.getContactName(contact)}");
  }

  Future<ContactClaim> reload() async {
    DocumentSnapshot doc = await dbContactClaim.doc(id).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    ContactClaim contactClaim = ContactClaim.fromJson(data);

    return contactClaim;
  }

  Future<void> getContact() async {
    try {
      // QuerySnapshot query =
      //     await dbContacts.where("uuid", isEqualTo: contact).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // contactObj = Contact.fromJson(data);
      contactObj = await Contact.byUuid(contact);
    } catch (e) {
      //return Position("");
    }
  }

  Future<void> getManager() async {
    try {
      managerObj = await Contact.byUuid(manager);
      // QuerySnapshot query =
      //     await dbContacts.where("uuid", isEqualTo: manager).get();
      // final doc = query.docs.first;
      // final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // data["id"] = doc.id;
      // managerObj = Contact.fromJson(data);
    } catch (e) {
      //return Position("");
    }
  }


  static Future<List<ContactClaim>> getContactClaims() async {
    List<ContactClaim> items = [];
    QuerySnapshot query = await dbContactClaim.get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      ContactClaim item = ContactClaim.fromJson(data);
      await item.getContact();
      await item.getManager();
      items.add(item);
      //items.add(ContactClaim.fromJson(data));
    }
    return items;
  }

  static Future<List> getClaimsByContact(String contact) async {
    List<ContactClaim> items = [];

    QuerySnapshot query =
        await dbContactClaim.where("contact", isEqualTo: contact).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      ContactClaim item = ContactClaim.fromJson(data);
      await item.getContact();
      await item.getManager();
      items.add(item);
      //items.add(ContactClaim.fromJson(data));
    }
    return items;
  }
}

