// import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/utils.dart';
// import 'package:uuid/uuid.dart';

class Workday {
  String id;
  // String uuid;
  String userId;
  bool open;
  DateTime startDate;
  DateTime endDate;

  static const String tbName = "s4c_workday";

  Workday({
    required this.id,
    // required this.uuid,
    required this.userId,
    required this.open,
    required this.startDate,
    required this.endDate,
  });

  factory Workday.fromJson(Map data) {
    return Workday(
      id: data['id'],
      // uuid: data['uuid'],
      userId: data['userId'],
      open: data["open"],
      startDate: data['startDate'].toDate(),
      endDate: data['endDate'].toDate(),
    );
  }

  factory Workday.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Workday.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        // 'uuid': uuid,
        'userId': userId,
        'open': open,
        'startDate': startDate,
        'endDate': endDate,
      };

  @override
  String toString() {
    return 'Workday $id $userId $startDate $endDate $open';
  }

  Future<Workday> save() async {
    // if (id == "") {
    //   id = uuid;
    //   Map<String, dynamic> data = toJson();
    //   database.add(data).then(data)
    // } else {
    //   Map<String, dynamic> data = toJson();
    //   database.doc(id).set(data);
    // }
    if (id == "") {
      await FirebaseFirestore.instance
          .collection(Workday.tbName)
          .add(toJson())
          .then((value) {
        id = value.id;
        FirebaseFirestore.instance
            .collection(Workday.tbName)
            .doc(id)
            .update({'id': id});
      });
    } else {
      await FirebaseFirestore.instance
          .collection(Workday.tbName)
          .doc(id)
          .update(toJson());
    }
    return this;
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(Workday.tbName).doc(id).delete();
    }
  }

  double hours() {
    return endDate.difference(startDate).inMinutes / 60;
  }

  bool isValid() {
    if (startDate.isAfter(endDate)) {
      return false;
    }
    if (startDate.isBefore(DateTime(2000))) {
      return false;
    }
    if (endDate.isBefore(DateTime(2000))) {
      return false;
    }
    if (endDate.difference(startDate).inMinutes < 1 && !open) {
      return false; // If the duration is less than 1 minute and not open
    }
    return true;
  }

  static Workday getEmpty({String email = '', bool open = true}) {
    DateTime today = DateTime.now();
    return Workday(
        id: '', userId: email, open: open, startDate: today, endDate: today);
  }

  static Future<Workday?> currentByUser(String email) async {
    try {
      List<Workday> items = [];
      DateTime today = DateTime.now();
      today = truncDate(today);
      final query = await FirebaseFirestore.instance
          .collection(Workday.tbName)
          .where("userId", isEqualTo: email)
          .where("startDate", isGreaterThanOrEqualTo: today)
          .get();
      if (query.docs.isNotEmpty) {
        for (var result in query.docs) {
          Workday item = Workday.fromFirestore(result);
          if (item.open) {
            items.add(item);
          }
        }
      }
      if (items.isNotEmpty) {
        items.sort((a, b) => ((b.startDate.compareTo(a.startDate))));
        return items.first;
      } else {
        Workday empty = Workday.getEmpty();
        empty.userId = email;
        empty.open = true;
        empty.startDate = DateTime.now();
        empty.endDate = empty.startDate.add(const Duration(hours: 8));
        empty.save();
        return empty;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<Workday>> byUser(dynamic email,
      [DateTime? fromDate]) async {
    List<Workday> items = [];
    fromDate ??= DateTime.now().subtract(const Duration(days: 40));

    if (email is String) {
      email = [email];
    }

    if (email.isEmpty) {
      return items; // Return empty list if no email provided
    }

    final query = await FirebaseFirestore.instance
        .collection(Workday.tbName)
        .where("userId", whereIn: email)
        .where("startDate",
            isGreaterThanOrEqualTo:
                DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0))
        .get();
    for (var result in query.docs) {
      items.add(Workday.fromFirestore(result));
    }
    if (items.isEmpty) {
      Workday empty = Workday.getEmpty();
      empty.userId = email;
      empty.open = false;
      items.add(empty);
    }

    items.sort((a, b) => (-1 * (a.startDate.compareTo(b.startDate))));
    return items;
  }
}
