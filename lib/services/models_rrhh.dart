import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/utils.dart';
// import 'package:flutter/material.dart';

// import 'package:uuid/uuid.dart';

class Nomina {
  static const String tbName = "s4c_nominas";

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
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(toJson())
          .then((value) => id = value.id);
    } else {
      await FirebaseFirestore.instance
          .collection(tbName)
          .doc(id)
          .update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
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
    await FirebaseFirestore.instance
        .collection(tbName)
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
  static const String tbName = "s4c_employment_promotions";

  bool active;
  int order;
  String uuid;
  String name;
  String description;

  EmploymentPromotion(
      {required this.uuid,
      required this.order,
      required this.active,
      required this.name,
      required this.description});

  factory EmploymentPromotion.fromJson(Map<String, dynamic> json) {
    return EmploymentPromotion(
        uuid: json['uuid'],
        order: json.containsKey('order') ? json['order'] : 1000,
        active: json['active'],
        name: json['name'],
        description: json['description']);
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'active': active,
        'order': order,
        'name': name,
        'description': description
      };

  static EmploymentPromotion getEmpty() {
    return EmploymentPromotion(
        uuid: '', active: true, name: '', description: '', order: 1000);
  }

  static Future<List<EmploymentPromotion>> getAll() async {
    // get from database
    List<EmploymentPromotion> items = [];
    await FirebaseFirestore.instance.collection(tbName).get().then((value) {
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
    await FirebaseFirestore.instance
        .collection(tbName)
        .where('active', isEqualTo: true)
        .get()
        .then((value) {
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
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(toJson())
          .then((value) => uuid = value.id);
    } else {
      await FirebaseFirestore.instance
          .collection(tbName)
          .doc(uuid)
          .update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(uuid).delete();
  }
}

class Salary {
  DateTime date;
  double amount;

  Salary({required this.date, required this.amount});

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
        date: getDate(json['date'] ?? DateTime.now()),
        amount: json['amount'] ?? 0.0);
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'amount': amount,
      };
}

class Alta {
  DateTime date;
  String? pathContract;
  String? pathAnnex;
  String? pathNDA;
  String? pathNIF;
  String? pathLOPD;
  String position = '';
  String category = '';
  String employmentPromotion = '';
  int annualPayments = 12;
  Baja? baja;
  List salary = [];

  Map<String, String>? pathOthers;

  Alta({
    required this.date,
    this.pathContract,
    this.pathAnnex,
    this.pathNDA,
    this.pathNIF,
    this.pathLOPD,
    this.pathOthers,
    this.employmentPromotion = 'Ninguna',
    this.position = '',
    this.category = '',
    this.annualPayments = 12,
  });

  static Alta fromJson(Map<String, dynamic> json) {
    Alta item = Alta(
      date: getDate(json['date']), // ?? DateTime.now()),
      pathContract: json['pathContract'],
      pathAnnex: json['pathAnnex'],
      pathNDA: json['pathNDA'],
      pathNIF: json['pathNIF'],
      pathLOPD: json['pathLOPD'],
      pathOthers: json['pathOthers'],
      position: json.containsKey('position') ? json['position'] : '',
      category: json.containsKey('category') ? json['category'] : '',
      annualPayments:
          json.containsKey('annualPayments') ? json['annualPayments'] : 12,
    );
    if (json.containsKey('baja')) {
      try {
        item.baja = Baja.fromJson(json['baja']);
      } catch (e) {
        item.baja = Baja.getEmpty();
      }
    } else {
      item.baja = Baja.getEmpty();
    }
    if (json.containsKey('employmentPromotion')) {
      item.employmentPromotion = json['employmentPromotion'];
    } else {
      item.employmentPromotion = '';
    }
    if (json.containsKey('salary')) {
      //check if salary is a list of objects or a double
      if (json['salary'] is double) {
        item.salary.add(Salary(date: item.date, amount: json['salary']));
      } else {
        if (json['salary'].isEmpty) {
          item.salary.add(Salary(date: item.date, amount: 0.0));
        }
        item.salary = json['salary'].map((e) {
          try {
            return Salary.fromJson(e);
          } catch (exception) {
            return Salary(date: getDate(json['date']), amount: 0.0);
          }
        }).toList();
      }
    } else {
      item.salary = [];
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
        'baja': baja?.toJson(),
        'salary': salary.map((e) => e.toJson()).toList(),
        'position': position,
        'category': category,
        'annualPayments': annualPayments,
        'employmentPromotion':
            employmentPromotion.isEmpty ? '' : employmentPromotion,
      };

  @override
  String toString() {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  double getFiniquito() {
    if (salary.isEmpty) {
      return 0.0;
    }
    salary.sort((a, b) => a.date.compareTo(b.date));
    //double grossSalary = salary.last.amount;
    //double dailyPayment = grossSalary / 365;

    return 0.0;
  }

  String setSalary(double salary) {
    if (this.salary.isEmpty) {
      this.salary.add(Salary(date: date, amount: salary));
      return DateFormat('dd/MM/yyyy').format(date);
    }
    this.salary.sort((a, b) => a.date.compareTo(b.date));
    this.salary.last.amount = salary;
    return DateFormat('dd/MM/yyyy').format(this.salary.last.date);
  }

  DateTime? bajaDate() {
    if (baja == null) {
      return DateTime(2099, 12, 31);
    }
    return baja!.date;
  }

  static Alta getEmpty() {
    Alta item = Alta(date: DateTime.now());
    item.baja = Baja.getEmpty();
    return item;
  }

  int altaDays() {
    if (baja == null) {
      return truncDate(DateTime.now()).difference(date).inDays + 1;
    }
    if (baja!.date.isAfter(DateTime.now())) {
      return truncDate(DateTime.now()).difference(date).inDays + 1;
    }
    return truncDate(baja!.date).difference(date).inDays + 1;
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
      reason: json.containsKey('reason') ? json['reason'] : 'Sin especificar',
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

  static Baja getEmpty() {
    return Baja(
        date: DateTime(2099, 12, 31),
        reason: 'Sin especificar',
        extraDocument: false);
  }
}

class BajaReason {
  static const String tbName = "s4c_baja_reasons";

  String name;
  String? uuid;
  bool extraDocument = false;
  int order;

  BajaReason({
    required this.name,
    this.uuid,
    this.extraDocument = false,
    this.order = 1000,
  });

  factory BajaReason.fromJson(Map<String, dynamic> json) {
    return BajaReason(
        name: json['name'],
        extraDocument: json['extraDocument'],
        order: json.containsKey('order') ? json['order'] : 1000,
        uuid: json.containsKey('uuid') ? json['uuid'] : null);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'extraDocument': extraDocument,
        'order': order,
        'uuid': uuid,
      };

  static BajaReason getEmpty() {
    return BajaReason(name: '');
  }

  static Future<List<BajaReason>> getAll() async {
    // get from database
    List<BajaReason> items = [];
    await FirebaseFirestore.instance.collection(tbName).get().then((value) {
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
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(toJson())
          .then((value) {
        uuid = value.id;
        FirebaseFirestore.instance
            .collection(tbName)
            .doc(uuid)
            .update({'uuid': uuid});
      });
    } else {
      await FirebaseFirestore.instance
          .collection(tbName)
          .doc(uuid)
          .update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(uuid).delete();
  }
}

class Employee {
  static const String tbName = "s4c_employees";

  String? id;
  String code;
  String firstName;
  String lastName1;
  String lastName2;
  String email;
  String phone;
  // String position;
  // String category;
  String sex = 'O';
  String bankAccount = '';
  DateTime? bornDate = DateTime(2000, 1, 1);
  String? organization;
  List altas = [];
  // List bajas = [];
  Map<String, dynamic> extraDocs = {};
  String? photoPath;

  Employee(
      {required this.code,
      required this.firstName,
      required this.lastName1,
      required this.lastName2,
      required this.email,
      required this.phone,
      required this.organization,
      this.bankAccount = '',
      this.altas = const [],
      this.extraDocs = const {},
      this.photoPath,
      this.sex = 'O',
      this.bornDate});

  @override
  String toString() {
    return '$firstName $lastName1 $lastName2 ($code), $email';
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      code: json['code'],
      firstName: json['firstName'],
      lastName1: json['lastName1'],
      lastName2: json['lastName2'],
      email: json['email'],
      phone: json['phone'],
      photoPath: json['photoPath'],
      organization:
          (json.containsKey('organization')) ? json['organization'] : null,
      sex: (json.containsKey('sex')) ? json['sex'] : 'O',
      bornDate: (json.containsKey('bornDate'))
          ? getDate(json['bornDate'],
              truncate: true, defaultValue: DateTime(2000, 1, 1))
          : truncDate(DateTime(2000, 1, 1)),
      bankAccount: (json.containsKey('bankAccount')) ? json['bankAccount'] : '',
      altas: (json['altas'] == null) || (json['altas'].isEmpty)
          ? []
          : json['altas'].map((e) {
              try {
                return Alta.fromJson(e as Map<String, dynamic>);
              } catch (exception) {
                Alta alta = Alta(
                  date: getDate(e),
                );
                alta.baja = Baja.getEmpty();
                return alta;
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
        'sex': sex,
        'organization': organization,
        'phone': phone,
        'photoPath': photoPath,
        'bornDate': getDate(bornDate,
            truncate: true, defaultValue: DateTime(2000, 1, 1)),
        'altas': altas.map((e) => e.toJson()).toList(),
        'extraDocs': extraDocs.isEmpty ? {} : extraDocs,
        'bankAccount': bankAccount,
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

  DateTime getBornDate() {
    return bornDate ?? DateTime(1924, 1, 1);
  }

  Future<Employee> save() async {
    altas.sort((a, b) => a.date.compareTo(b.date));
    // bajas.sort((a, b) => a.date.compareTo(b.date));
    if (id == null) {
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(toJson())
          .then((value) => id = value.id);
    } else {
      await FirebaseFirestore.instance
          .collection(tbName)
          .doc(id)
          .update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
  }

  String getPosition() {
    if (altas.isEmpty) {
      return '';
    }
    altas.sort((a, b) => a.date.compareTo(b.date));
    return altas.last.position;
  }

  void setPosition(String position) {
    if (altas.isNotEmpty) {
      altas.sort((a, b) => a.date.compareTo(b.date));
      altas.last.position = position;
    }
  }

  String getCategory() {
    if (altas.isEmpty) {
      return '';
    }
    altas.sort((a, b) => a.date.compareTo(b.date));
    return altas.last.category;
  }

  void setCategory(String category) {
    if (altas.isNotEmpty) {
      altas.sort((a, b) => a.date.compareTo(b.date));
      altas.last.category = category;
    }
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

  double getSalary([DateTime? date, verbose = false]) {
    if (altas.isEmpty) {
      return 0.0;
    }
    date ??= DateTime.now();
    altas.sort((a, b) => b.date.compareTo(a.date));
    // if (verbose) {
    //   for (var alta in altas) {
    //     print('Alta: ${alta.date}, Salary: ${alta.salary}');
    //   }
    // }
    try {
      Alta curentAlta =
          altas.firstWhere((element) => element.date.isBefore(date));
      curentAlta.salary.sort((a, b) => a.date.compareTo(b.date));
      return curentAlta.salary.last.amount;
    } catch (e) {
      return 0.0;
    }
  }

  int altaDays({DateTime? date}) {
    DateTime fromDate = getAltaDate();
    altas.sort((a, b) => b.date.compareTo(a.date));
    if (date == null) {
      date = DateTime.now();
      fromDate =
          altas.firstWhere((element) => element.date.isBefore(date)).date;
    }
    if (altas.isEmpty) {
      return 0;
    }
    return date.difference(truncDate(fromDate)).inDays + 1;
  }

  static Employee getEmpty({name = ''}) {
    return Employee(
        code: '',
        firstName: '',
        lastName1: '',
        lastName2: '',
        email: '',
        phone: '',
        organization: null,
        // position: '',
        // category: '',
        altas: [Alta.getEmpty()],
        // bajas: [],
        extraDocs: {});
  }

  static Future<Employee> byCode(String code) async {
    // get from database
    Employee item = Employee.getEmpty();
    await FirebaseFirestore.instance
        .collection(tbName)
        .where('code', isEqualTo: code)
        .get()
        .then((value) {
      if (value.docs.isEmpty) return Employee.getEmpty();
      item = Employee.fromJson(value.docs.first.data());
      item.id = value.docs.first.id;
    });

    return item;
  }

  static Future<Employee> byEmail(String email) async {
    // get from database
    Employee item = Employee.getEmpty();
    item.email = email;
    item.firstName = email;
    await FirebaseFirestore.instance
        .collection(tbName)
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      if (value.docs.isEmpty) return Employee.getEmpty();
      item = Employee.fromJson(value.docs.first.data());
      item.id = value.docs.first.id;
    });

    return item;
  }

  static Future<List<Employee>> getAll() async {
    // get from database
    return await getEmployees();
  }

  static Future<List<Employee>> getEmployees(
      {Organization? organization}) async {
    // get from database
    List<Employee> items = [];
    if (organization != null) {
      await FirebaseFirestore.instance
          .collection(tbName)
          .where('organization', isEqualTo: organization.id)
          .get()
          .then((value) {
        if (value.docs.isEmpty) return [];
        items = value.docs.map((e) {
          Employee item = Employee.fromJson(e.data());
          item.id = e.id;
          return item;
        }).toList();
      });
    }

    if (items.isEmpty) {
      await FirebaseFirestore.instance.collection(tbName).get().then((value) {
        if (value.docs.isEmpty) return [];
        items = value.docs.map((e) {
          Employee item = Employee.fromJson(e.data());
          if (!e.data().containsKey('organization')) {
            item.organization = null;
          }
          item.id = e.id;
          return item;
        }).toList();
      });
      if (organization != null) {
        items = items
            .where((element) => ((element.organization == organization.id) ||
                (element.organization == null)))
            .toList();
      }
    }
    return items;
  }

  static Future<Employee> byId(String id) async {
    // get from database
    Employee item = Employee.getEmpty();
    await FirebaseFirestore.instance
        .collection(tbName)
        .doc(id)
        .get()
        .then((value) {
      if (!value.exists) return Employee.getEmpty();
      item = Employee.fromJson(value.data()!);
      item.id = value.id;
    });

    return item;
  }

  Future<String> photoFileUrl() async {
    final ref = FirebaseStorage.instance.ref().child(photoPath!);
    return await ref.getDownloadURL();
  }

  Future<List<Employee>> getSubordinates() async {
    id ??= '';
    if (id!.isEmpty) return [];
    List<Employee> items = [];
    List<Department> departments =
        await Department.getDepartmentsByManager(id!);
    if (departments.isEmpty) return [];
    List<Department> parentDepartments = [];
    for (Department department in departments) {
      String? curentParentId = department.parent;
      while (curentParentId != null && curentParentId.isNotEmpty) {
        Department? parentDepartment = await Department.byId(curentParentId);
        if (parentDepartment.id == null || parentDepartment.id!.isEmpty) {
          break;
        }
        parentDepartments.add(parentDepartment);
        curentParentId = parentDepartment.parent;
      }
    }
    departments.addAll(parentDepartments);
    return items;

    List<String> employeeIds = [];
    for (Department department in departments) {
      if (department.employees.isEmpty) continue;
      employeeIds.addAll(department.employees);
    }

    await FirebaseFirestore.instance
        .collection(tbName)
        .where(FieldPath.documentId, whereIn: employeeIds)
        .get()
        .then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        Employee item = Employee.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();
    });
    print("Subordinates count: ${items.length}");
    return items;
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
    if (altas.isEmpty) {
      return DateTime(2099, 12, 31);
    }
    altas.sort((a, b) => a.date.compareTo(b.date));
    try {
      return altas.last.bajaDate();
    } catch (e) {
      return DateTime(2099, 12, 31);
    }
    // if (bajas.isEmpty) {
    //   //return date in one year
    //   return DateTime.now().add(const Duration(days: 365));
    // }
    // bajas.sort(((a, b) => a.date.compareTo(b.date)));
    // return bajas.last.date;
  }

  Alta getCurrentAlta() {
    altas.sort((a, b) => a.date.compareTo(b.date));
    if (altas.isEmpty) {
      return Alta(date: truncDate(DateTime.now()));
    }
    return altas.last;
  }

  Baja getBaja() {
    altas.sort((a, b) => a.date.compareTo(b.date));
    if (altas.isEmpty) {
      return Baja.getEmpty();
    }
    return altas.last.baja ?? Baja(date: DateTime(2099, 12, 31), reason: '');
  }

  bool isActive() {
    return (altas.isNotEmpty &&
        (getBajaDate().isAfter(DateTime.now()) ||
            getBajaDate().isAtSameMomentAs(DateTime.now())));
  }

  String getFullName() {
    return '$firstName $lastName1 $lastName2';
  }
}

class Department {
  static const String tbName = 's4c_departments';

  String? id;
  String name;
  String? parent;
  String? manager;
  List<String> employees = [];
  String? organization;

  Department(
      {required this.name,
      this.parent,
      this.manager,
      required this.employees,
      required this.organization});

  static Department fromJson(Map<String, dynamic> json) {
    if (json.containsKey('manager')) {
      if (json['manager'] is String) {
        if (json['manager'].isEmpty) {
          json['manager'] = null;
        }
      } else if (json['manager'] is Map<String, dynamic>) {
        if (json['manager'].containsKey('id')) {
          json['manager'] = json['manager']['id'];
        } else {
          json['manager'] = null;
        }
      }
    } else {
      json['manager'] = null;
    }

    Department item = Department(
        name: json['name'],
        parent: (json.containsKey('parent')) ? json['parent'] : null,
        manager: (json.containsKey('manager')) ? json['manager'] : null,
        employees: (json.containsKey('employees'))
            ? List<String>.from(json['employees'])
            : [],
        organization:
            (json.containsKey('organization')) ? json['organization'] : null);
    if (json.containsKey('id')) {
      item.id = (json['id'] == null) ? '' : json['id'];
    } else {
      item.id = '';
    }

    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parent': parent,
        'manager': manager,
        'employees': employees,
        'organization': organization
      };

  Future<Department> save() async {
    parent ??= null;
    if ((id == null) || (id == '')) {
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(toJson())
          .then((value) {
        id = value.id;
        save();
      });
    } else {
      await FirebaseFirestore.instance
          .collection(tbName)
          .doc(id)
          .update(toJson());
    }
    return this;
  }

  Future<void> delete() async {
    List<Department> childrens = await Department.getDepartmentsByParent(id!);
    if (childrens.isNotEmpty) {
      for (var child in childrens) {
        child.parent = parent;
        await child.save();
      }
    }
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
  }

  Future<String> getLabel() async {
    String label = name.toUpperCase();
    Employee managerObj = await Employee.byId(manager ?? '');
    if (manager != null) {
      label +=
          ', supervisor: ${managerObj.getFullName()}, employees (${employees.length})';
    }
    if (employees.isNotEmpty) {
      label += ', employees (${employees.length}): ';
      // Print the frist 5 employees names and if more than 5, add the text 'and more'
      for (int i = 0; i < employees.length && i < 5; i++) {
        Employee employeeObj = await Employee.byId(employees[i]);
        label += employeeObj.getFullName();
        if (i < employees.length - 1) {
          label += ', ';
        }
      }
      if (employees.length > 5) {
        label += ' and more';
      }
    } else {
      label += ', no employees';
    }

    return label;
  }

  static Department getEmpty() {
    return Department(
        name: '', employees: [], parent: null, organization: null);
  }

  static Future<List<Department>> getDepartments(
      {Organization? organization}) async {
    // get from database
    List<Department> items = [];

    try {
      if (organization != null) {
        await FirebaseFirestore.instance
            .collection(tbName)
            .where('organization', isEqualTo: organization.id)
            .get()
            .then((value) {
          if (value.docs.isEmpty) return [];
          items = value.docs.map((e) {
            Department item = Department.fromJson(e.data());
            item.id = e.id;
            return item;
          }).toList();
        });
      } else {
        await FirebaseFirestore.instance.collection(tbName).get().then((value) {
          if (value.docs.isEmpty) return [];
          items = value.docs.map((e) {
            Department item = Department.fromJson(e.data());
            item.id = e.id;
            return item;
          }).toList();
        });
      }
    } catch (e) {
      // print('Error getting departments: $e');
    }
    return items;
  }

  static Future<List<Department>> getDepartmentsByEmployee(
      String employeeCode) async {
    // get from database
    List<Department> items = [];
    await FirebaseFirestore.instance.collection(tbName).get().then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        Department item = Department.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();
    });

    items = items
        .where((element) => element.employees.contains(employeeCode))
        .toList();

    items.sort((a, b) => a.name.compareTo(b.name));

    return items;
  }

  static Future<List<Department>> getDepartmentsByParent(String parent) async {
    // get from database
    List<Department> items = [];

    await FirebaseFirestore.instance
        .collection(tbName)
        .where('parent', isEqualTo: parent)
        .get()
        .then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        Department item = Department.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();
    });

    items.sort((a, b) => a.name.compareTo(b.name));

    return items;
  }

  static Future<Department> byId(String id) async {
    // get from database
    Department item = Department.getEmpty();
    await FirebaseFirestore.instance
        .collection(tbName)
        .doc(id)
        .get()
        .then((value) {
      if (!value.exists) return Department.getEmpty();
      item = Department.fromJson(value.data()!);
      item.id = value.id;
    });

    return item;
  }

  static Future<List<Department>> getDepartmentsByManager(
      String manager) async {
    // get from database
    List<Department> items = [];
    await FirebaseFirestore.instance
        .collection(tbName)
        .where('manager', isEqualTo: manager)
        .get()
        .then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        Department item = Department.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();
    });

    items.sort((a, b) => a.name.compareTo(b.name));

    return items;
  }
}
