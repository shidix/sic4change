// import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
// import 'package:googleapis/photoslibrary/v1.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
import 'dart:developer' as dev;
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

  Future<Workday?> save() async {
    if (userId is List) {
      userId = (userId as List).first;
    }
    if (!isEmail(userId)) {
      return null;
    }

    if (id == "") {
      var item = await FirebaseFirestore.instance
          .collection(Workday.tbName)
          .add(toJson());
      id = item.id;
      await item.update({'id': item.id});
      return this;
    } else {
      // Check if the document exists
      var doc = await FirebaseFirestore.instance
          .collection(Workday.tbName)
          .doc(id)
          .get();
      if (!doc.exists) {
        return null;
      }
      await FirebaseFirestore.instance
          .collection(Workday.tbName)
          .doc(id)
          .update(toJson())
          .catchError((e) {
        dev.log("Error updating Workday: $e");
        return null;
      });
      return this;
    }
    // return this;
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
    if (endDate.isAfter(DateTime.now()) && !open) {
      return false; // If the end date is in the future and not open
    }
    return true;
  }

  bool isSame(Workday? other) {
    if (other == null) return false;
    return id != other.id &&
        userId == other.userId &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        open == other.open;
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
    // Check if email are > 30 elements

    List<Workday> items = [];
    fromDate ??= DateTime.now().subtract(const Duration(days: 40));

    if (email is String) {
      email = [email];
    }

    if (email.isEmpty) {
      return items; // Return empty list if no email provided
    }

    // Check if email has more than 30 elements
    if (email.length > 30) {
      // Split email in chunks of 30
      List<Workday> allItems = [];
      for (var i = 0; i < email.length; i += 30) {
        var chunk =
            email.sublist(i, i + 30 > email.length ? email.length : i + 30);
        var chunkItems = await Workday.byUser(chunk, fromDate);
        allItems.addAll(chunkItems);
      }
      allItems.sort((a, b) => (-1 * (a.startDate.compareTo(b.startDate))));
      return allItems;
    } else {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection(Workday.tbName)
          .where("userId", whereIn: email)
          .where("startDate",
              isGreaterThanOrEqualTo: DateTime(
                  fromDate.year, fromDate.month, fromDate.day, 0, 0, 0))
          .get();
      for (var result in query.docs) {
        items.add(Workday.fromJson(result.data() as Map<String, dynamic>));
      }
      if (items.isNotEmpty) {
        // Workday empty = Workday.getEmpty();
        // empty.userId = email.first;
        // empty.open = true;
        // items.add(empty);
        items.sort((a, b) => (-1 * (a.startDate.compareTo(b.startDate))));
      }
      return items;
    }
  }
}

class WorkdayUpload {
  static const String tbName = "s4c_workday_uploads";
  String id = "";
  String employee;
  DateTime date;
  DateTime updatedAt = DateTime.now();
  String path;

  WorkdayUpload(
      {required this.employee,
      required this.date,
      required this.path,
      DateTime? updatedAt}) {
    if (updatedAt != null) {
      this.updatedAt = updatedAt;
    }
  }

  factory WorkdayUpload.fromJson(Map data) {
    WorkdayUpload item = WorkdayUpload(
      employee: data['employee'],
      date: getDate(data['date']),
      path: data['path'],
      updatedAt: getDate(data['updatedAt']),
    );
    item.id = data['id'] ?? "";
    return item;
  }

  factory WorkdayUpload.getEmpty() {
    return WorkdayUpload(
      employee: "",
      date: DateTime(DateTime.now().year, DateTime.now().month, 1),
      path: "",
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee': employee,
        'date': date,
        'path': path,
        'updatedAt': updatedAt,
      };

  Future<WorkdayUpload?> save() async {
    if (employee is List) {
      employee = (employee as List).first;
    }

    if (id != "") {
      await FirebaseFirestore.instance
          .collection(tbName)
          .doc(id)
          .update(toJson())
          .catchError((e) {
        dev.log("Error updating WorkdayUpload: $e");
      });
      return this;
    } else {
      var item =
          await FirebaseFirestore.instance.collection(tbName).add(toJson());
      id = item.id;
      await item.update({'id': item.id});
      return this;
    }
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance
          .collection(tbName)
          .doc(id)
          .delete()
          .catchError((e) {
        dev.log("Error deleting WorkdayUpload: $e");
        // createLog("Error deleting WorkdayUpload: $e");
      });
    }
  }

  static Future<WorkdayUpload?> byId(String id) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection(WorkdayUpload.tbName)
          .doc(id)
          .get();
      if (doc.exists) {
        return WorkdayUpload.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<WorkdayUpload?> byEmployeeDate(
      dynamic employee, DateTime date) async {
    if (employee is Employee) {
      employee = employee.id;
    }
    try {
      var query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("employee", isEqualTo: employee)
          .where("date", isEqualTo: DateTime(date.year, date.month, 1))
          .get();

      if (query.docs.isNotEmpty) {
        return WorkdayUpload.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<WorkdayUpload>> byEmployee(dynamic employee) async {
    if (employee is Employee) {
      employee = employee.id;
    }
    List<WorkdayUpload> items = [];
    try {
      var query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("employee", isEqualTo: employee)
          .get();
      for (var doc in query.docs) {
        items.add(WorkdayUpload.fromJson(doc.data()));
      }
      return items;
    } catch (e) {
      return items;
    }
  }

  @override
  String toString() {
    return 'WorkdayUpload $employee $date $path';
  }
}
