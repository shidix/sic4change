import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
// import 'package:flutter/material.dart';

// import 'package:uuid/uuid.dart';

const double defaultHours = 8.0;

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

class Shift {
  DateTime date;
  List<double> hours;

  Shift({required this.date, required this.hours});

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
        date: getDate(json['date'] ?? DateTime.now()),
        hours: (json['hours'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            []);
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'hours': hours,
      };

  factory Shift.getEmpty({DateTime? date}) {
    return Shift(date: truncDate(date ?? DateTime.now()), hours: [
      defaultHours,
      defaultHours,
      defaultHours,
      defaultHours,
      defaultHours,
      0,
      0
    ]);
  }

  bool isWorkingDay(DateTime date) {
    int weekday = date.weekday; // 1 = Monday, 7 = Sunday
    if (hours.length < weekday) {
      return false;
    }
    return hours[weekday - 1] > 0;
  }
}

class Employee {
  static const String tbName = "s4c_employees";
  DocumentReference? docRef;

  String? id = '';
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
  String affiliation = '';
  DateTime? bornDate = DateTime(2000, 1, 1);
  String? organization;
  Workplace workplace = Workplace.getEmpty();
  List altas = [];
  List shift = [];
  // List bajas = [];
  Map<String, dynamic> extraDocs = {};
  String? photoPath;
  Function? onChanged;

  Employee(
      {required this.code,
      required this.firstName,
      required this.lastName1,
      required this.lastName2,
      required this.email,
      required this.phone,
      required this.organization,
      this.affiliation = '',
      this.bankAccount = '',
      this.shift = const [],
      this.altas = const [],
      this.extraDocs = const {},
      this.photoPath,
      this.sex = 'O',
      this.bornDate,
      this.onChanged});

  @override
  String toString() {
    return '$firstName $lastName1 $lastName2 ($code), $email';
  }

  String aka() {
    String fullName = getFullName().toUpperCase();
    List<String> parts = fullName.split(' ');
    // return firts character of each part => 'Daniel Jacobo Diaz Gonzalez' => 'DJDG'
    try {
      return parts.map((part) => part[0]).join('');
    } catch (e) {
      // If there is an error, return the first three letters of the first name
      return email.split('@')[0];
    }
  }

  // static Future<Employee> fromJson(Map<String, dynamic> json) async {
  static Future<Employee> fromJson(DocumentReference doc) async {
    var query = await doc.get();
    Map<String, dynamic> json = query.data() as Map<String, dynamic>;

    Employee item = Employee(
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
      affiliation: (json.containsKey('affiliation'))
          ? json['affiliation']
          : '', // Aseguradora o mutua
      shift: (!json.containsKey('shift')) ||
              (json['shift'] == null) ||
              (json['shift'].isEmpty)
          ? []
          : json['shift'].map((e) {
              try {
                return Shift.fromJson(e as Map<String, dynamic>);
              } catch (exception) {
                return Shift(date: truncDate(DateTime.now()), hours: []);
              }
            }).toList(),
    );
    item.id = json.containsKey('id') ? json['id'] : null;
    item.workplace = (json.containsKey('workplace'))
        ? await Workplace.byId(json['workplace'])
        : Workplace.getEmpty();

    item.docRef ??= doc;
    if (item.docRef != null) {
      item.docRef!.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          var json = data;
          // Update fields
          item.code = data['code'];
          item.firstName = data['firstName'];
          item.lastName1 = data['lastName1'];
          item.lastName2 = data['lastName2'];
          item.email = data['email'];
          item.phone = data['phone'];
          item.photoPath = data['photoPath'];
          item.organization = data['organization'];
          item.sex = data['sex'];
          item.bornDate = getDate(data['bornDate']);
          item.bankAccount = data['bankAccount'];
          item.altas = (json['altas'] == null) || (json['altas'].isEmpty)
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
                }).toList();
          item.extraDocs = data['extraDocs'];
          item.affiliation = data['affiliation'];

          item.shift = (!data.containsKey('shift')) ||
                  (data['shift'] == null) ||
                  (data['shift'].isEmpty)
              ? []
              : data['shift'].map((e) {
                  try {
                    return Shift.fromJson(e as Map<String, dynamic>);
                  } catch (exception) {
                    return Shift(date: truncDate(DateTime.now()), hours: []);
                  }
                }).toList();

          (json.containsKey('workplace'))
              ? Workplace.byId(json['workplace']).then((value) {
                  item.workplace = value;
                })
              : Workplace.getEmpty();
        }
        item.onChanged?.call();
      });
    }

    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
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
        'affiliation': affiliation, // Aseguradora o mutua
        'shift': shift.map((e) => e.toJson()).toList(),
        'workplace': workplace.id,
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

  Shift getShift({DateTime? date}) {
    if (shift.isEmpty) {
      shift.add(Shift(date: truncDate(DateTime.now()), hours: [
        defaultHours,
        defaultHours,
        defaultHours,
        defaultHours,
        defaultHours,
        0,
        0
      ]));
      save();
      return shift.first;
    }
    date ??= DateTime.now();
    shift.sort((a, b) => b.date.compareTo(a.date)); // latest first
    try {
      return shift.firstWhere((element) => element.date.isBefore(date!));
    } catch (e) {
      return Shift.getEmpty(date: date);
    }
  }

  void setShift(Shift newShift) {
    try {
      Shift existingShift = shift.firstWhere(
          (element) => truncDate(element.date) == truncDate(newShift.date));
      existingShift.hours = newShift.hours;
    } catch (e) {
      shift.add(newShift);
    }
    shift.sort((a, b) => b.date.compareTo(a.date)); // latest first
    save();
  }

  void removeShift(DateTime date) {
    shift.removeWhere((element) => truncDate(element.date) == truncDate(date));
    save();
  }

  // Future<Employee> save() async {
  //   altas.sort((a, b) => a.date.compareTo(b.date));
  //   // bajas.sort((a, b) => a.date.compareTo(b.date));
  //   if (id == null) {
  //     await FirebaseFirestore.instance
  //         .collection(tbName)
  //         .add(toJson())
  //         .then((value) => id = value.id);
  //     FirebaseFirestore.instance.collection(tbName).doc(id).set(toJson());
  //   } else {
  //     await FirebaseFirestore.instance
  //         .collection(tbName)
  //         .doc(id)
  //         .update(toJson());
  //   }
  //   return this;
  // }
  void save() async {
    altas.sort((a, b) => a.date.compareTo(b.date));
    // bajas.sort((a, b) => a.date.compareTo(b.date));
    if (id == null || id!.isEmpty) {
      var item =
          await FirebaseFirestore.instance.collection(tbName).add(toJson());
      id = item.id;
      item.update({'id': id});
      // FirebaseFirestore.instance.collection(tbName).add(toJson()).then((value) {
      //   id = value.id;
      //   FirebaseFirestore.instance
      //       .collection(tbName)
      //       .doc(id)
      //       .update({'id': id});
      // });
    } else {
      await FirebaseFirestore.instance
          .collection(tbName)
          .doc(id)
          .update(toJson());
    }
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
      return '0';
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
    final data = await FirebaseFirestore.instance
        .collection(tbName)
        .where('code', isEqualTo: code)
        .get();

    if (data.docs.isNotEmpty) {
      item = await Employee.fromJson(data.docs.first.reference);
    }

    // await FirebaseFirestore.instance
    //     .collection(tbName)
    //     .where('code', isEqualTo: code)
    //     .get()
    //     .then((value) {
    //   if (value.docs.isEmpty) return Employee.getEmpty();
    //   item = Employee.fromJson(value.docs.first.data());
    //   item.id = value.docs.first.id;
    // });

    return item;
  }

  static Future<Employee> byEmail(String email) async {
    // get from database
    if (email.isEmpty) return Employee.getEmpty();
    Employee item = Employee.getEmpty();
    final data = await FirebaseFirestore.instance
        .collection(tbName)
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty) {
      item = await Employee.fromJson(data.docs.first.reference);
    } else {
      item.email = email;
    }

    return item;
  }

  static Future<List<Employee>> getAll() async {
    // get from database
    return await getEmployees();
  }

  static Future<List<Employee>> getEmployees(
      {dynamic organization, bool includeInactive = false}) async {
    // get from database
    String organizationId = '';

    if (organization is Organization) {
      organizationId = organization.id;
    }
    List<Employee> items = [];
    QuerySnapshot<Map<String, dynamic>>? data;
    if (organizationId.isNotEmpty) {
      data = await FirebaseFirestore.instance
          .collection(tbName)
          .where('organization', isEqualTo: organizationId)
          .get();
      if (data.docs.isEmpty) {
        data = await FirebaseFirestore.instance.collection(tbName).get();
      }
    } else {
      data = await FirebaseFirestore.instance.collection(tbName).get();
    }

    if (data.docs.isNotEmpty) {
      for (var doc in data.docs) {
        Employee item = await Employee.fromJson(doc.reference);

        if (!doc.data().containsKey('organization')) {
          item.organization = organizationId;
        }
        item.id = doc.id;

        items.add(item);
      }

      if (organizationId.isNotEmpty) {
        items = items
            .where((element) => ((element.organization == organizationId) ||
                (element.organization == null)))
            .toList();
      }
    }

    if (!includeInactive) {
      items = items.where((element) => element.isActive()).toList();
    }
    return items;
  }

  bool inDepartment(dynamic departments) {
    if (departments is Department) {
      departments = [departments];
    }
    return departments.any((element) => element.employees.contains(id));
  }

  static Future<dynamic> byId(dynamic id) async {
    QuerySnapshot<Map<String, dynamic>>? snapshot;
    List<Employee> items = [];
    // get from database
    if (id is String) {
      snapshot = await FirebaseFirestore.instance
          .collection(tbName)
          .where(FieldPath.documentId, isEqualTo: id)
          .get();

      if (snapshot.docs.isEmpty) {
        return Employee.getEmpty();
      }

      Employee item = await Employee.fromJson(snapshot.docs.first.reference);
      item.id = snapshot.docs.first.id;
      // final docRef = FirebaseFirestore.instance.collection(tbName).doc(item.id);
      // docRef.update({'id': item.id});
      // docRef.snapshots().listen((event) {
      //   if (event.exists) {
      //     // print('Document data: ${event.data()}');
      //     // Update item with new data
      //     Employee.fromJson(event.data()!).then((value) {
      //       item = value;
      //       item.id = event.id;
      //     });
      //   } else {
      //     // print('Document does not exist on the database');
      //   }
      // });
      return item;
    } else if (id is List<String>) {
      // If list is longer than 25, split in chunks of 25
      int itemsByChunk = 25;

      if (id.length > itemsByChunk) {
        List<List<String>> chunks = [];
        for (var i = 0; i < id.length; i += itemsByChunk) {
          int end =
              (i + itemsByChunk < id.length) ? i + itemsByChunk : id.length;
          chunks.add(id.sublist(i, end));
        }
        for (var chunk in chunks) {
          var chunkSnapshot = await FirebaseFirestore.instance
              .collection(tbName)
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          if (chunkSnapshot.docs.isNotEmpty) {
            for (var doc in chunkSnapshot.docs) {
              Employee item = await Employee.fromJson(doc.reference);
              item.id = doc.id;
              items.add(item);
            }
          }
        }
        return items;
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection(tbName)
            .where(FieldPath.documentId, whereIn: id)
            .get();
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            Employee item = await Employee.fromJson(doc.reference);
            item.id = doc.id;
            items.add(item);
          }
        }
        return items;
      }
    } else {
      return Employee.getEmpty();
    }

    // if (snapshot.docs.isEmpty) {
    //   return Employee.getEmpty();
    // } else if (id is String) {
    //   Employee item = await Employee.fromJson(snapshot.docs.first.data());
    //   item.id = snapshot.docs.first.id;
    //   return item;
    // } else if (id is List<String>) {
    //   // items = snapshot.docs.map((e) {
    //   //   Employee item = Employee.fromJson(e.data());
    //   //   item.id = e.id;
    //   //   return item;
    //   // }).toList();
    //   for (var doc in snapshot.docs) {
    //     Employee item = await Employee.fromJson(doc.data());
    //     item.id = doc.id;
    //     items.add(item);
    //   }
    //   return items;
    // }
  }

  Future<String> photoFileUrl() async {
    final ref = FirebaseStorage.instance.ref().child(photoPath!);
    return await ref.getDownloadURL();
  }

  Future<List<Employee>> getManagers({Organization? organization}) async {
    id ??= '';
    if (id!.isEmpty) return [];
    List<dynamic> items = [];

    List<Department> departments =
        await Department.getDepartments(organization: organization);
    if (departments.isEmpty) return [];
    Queue<Department> queue = Queue<Department>();
    queue
        .addAll(departments.where((element) => element.employees.contains(id)));

    while (queue.isNotEmpty) {
      Department department = queue.removeFirst();
      items.add(department.manager!);
      if (department.parent != null) {
        queue.addAll(
            departments.where((element) => element.id == department.parent));
      }
    }

    items = items
        .where((element) =>
            (element != id) && (element != null) && (element != ''))
        .toList();

    if (items.isEmpty) return [];

    List<Employee> employees = await Employee.byId(
        items.map((e) => e.toString()).toList().toSet().toList());
    // Remove employees that are not active or organization is different
    employees = employees.where((element) => element.isActive()).toList();
    if (organization != null) {
      employees = employees
          .where((element) => (element.organization == organization.id))
          .toList();
    }
    return employees;
  }

  Future<List<Employee>> getSuperiors({dynamic org}) async {
    id ??= '';
    if (id!.isEmpty) return [];
    org ??= organization;

    String organizationId = '';
    if (org is Organization) {
      organizationId = org.id;
    }

    List<dynamic> items = [];
    List<Department> departments =
        await Department.getDepartments(organization: organizationId);
    if (departments.isEmpty) return [];
    Queue<Department> queue = Queue<Department>();
    queue
        .addAll(departments.where((element) => element.employees.contains(id)));
    while (queue.isNotEmpty) {
      Department department = queue.removeFirst();
      items.add(department.manager!);
      if (department.parent != null) {
        queue.addAll(
            departments.where((element) => element.id == department.parent));
      }
    }
    items = items
        .where((element) =>
            (element != id) && (element != null) && (element != ''))
        .toList();

    // Recovery profiles with mainRole = RRHH
    List<Profile> allProfiles =
        await Profile.byOrganization(organization: organizationId);
    List<String> emailsProfiles = allProfiles
        .where((element) => element.mainRole == Profile.RRHH)
        .map((e) => e.email)
        .toList();
    List<Employee> allEmployees = await Employee.getEmployees(
        organization: organization, includeInactive: false);
    // Filter employees with email in emailsProfiles
    List<Employee> rrhhEmployees = allEmployees
        .where((element) => emailsProfiles.contains(element.email))
        .toList();
    List<String> rrhhIds = rrhhEmployees.map((e) => e.id!).toList();
    items.addAll(rrhhIds);
    items = items.toSet().toList();
    if (items.isEmpty) return [];

    // Filter allEmployees with id in items
    List<Employee> employees =
        allEmployees.where((element) => items.contains(element.id)).toList();
    // Remove employees that are not active or organization is different
    employees = employees.where((element) => element.isActive()).toList();
    if (organizationId.isNotEmpty) {
      employees = employees
          .where((element) => (element.organization == organizationId))
          .toList();
    }
    // Remove myself from the list
    employees = employees.where((element) => element.id != id).toList();

    return employees;
  }

  Future<List<Employee>> getSubordinates(
      {Organization? organization, List<Department>? departments}) async {
    id ??= '';
    if (id!.isEmpty) return [];
    List<dynamic> items = [];

    departments ??= await Department.getDepartments(organization: organization);
    // await Department.getDepartments(organization: organization);
    if (departments.isEmpty) return [];
    Queue<Department> queue = Queue<Department>();
    queue.addAll(departments.where((element) => element.manager == id));

    while (queue.isNotEmpty) {
      Department department = queue.removeFirst();
      items.addAll(department.employees);
      items.add(department.manager!);
      queue.addAll(
          departments.where((element) => element.parent == department.id));
    }

    items = items
        .where((element) =>
            (element != id) && (element != null) && (element != ''))
        .toList();

    if (items.isEmpty) return [];

    List<Employee> employees = await Employee.byId(
            items.map((e) => e.toString()).toList().toSet().toList())
        as List<Employee>;
    // Remove employees that are not active
    employees = employees.where((element) => element.isActive()).toList();
    return employees;
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
    try {
      return (altas.isNotEmpty &&
          (getBajaDate().isAfter(DateTime.now()) ||
              getBajaDate().isAtSameMomentAs(DateTime.now())));
    } catch (e) {
      return false;
    }
  }

  String getFullName() {
    // Remove any leading or trailing spaces from firstName, lastName1, and lastName2
    firstName = firstName.trim();
    lastName1 = lastName1.trim();
    lastName2 = lastName2.trim();
    // Remove any extra spaces between names
    firstName = firstName.replaceAll(RegExp(r'\s+'), ' ');
    lastName1 = lastName1.replaceAll(RegExp(r'\s+'), ' ');
    lastName2 = lastName2.replaceAll(RegExp(r'\s+'), ' ');
    return '$firstName $lastName1 $lastName2';
  }
}

///////// DEPARTMENT /////////
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

  @override
  String toString() {
    return 'Department: $name, parent: $parent, manager: $manager, employees: ${employees.length}, organization: $organization';
  }

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

  static Future<List<Department>> byOrganization(dynamic organization) async {
    return await getDepartments(organization: organization);
  }

  static Future<List<Department>> getDepartments({dynamic organization}) async {
    // get from database
    String organizationId = '';
    List<Department> items = [];
    if (organization is Organization) {
      organizationId = organization.id;
    }

    try {
      if (organizationId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(tbName)
            .where('organization', isEqualTo: organizationId)
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

class Workplace {
  static const String tbName = 's4c_workplaces';

  String id;
  String name;
  Organization? organization;
  String? address;
  String? city;
  String? postalCode;
  String? country;
  String? phone;

  Workplace({
    required this.name,
    this.id = '',
    this.organization,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.phone,
  });

  @override
  String toString() {
    return 'Working Center: $name, organization: ${organization?.id}, address: $address, city: $city, postalCode: $postalCode, country: $country, phone: $phone';
  }

  static Future<Workplace> fromJson(Map<String, dynamic> json) async {
    Workplace item = Workplace(
        name: json['name'],
        organization: (json.containsKey('organization'))
            ? await Organization.byId(json['organization'])
            : null,
        address: (json.containsKey('address')) ? json['address'] : null,
        city: (json.containsKey('city')) ? json['city'] : null,
        postalCode:
            (json.containsKey('postalCode')) ? json['postalCode'] : null,
        country: (json.containsKey('country')) ? json['country'] : null,
        phone: (json.containsKey('phone')) ? json['phone'] : null);
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
        'organization': organization?.id,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'country': country,
        'phone': phone,
      };

  Future<Workplace> save() async {
    if (id == '') {
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(toJson())
          .then((value) {
        id = value.id;
        FirebaseFirestore.instance
            .collection(tbName)
            .doc(id)
            .update({'id': id});
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
    await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
  }

  static Workplace getEmpty() {
    return Workplace(name: '');
  }

  static Future<List<Workplace>> getAll({Organization? organization}) async {
    // get from database
    List<Workplace> items = [];
    if (organization == null) {
      final value = await FirebaseFirestore.instance.collection(tbName).get();
      if (value.docs.isEmpty) return [];
      items = await Future.wait(value.docs.map((e) async {
        Workplace item = await Workplace.fromJson(e.data());
        item.id = e.id;
        return item;
      }));
      items.sort((a, b) => a.name.compareTo(b.name));
      return items;
    }
    final value = await FirebaseFirestore.instance
        .collection(tbName)
        .where('organization', isEqualTo: organization.id)
        .get();
    if (value.docs.isEmpty) return [];
    for (var doc in value.docs) {
      items.add(await Workplace.fromJson(doc.data()));
    }

    items.sort((a, b) => a.name.compareTo(b.name));

    return items;
  }

  static Future<Workplace> byId(String? id) async {
    if (id == null) return getEmpty();
    if (id.isEmpty) return getEmpty();
    final doc =
        await FirebaseFirestore.instance.collection(tbName).doc(id).get();
    if (doc.exists) {
      return await Workplace.fromJson(doc.data()!);
    }
    return getEmpty();
  }
}
