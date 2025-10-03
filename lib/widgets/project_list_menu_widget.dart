import 'package:flutter/material.dart';
// import 'package:sic4change/pages/projects_list_page.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget projectListMenu(context, tabSelected, {Function? extraction}) {
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        menuTab2(context, "Cuadro de proyectos", null,
            selected: (tabSelected == "proyectos"), extraction: extraction),
        menuTab2(context, "Cuadro de consultorías", null,
            // const ProjectListPage(prType: "Consultoria"),
            selected: (tabSelected == "consultorias"),
            extraction: extraction),
      ],
    ),
  );
}
