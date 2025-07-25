import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
// import 'package:uuid/uuid.dart';

class HolidaysConfig {
  String id = "";
  String name = "";
  int year;
  int totalDays;
  Organization organization;
  List<Event> gralHolidays;
  List<Employee> employees = [];

  static const String tbName = "s4c_holidays_config";

  HolidaysConfig({
    required this.id,
    required this.name,
    required this.year,
    required this.totalDays,
    required this.organization,
    required this.gralHolidays,
  });

  factory HolidaysConfig.fromJson(Map data) {
    HolidaysConfig temp = HolidaysConfig(
      id: data['id'],
      name: data['name'] ?? '',
      year: data['year'],
      totalDays: data['totalDays'],
      organization: Organization.fromJson(data['organization']),
      gralHolidays: (data['gralHolidays'] as List)
          .map<Event>((e) => Event.fromJson(e))
          .toList(),
    );
    if (data['employees'] != null &&
        data['employees'] is List &&
        data['employees'].isNotEmpty) {
      for (var idEmployee in data['employees']) {
        Employee.byId(idEmployee).then((employee) {
          if (employee.id != "") {
            temp.employees.add(employee);
          }
        }).catchError((error) {
          print("Error getting employee by id: $error");
        });
      }
    } else {
      temp.employees = [];
    }

    return temp;
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
        'employees': employees.map((e) => e.id).toList(),
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
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("organization", isEqualTo: uuid)
        .get();
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
      FirebaseFirestore.instance.collection(tbName).add(data).then((value) {
        id = value.id;
      });
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    }
  }

  HolidaysConfig addEmployee(Employee employee) {
    if (!employees.any((e) => e.id == employee.id)) {
      employees.add(employee);
      save();
    }
    return this;
  }

  HolidaysConfig removeEmployee(Employee employee) {
    employees.removeWhere((e) => e.id == employee.id);
    save();
    return this;
  }
}

class HolidayRequest {
  String id;
  // String uuid;
  String userId;
  HolidaysCategory? category;
  DateTime startDate;
  DateTime endDate;
  DateTime requestDate;
  DateTime approvalDate;
  String status;
  String approvedBy;

  static const String tbName = "s4c_holidays";

  HolidayRequest({
    required this.id,
    // required this.uuid,
    required this.userId,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.requestDate,
    required this.approvalDate,
    required this.status,
    required this.approvedBy,
  });

  factory HolidayRequest.fromJson(Map data) {
    HolidayRequest item = HolidayRequest(
      id: data['id'],
      // uuid: data['uuid'],
      userId: data['userId'],
      category: null,
      startDate: data['startDate'].toDate(),
      endDate: data['endDate'].toDate(),
      requestDate: data['requestDate'].toDate(),
      approvalDate: data['approvalDate'].toDate(),
      status: data['status'],
      approvedBy: data['approvedBy'],
    );

    String catUuid = data['category'];

    HolidaysCategory.byId(catUuid).then((cat) {
      item.category = cat;
    }).catchError((error) {
      print("Error getting category by uuid: $error");
    });

    return item;
  }

  factory HolidayRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return HolidayRequest.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        // 'uuid': uuid,
        'userId': userId,
        'category': category?.id ?? '',
        'startDate': startDate,
        'endDate': endDate,
        'requestDate': requestDate,
        'approvalDate': approvalDate,
        'status': status,
        'approvedBy': approvedBy,
      };

  @override
  String toString() {
    return 'HolidayRequest{id: $id, userId: $userId, catetory: $category, startDate: $startDate, endDate: $endDate, requestDate: $requestDate, approvalDate: $approvalDate, status: $status, approvedBy: $approvedBy}';
  }

  void save2() {
    if (id == "") {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).add(data).then((value) {
        id = value.id;
        save(); // Save again to update the id
      });
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  Future<HolidayRequest> save() async {
    if (id == "") {
      Map<String, dynamic> data = toJson();
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection(tbName).add(data);
      id = docRef.id;
    } else {
      Map<String, dynamic> data = toJson();
      await FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
    return this;
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    }
  }

  static HolidayRequest getEmpty() {
    return HolidayRequest(
      id: '',
      // uuid: Uuid().v4(),
      userId: '',
      category: null,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      requestDate: DateTime.now(),
      approvalDate: DateTime(2099, 1, 1),
      status: 'Pendiente',
      approvedBy: '',
    );
  }

  static Future<HolidayRequest> byId(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection(tbName).doc(id).get();
    if (doc.exists) {
      return HolidayRequest.fromFirestore(doc);
    } else {
      return getEmpty();
    }
  }

  static Future<List<HolidayRequest>> byUser(String uuid) async {
    List<HolidayRequest> items = [];
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("userId", isEqualTo: uuid)
        .get();
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

  static const String tbName = "s4c_holidays_user";

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
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("email", isEqualTo: email)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.map((e) => HolidaysUser.fromFirestore(e)).toList();
    } else {
      return [];
    }
  }

  void save() {
    if (id == "") {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).add(data).then((value) {
        id = value.id;
      });
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    }
  }
}

class HolidaysCategory {
  static const tbName = "s4c_holidays_category";
  String id;
  String name;
  bool docRequired = false;
  bool retroactive = false;
  Organization? organization;
  int days;

  HolidaysCategory({
    required this.id,
    required this.name,
    required this.organization,
    this.docRequired = false,
    this.retroactive = false,
    this.days = 0,
  });

  factory HolidaysCategory.fromJson(Map data) {
    HolidaysCategory item = HolidaysCategory(
      id: data['id'],
      name: data['name'] ?? '',
      organization: null,
      docRequired: data['docRequired'] ?? false,
      retroactive: data['retroactive'] ?? false,
      days: data['days'] ?? 0,
    );

    String orgUuid = data['organization'];

    Organization.byUuid(orgUuid).then((org) {
      item.organization = org;
    }).catchError((error) {
      print("Error getting organization by uuid: $error");
    });
    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'organization': organization?.uuid ?? '',
        'docRequired': docRequired,
        'retroactive': retroactive,
        'days': days,
      };

  @override
  String toString() {
    return 'HolidaysCategory{id: $id, name: $name, organization: ${organization?.name}, days: $days}';
  }

  void save() {
    if (id == "") {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).add(data).then((value) {
        id = value.id;
        save();
      });
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
  }

  void delete() {
    final database = FirebaseFirestore.instance.collection(tbName);
    if (id != "") {
      database.doc(id).delete();
    }
  }

  static HolidaysCategory getEmpty(
      {String id = '',
      String name = '',
      Organization? organization,
      int days = 0}) {
    return HolidaysCategory(
      id: id,
      name: name,
      organization: organization ?? Organization.getEmpty(),
      days: days,
    );
  }

  static Future<HolidaysCategory> byId(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection(tbName).doc(id).get();
    if (doc.exists) {
      return HolidaysCategory.fromJson(doc.data() as Map<String, dynamic>);
    } else {
      return getEmpty();
    }
  }

  static Future<List<HolidaysCategory>> byOrganization(
      Organization organization) async {
    String uuid = organization.uuid;
    if (uuid.isEmpty) {
      return [];
    }
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("organization", isEqualTo: uuid)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs
          .map((e) => HolidaysCategory.fromJson(e.data()))
          .toList();
    } else {
      return [];
    }
  }
}
