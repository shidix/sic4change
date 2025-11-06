// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sic4change/services/models_commons.dart';

class Profile {
  static const String tbName = "s4c_profiles";

  String id;
  String email;
  String name = "";
  String position = "";
  String phone = "";
  List<dynamic> holidaySupervisor;
  String mainRole;
  String? organization;

  static const String ADMIN = 'Admin';
  static const String TECHNICIAN = 'Técnico';
  static const String SUPERVISOR = 'Supervisor';
  static const String ADMINISTRATIVE = 'Administrativo';
  static const String RRHH = 'Administrativo';
  static const String USER = 'Usuario';

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
    this.organization,
  });

  factory Profile.fromJson(Map data) {
    Profile profile = Profile(
      id: data['id'],
      email: data['email'],
      holidaySupervisor: data['holidaySupervisor'],
      mainRole: data['mainRole'],
      organization:
          data.containsKey('organization') && data['organization'] != null
              ? data['organization']
              : null,
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
        'organization': organization,
      };

  @override
  String toString() {
    return 'Profile{id: $id, email: $email, holidaySupervisor: $holidaySupervisor, mainRole: $mainRole, organization: $organization}';
  }

  KeyValue toKeyValue() {
    return KeyValue(email, email);
  }

  factory Profile.getEmpty(
      {String email = "none@none.com", String id = "", String mainRole = ""}) {
    return Profile(
      id: id,
      email: email,
      holidaySupervisor: [],
      mainRole: mainRole,
    );
  }

  Future<Profile> save() async {
    if (id == "") {
      Map<String, dynamic> data = toJson();
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection(Profile.tbName).add(data);
      id = docRef.id;
      docRef.update({'id': id});
    } else {
      Map<String, dynamic> data = toJson();
      await FirebaseFirestore.instance
          .collection(Profile.tbName)
          .doc(id)
          .update(data);
    }
    return this;
  }

  void delete() {
    FirebaseFirestore.instance.collection(Profile.tbName).doc(id).delete();
  }

  Future<Organization?> getOrganization() async {
    if (organization == null || organization!.isEmpty) {
      if (email.isNotEmpty) {
        return Organization.byDomain(email);
      }
      return Organization("Sin organización");
    }
    Organization? result = await Organization.byId(organization!);
    result ??= Organization("Sin organización");
    return result;
  }

  bool isAdmin() {
    return mainRole == ADMIN;
  }

  bool isRRHH() {
    return mainRole == RRHH || mainRole == ADMINISTRATIVE;
  }

  static Future<List<Profile>> getProfiles({List<String>? emails}) async {
    if ((emails != null) && (emails.isNotEmpty)) {
      return FirebaseFirestore.instance
          .collection(Profile.tbName)
          .where("email", whereIn: emails)
          .get()
          .then((snap) =>
              snap.docs.map((doc) => Profile.fromFirestore(doc)).toList());
    }

    return FirebaseFirestore.instance.collection(Profile.tbName).get().then(
        (snap) => snap.docs.map((doc) => Profile.fromFirestore(doc)).toList());
  }

  static Future<Profile> getProfile(dynamic email) async {
    QuerySnapshot query;

    if (email is String) {
      query = await FirebaseFirestore.instance
          .collection(Profile.tbName)
          .where("email", isEqualTo: email)
          .get();
    } else if (email is List<String>) {
      query = await FirebaseFirestore.instance
          .collection(Profile.tbName)
          .where("email", whereIn: email)
          .get();
    } else {
      throw ArgumentError("Email must be a String or List<String>");
    }

    if (query.docs.isEmpty) {
      return Profile.getEmpty(email: email, mainRole: Profile.USER);
    }

    DocumentSnapshot doc = query.docs.first;
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    return Profile.fromJson(data);
  }

  static Future<Profile> byEmail(dynamic email) async {
    return await getProfile(email);
  }

  static Future<List<KeyValue>> getProfileHash() async {
    List<KeyValue> items = [];
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(Profile.tbName).get();
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
      Profile result = await getProfile(email);
      return result;
    } catch (e) {
      return Profile.getEmpty(
          email: "none@none.com", mainRole: Profile.ADMINISTRATIVE);
    }
  }

  static Future<List<Profile>> byOrganization({dynamic organization}) async {
    if (organization == null) {
      return [];
    }
    if (organization is Organization) {
      organization = organization.id;
    }
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(Profile.tbName)
        .where("organization", isEqualTo: organization)
        .get();

    return query.docs
        .map((doc) => Profile.fromJson(doc.data() as Map<String, dynamic>))
        .toList(growable: false);
  }
}
