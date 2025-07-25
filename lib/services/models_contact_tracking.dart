import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//--------------------------------------------------------------
//                      CONTACTS TRACKING
//--------------------------------------------------------------

class ContactTracking {
  String id = "";
  String uuid = "";
  String contact;

  String name = "";
  String description = "";
  DateTime date = DateTime.now();
  String manager = "";
  String assistants = "";
  String topics = "";
  String agreements = "";
  String nextSteps = "";

  static final dbContactTracking = db.collection("contactTracking");

  ContactTracking(this.contact);

  ContactTracking.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        contact = json['contact'],
        name = json['name'],
        description = json['description'],
        date = json['date'].toDate(),
        manager = json['manager'],
        assistants = json['assistants'],
        topics = json['topics'],
        agreements = json['agreements'],
        nextSteps = json['nextSteps'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'contact': contact,
        'name': name,
        'description': description,
        'date': date,
        'manager': manager,
        'assistants': assistants,
        'topics': topics,
        'agreements': agreements,
        'nextSteps': nextSteps,
      };

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbContactTracking.add(data);
      createLog(
          "Creado seguimiento $name en el contacto: ${Contact.getContactName(contact)}");
    } else {
      Map<String, dynamic> data = toJson();
      dbContactTracking.doc(id).set(data);
      createLog(
          "Modificado seguimiento $name en el contacto: ${Contact.getContactName(contact)}");
    }
  }

  Future<void> delete() async {
    await dbContactTracking.doc(id).delete();
    createLog(
        "Borrado seguimiento $name en el contacto: ${Contact.getContactName(contact)}");
  }

  Future<ContactTracking> reload() async {
    DocumentSnapshot doc = await dbContactTracking.doc(id).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    ContactTracking contactTracking = ContactTracking.fromJson(data);

    return contactTracking;
  }


  static Future<List> getContactTrackings() async {
    List<ContactTracking> items = [];
    QuerySnapshot query = await dbContactTracking.get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      items.add(ContactTracking.fromJson(data));
    }
    return items;
  }

  static Future<List> getTrakingsByContact(String contact) async {
    List<ContactTracking> items = [];

    try {
      QuerySnapshot query = await dbContactTracking
          .where("contact", isEqualTo: contact)
          .orderBy('date', descending: true)
          .get();
      /*QuerySnapshot query =
        await dbContactTracking.where("contact", isEqualTo: contact).get();*/
      for (var doc in query.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        items.add(ContactTracking.fromJson(data));
      }
    } catch (e) {
      print(e);
    }
    return items;
  }

}
