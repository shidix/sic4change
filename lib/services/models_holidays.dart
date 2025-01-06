import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:uuid/uuid.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class HolidaysConfig {
  String id = "";
  int year;
  int totalDays;
  Organization organization;
  List<DateTime> gralHolidays;

  final database = db.collection("s4c_holidays_config");

  HolidaysConfig({
    required this.id,
    required this.year,
    required this.totalDays,
    required this.organization,
    required this.gralHolidays,
  });

  factory HolidaysConfig.fromJson(Map data) {
    return HolidaysConfig(
      id: data['id'],
      year: data['year'],
      totalDays: data['totalDays'],
      organization: Organization.fromJson(data['organization']),
      gralHolidays:
          data['gralHolidays'].map<DateTime>((e) => e.toDate()).toList(),
    );
  }

  factory HolidaysConfig.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return HolidaysConfig.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'year': year,
        'totalDays': totalDays,
        'organization': organization.toJson(),
        'gralHolidays': gralHolidays,
      };

  @override
  String toString() {
    return 'HolidaysConfig{year: $year, totalDays: $totalDays, organization: $organization, gralHolidays: $gralHolidays}';
  }

  static HolidaysConfig getEmpty() {
    return HolidaysConfig(
      id: '',
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
      print("1");
      return query.docs.map((e) => HolidaysConfig.fromFirestore(e)).toList();
    } else {
      print("2");
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
