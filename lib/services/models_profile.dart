import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sic4change/services/models_commons.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class Profile {
  String id;
  String email;
  String name = "";
  String position = "";
  String phone = "";
  List<dynamic> holidaySupervisor;
  String mainRole;

  final database = db.collection("s4c_profiles");

  static const List<String> profiles = [
    'Admin',
    'Técnico',
    'Supervisor',
    'Administrativo',
    'Usuario'
  ];

  Profile({
    required this.id,
    required this.email,
    required this.holidaySupervisor,
    required this.mainRole,
  });

  factory Profile.fromJson(Map data) {
    Profile profile = Profile(
      id: data['id'],
      email: data['email'],
      holidaySupervisor: data['holidaySupervisor'],
      mainRole: data['mainRole'],
    );
    profile.name = (data['name'] != null) ? data['name'] : '';
    profile.position = (data['position'] != null) ? data['position'] : '';
    profile.phone = (data['phone'] != null) ? data['phone'] : '';
    return profile;
  }

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Profile.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'position': position,
        'phone': phone,
        'holidaySupervisor': holidaySupervisor,
        'mainRole': mainRole,
      };

  @override
  String toString() {
    return 'Profile{id: $id, email: $email, holidaySupervisor: $holidaySupervisor, mainRole: $mainRole}';
  }

  KeyValue toKeyValue() {
    return KeyValue(email, email);
  }

  factory Profile.getEmpty() {
    return Profile(
      id: "",
      email: "",
      holidaySupervisor: [],
      mainRole: "",
    );
  }

  void save() {
    if (id == "") {
      Map<String, dynamic> data = toJson();
      database.add(data).then((value) => id = value.id);
    } else {
      Map<String, dynamic> data = toJson();
      database.doc(id).update(data);
    }
  }

  void delete() {
    database.doc(id).delete();
  }

  static Future<List<Profile>> getProfiles({List<String>? emails}) async {
    if ((emails != null) && (emails.isNotEmpty)) {
      return db
          .collection("s4c_profiles")
          .where("email", whereIn: emails)
          .get()
          .then((snap) =>
              snap.docs.map((doc) => Profile.fromFirestore(doc)).toList());
    }

    return db.collection("s4c_profiles").get().then(
        (snap) => snap.docs.map((doc) => Profile.fromFirestore(doc)).toList());
  }

  static Future<Profile> getProfile(String email) async {
    QuerySnapshot query = await db.collection("s4c_profiles").get();

    List<Profile> items = [];
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Profile item = Profile.fromJson(data);
      items.add(item);
    }
    if (items.isNotEmpty) {
      return items.firstWhere((element) => element.email == email,
          orElse: () => Profile.getEmpty());
    } else {
      return Profile.getEmpty();
    }

    // if (query.docs.isEmpty) {
    //   return Profile.getEmpty();
    // } else {
    //   final dbResult = query.docs.first;
    //   return Profile.fromFirestore(dbResult);
    // }
  }

  static Future<List<KeyValue>> getProfileHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query = await db.collection("s4c_profiles").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      Profile item = Profile.fromJson(data);
      items.add(item.toKeyValue());
    }
    return items;
  }

  static Future<Profile> getCurrentProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      String email = user.email!;
      return getProfile(email);
    } catch (e) {
      return Profile.getEmpty();
    }
  }
}
