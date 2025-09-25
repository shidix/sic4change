import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_profile.dart';

class ProfileProvider with ChangeNotifier {
  Profile? _profile;
  Organization? _organization;
  late final UniqueKey key;
  User? user;
  bool _loading = false;
  Organization? get organization => _organization;
  set organization(Organization? value) {
    _organization = value;
    notifyListeners();
  }

  Profile? get profile => _profile;

  Future<void> loadProfile() async {
    if (user == null) return;
    if ((_profile != null || _loading) &&
        (user != null) &&
        (user?.email == _profile?.email)) {
      return; // Profile already loaded
    }
    _loading = true;
    _profile = await Profile.getCurrentProfile();
    if (profile != null) {
      if (_profile!.organization != null &&
          _profile!.organization!.isNotEmpty) {
        _organization = await Organization.byId(_profile!.organization!);
        _loading = false;
      } else {
        // Load organization by email domain
        String email = _profile?.email ?? user?.email ?? "none@none.com";
        _organization = await Organization.byDomain(email);
        if (_organization != null) {
          _profile!.organization = _organization!.id;
          _profile!.save();
        }
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> setProfile(Profile profile) async {
    _profile = profile;
    if (profile.organization != null && profile.organization!.isNotEmpty) {
      profile.getOrganization().then((value) {
        _organization = value;
        notifyListeners();
      });
    } else {
      _organization = null;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _organization = null;
    notifyListeners();
  }

  void initialize() {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    loadProfile();
  }

  ProfileProvider() {
    key = UniqueKey();
    initialize();
  }

  // Future<void> loadProfile() async {
  //   // _profile = await Profile.getCurrentProfile();
  //   _profile = await Future.delayed(Duration(seconds: 5), () {
  //     return Profile.getEmpty(email: "none@none.com");
  //   });
  //   notifyListeners();
  // }

  // void clear() {
  //   _profile = null;
  //   notifyListeners();
  // }
}
