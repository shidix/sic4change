import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sic4change/services/utils.dart';

class Nomina {
  static final db = FirebaseFirestore.instance;
  static final collection = db.collection("s4c_nominas");
  static final storage = FirebaseStorage.instance;

  String? id;
  String employeeCode;
  DateTime date;
  String noSignedPath;
  DateTime noSignedDate;
  String? signedPath;
  DateTime? signedDate;

  Nomina(
      {required this.employeeCode,
      required this.date,
      required this.noSignedPath,
      required this.noSignedDate,
      this.signedPath,
      this.signedDate});

  factory Nomina.fromJson(Map<String, dynamic> json) {
    return Nomina(
        employeeCode: json['employeeCode'],
        date: getDate(json['date'] ?? DateTime.now().toString()),
        noSignedPath: json['noSignedPath'],
        noSignedDate: DateTime.parse(json['noSignedDate']),
        signedPath: json['signedPath'],
        signedDate: getDate(json['signedDate'] ?? DateTime.now().toString()));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeCode': employeeCode,
        'noSignedPath': noSignedPath,
        'noSignedDate': noSignedDate,
        'signedPath': signedPath,
        'signedDate': signedDate
      };

  Future<String> getNoSignedUrl() async {
    return await FirebaseStorage.instance.ref(noSignedPath).getDownloadURL();
  }

  Future<String?> getSignedUrl() async {
    return await FirebaseStorage.instance.ref(signedPath!).getDownloadURL();
  }

  Future<void> setSignedPath(String path) async {
    signedPath = path;
    signedDate = DateTime.now();
  }

  Future<void> removeSignedPath() async {
    signedDate = null;
  }

  Future<void> save() async {
    if (id == null) {
      await collection.add(toJson()).then((value) => id = value.id);
    } else {
      await collection.doc(id).update(toJson());
    }
  }

  Future<void> delete() async {
    await collection.doc(id).delete();
  }

  static Future<List<Nomina>> getNominas(String employeeCode) async {
    // get from database
    List<Nomina> items = [];
    await collection
        .where('employeeCode', isEqualTo: employeeCode)
        .get()
        .then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        Nomina item = Nomina.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();
    });
    items.sort((a, b) => a.noSignedDate.compareTo(b.noSignedDate));
    return items;
  }
}
