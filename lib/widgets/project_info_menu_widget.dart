import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget projectInfoMenu(context, project, tabSelected) {
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        menuTab2(context, "Datos Generales", ProjectInfoPage(project: project),
            selected: (tabSelected == "info")),
        menuTab2(context, "Comunicación con el financiador",
            ReformulationPage(project: project),
            selected: (tabSelected == "reformulation")),
      ],
    ),
  );
}

Widget logo() {
  return const Image(
    image: AssetImage('assets/images/logo.jpg'),
    width: 100,
  );
}
