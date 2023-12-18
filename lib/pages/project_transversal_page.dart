// ignore_for_file: avoid_unnecessary_containers

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:js_util';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_quality.dart';
import 'package:sic4change/services/transversal_question_form.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';

// const PROJECT_INFO_TITLE = "Detalles del Proyecto";

Widget indicatorButton(
    context, String upperText, String text, Function action, dynamic args,
    {Color textColor = Colors.black54, Color iconColor = Colors.black54}) {
  return Tooltip(
      message: 'Click para ver / ocultar detalles',
      showDuration: const Duration(seconds: 0),
      child: ElevatedButton(
        onPressed: () {
          if (args == null) {
            action();
          } else {
            action(args);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
      ));
}

class ProjectTransversalPage extends StatefulWidget {
  final SProject? currentProject;

  const ProjectTransversalPage({Key? key, this.currentProject})
      : super(key: key);

  @override
  createState() => _ProjectTransversalPageState();
}

class _ProjectTransversalPageState extends State<ProjectTransversalPage> {
  TransversalQuestion? currentQuestion;
  User user = FirebaseAuth.instance.currentUser!;
  SProject? currentProject;

  Quality? quality;
  Widget? qualityPanelWidget;
  List? qualityQuestions;
  int qaQuestionsCompleted = 0;
  int qualityQuestionsCounter = 0;
  List<int> qualityCounters = [];
  bool collapsedQuality = false;

  Transparency? transparency;
  Widget? transparencyPanelWidget;
  List? transparencyQuestions;
  int transparencyQuestionsCompleted = 0;
  int transparencyQuestionsCounter = 0;
  List<int> transparencyCounters = [];
  bool collapsedTransparency = false;

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
    if (widget.currentProject == null) {
      SProject.getByUuid('6fbe1b21-eaf2-43ca-a496-d1e9dd2171c9')
          .then((project) {
        currentProject = project;

        Quality.byProject(project.uuid).then((value) {
          setState(() {
            quality = value;
            qualityPanel();
          });
        });

        Transparency.byProject(project.uuid).then((value) {
          setState(() {
            transparency = value;
            transparencyPanel();
          });
        });
      });
    } else {
      Quality.byProject(widget.currentProject!.uuid).then((value) {
        setState(() {
          currentProject = widget.currentProject;
          quality = value;
          qualityPanel();
        });
      });

      Transparency.byProject(widget.currentProject!.uuid).then((value) {
        setState(() {
          currentProject = widget.currentProject;
          transparency = value;
          transparencyPanel();
        });
      });
    }
  }

////// QUALITY QUESTIONS

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
    Map<String, String>? califications = {};
    qualityQuestions = quality!.questions;

    qualityQuestions!.sort((a, b) => a.code.compareTo(b.code));
    qualityCounters = [];
    TransversalQuestion? lastMain;
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
          califications[lastMain.code] =
              "${qualityCounters.last}/$questionsInMain";
        }
        questionsInMain = 0;
        lastMain = question;
        qualityCounters.add(0);
      }
    }

    if (lastMain != null) {
      califications[lastMain.code] = "${qualityCounters.last}/$questionsInMain";
    }

    Widget panel = Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        // height: 150,
        color: Colors.white,
        child: currentProject != null
            ? Column(children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: actionButtonVertical(
                            context,
                            'Nuevo ítem',
                            qualityQuestionDialog,
                            Icons.add,
                            {'context': context, 'item': null}))),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: qualityQuestions!.length,
                    itemBuilder: (BuildContext context, int index) {
                      TransversalQuestion item =
                          qualityQuestions!.elementAt(index);
                      TextStyle style = (item.isMain()
                          ? successText.copyWith(color: Colors.white)
                          : normalText);
                      Color bgColor =
                          (item.isMain() ? mainColor : Colors.white);
                      return Tooltip(
                          message: 'Click para editar',
                          showDuration: const Duration(seconds: 0),
                          child: ListTile(
                              subtitle: Container(
                                  color: bgColor,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(
                                                  item.code,
                                                  style: style,
                                                )),
                                          )),
                                      Expanded(
                                          flex: 8,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(
                                                  (item.isMain())
                                                      ? "${item.subject} (${califications[item.code]})"
                                                      : item.subject,
                                                  style: style,
                                                )),
                                          )),
                                      Expanded(
                                        flex: 2,
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
                                        flex: 6,
                                        child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              item.isMain()
                                                  ? "Comentarios"
                                                  : item.comments,
                                              style: style,
                                              textAlign: TextAlign.left,
                                            )),
                                      ),
                                      Expanded(
                                        flex: 2,
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
                                  )),
                              onTap: () {
                                qualityQuestionDialog(
                                    {'context': context, 'item': item});
                              }));
                    })
              ])
            : const Center(
                child: CircularProgressIndicator(),
              ));

    return Column(children: [
      panel,
      const Divider(
        height: 1,
      ),
    ]);
  }

  void qualityQuestionDialog(args) {
    BuildContext context = args['context'];
    currentQuestion = args['item'];

    _qualityQuestionDialog(context).then((value) {
      if (value != null) {
        setState(() {
          quality = value;
          qualityQuestions = quality!.questions;
          qualityPanelWidget = qualityPanel();
        });
      }
    });
  }

  Future<Quality?> _qualityQuestionDialog(context) {
    currentQuestion ??= TransversalQuestion.getEmpty();

    return showDialog<Quality>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context2) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Item de calidad'),
          content: Wrap(children: [
            TransversalQuestionForm(
              key: null,
              currentQuestion: currentQuestion,
              currentTransversal: quality as Transversal,
            )
          ]),
        );
      },
    );
  }

////// TRANSPARENCY QUESTIONS

  void addTransparencyPanel(args) {
    setState(() {
      collapsedTransparency = !collapsedTransparency;
      if (collapsedTransparency) {
        transparencyPanelWidget = transparencyPanel();
      } else {
        transparencyPanelWidget = null;
      }
    });
  }

  Widget transparencyPanel() {
    transparencyQuestions = transparency!.questions;

    transparencyQuestions!.sort((a, b) => a.code.compareTo(b.code));
    transparencyCounters = [];
    transparencyQuestionsCompleted = 0;
    transparencyQuestionsCounter = 0;
    Map<String, String>? califications = {};

    TransversalQuestion? lastMain;

    int questionsInMain = 0;
    for (var question in transparencyQuestions!) {
      if (!question.isMain()) {
        transparencyQuestionsCounter++;
        questionsInMain++;
        if (question.completed) {
          transparencyQuestionsCompleted++;
          transparencyCounters.last++;
        }
      } else {
        if (lastMain != null) {
          califications[lastMain.code] =
              "${transparencyCounters.last}/$questionsInMain";
        }
        questionsInMain = 0;
        lastMain = question;
        transparencyCounters.add(0);
      }
    }

    if (lastMain != null) {
      califications[lastMain.code] =
          "${transparencyCounters.last}/$questionsInMain";
    }

    Widget panel = Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        // height: 150,
        color: Colors.white,
        child: currentProject != null
            ? Column(children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: actionButtonVertical(
                            context,
                            'Nuevo ítem',
                            transparencyQuestionDialog,
                            Icons.add,
                            {'context': context, 'item': null}))),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: transparencyQuestions!.length,
                    itemBuilder: (BuildContext context, int index) {
                      TransversalQuestion item =
                          transparencyQuestions!.elementAt(index);
                      TextStyle style = (item.isMain()
                          ? successText.copyWith(color: Colors.white)
                          : normalText);
                      Color bgColor =
                          (item.isMain() ? mainColor : Colors.white);
                      return Tooltip(
                          message: 'Click para editar',
                          showDuration: const Duration(seconds: 0),
                          child: ListTile(
                              subtitle: Container(
                                  color: bgColor,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(
                                                  item.code,
                                                  style: style,
                                                )),
                                          )),
                                      Expanded(
                                          flex: 8,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(
                                                  (item.isMain())
                                                      ? "${item.subject} (${califications[item.code]})"
                                                      : item.subject,
                                                  style: style,
                                                )),
                                          )),
                                      Expanded(
                                        flex: 2,
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
                                        flex: 6,
                                        child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              item.isMain()
                                                  ? "Comentarios"
                                                  : item.comments,
                                              style: style,
                                              textAlign: TextAlign.left,
                                            )),
                                      ),
                                      Expanded(
                                        flex: 2,
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
                                  )),
                              onTap: () {
                                transparencyQuestionDialog(
                                    {'context': context, 'item': item});
                              }));
                    })
              ])
            : const Center(
                child: CircularProgressIndicator(),
              ));

    return Column(children: [
      panel,
      const Divider(
        height: 1,
      ),
    ]);
  }

  void transparencyQuestionDialog(args) {
    BuildContext context = args['context'];
    currentQuestion = args['item'];
    _transparencyQuestionDialog(context).then((value) {
      if (value != null) {
        setState(() {
          transparency = value;
          transparencyQuestions = transparency!.questions;
          transparencyPanelWidget = transparencyPanel();
        });
      }
    });
  }

  Future<Transparency?> _transparencyQuestionDialog(context) {
    currentQuestion ??= TransversalQuestion.getEmpty();
    return showDialog<Transparency>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context2) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Item de transparencia'),
          content: Wrap(children: [
            TransversalQuestionForm(
              key: null,
              currentQuestion: currentQuestion,
              currentTransversal: transparency as Transversal,
            )
          ]),
        );
      },
    );
  }

////// GENERAL
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
                      Text(currentProject!.name, style: headerTitleText),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 35, top: 20, bottom: 15),
                  child: Row(
                    children: [
                      customText("Transversal", 20),
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
              indicator(
                  "Transparencia",
                  "$transparencyQuestionsCompleted/$transparencyQuestionsCounter",
                  addTransparencyPanel),
              transparencyPanelWidget ?? Container(height: 0),
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
