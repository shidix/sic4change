import 'package:cloud_firestore/cloud_firestore.dart';

class Notify {
  static final db = FirebaseFirestore.instance;
  static final collection = db.collection("s4c_notify");

  String? id;
  String sender;
  String receiver;
  String message;
  DateTime sendingDate;
  DateTime? readingDate;
  bool read;

  Notify(
      {required this.sender,
      required this.receiver,
      required this.message,
      required this.sendingDate,
      this.readingDate,
      required this.read});

  factory Notify.fromJson(Map<String, dynamic> json) {
    return Notify(
        sender: json['sender'],
        receiver: json['receiver'],
        message: json['message'],
        sendingDate: json['sendingDate'],
        readingDate: json['readingDate'],
        read: json['read']);
  }

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'receiver': receiver,
        'message': message,
        'sendingDate': sendingDate,
        'readingDate': readingDate,
        'read': read
      };

  Future<void> setReadingDate() async {
    readingDate = DateTime.now();
  }

  Future<void> setRead() async {
    read = true;
  }

  Future<void> setUnread() async {
    read = false;
  }

  Future<void> removeReadingDate() async {
    readingDate = null;
  }

  Future<void> save() async {
    if (id == null) {
      final ref = await collection.add(toJson());
      id = ref.id;
    } else {
      await collection.doc(id).update(toJson());
    }
  }

  Future<void> delete() async {
    await collection.doc(id).delete();
  }

  static Future<List<Notify>> getNotifies() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => Notify.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  static Future<List<Notify>> getNotifiesByReceiver(String receiver) async {
    final snapshot =
        await collection.where('receiver', isEqualTo: receiver).get();
    return snapshot.docs
        .map((doc) => Notify.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  static Future<List<Notify>> getNotifiesBySender(String sender) async {
    final snapshot = await collection.where('sender', isEqualTo: sender).get();
    return snapshot.docs
        .map((doc) => Notify.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  static Notify getEmpty() {
    return Notify(
        sender: '',
        receiver: '',
        message: '',
        sendingDate: DateTime.now(),
        read: false);
  }
}
