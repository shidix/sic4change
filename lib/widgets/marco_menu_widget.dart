import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget marcoMenu(context, project, tabSelected) {
  bool marco = (tabSelected == "marco") ? true : false;
  bool risk = (tabSelected == "risk") ? true : false;
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        menuTab(context, "Marco lógico", "/goals", {'project': project},
            selected: marco),
        menuTab(context, "Riesgos", "/risks", {'project': project},
            selected: risk),
        menuTab(context, "Bitácora", "/goals", {'project': project}),
        menuTab(
            context, "Eva. externa y calidad", "/goals", {'project': project}),
        menuTab(context, "Aprendizajes", "/goals", {'project': project}),
        menuTab(context, "Req. calidad", "/goals", {'project': project}),
        menuTab(
            context, "Transparencia y calidad", "/goals", {'project': project}),
        menuTab(context, "Género", "/goals", {'project': project}),
        menuTab(context, "Medio ambiente", "/goals", {'project': project}),
      ],
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
    ),
  );
}

Widget logo() {
  return const Image(
    image: AssetImage('assets/images/logo.jpg'),
    width: 100,
  );
}
