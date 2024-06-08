import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/evaluation_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_evaluation.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

// conclussion = {
//   'description': "",
//   'stakeholder': "",
//   'isRefML': "No",
//   'unit': "",
//   'relevance': 1,
//   'feasibility': 1,
//   'recipientResponse': "",
//   'improvementAction': "",
//   'deadline': DateTime.now(),
//   'verificationMethod': "",
//   'followUp': "",
//   'followUpDate': DateTime.now(),
//   'supervision': "",
//   'observations': "",
// };

class EvaluationPage extends StatefulWidget {
  final SProject project;
  const EvaluationPage({super.key, required this.project});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  late SProject project;
  Evaluation? evaluation;

  @override
  initState() {
    super.initState();
    project = widget.project;
    Evaluation.byProjectUuid(project.uuid).then((value) {
      if (value == null) {
        value = Evaluation(project.uuid);
        value.save();
      }
      if (mounted) {
        setState(() {
          evaluation = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        pathHeader(context, project!.name),
        evaluationHeader(context, project),
        marcoMenu(context, project, "evaluation"),
        (evaluation == null)
            ? const Center(child: CircularProgressIndicator())
            : contentTab(context, contentEvaluation, evaluation),
        footer(context),
      ]),
    );
  }

/*-------------------------------------------------------------
                            EVALIATION
-------------------------------------------------------------*/
  Widget evaluationHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget contentEvaluation(context, evaluation) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              customCollapse(context, 'Conclusiones/Recomendación evaluación',
                  populateConclussions, evaluation),
              const Divider(),
              customCollapse(
                  context,
                  'Necesidades y expectativas partes interesadas',
                  populateRequirements,
                  evaluation),
            ],
          )),
    );
  }

  Widget populateConclussions(context, Evaluation obj) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: addBtnRow(
                  context, evaluationEditDialog, {"index": -1, "type": 0})),
        ]),
        for (var i = 0; i < obj.conclussions.length; i++)
          conclussionCard(context, {"index": i}),
      ],
    );
  }

  Widget conclussionContent(context, args) {
    Map<String, dynamic> conclussion = evaluation!.conclussions[args["index"]];

    if (conclussion["deadline"] is String) {
      conclussion["deadline"] =
          DateFormat('dd/MM/yyyy').parse(conclussion["deadline"]);
    } else if (conclussion["deadline"] is Timestamp) {
      conclussion["deadline"] = (conclussion["deadline"] as Timestamp).toDate();
    }

    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
              padding: const EdgeInsets.only(right: 0, top: 0),
              child: iconBtn(context, evaluationEditDialog,
                  {"index": args["index"], "type": 0},
                  icon: Icons.edit, text: "Editar")),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Partes interesadas'),
                  subtitle: Text(conclussion["stakeholder"] ?? ""),
                  titleTextStyle: TextTheme().bodyMedium,
                  subtitleTextStyle: TextTheme().bodyLarge,
                )),
          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: Text('Referencia ML', style: TextTheme().bodyMedium),
                  subtitle: Container(
                      alignment: Alignment.centerLeft,
                      child: getIcon(conclussion["isRefML"] == "Sí")),
                ),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Unidad'),
                  subtitle: Text(conclussion["unit"] ?? ""),
                ),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Relevancia'),
                  subtitle: Text(conclussion["relevance"].toString()),
                ),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Viabilidad'),
                  subtitle: Text(conclussion["feasibility"].toString()),
                ),
              )),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Respuesta del destinatario'),
                  subtitle: Text(conclussion["recipientResponse"] ?? ""),
                )),
          ),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Acción de mejora'),
                  subtitle: Text(conclussion["improvementAction"] ?? ""),
                )),
          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Fecha límite'),
                  subtitle: Text(DateFormat('dd/MM/yyyy')
                      .format(getDate(conclussion["deadline"]))),
                ),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Método de verificación'),
                  subtitle: Text(conclussion["verificationMethod"] ?? ""),
                ),
              )),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Seguimiento'),
                  subtitle: Text(conclussion["followUp"] ?? ""),
                )),
          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Fecha de seguimiento'),
                  subtitle: Text(DateFormat('dd/MM/yyyy')
                      .format(getDate(conclussion["followUpDate"]))),
                ),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Supervisión'),
                  subtitle: Text(conclussion["supervision"] ?? ""),
                ),
              )),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: ListTile(
                  title: const Text('Observaciones'),
                  subtitle: Text(conclussion["observations"] ?? ""),
                )),
          ),
        ]),
      ],
    );
  }

  Widget conclussionCard(context, args) {
    int index = args["index"];
    var conclussion = evaluation!.conclussions[index];
    return Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              customCollapse(context, conclussion["description"],
                  conclussionContent, {"index": index},
                  style: "secondary", expanded: false),
            ],
          ),
        ));
  }

  Widget populateRequirements(context, Evaluation obj) {
    return Column(
      children: [
        for (var i = 0; i < obj.requirements.length; i++)
          customCollapse(context, 'Requerimiento ${i + 1}', (context, args) {
            return Container();
          }, null),
      ],
    );
  }

  Future<void> evaluationEditDialog(context, args) async {
    int index = args["index"];
    int type = args["type"];
    final _keysDictionary = [
      "conclussions",
      "requirements",
    ];
    final _titlesDictionary = [
      "Conclusión",
      "Requerimiento/Necesidad",
    ];

    return showDialog<Evaluation>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar((index >= 0)
              ? 'Editando ${_titlesDictionary[type % 2]}'
              : 'Añadiendo ${_titlesDictionary[type % 2]}'),
          content:
              EvaluationForm(evaluation: evaluation!, type: type, index: index),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {});
      }
    });
  }
}
