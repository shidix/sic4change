import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:googleapis/photoslibrary/v1.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/utils.dart';

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

  String noSignedPath;
  DateTime noSignedDate;
  String? signedPath;
  DateTime? signedDate;

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
        noSignedPath: json['noSignedPath'],
        noSignedDate: getDate(json['noSignedDate'] ?? DateTime.now()),
        signedPath: json['signedPath'],
        signedDate: getDate(json['signedDate'] ?? DateTime.now()));
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'employeeCode': employeeCode,
        'grossSalary': grossSalary,
        'netSalary': netSalary,
        'deductions': deductions,
        'employeeSocialSecurity': employeeSocialSecurity,
        'employerSocialSecurity': employerSocialSecurity,
        'noSignedPath': noSignedPath,
        'noSignedDate': noSignedDate,
        'signedPath': signedPath,
        'signedDate': signedDate
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
        return a.date.compareTo(b.date) * sortAsc;
      case 2:
        return a.netSalary.compareTo(b.netSalary) * sortAsc;
      case 3:
        return a.deductions.compareTo(b.deductions) * sortAsc;
      case 4:
        return a.employeeSocialSecurity.compareTo(b.employeeSocialSecurity) *
            sortAsc;
      case 5:
        return a.grossSalary.compareTo(b.grossSalary) * sortAsc;
      case 6:
        return a.employerSocialSecurity.compareTo(b.employerSocialSecurity) *
            sortAsc;
      case 7:
        return (a.grossSalary + a.employerSocialSecurity)
                .compareTo(b.grossSalary + b.employerSocialSecurity) *
            sortAsc;
      default:
        return 0;
    }
  }
}

class Alta {
  DateTime date;
  String? pathContract;
  String? pathAnnex;
  String? pathNDA;
  String? pathNIF;
  String? pathLOPD;
  Map<String, String>? pathOthers;

  Alta(
      {required this.date,
      this.pathContract,
      this.pathAnnex,
      this.pathNDA,
      this.pathNIF,
      this.pathLOPD,
      this.pathOthers});

  factory Alta.fromJson(Map<String, dynamic> json) {
    return Alta(
        date: getDate(json['date'] ?? DateTime.now()),
        pathContract: json['pathContract'],
        pathAnnex: json['pathAnnex'],
        pathNDA: json['pathNDA'],
        pathNIF: json['pathNIF'],
        pathLOPD: json['pathLOPD'],
        pathOthers: json['pathOthers']);
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'pathContract': pathContract,
        'pathAnnex': pathAnnex,
        'pathNDA': pathNDA,
        'pathNIF': pathNIF,
        'pathLOPD': pathLOPD,
        'pathOthers': pathOthers
      };

  @override
  String toString() {
    return DateFormat('dd/MM/yyyy').format(date);
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
  List altas = [];
  List bajas = [];
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
      this.photoPath});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      code: json['code'],
      firstName: json['firstName'],
      lastName1: json['lastName1'],
      lastName2: json['lastName2'],
      email: json['email'],
      phone: json['phone'],
      photoPath: json['photoPath'],
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
          : json['bajas'].map((e) => getDate(e)).toList(),
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
        'altas': altas.map((e) => e.toJson()).toList(),
        'bajas': bajas.map((e) => e).toList(),
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
    altas.sort();
    bajas.sort();
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
        bajas: []);
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
    bajas.sort();
    return bajas.last;
  }

  bool isActive() {
    return (altas.isNotEmpty &&
        (bajas.isEmpty ||
            (getAltaDate().isAfter(getBajaDate()) ||
                !getBajaDate().isBefore(DateTime.now()))));
  }
}
