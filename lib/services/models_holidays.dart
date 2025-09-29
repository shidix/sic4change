import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/transcoder/v1.dart';
import 'package:sic4change/services/models_arbase.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
import 'dart:developer' as dev;
// import 'package:uuid/uuid.dart';

class HolidaysConfig {
  static const String tbName = "s4c_holidays_config";
  DocumentReference? docRef;
  Function? onChanged;

  String id = "";
  String name = "";
  int year;
  int totalDays;
  String organization;
  List<Event> gralHolidays;
  // List<Employee> employees = [];
  List<String> employees = [];

  HolidaysConfig({
    required this.id,
    required this.name,
    required this.year,
    required this.totalDays,
    required this.organization,
    required this.gralHolidays,
  });

  void mapping(Map data) {
    id = data['id'];
    name = data['name'] ?? '';
    year = data['year'];
    totalDays = data['totalDays'];
    organization = data['organization'] ?? '';
    gralHolidays = (data['gralHolidays'] as List)
        .map<Event>((e) => Event.fromJson(e))
        .toList();
    if (!data.containsKey('employees')) {
      employees = [];
    } else {
      employees = List<String>.from(data['employees']);
    }
  }

  static Future<HolidaysConfig> fromJson(DocumentReference doc) async {
    DocumentSnapshot docSnap = await doc.get();
    HolidaysConfig? temp;
    if (docSnap.exists) {
      Map data = docSnap.data() as Map<String, dynamic>;
      temp = HolidaysConfig.getEmpty();
      temp.mapping(data);
      temp.docRef ??= doc;
      if (temp.docRef != null) {
        temp.docRef!.snapshots().listen((event) {
          if (event.exists) {
            Map data = event.data() as Map<String, dynamic>;
            temp?.mapping(data);
            if (temp?.onChanged != null) {
              temp?.onChanged!.call();
            }
          }
        });
      }
    }
    return temp!;
  }

  // factory HolidaysConfig.fromFirestore(DocumentSnapshot doc) {
  //   Map data = doc.data() as Map<String, dynamic>;
  //   data['id'] = doc.id;
  //   return HolidaysConfig.fromJson(data);
  // }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'year': year,
        'totalDays': totalDays,
        'organization': organization,
        'gralHolidays': gralHolidays.map((e) => e.toJson()).toList(),
        'employees': employees,
      };

  @override
  String toString() {
    return 'HolidaysConfig{name: $name, year: $year, totalDays: $totalDays, organization: $organization, gralHolidays: $gralHolidays}';
  }

  static HolidaysConfig getEmpty({String name = 'Default0', int year = 0}) {
    return HolidaysConfig(
      id: '',
      name: name,
      year: year == 0 ? DateTime.now().year : year,
      totalDays: 0,
      organization: '',
      gralHolidays: [],
    );
  }

  static Future<HolidaysConfig> byEmployee(Employee employee,
      {int year = 0, bool fromServer = false}) async {
    if (year == 0) {
      year = DateTime.now().year;
    }
    if (employee.id!.isEmpty) {
      return getEmpty(year: year);
    }

    final Query query = FirebaseFirestore.instance
        .collection(tbName)
        .where("employees", arrayContains: employee.id);
    QuerySnapshot querySnap =
        await query.get(const GetOptions(source: Source.cache));
    if (querySnap.docs.isEmpty || fromServer) {
      querySnap = await query.get();
    }

    List<HolidaysConfig> items = [];
    for (var result in querySnap.docs) {
      Map<String, dynamic> data = result.data() as Map<String, dynamic>;
      HolidaysConfig temp = HolidaysConfig.getEmpty();
      temp.mapping(data);
      items.add(temp);
    }

    // Filter by organization and year
    items = items
        .where((item) =>
            item.organization == employee.organization && item.year == year)
        .toList();

    // Sort by year (Descending)
    return items.isNotEmpty
        ? items.first
        : getEmpty(name: 'Default', year: year);
  }

  //byOrganization (uuid)
  static Future<List<HolidaysConfig>> byOrganization(String uuid,
      {bool fromServer = false}) async {
    List<HolidaysConfig> items = [];
    final Query query = FirebaseFirestore.instance
        .collection(tbName)
        .where("organization", isEqualTo: uuid);
    QuerySnapshot querySnap =
        await query.get(const GetOptions(source: Source.cache));
    if (querySnap.docs.isEmpty || fromServer) {
      dev.log("Fetching HolidaysConfig from SERVER");
      querySnap = await query.get();
      dev.log("HolidaysConfig fetched from SERVER: ${querySnap.docs.length}");
    }
    if (querySnap.docs.isNotEmpty) {
      for (var result in querySnap.docs) {
        Map<String, dynamic> data = result.data() as Map<String, dynamic>;
        HolidaysConfig temp = HolidaysConfig.getEmpty();
        temp.mapping(data);
        items.add(temp);
      }
      // items =
      //     querySnap.docs.map((e) => HolidaysConfig.fromJson(e)).toList();
      // //Sort by year and Name
      // items.sort((a, b) {
      //   int yearComparison = b.year.compareTo(a.year);
      //   if (yearComparison != 0) return yearComparison;
      //   return a.name.compareTo(b.name);
      // });
      return items;
    } else {
      return [];
    }
  }

  Future<HolidaysConfig> save() async {
    if (gralHolidays.isEmpty) {
      gralHolidays.add(Event(
        subject: 'Año Nuevo',
        startTime: DateTime(year, 1, 1),
        endTime: DateTime(year, 1, 1),
        notes: 'Año Nuevo',
        isAllDay: true,
        id: '',
      ));
      gralHolidays.add(Event(
        subject: 'Navidad',
        startTime: DateTime(year, 12, 25),
        endTime: DateTime(year, 12, 25),
        notes: 'Navidad',
        isAllDay: true,
        id: '',
      ));
    }
    if (id == "") {
      Map<String, dynamic> data = toJson();
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(data)
          .then((value) {
        id = value.id;
        Map<String, dynamic> data = toJson();
        FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
      });
    } else {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
    }
    return this;
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    }
  }

  HolidaysConfig addEmployee(Employee employee) {
    if (!employees.any((e) => e == employee.id)) {
      employees.add(employee.id!);
      save();
    }
    return this;
  }

  HolidaysConfig removeEmployee(Employee employee) {
    employees.removeWhere((e) => e == employee.id);
    save();
    return this;
  }

  bool isHoliday(DateTime date) {
    for (var event in gralHolidays) {
      if (truncDate(event.startTime).isAtSameMomentAs(truncDate(date)) &&
          event.isAllDay) {
        return true;
      }
    }
    return false;
  }

  bool isWorkingDay(DateTime date) {
    return (!isHoliday(date));
  }
}

class HolidayRequest {
  String id;
  // String uuid;
  String userId;
  String category;
  DateTime startDate;
  DateTime endDate;
  DateTime requestDate;
  DateTime approvalDate;
  String status;
  String approvedBy;
  String documentsMessage = "";
  List<String> documents = [];

  static const String tbName = "s4c_holidays";
  static const List<String> statuses = ['Pendiente', 'Aprobado', 'Rechazado'];

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
    this.documents = const [],
  });

  factory HolidayRequest.fromJson(Map data) {
    if (!data.containsKey('documents')) {
      data['documents'] = [];
    }
    HolidayRequest item = HolidayRequest(
      id: data['id'],
      // uuid: data['uuid'],
      userId: data['userId'],
      category: data['category'] ?? '',
      startDate: data['startDate'].toDate(),
      endDate: data['endDate'].toDate(),
      requestDate: data['requestDate'].toDate(),
      approvalDate: data['approvalDate'].toDate(),
      status: data['status'],
      approvedBy: data['approvedBy'],
      documents: List<String>.from(data['documents'] ?? []),
    );

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
        'category': category,
        'startDate': startDate,
        'endDate': endDate,
        'requestDate': requestDate,
        'approvalDate': approvalDate,
        'status': status,
        'approvedBy': approvedBy,
        'documents': documents,
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
      save();
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

  bool isRejected() {
    return status.toLowerCase() == 'rechazado' ||
        status.toLowerCase() == 'rejected';
  }

  bool isAproved() {
    return status.toLowerCase() == 'aprobado' ||
        status.toLowerCase() == 'approved';
  }

  bool isPending() {
    return status.toLowerCase() == 'pendiente' ||
        status.toLowerCase() == 'pending';
  }

  static HolidayRequest getEmpty() {
    return HolidayRequest(
      id: '',
      // uuid: Uuid().v4(),
      userId: '',
      category: '',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      requestDate: DateTime.now(),
      approvalDate: DateTime(2099, 1, 1),
      status: 'Pendiente',
      approvedBy: '',
      documents: [],
    );
  }

  HolidaysCategory getCategory(List<HolidaysCategory> categories) {
    if (categories.isEmpty) {
      return HolidaysCategory.getEmpty();
    }
    if (categories.any((cat) => cat.id == category)) {
      return categories.firstWhere((cat) => cat.id == category);
    } else if (category.isEmpty) {
      return HolidaysCategory.getEmpty();
    }
    category = categories.first.id;
    save();
    return categories.first;
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

  static Future<List<HolidayRequest>> byUser(dynamic email,
      [DateTime? startDate, DateTime? endDate]) async {
    List<HolidayRequest> items = [];
    startDate ??= DateTime(DateTime.now().year, 1, 1);
    endDate ??= DateTime(DateTime.now().year + 1, 1, 1);

    if (email is String) {
      email = [email];
    }

    // Chuncks of 25
    int chunkSize = 25;
    for (var i = 0; i < email.length; i += chunkSize) {
      var chunk = email.sublist(
          i, i + chunkSize > email.length ? email.length : i + chunkSize);

      // Query => usendIds in chunk and (startDate OR endDate in datesRange)
      // final query = await FirebaseFirestore.instance
      //     .collection(tbName)
      //     .where("userId", whereIn: chunk)
      //     .get();
      Query queryBuilder = FirebaseFirestore.instance
          .collection(tbName)
          .where("userId", whereIn: chunk)
          .where("startDate", isLessThan: endDate)
          .where("endDate", isGreaterThan: startDate);
      QuerySnapshot query =
          await queryBuilder.get(const GetOptions(source: Source.cache));
      if (query.docs.isEmpty) {
        query = await queryBuilder.get();
      }

      for (var result in query.docs) {
        Map<String, dynamic> data = result.data() as Map<String, dynamic>;
        data['id'] = result.id;
        items.add(HolidayRequest.fromJson(data));
      }
    }

    // final query1 = await FirebaseFirestore.instance
    //     .collection(tbName)
    //     .where("userId", whereIn: email)
    //     .get();
    // for (var result in query1.docs) {
    //   Map<String, dynamic> data = result.data();
    //   data['id'] = result.id;
    //   items.add(HolidayRequest.fromJson(data));
    // }

    // Filiter intems in the date range
    items = items.where((item) {
      return item.startDate.isAfter(startDate!) &&
              item.startDate.isBefore(endDate!) ||
          item.endDate.isAfter(startDate) && item.endDate.isBefore(endDate!);
    }).toList();

    return items;
  }
}

class Event {
  String subject;
  DateTime startTime;
  DateTime endTime;
  String? notes;
  bool isAllDay;
  String id;

  Event({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.isAllDay,
    required this.id,
  });

  factory Event.fromJson(Map data) {
    return Event(
      subject: data['subject'],
      startTime: getDate(data['startTime']),
      endTime: getDate(data['endTime']),
      notes: data['notes'],
      isAllDay: data['isAllDay'],
      id: data['id'] ?? '',
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
  String code;
  int docRequired = 0;
  int year = DateTime.now().year;
  DateTime validUntil = DateTime(DateTime.now().year + 1, 1, 1);
  String docMessage = "";
  bool retroactive = false;
  bool obligation = false;
  bool onlyRRHH = false;
  Organization? organization;
  int days;

  HolidaysCategory({
    required this.id,
    required this.name,
    required this.organization,
    required this.year,
    this.code = '',
    this.docRequired = 0,
    this.retroactive = false,
    this.days = 0,
    this.docMessage = "",
    this.obligation = false,
    this.onlyRRHH = false,
  });

  factory HolidaysCategory.fromJson(Map data) {
    int year = DateTime.now().year;
    if (data.containsKey('year')) {
      year = data['year'];
    }
    if (!data.containsKey('onlyRRHH')) {
      data['onlyRRHH'] = false;
    }
    HolidaysCategory item = HolidaysCategory(
      id: data['id'],
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      organization: null,
      docRequired: int.tryParse(data['docRequired'].toString()) ?? 0,
      retroactive: data['retroactive'] ?? false,
      docMessage: data['docMessage'] ?? "",
      days: data['days'] ?? 0,
      obligation: data['obligation'] ?? false,
      onlyRRHH: data['onlyRRHH'] ?? false,
      year: year,
    );

    if (data.containsKey('validUntil')) {
      item.validUntil = getDate(data['validUntil']);
    } else {
      item.validUntil = DateTime(year + 1, 1, 1);
    }

    String orgUuid = data['organization'];

    Organization.byUuid(orgUuid).then((org) {
      item.organization = org;
    }).catchError((error) {});
    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': autoCode(),
        'organization': organization?.uuid ?? '',
        'docRequired': docRequired,
        'retroactive': retroactive,
        'docMessage': docMessage,
        'obligation': obligation,
        'days': days,
        'year': year,
        'validUntil': validUntil,
        'onlyRRHH': onlyRRHH,
      };

  @override
  String toString() {
    return 'HolidaysCategory{id: $id, name: $name, organization: ${organization?.name}, days: $days, code: $code}';
  }

  String autoCode() {
    if (code.isEmpty) {
      List<String> parts = name.split(' ');
      if (parts.length < 3) {
        code = name.substring(0, 3).toUpperCase();
      } else {
        code = parts.map((part) => part.substring(0, 1).toUpperCase()).join('');
      }
    }
    return code;
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

  bool isActive() {
    if (year > DateTime.now().year) return false;
    if (validUntil.isBefore(DateTime.now())) return false;
    return true;
  }

  static HolidaysCategory getEmpty(
      {String id = '',
      String name = 'Sin Categoría',
      Organization? organization,
      int days = 0}) {
    return HolidaysCategory(
      id: id,
      name: name,
      year: DateTime.now().year,
      organization: organization ?? Organization.getEmpty(),
      days: days,
    );
  }

  static Future<HolidaysCategory> byId(String id) async {
    DocumentReference snap =
        FirebaseFirestore.instance.collection(tbName).doc(id);
    DocumentSnapshot doc;
    try {
      doc = await snap.get(const GetOptions(source: Source.cache));
    } catch (e) {
      doc = await snap.get();
    }
    if (doc.exists) {
      return HolidaysCategory.fromJson(doc.data() as Map<String, dynamic>);
    } else {
      return getEmpty();
    }
  }

  static Future<List<HolidaysCategory>> byOrganization(
      dynamic organization) async {
    String uuid = "";
    if (organization is String) {
      uuid = organization;
    } else if (organization is Organization) {
      uuid = organization.uuid;
    }
    if (uuid.isEmpty) {
      return [];
    }
    Query query = FirebaseFirestore.instance
        .collection(tbName)
        .where("organization", isEqualTo: uuid);
    QuerySnapshot querySnap =
        await query.get(const GetOptions(source: Source.cache));
    if (querySnap.docs.isEmpty) {
      querySnap = await query.get();
    }
    if (querySnap.docs.isNotEmpty) {
      if (querySnap.metadata.isFromCache) {
        dev.log("Returned ${querySnap.docs.length} items from CACHE");
      } else {
        dev.log("Returned ${querySnap.docs.length} items from SERVER");
      }
      return querySnap.docs
          .map((e) =>
              HolidaysCategory.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  static Future<List<HolidaysCategory>> getAll(
      {Organization? organization}) async {
    if (organization != null && organization.uuid.isNotEmpty) {
      return await HolidaysCategory.byOrganization(organization);
    } else {
      Query query = FirebaseFirestore.instance.collection(tbName);
      QuerySnapshot querySnap =
          await query.get(const GetOptions(source: Source.cache));
      if (querySnap.docs.isEmpty) {
        querySnap = await query.get();
      }
      if (querySnap.docs.isNotEmpty) {
        return querySnap.docs
            .map((e) =>
                HolidaysCategory.fromJson(e.data() as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    }
  }

  Future<int> getAvailableDays(String employeeEmail) async {
    int usedDays = 0;
    List<HolidayRequest> requests = await HolidayRequest.byUser(employeeEmail);

    Employee employee = await Employee.byEmail(employeeEmail);
    HolidaysConfig calendar =
        await HolidaysConfig.byEmployee(employee, year: year);

    for (var request in requests) {
      if (request.isAproved() &&
          request.category == id &&
          !calendar.isHoliday(request.startDate)) {
        usedDays += request.endDate.difference(request.startDate).inDays + 1;
      }
    }

    return days - usedDays;
  }
}

class DocHolidays extends ARBaseModel {
  String id = "";
  String description = "";
  String fileUrl = "";
  String organizationId = "";

  static const String tbName = "s4c_holidays_docs";

  @override
  String getId() {
    return id;
  }

  @override
  void setId(String id) {
    this.id = id;
  }

  DocHolidays({
    required this.id,
    required this.description,
    required this.fileUrl,
    required this.organizationId,
  });

  factory DocHolidays.fromJson(Map data) {
    return DocHolidays(
      id: data['id'],
      description: data['description'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      organizationId: data['organizationId'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'fileUrl': fileUrl,
        'organizationId': organizationId,
      };

  @override
  Future<void> reload() async {
    // Implement reload logic if needed
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    description = json['description'] ?? '';
    fileUrl = json['fileUrl'] ?? '';
    organizationId = json['organizationId'] ?? '';
  }
}
