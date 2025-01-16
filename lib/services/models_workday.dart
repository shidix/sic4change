// import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/utils.dart';
import 'package:uuid/uuid.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class Workday {
  String id;
  String uuid;
  String userId;
  bool open;
  DateTime startDate;
  DateTime endDate;

  final database = db.collection("s4c_workday");

  Workday({
    required this.id,
    required this.uuid,
    required this.userId,
    required this.open,
    required this.startDate,
    required this.endDate,
  });

  factory Workday.fromJson(Map data) {
    return Workday(
      id: data['id'],
      uuid: data['uuid'],
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
        'uuid': uuid,
        'userId': userId,
        'open': open,
        'startDate': startDate,
        'endDate': endDate,
      };

  @override
  String toString() {
    return 'Workday $uuid $userId $startDate $endDate $open';
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
      await database.add(toJson()).then((value) {
        uuid = value.id;
        database.doc(uuid).update({'uuid': uuid});
      });
    } else {
      await database.doc(id).update(toJson());
    }
    return this;
  }

  void delete() {
    if (id != "") {
      database.doc(id).delete();
    }
  }

  double hours() {
    return endDate.difference(startDate).inMinutes / 60;
  }

  static Workday getEmpty({String email = '', bool open = true}) {
    DateTime today = DateTime.now();
    return Workday(
        id: '',
        uuid: '',
        userId: email,
        open: open,
        startDate: truncDate(today).subtract(const Duration(hours: 16)),
        endDate: truncDate(today).subtract(const Duration(hours: 6)));
  }

  static Future<Workday?> currentByUser(String email) async {
    try {
      final database = db.collection("s4c_workday");
      List<Workday> items = [];
      DateTime today = DateTime.now();
      today = truncDate(today);
      final query = await database
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
        items.sort((a, b) => (-1 * (a.startDate.compareTo(b.startDate))));
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

  static Future<List<Workday>> byUser(String email,
      [DateTime? fromDate]) async {
    final database = db.collection("s4c_workday");
    List<Workday> items = [];
    fromDate ??= DateTime.now().subtract(const Duration(days: 7));

    final query = await database
        .where("userId", isEqualTo: email)
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
