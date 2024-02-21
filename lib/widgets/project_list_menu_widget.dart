import 'package:flutter/material.dart';
import 'package:sic4change/pages/projects_list_page.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget projectListMenu(context, tabSelected) {
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        menuTab2(context, "Cuadro de proyectos", const ProjectListPage(),
            selected: (tabSelected == "proyectos")),
        menuTab2(context, "Cuadro de consultorías",
            const ProjectListPage(prType: "Consultoria"),
            selected: (tabSelected == "consultorias")),
      ],
    ),
  );
}
