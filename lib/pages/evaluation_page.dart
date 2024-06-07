import 'package:flutter/material.dart';
import 'package:sic4change/services/evaluation_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_evaluation.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

//const riskPageTitle = "Riesgos";
//List risks = [];

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
              ? const Center(child:CircularProgressIndicator())
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
      child: Padding(padding: const EdgeInsets.all(15),
        child:
      
      Column(
        children: [
          customCollapse(context, 'Conclusiones/Recomendación evaluación', populateConclussions, evaluation),
          const Divider(),
          customCollapse(context, 'Necesidades y expectativas partes interesadas', populateRequirements, evaluation),
        ],
      )),
    );
  }

  Widget populateConclussions(context, Evaluation obj) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(padding: const EdgeInsets.all(10),
            child:
          addBtnRow(context, evaluationEditDialog, {"index": -1, "type": 0})),
        ]),

        for (var i = 0; i < obj.conclussions.length; i++)
          customCollapse(context, 'Conclusión ${i + 1}', (context, args) {return Container();}, null),
      ],
    );
  }

  Widget populateRequirements(context, Evaluation obj) {
    return Column(
      children: [
        for (var i = 0; i < obj.requirements.length; i++)
          customCollapse(context, 'Requerimiento ${i + 1}', (context, args) {return Container();}, null),
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


    String keyIndex = _keysDictionary[type % 6];
    Map<String, dynamic> item;

    // if (index >= 0) {
    //   item = evaluation?.toJson()[keyIndex][index];
    // } else {
    //   item = {
    //     'description': "",
    //     'stakeholder': "",
    //     'isRefML': "No",
    //     'unit': "",
    //     'relevance': 1,
    //     'feasibility': 1,
    //     'recipientResponse': "",
    //     'improvementAction': "",
    //     'deadline': DateTime.now(),
    //     'verificationMethod': "",
    //     'followUp': "",
    //     'followUpDate': DateTime.now(),
    //     'supervision': "",
    //     'observations': "",
    //   };
    // }

    return showDialog<Evaluation>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar((index >= 0)
              ? 'Editando ${_titlesDictionary[type % 2]}'
              : 'Añadiendo ${_titlesDictionary[type % 2]}'),
          content: EvaluationForm(evaluation: evaluation!, type: type, index: index),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {});
      }
    });
  }


}
