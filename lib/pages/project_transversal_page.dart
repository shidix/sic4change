// ignore_for_file: avoid_unnecessary_containers

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:js_util';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_quality.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';

// const PROJECT_INFO_TITLE = "Detalles del Proyecto";

Widget indicatorButton(
    context, String upperText, String text, Function action, dynamic args,
    {Color textColor = Colors.black54, Color iconColor = Colors.black54}) {
  return ElevatedButton(
    onPressed: () {
      if (args == null) {
        action();
      } else {
        action(args);
      }
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
    ),
    child: Column(
      children: [
        Text(
          upperText,
          textAlign: TextAlign.center,
          style: mainText.copyWith(fontSize: 14),
        ),
        space(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: mainText.copyWith(fontSize: 30),
        ),
      ],
    ),
  );
}

class ProjectTransversalPage extends StatefulWidget {
  final SProject? currentProject;

  const ProjectTransversalPage({Key? key, this.currentProject})
      : super(key: key);

  @override
  createState() => _ProjectTransversalPageState();
}

class _ProjectTransversalPageState extends State<ProjectTransversalPage> {
  User user = FirebaseAuth.instance.currentUser!;
  SProject? currentProject;
  Widget? qualityPanelWidget;
  List<QualityQuestion>? qualityQuestions;
  int qaQuestionsCompleted = 0;
  int qualityQuestionsCounter = 0;
  List<int> qualityCounters = [];
  bool collapsedQuality = false;

  Widget totalBudget(context, SProject project) {
    double percent = 50;
    String budgetInEuros = toCurrency(double.parse(project.budget));
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(children: [
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text("Presupuesto Total",
                        style: mainText.copyWith(color: normalColor)))),
            Expanded(
                flex: 1,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(budgetInEuros, style: subTitleText))),
          ]),
          space(height: 10),
          Row(children: [
            Expanded(
                flex: 1,
                child: LinearPercentIndicator(
                  percent: percent / 100,
                  lineHeight: 16,
                  progressColor: Colors.blueGrey,
                  center: Text("$percent %",
                      style: subTitleText.copyWith(color: Colors.white)),
                )),
          ]),
        ]));
  }

  Widget statusEjecucion(context, SProject project) {
    double percent = 50;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(children: [
          const Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text("En ejecución", style: mainText))),
          ]),
          space(height: 10),
          Row(children: [
            Expanded(
                flex: 1,
                child: LinearPercentIndicator(
                  percent: percent / 100,
                  lineHeight: 16,
                  progressColor: mainColor,
                  center: Text("$percent %",
                      style: subTitleText.copyWith(color: Colors.white)),
                )),
          ]),
        ]));
  }

  void test() {}

  @override
  void initState() {
    super.initState();
    qualityPanel();
    if (widget.currentProject == null) {
      SProject.getByUuid('6fbe1b21-eaf2-43ca-a496-d1e9dd2171c9')
          .then((project) {
        setState(() {
          currentProject = project;
        });
      });
    } else {
      setState(() {
        currentProject = widget.currentProject;
      });
    }
  }

  void addQualityPanel(args) {
    setState(() {
      collapsedQuality = !collapsedQuality;
      if (collapsedQuality) {
        qualityPanelWidget = qualityPanel();
      } else {
        qualityPanelWidget = null;
      }
    });
  }

  Widget qualityPanel() {
    qualityQuestions = [];

    qualityQuestions!.add(QualityQuestion(
        code: "1",
        subject: "Cumplimiento de requisitos",
        completed: true,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "1.1",
        subject:
            "¿El proyecto cumple con los requisitos del alcance establecidos?",
        completed: false,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "1.2",
        subject:
            "¿El proyecto se está ejecutando dentro del presupuesto establecido?",
        completed: true,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "1.3",
        subject:
            "¿El proyecto se está ejecutando dentro del cronograma establecido?",
        completed: false,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "1.4",
        subject:
            "¿Los requisitos del proyecto están claramente definidos y acordados?",
        completed: true,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "1.5",
        subject: "¿Se está alcanzando a los usarios establecidos?",
        completed: false,
        comments: "Actualmente estamos a un 80% del objetivo fijado",
        docs: []));

    qualityQuestions!.add(QualityQuestion(
        code: "2",
        subject: "Gestión de procesos",
        completed: true,
        comments: "",
        docs: []));

    qualityQuestions!.add(QualityQuestion(
        code: "2.1",
        subject:
            "¿Los procesos del proyecto están documentados y se siguen de manera efectiva?",
        completed: true,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "2.2",
        subject:
            "¿La comunicación entre las partes interesadas del proyecto es efectiva?",
        completed: true,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "2.3",
        subject:
            "¿Los riesgos del proyecto se han identificado y se están mitigando de manera efectiva?",
        completed: false,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "2.4",
        subject: "¿Los cambios al proyecto se gestionan de manera efectiva?",
        completed: false,
        comments: "",
        docs: []));

    qualityQuestions!.add(QualityQuestion(
        code: "3",
        subject: "Mejora Continua",
        completed: false,
        comments: "",
        docs: []));

    qualityQuestions!.add(QualityQuestion(
        code: "3.1",
        subject:
            "¿Se están aplicando las lecciones aprendidas de proyectos anteriores?",
        completed: true,
        comments: "",
        docs: []));
    qualityQuestions!.add(QualityQuestion(
        code: "3.2",
        subject:
            "¿Se están implementando acciones para mejorar la gestión de calidad del proyecto",
        completed: true,
        comments: "",
        docs: []));

    qualityQuestions!.sort((a, b) => a.code.compareTo(b.code));
    qualityCounters = [];
    QualityQuestion? lastMain;
    qaQuestionsCompleted = 0;
    qualityQuestionsCounter = 0;
    int questionsInMain = 0;
    for (var question in qualityQuestions!) {
      if (!question.isMain()) {
        qualityQuestionsCounter++;
        questionsInMain++;
        if (question.completed) {
          qaQuestionsCompleted++;
          qualityCounters.last++;
        }
      } else {
        if (lastMain != null) {
          lastMain.subject += " (${qualityCounters.last}/$questionsInMain)";
        }
        questionsInMain = 0;
        lastMain = question;
        qualityCounters.add(0);
      }
    }

    if (lastMain != null) {
      lastMain.subject += " (${qualityCounters.last}/$questionsInMain)";
    }

    setState(() {
      qualityQuestions = qualityQuestions;
      qaQuestionsCompleted = qaQuestionsCompleted;
    });

    Widget result = Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        // height: 150,
        color: Colors.white,
        child: currentProject != null
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: qualityQuestions!.length,
                //scrollDirection: Axis.vertical,

                itemBuilder: (BuildContext context, int index) {
                  QualityQuestion item = qualityQuestions!.elementAt(index);
                  TextStyle style = (item.isMain()
                      ? successText.copyWith(color: Colors.white)
                      : normalText);
                  Color bgColor = (item.isMain() ? successColor : Colors.white);
                  return ListTile(
                      subtitle: Container(
                          color: bgColor,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          item.subject,
                                          style: style,
                                        )),
                                  )),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      (item.isMain()
                                          ? "Sí/No"
                                          : item.completed
                                              ? "Sí"
                                              : "No"),
                                      style: style,
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      item.isMain()
                                          ? "Comentarios"
                                          : item.comments,
                                      style: style,
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      item.isMain()
                                          ? "Docs."
                                          : item.docs.isNotEmpty
                                              ? item.docs.toString()
                                              : '',
                                      style: style,
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                            ],
                          )));
                })
            : const Center(
                child: CircularProgressIndicator(),
              ));

    return Column(children: [
      result,
      Divider(
        height: 1,
      ),
    ]);
  }

  Widget statusProject() {
    return Container(
        child: Row(children: [
      Expanded(flex: 1, child: statusEjecucion(context, currentProject!)),
      Expanded(flex: 1, child: totalBudget(context, currentProject!)),
    ]));
  }

  Widget content(context) {
    if (currentProject == null) {
      return Column(children: [
        mainMenu(context, user, "/projects"),
        Container(height: 10),
        const Center(child: CircularProgressIndicator())
      ]);
    } else {
      return Column(
        children: [
          mainMenu(context, user, "/projects"),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Column(children: [
                Container(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(currentProject!.name,
                          style: titleText.copyWith(color: normalColor)),
                    ],
                  ),
                ),
                // statusProject(),
                // Container(
                //   height: 20,
                // ),
                // const Divider(height: 1),

                // topButtons(context))
                marcoMenu(context, currentProject, "transversal"),
                multiplesIndicators(),
              ]))
        ],
      );
    }
  }

  Widget indicator(String title, String value, Function action,
      [List args = const []]) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        color: Colors.white,
        child: Column(children: [
          (title != "Calidad")
              ? const Divider(height: 1)
              : Container(height: 0),
          Container(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 8,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(title,
                                  style: normalText.copyWith(fontSize: 20)))),
                      Expanded(
                          flex: 2,
                          child: indicatorButton(context, "TOTAL EVALUACIÓN",
                              value, action, args)),
                    ],
                  ))),
        ]));
  }

  Widget multiplesIndicators() {
    return Card(
        elevation: 5,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(children: [
              indicator(
                  "Calidad",
                  "$qaQuestionsCompleted/$qualityQuestionsCounter",
                  addQualityPanel),
              qualityPanelWidget ?? Container(height: 0),
              indicator("Transparencia", "8/10", test),
              indicator("Género", "7/9", test),
              indicator("Medio Ambiente", "5/8", test),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    if (currentProject == null) {}
    return Scaffold(body: SingleChildScrollView(child: content(context)));
  }
}
