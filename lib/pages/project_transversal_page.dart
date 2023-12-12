// ignore_for_file: avoid_unnecessary_containers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sic4change/services/models.dart';
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
          style: mainText.copyWith(fontSize: 14),
        ),
        space(height: 10),
        Text(
          text,
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

  Widget totalBudget(context, SProject project) {
    double percent = 50;
    String budget_in_euros = toCurrency(double.parse(project.budget));
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
                    child: Text(budget_in_euros, style: subTitleText))),
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

  @override
  void initState() {
    super.initState();
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
      if (qualityPanelWidget == null) {
        qualityPanelWidget = qualityPanel();
      } else {
        qualityPanelWidget = null;
      }
    });
  }

  Widget qualityPanel() {
    List<dynamic> headers = [
      [
        "Necesidades del conjunto de clientes y otras partes interesadas",
        4,
        TextAlign.left
      ],
      ["Cumplido", 1, TextAlign.center],
      ["Comentarios", 4, TextAlign.left],
      ["Documentos", 1, TextAlign.center],
      ["Puntuación (3/4)", 1, TextAlign.center]
    ];

    List<dynamic> rows = [
      [
        [
          'Quiénes son los clientes finales (personas destinatarias) y otras partes interesadas en la intervención',
          4,
          TextAlign.left
        ],
        ['Sí', 1, TextAlign.center],
        ['Niños menores de 12 años de entornos rurales', 4, TextAlign.left],
        ['', 2, TextAlign.center],
      ],
      [
        [
          '¿Los materiales y recursos del proyecto son adecuados para los usuarios?',
          4,
          TextAlign.left
        ],
        ['Sí', 1, TextAlign.center],
        ['', 4, TextAlign.left],
        ['', 2, TextAlign.center],
      ],
      [
        [
          '¿Los métodos de enseñanza y aprendizaje del proyecto son eficaces?',
          4,
          TextAlign.left
        ],
        ['Sí', 1, TextAlign.center],
        ['', 4, TextAlign.left],
        ['', 2, TextAlign.center],
      ],
      [
        [
          '¿El número de usuarios se corresponde con lo esperado?',
          4,
          TextAlign.left
        ],
        ['No', 1, TextAlign.center],
        ['', 4, TextAlign.left],
        ['', 2, TextAlign.center],
      ],
    ];
    return Column(children: [
      Container(
          color: mainColor,
          child: Row(children: [
            for (var header in headers)
              Expanded(
                flex: header[1],
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(header[0],
                            textAlign: header[2],
                            style: mainText.copyWith(color: Colors.white)))),
              ),
          ])),
      for (var row in rows)
        Column(children: [
          Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Row(children: [
                  for (var col in row)
                    Expanded(
                        flex: col[1],
                        child:
                            Text(col[0], textAlign: col[2], style: normalText)),
                ]),
              )),
          const Divider(height: 1),
        ])
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
          const Divider(height: 1),
        ]));
  }

  Widget multiplesIndicators() {
    return Card(
        elevation: 5,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(children: [
              indicator("Calidad", "3/4", addQualityPanel),
              qualityPanelWidget ?? Container(height: 0),
              indicator("Transparencia", "8/10", print),
              indicator("Género", "7/9", print),
              indicator("Medio Ambiente", "5/8", print),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    if (currentProject == null) {}
    return Scaffold(body: SingleChildScrollView(child: content(context)));
  }
}
