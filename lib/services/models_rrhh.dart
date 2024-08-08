import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sic4change/services/utils.dart';

class Nomina {
  static final db = FirebaseFirestore.instance;
  static final collection = db.collection("s4c_nominas");
  static final storage = FirebaseStorage.instance;

  String? id;
  String employeeCode;
  DateTime date;
  String noSignedPath;
  DateTime noSignedDate;
  String? signedPath;
  DateTime? signedDate;

  Nomina(
      {required this.employeeCode,
      required this.date,
      required this.noSignedPath,
      required this.noSignedDate,
      this.signedPath,
      this.signedDate});

  factory Nomina.fromJson(Map<String, dynamic> json) {
    return Nomina(
        employeeCode: json['employeeCode'],
        date: getDate(json['date'] ?? DateTime.now()),
        noSignedPath: json['noSignedPath'],
        noSignedDate: getDate(json['noSignedDate'] ?? DateTime.now()),
        signedPath: json['signedPath'],
        signedDate: getDate(json['signedDate'] ?? DateTime.now()));
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'employeeCode': employeeCode,
        'noSignedPath': noSignedPath,
        'noSignedDate': noSignedDate,
        'signedPath': signedPath,
        'signedDate': signedDate
      };

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
        noSignedPath: '',
        noSignedDate: DateTime.now());
  }

  static Future<List<Nomina>> getNominas(String employeeCode) async {
    // get from database
    List<Nomina> items = [];
    await collection
        .where('employeeCode', isEqualTo: employeeCode)
        .get()
        .then((value) {
      if (value.docs.isEmpty) return [];
      items = value.docs.map((e) {
        Nomina item = Nomina.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();
    });
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

  int compareTo(Nomina other) {
    if (date.compareTo(other.date) == 0) {
      if (noSignedDate.compareTo(other.noSignedDate) == 0) {
        return employeeCode.compareTo(other.employeeCode);
      } else {
        return noSignedDate.compareTo(other.noSignedDate) * -1;
      }
    }
    return date.compareTo(other.date) * -1;
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
          : json['altas'].map((e) => getDate(e)).toList(),
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
        'altas': altas.map((e) => e).toList(),
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
        altas: [DateTime.now()],
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
      altas.add(DateTime.now());
    }
    altas.sort();
    return altas.last;
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
