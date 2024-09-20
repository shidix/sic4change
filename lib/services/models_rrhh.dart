import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/utils.dart';
import 'package:uuid/uuid.dart';

class Nomina {
  static final db = FirebaseFirestore.instance;
  static final collection = db.collection("s4c_nominas");
  static final storage = FirebaseStorage.instance;

  String? id;
  String employeeCode;
  DateTime date;
  double grossSalary;
  double netSalary;
  double deductions; // IRPF
  double employeeSocialSecurity;
  double employerSocialSecurity;
  DateTime? paymentDate;

  String? reciptPath;

  String noSignedPath;
  DateTime noSignedDate;
  String? signedPath;
  DateTime? signedDate;

  Employee? employee;

  Nomina(
      {required this.employeeCode,
      required this.date,
      required this.grossSalary,
      required this.netSalary,
      required this.deductions,
      required this.employeeSocialSecurity,
      required this.employerSocialSecurity,
      required this.noSignedPath,
      required this.noSignedDate,
      this.paymentDate,
      this.reciptPath,
      this.signedPath,
      this.signedDate});

  factory Nomina.fromJson(Map<String, dynamic> json) {
    return Nomina(
        employeeCode: json['employeeCode'],
        date: getDate(json['date'] ?? DateTime.now()),
        grossSalary:
            (json.containsKey('grossSalary')) ? json['grossSalary'] : 0.0,
        netSalary: (json.containsKey('netSalary')) ? json['netSalary'] : 0.0,
        deductions: (json.containsKey('deductions')) ? json['deductions'] : 0.0,
        employeeSocialSecurity: (json.containsKey('employeeSocialSecurity'))
            ? json['employeeSocialSecurity']
            : 0.0,
        employerSocialSecurity: (json.containsKey('employerSocialSecurity'))
            ? json['employerSocialSecurity']
            : 0.0,
        paymentDate: (json.containsKey('paymentDate'))
            ? getDate(json['paymentDate'], truncate: true)
            : (json.containsKey('date'))
                ? getDate(json['date'], truncate: true)
                : DateTime.now(),
        reciptPath:
            (json.containsKey('reciptPath')) ? json['reciptPath'] : null,
        noSignedPath: json['noSignedPath'],
        noSignedDate: getDate(json['noSignedDate'] ?? DateTime.now()),
        signedPath: json['signedPath'],
        signedDate: getDate(json['signedDate'] ?? DateTime.now()));
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'paymentDate': paymentDate,
        'employeeCode': employeeCode,
        'grossSalary': grossSalary,
        'netSalary': netSalary,
        'deductions': deductions,
        'employeeSocialSecurity': employeeSocialSecurity,
        'employerSocialSecurity': employerSocialSecurity,
        'noSignedPath': noSignedPath,
        'noSignedDate': noSignedDate,
        'signedPath': signedPath,
        'signedDate': signedDate,
        'reciptPath': reciptPath,
      };

  double getNetSalary() {
    return grossSalary - deductions - employeeSocialSecurity;
  }

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

  Future<Nomina> save() async {
    if (id == null) {
      await collection.add(toJson()).then((value) => id = value.id);
    } else {
      await collection.doc(id).update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    await collection.doc(id).delete();
  }

  static Nomina getEmpty() {
    return Nomina(
        employeeCode: '',
        date: DateTime.now(),
        grossSalary: 0.0,
        netSalary: 0.0,
        deductions: 0.0,
        employeeSocialSecurity: 0.0,
        employerSocialSecurity: 0.0,
        noSignedPath: '',
        noSignedDate: DateTime.now());
  }

  static Future<List<Nomina>> getNominas(
      {String? employeeCode, DateTime? beforeAt, DateTime? atfterAt}) async {
    // get from database
    beforeAt ??= DateTime.now().add(const Duration(days: 3650));
    atfterAt ??= DateTime.now().subtract(const Duration(days: 3650));
    List<Nomina> items = [];
    await collection
        .where('date', isGreaterThanOrEqualTo: atfterAt)
        .where('date', isLessThanOrEqualTo: beforeAt)
        .get()
        .then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        Nomina item = Nomina.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();
    });

    if (employeeCode != null) {
      items = items
          .where((element) => element.employeeCode == employeeCode)
          .toList();
    }

    items.sort((a, b) => a.noSignedDate.compareTo(b.noSignedDate));
    return items;
  }

  Future<String> noSignedFileUrl() async {
    final ref = FirebaseStorage.instance.ref().child(noSignedPath);
    return await ref.getDownloadURL();
  }

  Future<String> signedFileUrl() async {
    if (signedPath == null) return '';
    final ref = FirebaseStorage.instance.ref().child(signedPath!);
    return await ref.getDownloadURL();
  }

  static int compareNomina(
      Nomina a, Nomina b, int sortColumnIndex, int sortAsc) {
    return a.compareTo(b, sortColumnIndex: sortColumnIndex, sortAsc: sortAsc);
  }

  int compareTo(Nomina b, {int sortColumnIndex = 1, int sortAsc = 1}) {
    Nomina a = this;

    switch (sortColumnIndex) {
      case 0:
        return a.employeeCode.compareTo(b.employeeCode) * sortAsc;
      case 1:
        // order by firstName
        if (a.employee != null && b.employee != null) {
          String aSurnames = a.employee!.lastName1 + a.employee!.lastName2;
          String bSurnames = b.employee!.lastName1 + b.employee!.lastName2;

          return aSurnames.compareTo(bSurnames) * sortAsc;
        } else {
          return a.employeeCode.compareTo(b.employeeCode) * sortAsc;
        }
      case 2:
        // order by lastName1
        if (a.employee != null && b.employee != null) {
          return a.employee!.lastName1.compareTo(b.employee!.lastName1) *
              sortAsc;
        } else {
          return a.employeeCode.compareTo(b.employeeCode) * sortAsc;
        }
      case 3:
        return a.date.compareTo(b.date) * sortAsc;
      case 4:
        return a.netSalary.compareTo(b.netSalary) * sortAsc;
      case 5:
        return a.deductions.compareTo(b.deductions) * sortAsc;
      case 6:
        return a.employeeSocialSecurity.compareTo(b.employeeSocialSecurity) *
            sortAsc;
      case 7:
        return a.grossSalary.compareTo(b.grossSalary) * sortAsc;
      case 8:
        return a.employerSocialSecurity.compareTo(b.employerSocialSecurity) *
            sortAsc;
      case 9:
        return (a.grossSalary + a.employerSocialSecurity)
                .compareTo(b.grossSalary + b.employerSocialSecurity) *
            sortAsc;
      default:
        return 0;
    }
  }
}

class EmploymentPromotion {
  static final db = FirebaseFirestore.instance;
  static final collection = db.collection("s4c_employment_promotions");

  bool active;
  String uuid;
  String name;
  String description;

  EmploymentPromotion(
      {required this.uuid,
      required this.active,
      required this.name,
      required this.description});

  factory EmploymentPromotion.fromJson(Map<String, dynamic> json) {
    return EmploymentPromotion(
        uuid: json['uuid'],
        active: json['active'],
        name: json['name'],
        description: json['description']);
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'active': active,
        'name': name,
        'description': description
      };

  static EmploymentPromotion getEmpty() {
    return EmploymentPromotion(
        uuid: '', active: true, name: '', description: '');
  }

  static Future<List<EmploymentPromotion>> getAll() async {
    // get from database
    List<EmploymentPromotion> items = [];
    await collection.get().then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        EmploymentPromotion item = EmploymentPromotion.fromJson(e.data());
        return item;
      }).toList();
    });

    return items;
  }

  static Future<List<EmploymentPromotion>> getActive() async {
    // get from database
    List<EmploymentPromotion> items = [];
    await collection.where('active', isEqualTo: true).get().then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        EmploymentPromotion item = EmploymentPromotion.fromJson(e.data());
        return item;
      }).toList();
    });

    return items;
  }

  Future<EmploymentPromotion> save() async {
    if (uuid.isEmpty) {
      await collection.add(toJson()).then((value) => uuid = value.id);
    } else {
      await collection.doc(uuid).update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    await collection.doc(uuid).delete();
  }
}

class Alta {
  DateTime date;
  String? pathContract;
  String? pathAnnex;
  String? pathNDA;
  String? pathNIF;
  String? pathLOPD;
  String employmentPromotion = '';
  double salary = 0.0;

  Map<String, String>? pathOthers;

  Alta({
    required this.date,
    this.pathContract,
    this.pathAnnex,
    this.pathNDA,
    this.pathNIF,
    this.pathLOPD,
    this.pathOthers,
    this.employmentPromotion = '',
    this.salary = 0.0,
  });

  static Alta fromJson(Map<String, dynamic> json) {
    Alta item = Alta(
      date: getDate(json['date'] ?? DateTime.now()),
      pathContract: json['pathContract'],
      pathAnnex: json['pathAnnex'],
      pathNDA: json['pathNDA'],
      pathNIF: json['pathNIF'],
      pathLOPD: json['pathLOPD'],
      pathOthers: json['pathOthers'],
    );
    if (json.containsKey('employmentPromotion')) {
      item.employmentPromotion = json['employmentPromotion'];
    } else {
      item.employmentPromotion = '';
    }
    if (json.containsKey('salary')) {
      item.salary = json['salary'];
    } else {
      item.salary = 0.0;
    }
    return item;
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'pathContract': pathContract,
        'pathAnnex': pathAnnex,
        'pathNDA': pathNDA,
        'pathNIF': pathNIF,
        'pathLOPD': pathLOPD,
        'pathOthers': pathOthers,
        'salary': salary,
        'employmentPromotion': employmentPromotion == null
            ? ''
            : employmentPromotion!.isEmpty
                ? ''
                : employmentPromotion,
      };

  @override
  String toString() {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class Baja {
  DateTime date;
  String reason;
  bool extraDocument = false;
  String? pathFiniquito;
  String? pathExtraDoc;

  Baja({
    required this.date,
    required this.reason,
    this.pathFiniquito,
    this.extraDocument = false,
    this.pathExtraDoc,
  });

  static Baja fromJson(Map<String, dynamic> json) {
    return Baja(
      date: getDate(json['date'] ?? DateTime.now()),
      pathFiniquito: json['pathFiniquito'],
      reason: json.containsKey('reason') ? json['reason'] : '',
      extraDocument:
          json.containsKey('extraDocument') ? json['extraDocument'] : false,
      pathExtraDoc:
          json.containsKey('pathExtraDoc') ? json['pathExtraDoc'] : '',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'pathFiniquito': pathFiniquito,
        'reason': reason,
        'extraDocument': extraDocument,
        'pathExtraDoc': pathExtraDoc,
      };
  @override
  String toString() {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class BajaReason {
  static final db = FirebaseFirestore.instance;
  static final collection = db.collection("s4c_baja_reasons");

  String name;
  String? uuid;
  bool extraDocument = false;

  BajaReason({
    required this.name,
    this.uuid,
    this.extraDocument = false,
  });

  factory BajaReason.fromJson(Map<String, dynamic> json) {
    return BajaReason(
        name: json['name'],
        extraDocument: json['extraDocument'],
        uuid: json.containsKey('uuid') ? json['uuid'] : null);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'extraDocument': extraDocument,
        'uuid': uuid,
      };

  static BajaReason getEmpty() {
    return BajaReason(name: '');
  }

  static Future<List<BajaReason>> getAll() async {
    // get from database
    List<BajaReason> items = [];
    await collection.get().then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        BajaReason item = BajaReason.fromJson(e.data());
        item.uuid = e.id;
        return item;
      }).toList();
    });

    return items;
  }

  Future<BajaReason> save() async {
    if (uuid == null) {
      await collection.add(toJson()).then((value) => uuid = value.id);
    } else {
      await collection.doc(uuid).update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    await collection.doc(uuid).delete();
  }
}

class Employee {
  static final db = FirebaseFirestore.instance;
  static final collection = db.collection("s4c_employees");

  String? id;
  String code;
  String firstName;
  String lastName1;
  String lastName2;
  String email;
  String phone;
  String position;
  String category;
  String sex = 'O';
  DateTime? bornDate = DateTime(2000, 1, 1);
  List altas = [];
  List bajas = [];
  Map<String, dynamic> extraDocs = {};
  String? photoPath;

  Employee(
      {required this.code,
      required this.firstName,
      required this.lastName1,
      required this.lastName2,
      required this.email,
      required this.phone,
      required this.position,
      required this.category,
      this.altas = const [],
      this.bajas = const [],
      this.extraDocs = const {},
      this.photoPath,
      this.sex = 'O',
      this.bornDate});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      code: json['code'],
      firstName: json['firstName'],
      lastName1: json['lastName1'],
      lastName2: json['lastName2'],
      email: json['email'],
      phone: json['phone'],
      photoPath: json['photoPath'],
      sex: (json.containsKey('sex')) ? json['sex'] : 'O',
      bornDate: (json.containsKey('bornDate'))
          ? getDate(json['bornDate'])
          : truncDate(DateTime(2000, 1, 1)),
      category: (json.containsKey('category')) ? json['category'] : '',
      position: (json.containsKey('position')) ? json['position'] : '',
      altas: (json['altas'] == null) || (json['altas'].isEmpty)
          ? []
          : json['altas'].map((e) {
              try {
                return Alta.fromJson(e as Map<String, dynamic>);
              } catch (exception) {
                return Alta(
                  date: getDate(e),
                );
              }
            }).toList(),
      bajas: (json['bajas'] == null) || (json['bajas'].isEmpty)
          ? []
          : json['bajas'].map((e) {
              try {
                return Baja.fromJson(e as Map<String, dynamic>);
              } catch (exception) {
                return Baja(
                  date: getDate(e),
                  reason: '',
                );
              }
            }).toList(),
      extraDocs: (json['extraDocs'] == null) || (json['extraDocs'].isEmpty)
          ? {}
          : json['extraDocs'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'firstName': firstName,
        'lastName1': lastName1,
        'lastName2': lastName2,
        'email': email,
        'phone': phone,
        'photoPath': photoPath,
        'category': category,
        'position': position,
        'bornDate': bornDate,
        'altas': altas.map((e) => e.toJson()).toList(),
        'bajas': bajas.map((e) => e.toJson()).toList(),
        'extraDocs': extraDocs.isEmpty ? {} : extraDocs,
      };

  Future<String> getPhotoUrl() async {
    return await FirebaseStorage.instance.ref(photoPath!).getDownloadURL();
  }

  Future<void> setPhotoPath(String path) async {
    photoPath = path;
  }

  Future<void> removePhotoPath() async {
    photoPath = null;
  }

  Future<Employee> save() async {
    altas.sort((a, b) => a.date.compareTo(b.date));
    bajas.sort((a, b) => a.date.compareTo(b.date));
    if (id == null) {
      await collection.add(toJson()).then((value) => id = value.id);
    } else {
      await collection.doc(id).update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    await collection.doc(id).delete();
  }

  void updateDocument(dictDoc, newPath) {
    if (dictDoc != null) {
      if (dictDoc['type'] == "Alta") {
        if (dictDoc['desc'] == 'Contrato') {
          altas
              .firstWhere((element) => element.date == dictDoc['date'])
              .pathContract = newPath;
        } else if (dictDoc['desc'] == 'Anexo') {
          altas
              .firstWhere((element) => element.date == dictDoc['date'])
              .pathAnnex = newPath;
        } else if (dictDoc['desc'] == 'NDA') {
          altas
              .firstWhere((element) => element.date == dictDoc['date'])
              .pathNDA = newPath;
        } else if (dictDoc['desc'] == 'NIF') {
          altas
              .firstWhere((element) => element.date == dictDoc['date'])
              .pathNIF = newPath;
        } else if (dictDoc['desc'] == 'LOPD') {
          altas
              .firstWhere((element) => element.date == dictDoc['date'])
              .pathLOPD = newPath;
        } else {
          if (altas
                  .firstWhere((element) => element.date == dictDoc['date'])
                  .pathOthers ==
              null) {
            altas
                .firstWhere((element) => element.date == dictDoc['date'])
                .pathOthers = {};
          }
          altas
              .firstWhere((element) => element.date == dictDoc['date'])
              .pathOthers![dictDoc['desc']] = newPath;
        }
      }
    }
  }

  double getSalary([DateTime? date]) {
    if (altas.isEmpty) {
      return 0.0;
    }
    date ??= DateTime.now();
    altas.sort((a, b) => a.date.compareTo(b.date));
    try {
      Alta alta = altas.firstWhere((element) => element.date.isAfter(date));
      return alta.salary;
    } catch (e) {
      return altas.last.salary;
    }
  }

  int altaDays({DateTime? date}) {
    DateTime fromDate = getAltaDate();
    altas.sort((a, b) => a.date.compareTo(b.date));
    if (date == null) {
      date = DateTime.now();
      fromDate =
          altas.firstWhere((element) => element.date.isBefore(date)).date;
    }
    if (altas.isEmpty) {
      return 0;
    }
    return date.difference(truncDate(fromDate)).inDays;
  }

  static Employee getEmpty() {
    return Employee(
        code: '',
        firstName: '',
        lastName1: '',
        lastName2: '',
        email: '',
        phone: '',
        position: '',
        category: '',
        altas: [],
        bajas: [],
        extraDocs: {});
  }

  static Future<List<Employee>> getEmployees() async {
    // get from database
    List<Employee> items = [];
    await collection.get().then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        Employee item = Employee.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();
    });

    items.sort((a, b) => a.compareTo(b));

    return items;
  }

  Future<String> photoFileUrl() async {
    final ref = FirebaseStorage.instance.ref().child(photoPath!);
    return await ref.getDownloadURL();
  }

  int compareTo(Employee other) {
    // sort by lastName1, lastName2, firstName ignoring case

    if (lastName1.toLowerCase().compareTo(other.lastName1.toLowerCase()) == 0) {
      if (lastName2.toLowerCase().compareTo(other.lastName2.toLowerCase()) ==
          0) {
        return firstName.toLowerCase().compareTo(other.firstName.toLowerCase());
      } else {
        return lastName2.toLowerCase().compareTo(other.lastName2.toLowerCase());
      }
    }
    return lastName1.toLowerCase().compareTo(other.lastName1.toLowerCase());
  }

  DateTime getAltaDate() {
    if (altas.isEmpty) {
      altas.add(Alta(date: truncDate(DateTime.now())));
    }
    altas.sort((a, b) => a.date.compareTo(b.date));
    return altas.last.date;
  }

  DateTime getBajaDate() {
    if (bajas.isEmpty) {
      //return date in one year
      return DateTime.now().add(const Duration(days: 365));
    }
    bajas.sort(((a, b) => a.date.compareTo(b.date)));
    return bajas.last.date;
  }

  bool isActive() {
    return (altas.isNotEmpty &&
        (bajas.isEmpty ||
            (getAltaDate().isAfter(getBajaDate()) ||
                !getBajaDate().isBefore(DateTime.now()))));
  }

  String getFullName() {
    return '$firstName $lastName1 $lastName2';
  }
}
