// ignore_for_file: constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/nominas_page.dart';
import 'package:sic4change/pages/home_page.dart';
import 'package:sic4change/pages/rrhh_page.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const NOMINA_ITEM = 0;
const EMPLOYEE_ITEM = 1;

Widget secondaryMenu(context, int option, Profile? profile) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    mainAxisSize: MainAxisSize.max,
    children: [
      (option != NOMINA_ITEM)
          ? goPage(context, 'Nóminas', NominasPage(profile: profile),
              Icons.euro_symbol)
          : goPage(context, 'Nóminas', null, Icons.euro_symbol),
      space(width: 10),
      (option != EMPLOYEE_ITEM)
          ? goPage(context, 'Empleados', EmployeesPage(profile: profile),
              Icons.people)
          : goPage(context, 'Empleados', null, Icons.people),
    ],
  );
}
