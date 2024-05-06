import 'package:flutter/material.dart';
import 'package:sic4change/pages/profile_page.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget profileDetailsMenu(context, tabSelected) {
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        menuTab2(context, "Vacaciones", ProfilePage(),
            selected: (tabSelected == "holidays")),
        menuTab2(context, "Liquidación de gastos", ProfilePage(),
            selected: (tabSelected == "bills")),
        menuTab2(context, "Nóminas", ProfilePage(),
            selected: (tabSelected == "payments")),
        menuTab2(context, "Parte de horas", ProfilePage(),
            selected: (tabSelected == "worked")),
      ],
    ),
  );
}
