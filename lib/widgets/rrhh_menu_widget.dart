// ignore_for_file: constant_identifier_names

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/admin_calendar_holidays.dart';
import 'package:sic4change/pages/hierarchy_page.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/pages/rrhh_nominas_page.dart';
// import 'package:sic4change/pages/home_page.dart';
import 'package:sic4change/pages/employee_page.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const NOMINA_ITEM = 0;
const EMPLOYEE_ITEM = 1;
const HIERARCHY_ITEM = 2;
const CALENDAR_ITEM = 3;

Widget secondaryMenu(context, int option) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    mainAxisSize: MainAxisSize.max,
    children: [
      (option != NOMINA_ITEM)
          ? goPage(context, 'Nóminas', const NominasPage(), Icons.euro_symbol)
          : goPage(context, 'Nóminas', null, Icons.euro_symbol),
      space(width: 10),
      (option != EMPLOYEE_ITEM)
          ? goPage(context, 'Empleados', const EmployeesPage(), Icons.people)
          : goPage(context, 'Empleados', null, Icons.people),
      space(width: 10),
      (option != HIERARCHY_ITEM)
          ? goPage(context, 'Departamentos', const HierarchyPage(),
              Icons.account_tree)
          : goPage(context, 'Departamentos', null, Icons.account_tree),
      space(width: 10),
      (option != CALENDAR_ITEM)
          ? goPage(context, 'Calendarios', const CalendarHolidaysPage(),
              Icons.calendar_today)
          : goPage(context, 'Calendarios', null, Icons.calendar_today),
      space(width: 10),
      backButton(context),
    ],
  );
}
