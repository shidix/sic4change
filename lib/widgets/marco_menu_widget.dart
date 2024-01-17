import 'package:flutter/material.dart';
import 'package:sic4change/pages/bitacora_page.dart';
import 'package:sic4change/pages/evaluation_page.dart';
import 'package:sic4change/pages/goals_page.dart';
import 'package:sic4change/pages/learnings_page.dart';
import 'package:sic4change/pages/project_transversal_page.dart';
import 'package:sic4change/pages/risks_page.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget marcoMenu(context, project, tabSelected) {
  /*bool marco = (tabSelected == "marco") ? true : false;
  bool risk = (tabSelected == "risk") ? true : false;*/

  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        menuTab2(context, "Marco lógico", GoalsPage(project: project),
            selected: (tabSelected == "marco")),
        menuTab2(context, "Riesgos", RisksPage(project: project),
            selected: (tabSelected == "risk")),
        menuTab2(context, "Bitácora", BitacoraPage(project: project),
            selected: (tabSelected == "bitacora")),
        menuTab2(
            context, "Eva. externa y calidad", EvaluationPage(project: project),
            selected: (tabSelected == "evaluation")),
        menuTab2(context, "Aprendizajes", LearningsPage(project: project),
            selected: (tabSelected == "learnings")),
        menuTab2(context, "Transversal",
            ProjectTransversalPage(currentProject: project),
            selected: (tabSelected == "transversal")),
        /*menuTab(context, "Marco lógico", "/goals", {'project': project},
            selected: marco),
        menuTab(context, "Riesgos", "/risks", {'project': project},
            selected: risk),*/
        // menuTab(context, "Req. calidad", "/goals", {'project': project}),
        // menuTab(
        //     context, "Transparencia y calidad", "/goals", {'project': project}),
        // menuTab(context, "Género", "/goals", {'project': project}),
        // menuTab(context, "Medio ambiente", "/goals", {'project': project}),
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
