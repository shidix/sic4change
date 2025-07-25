// import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:googleapis/photoslibrary/v1.dart';
// import 'package:googleapis/transcoder/v1.dart';
// import 'package:googleapis/youtubereporting/v1.dart';
import 'package:sic4change/pages/risks_tracks_form.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/services/models_risks.dart';
import 'package:sic4change/services/risks_form.dart';
import 'package:sic4change/services/utils.dart';
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
  Risk? riskSelected;
  SProject? project;
  List<Contact> contacts = [];
  List goals = [];
  List<Row> containerRisk = [];
  void loadRisks(value) async {
    await Risk.getRisksByProject(value).then((val) {
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
    // await getGoalsByProject(project!.uuid).then((val) {
    //   goals = val;
    // });
    goals = await Goal.getGoalsByProject(project!.uuid);
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    project = widget.project;
    risks = [];
    Contact.getAll().then((val) {
      for (var contact in val) {
        if ((project!.partners.contains(contact.organization)) ||
            (project!.managerObj.organization == contact.organization)) {
          contacts.add(contact);
        }
      }
    });

    Goal.getGoalsByProject(project!.uuid).then((val) {
      goals = val;
      if (mounted) {
        setState(() {});
      }
    });

    Risk.getRisksByProject(project!.uuid).then((val) {
      risks = val;
      if (mounted) {
        setState(() {});
      }
    });
    createLog("Acceso a Riesgos de la iniciativa: ${project!.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              mainMenu(context),
              pathHeader(context, project!.name),
              riskHeader(context, project),
              marcoMenu(context, project, "risk"),
              contentTab(context, riskList, project),
              footer(context),
            ]),
      ),

      // Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      //   mainMenu(context),
      //   pathHeader(context, project!.name),
      //   riskHeader(context, project),
      //   marcoMenu(context, project, "risk"),
      //   contentTab(context, riskList, project),
      //   footer(context),
      // ]),
    );
  }

/*-------------------------------------------------------------
                            RISKS
-------------------------------------------------------------*/
  Widget riskHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
    String goalSelected = "Ninguno";
    for (var goal in goals) {
      if (!goal.name.contains(".")) {
        goal.name = goal.name + ".";
      }
      String option = goal.name.split('.')[0];
      if (option != "") {
        goalsOptions.add(KeyValue(option, option));
        if (option == risk.extraInfo["objetivo"]) {
          goalSelected = option;
        }
      }
    }

    if (!(risk.extraInfo["marco_logico"] == "Sí")) {
      risk.extraInfo["marco_logico"] = "No";
    }

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
                      risk.description = val;
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
                    initial: risk.extraInfo["marco_logico"],
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
                    initial: goalSelected,
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
                      risk.extraInfo["prob"] = val;
                      risk.extraInfo["risk"] =
                          (int.parse(risk.extraInfo["prob"]!) *
                                  int.parse(risk.extraInfo["impact"]!))
                              .toString();
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
                      risk.extraInfo["impact"] = val;
                      risk.extraInfo["risk"] =
                          (int.parse(risk.extraInfo["prob"]!) *
                                  int.parse(risk.extraInfo["impact"]!))
                              .toString();
                    }))),
      ]),
      Row(children: [
        Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(left: 0, top: 20),
                child: CustomTextField(
                    labelText: "Descripción de lo ocurrido",
                    initial: risk.extraInfo["history"] ?? "",
                    size: 220,
                    maxLines: 5,
                    fieldValue: (String val) {
                      risk.extraInfo["history"] = val;
                    }))),
      ]),
    ];

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
                      risk.extraInfo["observations"] = val;
                    }))),
      ]),
    ];

    containerRisk += [
      Row(children: [
        Expanded(
            flex: 1,
            child: space(
              height: 40,
            ))
      ]),
    ];
    // + mitigationsList;

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
                        flex: 4,
                        child: CustomTextField(
                          labelText: "Nombre",
                          initial: risk.name,
                          size: 220,
                          fieldValue: (String val) {
                            risk.name = val;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: (risks.isNotEmpty)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (Risk risk in risks) riskRow(context, risk, project),
                  ],
                )
              : const Center(child: Text("No hay riesgos registrados")),
        ),
      ],
    );
  }

  Widget toggleRisk(context, risk) {
    List<Widget> riskContent = [
      space(height: 20),
      Row(children: [
        Expanded(
            flex: 5,
            child: customText("Relacionado con Marco Lógico", 14,
                bold: FontWeight.bold)),
        Expanded(
            flex: 5, child: customText("Objetivo", 14, bold: FontWeight.bold)),
        Expanded(
            flex: 1,
            child: customText("Probabilidad", 14,
                bold: FontWeight.bold, align: TextAlign.center)),
        Expanded(
            flex: 1,
            child: customText("Impacto", 14,
                bold: FontWeight.bold, align: TextAlign.center)),
        Expanded(
            flex: 1,
            child: customText("Combinado", 14,
                bold: FontWeight.bold, align: TextAlign.center)),
      ]),
      Row(children: [
        Expanded(
            flex: 5, child: customText(risk.extraInfo["marco_logico"], 14)),
        Expanded(flex: 5, child: customText(risk.extraInfo["objetivo"], 14)),
        Expanded(
            flex: 1,
            child: customText(risk.extraInfo["prob"], 14,
                align: TextAlign.center)),
        Expanded(
            flex: 1,
            child: customText(risk.extraInfo["impact"], 14,
                align: TextAlign.center)),
        Expanded(
            flex: 1,
            child: customText(risk.extraInfo["risk"], 14,
                align: TextAlign.center)),
      ]),
      space(height: 10),
      Row(children: [
        Expanded(
            flex: 1,
            child: customText("Descripción de lo ocurrido", 14,
                bold: FontWeight.bold)),
      ]),
      Row(children: [
        Expanded(flex: 1, child: customText(risk.extraInfo["history"], 14)),
      ]),
      space(height: 10),
      Row(children: [
        Expanded(
            flex: 1,
            child: customText("Observaciones", 14, bold: FontWeight.bold)),
      ]),
      Row(children: [
        Expanded(
            flex: 1, child: customText(risk.extraInfo["observations"], 14)),
      ]),
    ];

    List<Widget> mitigationsList = [space(height: 20)];
    int counter = 0;

    mitigationsList.add(Row(
      children: [
        Expanded(
            flex: 7,
            child: customText(
                "Medidas correctoras (${risk.extraInfo["mitigations"].length})",
                14,
                bold: FontWeight.bold)),
        Expanded(
            flex: 2,
            child: customText("Responsable", 14, bold: FontWeight.bold)),
        Expanded(flex: 1, child: customText("Tipo", 14, bold: FontWeight.bold)),
        Expanded(
            flex: 1,
            child: customText("Implementada", 14,
                bold: FontWeight.bold, align: TextAlign.center)),
        Expanded(
            flex: 1,
            child: customText("Fecha", 14,
                bold: FontWeight.bold, align: TextAlign.center)),
        Expanded(
            flex: 1,
            child: customText("Corrección", 14,
                bold: FontWeight.bold, align: TextAlign.center)),
        Expanded(
            flex: 2,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              addBtnRow(
                  context, mitigationEditDialog, {'risk': risk, 'index': -1})
            ])),
      ],
    ));

    for (var mitigation in risk.extraInfo["mitigations"]) {
      if (!["Sí", "No", "Parcialmente"].contains(mitigation["fixed"])) {
        mitigation["fixed"] = "No";
      }
      Icon fixedMitigation = (mitigation["fixed"] == "Sí")
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : (mitigation["fixed"] == "Parcialmente")
              ? const Icon(Icons.check_circle_outline, color: Colors.orange)
              : const Icon(Icons.remove_circle_outline, color: Colors.red);
      if (mitigation["date"] is String) {
        try {
          mitigation["date"] = DateFormat("dd/MM/yyyy")
              .parse(mitigation["date"].replaceAll("-", "/"));
        } catch (e) {
          mitigation["date"] = DateTime.now();
        }
        if ((DateTime(2015).isAfter(mitigation["date"])) ||
            ((DateTime(DateTime.now().year + 5).isAfter(mitigation["date"])))) {
          mitigation["date"] = DateTime.now();
        }
      }
      if (mitigation["date"] is Timestamp) {
        mitigation["date"] = mitigation["date"].toDate();
      }
      if (!mitigation.containsKey("type")) {
        mitigation["type"] = "Mitigación";
      }
      Object responsible = (getObject(contacts, mitigation["responsible"]));
      if (responsible == Null) {
        responsible = Contact('No asignado');
      }
      mitigationsList.add(Row(
        children: [
          Expanded(flex: 7, child: customText(mitigation["description"], 12)),
          Expanded(
              flex: 2, child: customText((responsible as Contact).name, 12)),
          Expanded(flex: 1, child: customText(mitigation["type"], 12)),
          Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.center,
                  child: (mitigation["implemented"])
                      ? const Icon(Icons.check_circle_outline,
                          color: Colors.green)
                      : const Icon(Icons.remove_circle_outline,
                          color: Colors.red))),
          Expanded(
              flex: 1,
              child: customText(
                  DateFormat('dd/MM/yyyy').format(mitigation["date"]), 12,
                  align: TextAlign.center)),
          Expanded(
              flex: 1,
              child:
                  Align(alignment: Alignment.center, child: fixedMitigation)),
          Expanded(
              flex: 2,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                editBtn(context, mitigationEditDialog,
                    {"risk": risk, "index": counter}),
                removeBtn(context, removeMitigationDialog,
                    {"risk": risk, "index": counter}),
                iconBtn(context, trackingListDialog,
                    {"risk": risk, "index": counter},
                    icon: Icons.center_focus_strong, text: "Seguimiento"),
              ]))
        ],
      ));
      counter += 1;
    }
    // mitigationsList.add(addBtn(context, mitigationEditDialog, {"mitigation": Mitigation(risk.uuid)}));
    panelMitigations[risk.uuid] = Column(children: mitigationsList);

    Widget panel = Container();
    if (panelMitigations.keys.contains(risk.uuid)) {
      panel = panelMitigations[risk.uuid]!;
    }

    return Column(
      children: riskContent + [space(height: 10), panel],
    );
  }

  Widget riskRow(context, risk, project) {
    risk.extraInfo["fixed"] = "No";
    for (Map<String, dynamic> mitigation in risk.extraInfo["mitigations"]) {
      if (mitigation.containsKey("fixed")) {
        if (mitigation["fixed"] == "Sí") {
          risk.extraInfo["fixed"] = "Sí";
          break;
        }
        if (mitigation["fixed"] == "Parcialmente") {
          risk.extraInfo["fixed"] = "Parcialmente";
        }
      }
    }

    Icon occurIcon = (risk.occur == "Sí")
        ? const Icon(Icons.check_circle_outline, color: Colors.green)
        : (risk.occur == "Parcialmente")
            ? const Icon(Icons.check_circle_outline, color: Colors.orange)
            : const Icon(Icons.remove_circle_outline, color: Colors.red);
    Icon fixedRisk = (risk.extraInfo["fixed"] == "Sí")
        ? const Icon(Icons.check_circle_outline, color: Colors.green)
        : (risk.extraInfo["fixed"] == "Parcialmente")
            ? const Icon(Icons.check_circle_outline, color: Colors.orange)
            : const Icon(Icons.remove_circle_outline, color: Colors.red);
    List<Widget> riskContent = [];

    riskContent = [
      Row(children: [
        Expanded(
            flex: 8,
            child: customText('${risk.name}', 16, bold: FontWeight.bold)),
        Expanded(
            flex: 2,
            child: customText('¿Ocurrió?', 16,
                bold: FontWeight.bold, align: TextAlign.center)),
        Expanded(
            flex: 2,
            child: customText('¿Se corrigió?', 16,
                bold: FontWeight.bold, align: TextAlign.center)),
        Expanded(
            flex: 1,
            child: Align(
                alignment: Alignment.centerRight,
                child: Row(children: [
                  editBtn(context, riskEditDialog, {"risk": risk}),
                  removeBtn(context, removeRiskDialog,
                      {"risk": risk, "project": project.uuid}),
                ]))),
      ]),
      Row(children: [
        Expanded(flex: 8, child: customText(risk.description, 14)),
        Expanded(flex: 2, child: occurIcon),
        Expanded(flex: 2, child: fixedRisk),
        Expanded(flex: 1, child: Container()),
      ]),
    ];

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: customCollapse(
            context, Column(children: riskContent), toggleRisk, risk,
            expanded: false));
  }

  Future<void> trackingListDialog(context, args) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Seguimiento de la medida correctora'),
          content: RisksTracksForm(risk: args["risk"], index: args["index"]),
        );
      },
    );
  }

  Future<void> removeMitigationDialog(context, args) {
    int index = args["index"];
    Risk risk = args["risk"];
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Eliminar Medida correctora'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                customText(
                    '¿Está seguro de que desea eliminar la medida correctora?',
                    16),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: customText('Cancelar', 16),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: customText('Eliminar', 16),
              onPressed: () {
                risk.extraInfo["mitigations"].removeAt(index);
                risk.save();
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> mitigationEditDialog(context, args) {
    Risk risk = args["risk"];
    int index = args["index"];

    Map<String, dynamic> mitigation = {
      "description": "",
      "implemented": false,
      "date": DateTime.now(),
      "responsible": "",
    };

    if (index >= 0) {
      mitigation = risk.extraInfo["mitigations"][args["index"]];
    }

    return showDialog<Risk>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar((mitigation["description"] != "")
              ? 'Editando Medida correctora'
              : 'Añadiendo Medida correctora'),
          content: MitigationForm(mitigation: mitigation, contacts: contacts),
          actions: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              saveBtnForm(context, (args) {
                mitigation = args[0];
                risk = args[1];
                if (mitigation["description"] != "") {
                  if (index >= 0) {
                    risk.extraInfo["mitigations"][index] = mitigation;
                  } else {
                    risk.extraInfo["mitigations"].add(mitigation);
                  }
                  risk.save();
                  // loadRisks(risk.project);
                  Navigator.of(context).pop(risk);
                  setState(() {});
                }
              }, [mitigation, risk]),
              space(width: 10),
              cancelBtnForm(context),
            ])
          ],
        );
      },
    );
  }

  void removeRiskDialog(context, args) {
    customRemoveDialog(context, args["risk"], loadRisks, args["project"]);
  }
}
