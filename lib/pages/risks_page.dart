import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:googleapis/transcoder/v1.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/services/models_risks.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const riskPageTitle = "Riesgos";
List risks = [];
Map<String, List> mitigations = {};
Map<String, Widget> panelMitigations = {};

class RisksPage extends StatefulWidget {
  final SProject? project;
  const RisksPage({super.key, this.project});

  @override
  State<RisksPage> createState() => _RisksPageState();
}

class _RisksPageState extends State<RisksPage> {
  SProject? project;
  List goals = [];
  List<Row> containerRisk = [];
  void loadRisks(value) async {
    await getRisksByProject(value).then((val) {
      risks = val;
      for (Risk risk in risks) {
        if (!risk.extraInfo.containsKey("mitigations")) {
          risk.extraInfo["mitigations"] = [];
        }
        mitigations[risk.uuid] = risk.extraInfo["mitigations"];
      }
      
    });
    setState(() {});
  }

  void loadGoals() async {
    await getGoalsByProject(project!.uuid).then((val) {
      goals = val;
    });
    setState(() {});
  }

  @override
  initState() {
    super.initState();

    project = widget.project;
    getGoalsByProject(project!.uuid).then((val) {
      goals = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    /*if (ModalRoute.of(context)!.settings.arguments != null) {
      Map args = ModalRoute.of(context)!.settings.arguments as Map;
      project = args["project"];
    } else {
      project = null;
    }

    if (project == null) return const Page404();*/

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        pathHeader(context, project!.name),
        riskHeader(context, project),
        marcoMenu(context, project, "risk"),
        contentTab(context, riskList, project),
        footer(context),
      ]),
    );
  }

/*-------------------------------------------------------------
                            RISKS
-------------------------------------------------------------*/
  Widget riskHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      /*Container(
        padding: const EdgeInsets.only(left: 40),
        child: customText(riskPageTitle, 20),
      ),*/
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, riskEditDialog, {'risk': Risk(project.uuid)}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveRisk(List args) async {
    Risk risk = args[0];
    risk.save();
    loadRisks(risk.project);

    Navigator.pop(context);
  }

  Future<void> riskEditDialog(context, Map<String, dynamic> args) {
    Risk risk = args["risk"];
    List<KeyValue> goalsOptions = [KeyValue("Ninguno", "Ninguno")];
    for (var goal in goals) {
      goalsOptions
          .add(KeyValue(goal.name.split('.')[0], goal.name.split('.')[0]));
    }
    if (!risk.extraInfo.containsKey("mitigations")) {
      risk.extraInfo["mitigations"] = [];
    }
    List<Row> mitigationsList = [];
    int counter = 0;
    for (var mitigation in risk.extraInfo["mitigations"]) {
      counter += 1;
      mitigationsList.add(Row(children: [
        Expanded(
            flex: 3,
            child: Padding(
                padding: const EdgeInsets.only(left: 0, top: 10),
                child: CustomTextField(
                  labelText: "Descripción",
                  initial: risk.extraInfo["mitigations"][counter]
                      ["description"],
                  size: 220,
                  maxLines: 5,
                  fieldValue: (String val) {
                    setState(() => mitigation["description"] = val);
                  },
                ))),
        Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: CustomSelectFormField(
                    labelText: "Implementada",
                    initial: mitigation["implemented"],
                    options: List<KeyValue>.from([
                      KeyValue("Preventiva", "Sí"),
                      KeyValue("Correctiva", "No"),
                    ]),
                    onSelectedOpt: (String val) {
                      setState(() => mitigation["implemented"] = val);
                    }))),
        Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: CustomTextField(
                    labelText: "Fecha",
                    initial: mitigation["date"],
                    size: 220,
                    fieldValue: (String val) {
                      setState(() => mitigation["date"] = val);
                    }))),
        Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: CustomTextField(
                  labelText: "Responsable",
                  initial: mitigation["responsible"],
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => mitigation["responsible"] = val);
                  },
                )))
      ]));
    }

    if (risk.occur != "No") {
      containerRisk = [
        Row(
          children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: const EdgeInsets.only(left: 0, top: 10),
                    child: CustomTextField(
                      labelText: "Descripción",
                      initial: risk.description,
                      size: 220,
                      maxLines: 5,
                      fieldValue: (String val) {
                        setState(() => risk.description = val);
                      },
                    ))),
          ],
        ),
        Row(children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(left: 0, top: 20),
                  child: CustomSelectFormField(
                      labelText: "Relacionado con Marco Lógico",
                      initial: risk.extraInfo["marco_logico"] ?? "No",
                      options: List<KeyValue>.from([
                        KeyValue("No", "No"),
                        KeyValue("Sí", "Sí"),
                      ]),
                      onSelectedOpt: (String val) {
                        risk.extraInfo["marco_logico"] = val;
                      }))),
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: CustomSelectFormField(
                      labelText: "Objetivo",
                      initial: risk.extraInfo["objetivo"] ?? "Ninguno",
                      options: goalsOptions,
                      onSelectedOpt: (String val) {
                        risk.extraInfo["objetivo"] = val;
                      }))),
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: CustomSelectFormField(
                      labelText: "Probabilidad",
                      initial: risk.extraInfo["prob"] ?? "1",
                      options: List<KeyValue>.from([
                        KeyValue("1", "1"),
                        KeyValue("2", "2"),
                        KeyValue("3", "3"),
                        KeyValue("4", "4"),
                      ]),
                      onSelectedOpt: (String val) {
                        setState(() {
                          risk.extraInfo["prob"] = val;
                          risk.extraInfo["risk"] =
                              (int.parse(risk.extraInfo["prob"]!) *
                                      int.parse(risk.extraInfo["impact"]!))
                                  .toString();
                        });
                      }))),
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: CustomSelectFormField(
                      labelText: "Impacto",
                      initial: risk.extraInfo["impact"] ?? "1",
                      options: List<KeyValue>.from([
                        KeyValue("1", "1"),
                        KeyValue("2", "2"),
                        KeyValue("3", "3"),
                        KeyValue("4", "4"),
                      ]),
                      onSelectedOpt: (String val) {
                        setState(() {
                          risk.extraInfo["impact"] = val;
                          risk.extraInfo["risk"] =
                              (int.parse(risk.extraInfo["prob"]!) *
                                      int.parse(risk.extraInfo["impact"]!))
                                  .toString();
                        });
                      }))),
        ]),
        Row(children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(left: 0, top: 20),
                  child: CustomTextField(
                      labelText: "Descripción de los ocurrido",
                      initial: risk.extraInfo["history"] ?? "",
                      size: 220,
                      maxLines: 5,
                      fieldValue: (String val) {
                        setState(() => risk.extraInfo["history"] = val);
                      }))),
        ])
      ];
      containerRisk += mitigationsList;
      containerRisk += [
        Row(children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(left: 0, top: 20),
                  child: CustomTextField(
                      labelText: "Observaciones",
                      initial: risk.extraInfo["observations"] ?? "",
                      size: 220,
                      maxLines: 5,
                      fieldValue: (String val) {
                        setState(() => risk.extraInfo["observations"] = val);
                      }))),
        ]),
      ];
    } else {
      containerRisk = [];
    }

    if (!risk.extraInfo.containsKey("impact")) {
      risk.extraInfo["impact"] = "1";
    }
    if (!risk.extraInfo.containsKey("prob")) {
      risk.extraInfo["prob"] = "1";
    }
    if (!risk.extraInfo.containsKey("risk")) {
      risk.extraInfo["risk"] = "1";
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar(
              (risk.name != "") ? 'Editando Riesgo' : 'Añadiendo Riesgo'),
          content: SingleChildScrollView(
              child: Column(
            children: [
                  Row(children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: CustomTextField(
                          labelText: "Nombre",
                          initial: risk.name,
                          size: 220,
                          fieldValue: (String val) {
                            setState(() => risk.name = val);
                          },
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: CustomSelectFormField(
                                labelText: "¿Ocurrió?",
                                initial: risk.occur,
                                options: List<KeyValue>.from([
                                  KeyValue("No", "No"),
                                  KeyValue("Parcialmente", "Parcialmente"),
                                  KeyValue("Sí", "Sí")
                                ]),
                                onSelectedOpt: (String val) {
                                  if (val != risk.occur) {
                                    risk.occur = val;
                                    Navigator.of(context).pop();
                                    riskEditDialog(context, {"risk": risk});
                                  }
                                }))),
                  ]),
                ] +
                containerRisk,
          )),
          actions: <Widget>[dialogsBtns(context, saveRisk, risk)],
        );
      },
    );
  }

  Widget riskList(context, project) {
    return FutureBuilder(
        future: getRisksByProject(project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            risks = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: risks.length,
                            itemBuilder: (BuildContext context, int index) {
                              Risk risk = risks[index];
                              return Container(
                                // height: 100,
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey[300]!, width: 1),
                                  ),
                                ),
                                child: riskRow(context, risk, project),
                              );
                            }))),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget riskRow(context, risk, project) {
    Icon occurIcon = (risk.occur == "Sí")
        ? const Icon(Icons.check_circle_outline, color: Colors.green)
        : (risk.occur == "Parcialmente")
            ? const Icon(Icons.check_circle_outline, color: Colors.orange)
            : const Icon(Icons.remove_circle_outline, color: Colors.red);

    Row riskContent = 
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText('${risk.name}', 16, bold: FontWeight.bold),
              space(height: 10),
              Text(risk.description),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText('¿Ocurrió?', 14, bold: FontWeight.bold),
            space(height: 10),
            occurIcon,
          ],
        ),
        Row(children: [
          editBtn(context, riskEditDialog, {"risk": risk}),
          removeBtn(context, removeRiskDialog,
              {"risk": risk, "project": project.uuid}),
          listBtn(context, toogleActions, {"risk": risk}, text: "Mitigaciones"),
        ])
      ],
    );
    Widget panel = Container();
    if (panelMitigations.keys.contains(risk.uuid)) {
      panel = panelMitigations[risk.uuid]!;
    } 

    return Column(children: [ riskContent, 
                              space(height: 10),    
                              panel],);

  }



  void toogleActions(context, args) {
    Risk risk = args["risk"];
    if (panelMitigations.keys.contains(args["risk"].uuid)) {
      panelMitigations.remove(args["risk"].uuid);
    } else {
      List<Widget> mitigationsList = [];
      int counter = 0;

      mitigationsList.add( 
        Row(children: [
          Expanded(flex: 3, child: customText("Descripción", 24, bold: FontWeight.bold)),
          Expanded(flex: 1, child: customText("Implementada", 24, bold: FontWeight.bold)),
          Expanded(flex: 1, child: customText("Fecha", 24, bold: FontWeight.bold)),
        ],));
      
      for (var mitigation in risk.extraInfo["mitigations"]) {
        
        mitigationsList.add(
          Row(children: [
            Expanded(flex: 3, child: customText(mitigation["description"], 16)),
            Expanded(flex: 1, child: (mitigation["implemented"]) ? const Icon(Icons.check_circle_outline, color: Colors.green) : const Icon(Icons.remove_circle_outline, color: Colors.red)),
            Expanded(flex: 1, child: customText(mitigation["date"], 16)),
          ],));
          counter += 1;
      }
      // mitigationsList.add(addBtn(context, mitigationEditDialog, {"mitigation": Mitigation(risk.uuid)}));
      panelMitigations[risk.uuid] = Column(children: mitigationsList);


    } 
  
    setState(() {});
  }

  void removeRiskDialog(context, args) {
    customRemoveDialog(context, args["risk"], loadRisks, args["project"]);
  }
}
