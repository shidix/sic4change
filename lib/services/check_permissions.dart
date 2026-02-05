import 'dart:developer' as dev;
import 'package:sic4change/services/models_profile.dart';

canAddProgramme(Profile? profile) {
  if (profile == null) return false;
  return profile.isAdmin();
}

canAddProject(Profile? profile) {
  if (profile == null) return false;
  return profile.isAdmin() || profile.isSupervisor();
}

canDeleteProgramme(Profile? profile) {
  if (profile == null) return false;
  return profile.isAdmin();
}

canDeleteProject(Profile? profile) {
  if (profile == null) return false;
  return profile.isAdmin() || profile.isSupervisor();
}
