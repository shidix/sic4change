import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:uuid/uuid.dart';

//--------------------------------------------------------------
//                      CONTACTS TRACKING
//--------------------------------------------------------------

class ContactTracking {
  static const String tbName = "s4c_contact_tracking";

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
      FirebaseFirestore.instance.collection(tbName).add(data);
      createLog(
          "Creado seguimiento $name en el contacto: ${Contact.getContactName(contact)}");
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
      createLog(
          "Modificado seguimiento $name en el contacto: ${Contact.getContactName(contact)}");
    }
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    createLog(
        "Borrado seguimiento $name en el contacto: ${Contact.getContactName(contact)}");
  }

  Future<ContactTracking> reload() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection(tbName).doc(id).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    ContactTracking contactTracking = ContactTracking.fromJson(data);

    return contactTracking;
  }

  static Future<List> getContactTrackings() async {
    List<ContactTracking> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
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
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection(tbName)
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
    } catch (e) {}
    return items;
  }

  static Future<ContactTracking> byUuid(String uuid) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("No contact tracking found with UUID: $uuid");
    }

    DocumentSnapshot doc = query.docs.first;
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    return ContactTracking.fromJson(data);
  }
}
