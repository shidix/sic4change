import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/utils.dart';
import 'package:uuid/uuid.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class HolidaysConfig {
  String id = "";
  String name = "";
  int year;
  int totalDays;
  Organization organization;
  List<Event> gralHolidays;

  final database = db.collection("s4c_holidays_config");

  HolidaysConfig({
    required this.id,
    required this.name,
    required this.year,
    required this.totalDays,
    required this.organization,
    required this.gralHolidays,
  });

  factory HolidaysConfig.fromJson(Map data) {
    return HolidaysConfig(
      id: data['id'],
      // if data has key 'name' then assign it to name, otherwise assign empty string
      name: data['name'] ?? '',
      year: data['year'],
      totalDays: data['totalDays'],
      organization: Organization.fromJson(data['organization']),
      gralHolidays:
          data['gralHolidays'].map<Event>((e) => Event.fromJson(e)).toList(),
    );
  }

  factory HolidaysConfig.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return HolidaysConfig.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'year': year,
        'totalDays': totalDays,
        'organization': organization.toJson(),
        'gralHolidays': gralHolidays.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() {
    return 'HolidaysConfig{name: $name, year: $year, totalDays: $totalDays, organization: $organization, gralHolidays: $gralHolidays}';
  }

  static HolidaysConfig getEmpty() {
    return HolidaysConfig(
      id: '',
      name: '',
      year: DateTime.now().year,
      totalDays: 0,
      organization: Organization.getEmpty(),
      gralHolidays: [],
    );
  }

  //byOrganization (uuid)
  static Future<List<HolidaysConfig>> byOrganization(String uuid) async {
    final database = db.collection("s4c_holidays_config");
    final query =
        await database.where("organization.uuid", isEqualTo: uuid).get();
    if (query.docs.isNotEmpty) {
      return query.docs.map((e) => HolidaysConfig.fromFirestore(e)).toList();
    } else {
      return [];
    }
  }

  void save() {
    if (gralHolidays.isEmpty) {
      gralHolidays.add(Event(
        subject: 'Año Nuevo',
        startTime: DateTime(year, 1, 1),
        endTime: DateTime(year, 1, 1),
        notes: 'Año Nuevo',
        isAllDay: true,
      ));
      gralHolidays.add(Event(
        subject: 'Navidad',
        startTime: DateTime(year, 12, 25),
        endTime: DateTime(year, 12, 25),
        notes: 'Navidad',
        isAllDay: true,
      ));
    }
    if (id == "") {
      Map<String, dynamic> data = toJson();
      database.add(data).then((value) {
        id = value.id;
      });
    } else {
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
    }
  }

  void delete() {
    if (id != "") {
      database.doc(id).delete();
    }
  }
}

class HolidayRequest {
  String id;
  String uuid;
  String userId;
  String catetory;
  DateTime startDate;
  DateTime endDate;
  DateTime requestDate;
  DateTime approvalDate;
  String status;
  String approvedBy;

  final database = db.collection("s4c_holidays");

  HolidayRequest({
    required this.id,
    required this.uuid,
    required this.userId,
    required this.catetory,
    required this.startDate,
    required this.endDate,
    required this.requestDate,
    required this.approvalDate,
    required this.status,
    required this.approvedBy,
  });

  factory HolidayRequest.fromJson(Map data) {
    return HolidayRequest(
      id: data['id'],
      uuid: data['uuid'],
      userId: data['userId'],
      catetory: data['catetory'],
      startDate: data['startDate'].toDate(),
      endDate: data['endDate'].toDate(),
      requestDate: data['requestDate'].toDate(),
      approvalDate: data['approvalDate'].toDate(),
      status: data['status'],
      approvedBy: data['approvedBy'],
    );
  }

  factory HolidayRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return HolidayRequest.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'userId': userId,
        'catetory': catetory,
        'startDate': startDate,
        'endDate': endDate,
        'requestDate': requestDate,
        'approvalDate': approvalDate,
        'status': status,
        'approvedBy': approvedBy,
      };

  @override
  String toString() {
    return 'HolidayRequest{id: $id, uuid: $uuid, userId: $userId, catetory: $catetory, startDate: $startDate, endDate: $endDate, requestDate: $requestDate, approvalDate: $approvalDate, status: $status, approvedBy: $approvedBy}';
  }

  void save() {
    if (id == "") {
      id = uuid;
      Map<String, dynamic> data = toJson();
      database.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
    }
  }

  void delete() {
    if (id != "") {
      database.doc(id).delete();
    }
  }

  static HolidayRequest getEmpty() {
    return HolidayRequest(
      id: '',
      uuid: Uuid().v4(),
      userId: '',
      catetory: 'Vacaciones',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      requestDate: DateTime.now(),
      approvalDate: DateTime(2099, 1, 1),
      status: 'Pendiente',
      approvedBy: '',
    );
  }

  static Future<List<HolidayRequest>> byUser(String uuid) async {
    final database = db.collection("s4c_holidays");
    List<HolidayRequest> items = [];
    final query = await database.where("userId", isEqualTo: uuid).get();
    query.docs.forEach((result) {
      items.add(HolidayRequest.fromFirestore(result));
    });
    return items;
  }
}

class Event {
  String subject;
  DateTime startTime;
  DateTime endTime;
  String? notes;
  bool isAllDay;

  Event({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.isAllDay,
  });

  factory Event.fromJson(Map data) {
    return Event(
      subject: data['subject'],
      startTime: getDate(data['startTime']),
      endTime: getDate(data['endTime']),
      notes: data['notes'],
      isAllDay: data['isAllDay'],
    );
  }

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'startTime': startTime,
        'endTime': endTime,
        'notes': notes,
        'isAllDay': isAllDay,
      };
}

class HolidaysUser {
  String id = "";
  String name = "";
  int year;
  int totalDays;
  String email;
  List<Event> holidays;

  final database = db.collection("s4c_holidays_user");

  HolidaysUser({
    required this.id,
    required this.name,
    required this.year,
    required this.totalDays,
    required this.email,
    required this.holidays,
  });

  factory HolidaysUser.fromJson(Map data) {
    return HolidaysUser(
      id: data['id'],
      name: data['name'] ?? '',
      year: data['year'],
      totalDays: data['totalDays'],
      email: data['email'],
      holidays: data['holidays'].map<Event>((e) => Event.fromJson(e)).toList(),
    );
  }

  factory HolidaysUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return HolidaysUser.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'year': year,
        'totalDays': totalDays,
        'email': email,
        'holidays': holidays.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() {
    return 'HolidaysUser{name: $name, year: $year, totalDays: $totalDays, organization: $email, holidays: $holidays}';
  }

  static HolidaysUser getEmpty() {
    return HolidaysUser(
      id: '',
      name: '',
      year: DateTime.now().year,
      totalDays: 0,
      email: 'none@none.com',
      holidays: [],
    );
  }

  //byOrganization (uuid)
  static Future<List<HolidaysUser>> byEmail(String email) async {
    final database = db.collection("s4c_holidays_user");
    final query = await database.where("email", isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      return query.docs.map((e) => HolidaysUser.fromFirestore(e)).toList();
    } else {
      return [];
    }
  }

  void save() {
    if (id == "") {
      Map<String, dynamic> data = toJson();
      database.add(data).then((value) {
        id = value.id;
      });
    } else {
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
    }
  }

  void delete() {
    if (id != "") {
      database.doc(id).delete();
    }
  }
}
