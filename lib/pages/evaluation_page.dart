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
      body: SingleChildScrollView(
        child:
      
      Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        mainAxisSize: MainAxisSize.min,
        children: [
        mainMenu(context),
        pathHeader(context, project!.name),
        evaluationHeader(context, project),
        marcoMenu(context, project, "evaluation"),
        (evaluation == null)
            ? const Center(child: CircularProgressIndicator())
            : contentTab(context, contentEvaluation, evaluation),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            EVALUATION
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
              customCollapse(
                  context,
                  const Text(
                    'Conclusiones/Recomendación evaluación',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                  populateConclussions,
                  evaluation),
              const Divider(),
              customCollapse(
                  context,
                  const Text(
                    'Necesidades y expectativas partes interesadas',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                  populateRequirements,
                  evaluation),
            ],
          )),
    );
  }

  void removeItem(context, args) {
    int index = args["index"];
    int type = args["type"];

    if (type == 0) {
      evaluation!.conclussions.removeAt(index);
    } else {
      evaluation!.requirements.removeAt(index);
    }
    evaluation!.save();
    setState(() {});
  }

  Widget itemContent(context, args) {
    Map<String, dynamic> item;
    int type = args["type"];

    if (type == 0) {
      item = evaluation!.conclussions[args["index"]];
    } else {
      item = evaluation!.requirements[args["index"]];
    }

    if (item["deadline"] is String) {
      item["deadline"] =
          DateFormat('dd/MM/yyyy').parse(item["deadline"]);
    } else if (item["deadline"] is Timestamp) {
      item["deadline"] = (item["deadline"] as Timestamp).toDate();
    }
    

    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: 
            [
              Padding(
                  padding: const EdgeInsets.only(right: 0, top: 0),
                  child: iconBtn(context, evaluationEditDialog,
                      {"index": args["index"], "type": type},
                      icon: Icons.edit, text: "Editar")),
              Padding(
                  padding: const EdgeInsets.only(right: 0, top: 0),
                  child: removeConfirmBtn(context, removeItem, args) 
                  ),
            ]),
            Row(children: [
              Expanded(
                flex: (type == 0)?0:3,
                child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child:  (type == 0)? Container():
                    customTextLabel(
                      context,
                      "Partes interesadas",
                      item["stakeholder"],
                    )),
              ),
              Expanded(
                  flex: (type==0)?6:3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child: customTextLabel(
                      context,
                      "Unidad/Dpto",
                      item["unit"],
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child: customTextLabel(
                      context,
                      (type == 0)?"Referencia ML":"Necesidad",
                      getIcon(item["isRefML"] == "Sí", size: 18.0),
                    ),
                  )),

              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child: customTextLabel(
                      context,
                      "Relevancia",
                      item["relevance"].toString(),
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child: customTextLabel(
                      context,
                      "Viabilidad",
                      item["feasibility"].toString(),
                    ),
                  )),
            ]),
            Row(children: [
              Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child: customTextLabel(
                      context,
                      "Respuesta del destinatario",
                      item["recipientResponse"],
                    )),
              ),
            ]),
            Row(children: [
              Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child: customTextLabel(
                      context,
                      "Acción de mejora",
                      item["improvementAction"] ?? "",
                    )),
              ),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child: customTextLabel(
                      context,
                      "Fecha límite",
                      DateFormat('dd/MM/yyyy')
                          .format(getDate(item["deadline"])),
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 0),
                    child: customTextLabel(
                      context,
                      "Método de verificación",
                      item["verificationMethod"] ?? "",
                    ),
                  )),
            ]),
            Row(children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0, top: 0),
                  child: customTextLabel(
                    context,
                    "Seguimiento",
                    item["followUp"] ?? "",
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0, top: 0),
                  child: customTextLabel(
                    context,
                    "Fecha de seguimiento",
                    DateFormat('dd/MM/yyyy')
                        .format(getDate(item["followUpDate"])),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0, top: 0),
                  child: customTextLabel(
                    context,
                    "Supervisión",
                    item["supervision"] ?? "",
                  ),
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0, top: 0),
                  child: customTextLabel(context, "Observaciones",
                      item["observations"] ?? ""),
                ),
              ),
            ]),
          ],
        ));
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
    args["type"] = 0;
    return itemContent(context, args);
  }
  
  Widget conclussionCard(context, args) {
    int index = args["index"];
    var conclussion = evaluation!.conclussions[index];
    Map<String, dynamic> styleCollapse = { 
      "iconColor": mainMenuBtnSelectedColor,
      "bgColor": headerListBgColorIndicator,
      "titleColor": mainMenuBtnSelectedColor
      };
    return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 10, right: 10, left: 10),
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
                  style: styleCollapse, expanded: false),
            ],
          ),
        ));
  }

  Widget populateRequirements(context, Evaluation obj) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: addBtnRow(
                  context, evaluationEditDialog, {"index": -1, "type": 1})),
        ]),
        for (var i = 0; i < obj.requirements.length; i++)
          requirementCard(context, {"index": i}),

      ],
    );
  }

  Widget requirementCard(context, args) {
    int index = args["index"];
    var requirement = evaluation!.requirements[index];
    Map<String, dynamic> styleCollapse = { 
      "iconColor": mainMenuBtnSelectedColor,
      "bgColor": headerListBgColorIndicator,
      "titleColor": mainMenuBtnSelectedColor
      };
    return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 10, right: 10, left: 10),
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
              customCollapse(context, requirement["description"],
                  requirementContent, {"index": index},
                  style: styleCollapse, expanded: false),
            ],
          ),
        ));

  }

  Widget requirementContent(context, args) {
    args["type"] = 1;
    return itemContent(context, args);
  }

  Future<void> evaluationEditDialog(context, args) async {
    int index = args["index"];
    int type = args["type"];
    // final _keysDictionary = [
    //   "conclussions",
    //   "requirements",
    // ];
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
