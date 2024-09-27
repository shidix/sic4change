// ignore_for_file: avoid_unnecessary_containers

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:js_util';

import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/logs_lib.dart';
// import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_quality.dart';
import 'package:sic4change/services/transversal_question_form.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  final Profile? profile;

  const ProjectTransversalPage({Key? key, this.currentProject, this.profile})
      : super(key: key);

  @override
  createState() => _ProjectTransversalPageState();
}

class _ProjectTransversalPageState extends State<ProjectTransversalPage> {
  TransversalQuestion? currentQuestion;
  //User user = FirebaseAuth.instance.currentUser!;
  SProject? currentProject;
  Profile? profile;

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

  Gender? gender;
  Widget? genderPanelWidget;
  List? genderQuestions;
  int genderQuestionsCompleted = 0;
  int genderQuestionsCounter = 0;
  List<int> genderCounters = [];
  bool collapsedGender = false;

  Environment? environment;
  Widget? environmentPanelWidget;
  List? environmentQuestions;
  int environmentQuestionsCompleted = 0;
  int environmentQuestionsCounter = 0;
  List<int> environmentCounters = [];
  bool collapsedEnvironment = false;

  @override
  void initState() {
    super.initState();
    if (widget.profile == null) {
      Profile.getCurrentProfile().then((value) {
        profile = value;
        if (mounted) {
          setState() {}
        }
      });
    } else {
      profile = widget.profile;
    }
    currentProject = widget.currentProject;
    profile = widget.profile;

    Quality.byProject(currentProject!.uuid).then((Quality value) {
      if (value.questions.isEmpty) {
        quality = value;
        rootBundle.loadString('config/quality.json').then((value) {
          Quality template = Quality.fromJson(jsonDecode(value));
          quality!.questions = template.questions;
          quality!.save();
          qualityPanel();
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        quality = value;
        qualityPanel();
        if (mounted) {
          setState(() {});
        }
      }
    });

    Transparency.byProject(widget.currentProject!.uuid).then((value) {
      if (value.questions.isEmpty) {
        transparency = value;
        rootBundle.loadString('config/transparency.json').then((value) {
          Transparency template = Transparency.fromJson(jsonDecode(value));
          transparency!.questions = template.questions;
          transparency!.save();
          transparencyPanel();
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        transparency = value;
        transparencyPanel();
        if (mounted) {
          setState(() {});
        }
      }
    });

    Gender.byProject(widget.currentProject!.uuid).then((value) {
      if (value.questions.isEmpty) {
        gender = value;
        rootBundle.loadString('config/gender.json').then((value) {
          Gender template = Gender.fromJson(jsonDecode(value));
          gender!.questions = template.questions;
          gender!.save();
          genderPanel();
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        gender = value;
        genderPanel();
        if (mounted) {
          setState(() {});
        }
      }
    });

    Environment.byProject(widget.currentProject!.uuid).then((value) {
      if (value.questions.isEmpty) {
        environment = value;
        rootBundle.loadString('config/environment.json').then((value) {
          Environment template = Environment.fromJson(jsonDecode(value));
          environment!.questions = template.questions;
          environment!.save();
          environmentPanel();
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        environment = value;
        environmentPanel();
        if (mounted) {
          setState(() {});
        }
      }
    });

    createLog("Acceso a Transversal de la iniciativa: ${currentProject!.name}");
  }

  List<Widget> panelActions(dialog, code) {
    List<Widget> actions = [
      ["Admin", "Supervisor"].contains(profile!.mainRole)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: actionButtonVertical(context, 'Resetear', resetSection,
                  Icons.refresh, {'context': context, 'code': code}))
          : Container(),
      Padding(
          padding:
              const EdgeInsets.only(right: 20, top: 10, bottom: 10, left: 5),
          child: actionButtonVertical(context, 'Nuevo ítem', dialog, Icons.add,
              {'context': context, 'item': null})),
    ];
    return actions;
  }

  void resetSection(args) async {
    bool confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Confirmación de borrado'),
              content: const Text(
                  'Vas a resetear el cuestionario. Se eliminarán todas las respuestas y las preguntas adicionales que hayas podido agregar. ¿Quiers confirmar?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Cancelar')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Aceptar')),
              ]);
        }) as bool;
    if (confirmation) {
      String code = args['code'];
      if (code == "transparency") {
        transparency!.questions = [];
        transparency!.save();

        transparencyPanel();
        if (mounted) {
          setState(() {});
        }
      } else if (code == "gender") {
        gender!.questions = [];
        gender!.save();
        genderPanel();
        if (mounted) {
          setState(() {});
        }
      } else if (code == "environment") {
        environment!.questions = [];
        environment!.save();
        environmentPanel();
        if (mounted) {
          setState(() {});
        }
      } else if (code == "quality") {
        quality!.questions = [];
        quality!.save();
        qualityPanel();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  Widget generalPanel(context, questions, califications, dialog, code) {
    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        // height: 150,
        color: Colors.white,
        child: currentProject != null
            ? Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: panelActions(dialog, code)),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: questions!.length,
                    itemBuilder: (BuildContext context, int index) {
                      TransversalQuestion item = questions!.elementAt(index);
                      return Tooltip(
                          message: 'Click para editar',
                          showDuration: const Duration(seconds: 0),
                          child: ListTile(
                              subtitle: rowTransversal(item, califications),
                              onTap: () {
                                dialog({'context': context, 'item': item});
                              }));
                    })
              ])
            : const Center(
                child: CircularProgressIndicator(),
              ));
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

    qualityQuestions!.sort((a, b) => a.compareTo(b));
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

    Widget panel = generalPanel(context, qualityQuestions, califications,
        qualityQuestionDialog, "quality");

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

//// GENDER QUESTIONS ////
  void addGenderPanel(args) {
    setState(() {
      collapsedGender = !collapsedGender;
      if (collapsedGender) {
        genderPanelWidget = genderPanel();
      } else {
        genderPanelWidget = null;
      }
    });
  }

  void genderQuestionDialog(args) {
    BuildContext context = args['context'];
    currentQuestion = args['item'];

    _genderQuestionDialog(context).then((value) {
      if (value != null) {
        setState(() {
          gender = value;
          genderQuestions = gender!.questions;
          genderPanelWidget = genderPanel();
        });
      }
    });
  }

  Future<Gender?> _genderQuestionDialog(context) {
    currentQuestion ??= TransversalQuestion.getEmpty();
    return showDialog<Gender>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context2) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Item de Género'),
          content: Wrap(children: [
            TransversalQuestionForm(
              key: null,
              currentQuestion: currentQuestion,
              currentTransversal: gender as Transversal,
            )
          ]),
        );
      },
    );
  }

  Widget genderPanel() {
    genderQuestions = gender!.questions;

    genderQuestions!.sort((a, b) => a.compareTo(b));
    genderCounters = [];
    genderQuestionsCompleted = 0;
    genderQuestionsCounter = 0;
    Map<String, String>? califications = {};

    TransversalQuestion? lastMain;

    int questionsInMain = 0;
    for (var question in genderQuestions!) {
      if (!question.isMain()) {
        genderQuestionsCounter++;
        questionsInMain++;
        if (question.completed) {
          genderQuestionsCompleted++;
          genderCounters.last++;
        }
      } else {
        if (lastMain != null) {
          califications[lastMain.code] =
              "${genderCounters.last}/$questionsInMain";
        }
        questionsInMain = 0;
        lastMain = question;
        genderCounters.add(0);
      }
    }

    if (lastMain != null) {
      califications[lastMain.code] = "${genderCounters.last}/$questionsInMain";
    }

    Widget panel = generalPanel(context, genderQuestions, califications,
        genderQuestionDialog, "gender");
    return Column(children: [
      panel,
      const Divider(
        height: 1,
      ),
    ]);
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

    transparencyQuestions!.sort((a, b) => a.compareTo(b));
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

    Widget panel = generalPanel(context, transparencyQuestions, califications,
        transparencyQuestionDialog, 'transp');

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

////// Environment
  void addEnvironmentPanel(args) {
    setState(() {
      collapsedEnvironment = !collapsedEnvironment;
      if (collapsedEnvironment) {
        environmentPanelWidget = environmentPanel();
      } else {
        environmentPanelWidget = null;
      }
    });
  }

  Widget environmentPanel() {
    environmentQuestions = environment!.questions;

    environmentQuestions!.sort((a, b) => a.compareTo(b));
    environmentCounters = [];
    environmentQuestionsCompleted = 0;
    environmentQuestionsCounter = 0;
    Map<String, String>? califications = {};

    TransversalQuestion? lastMain;

    int questionsInMain = 0;
    for (var question in environmentQuestions!) {
      if (!question.isMain()) {
        environmentQuestionsCounter++;
        questionsInMain++;
        if (question.completed) {
          environmentQuestionsCompleted++;
          environmentCounters.last++;
        }
      } else {
        if (lastMain != null) {
          califications[lastMain.code] =
              "${environmentCounters.last}/$questionsInMain";
        }
        questionsInMain = 0;
        lastMain = question;
        environmentCounters.add(0);
      }
    }

    if (lastMain != null) {
      califications[lastMain.code] =
          "${environmentCounters.last}/$questionsInMain";
    }

    Widget panel = generalPanel(context, environmentQuestions, califications,
        environmentQuestionDialog, "environment");
    return Column(children: [
      panel,
      const Divider(
        height: 1,
      ),
    ]);
  }

  void environmentQuestionDialog(args) {
    BuildContext context = args['context'];
    currentQuestion = args['item'];
    _environmentQuestionDialog(context).then((value) {
      if (value != null) {
        setState(() {
          environment = value;
          environmentQuestions = environment!.questions;
          environmentPanelWidget = environmentPanel();
        });
      }
    });
  }

  Future<Environment?> _environmentQuestionDialog(context) {
    currentQuestion ??= TransversalQuestion.getEmpty();
    return showDialog<Environment>(
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
              currentTransversal: environment as Transversal,
            )
          ]),
        );
      },
    );
  }

////// GENERAL

  void exportTransversal() async {
    Quality qualityCopy = Quality.fromJson(quality!.toJson());
    qualityCopy.id = "";
    qualityCopy.uuid = "";
    qualityCopy.project = "";

    Gender genderCopy = Gender.fromJson(gender!.toJson());
    genderCopy.id = "";
    genderCopy.uuid = "";
    genderCopy.project = "";

    Transparency transparencyCopy =
        Transparency.fromJson(transparency!.toJson());
    transparencyCopy.id = "";
    transparencyCopy.uuid = "";
    transparencyCopy.project = "";

    Environment environmentCopy = Environment.fromJson(environment!.toJson());
    environmentCopy.id = "";
    environmentCopy.uuid = "";
    environmentCopy.project = "";

    String qualityString = jsonEncode(qualityCopy);
    AnchorElement(
        href:
            "data:application/json;charset=utf-16,${Uri.encodeComponent(qualityString)}")
      ..setAttribute("download", "quality.json")
      ..click();

    String genderString = jsonEncode(genderCopy);
    AnchorElement(
        href:
            "data:application/json;charset=utf-16,${Uri.encodeComponent(genderString)}")
      ..setAttribute("download", "gender.json")
      ..click();

    String transparencyString = jsonEncode(transparencyCopy);
    AnchorElement(
        href:
            "data:application/json;charset=utf-16,${Uri.encodeComponent(transparencyString)}")
      ..setAttribute("download", "transparency.json")
      ..click();

    String environmentString = jsonEncode(environmentCopy);
    AnchorElement(
        href:
            "data:application/json;charset=utf-16,${Uri.encodeComponent(environmentString)}")
      ..setAttribute("download", "environment.json")
      ..click();
  }

  Container rowTransversal(item, califications) {
    TextStyle style = (item.isMain()
        ? successText.copyWith(color: Colors.white)
        : normalText);
    Color bgColor = (item.isMain() ? mainColor : Colors.white);
    return Container(
        color: bgColor,
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
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
                      padding: const EdgeInsets.all(10),
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
                        ? "Cumple"
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
                    item.isMain() ? "Comentarios" : item.comments,
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
                            ? item.docs.join(",")
                            : '',
                    style: style,
                    textAlign: TextAlign.center,
                  )),
            ),
          ],
        ));
  }

  // Widget statusProject() {
  //   return Container(
  //       child: Row(children: [
  //     Expanded(flex: 1, child: statusEjecucion(context, currentProject!)),
  //     Expanded(flex: 1, child: totalBudget(context, currentProject!)),
  //   ]));
  // }

  Widget topButtons(BuildContext context) {
    if (profile == null) {
      return Container();
    }
    List<Widget> buttons = [
      (["Admin", "Supervisor"].contains(profile!.mainRole))
          ? actionButtonVertical(context, "Exportar", exportTransversal,
              Icons.download_for_offline_outlined, null)
          : Container(),
      (["Admin", "Supervisor"].contains(profile!.mainRole))
          ? space(width: 5)
          : Container(),
      goPage(
        context,
        "Volver",
        const ProjectsPage(),
        Icons.arrow_circle_left_outlined,
      ),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  Widget content(context) {
    if (currentProject == null) {
      return Column(children: [
        mainMenu(context, "/projects"),
        Container(height: MediaQuery.of(context).size.height * 0.75),
        const Center(child: CircularProgressIndicator()),
        footer(context),
      ]);
    } else {
      return Column(
        children: [
          mainMenu(context, "/projects"),
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
                topButtons(context),
                marcoMenu(context, currentProject, "transversal"),
                multiplesIndicators(),
                footer(context),
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
              indicator(
                  "Género",
                  "$genderQuestionsCompleted/$genderQuestionsCounter",
                  addGenderPanel),
              genderPanelWidget ?? Container(height: 0),
              indicator(
                  "Medio Ambiente",
                  "$environmentQuestionsCompleted/$environmentQuestionsCounter",
                  addEnvironmentPanel),
              environmentPanelWidget ?? Container(height: 0),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    if (currentProject == null) {}
    return Scaffold(body: SingleChildScrollView(child: content(context)));
  }
}
