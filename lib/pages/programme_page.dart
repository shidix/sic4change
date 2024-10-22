import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/projects_page.dart';
import 'package:sic4change/services/diagram_lib.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/programme_lib.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const programmeTitle = "Programas";
bool loading = false;
Widget? _mainMenu;

class ProgrammePage extends StatefulWidget {
  final Programme? programme;
  const ProgrammePage({super.key, this.programme});

  @override
  State<ProgrammePage> createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> {
  Programme? programme;
  Profile? profile;
  List projects = [];
  List indicators = [];
  Map<String, double> financiers = {};
  Map<String, double> goalsPercent = {};
  Map<String, double> totalsExecuted = {};
  Map<String, double> projStatus = {};
  Map<String, int> sourceFinancing = {};

  double totalBudget = 0.0; //Suma de los presupuestos de los proyectos
  double totalFinancing = 0.0; //Suma de las aportaciones de los financiadores
  double totalExecuted =
      0.0; //Suma de los importes de las facturas de los proyectos
  double totalGoals =
      0.0; //Suma de los porcentajes de los indicadores específicos de los proyectos

  int touchedIndex = -1;

  void loadProgrammeProjects() async {
    setState(() {
      loading = true;
    });
    await getProjectsByProgramme(programme!.uuid).then((val) async {
      projects = val;
      financiers = await getProgrammeFinanciers(projects);
      projStatus = setProjectByStatus(projects);
      sourceFinancing = await setSourceFinancing(projects);
      totalsExecuted = await getTotalExectuteBudget(projects);
      goalsPercent = await getGoalsPercent(projects);
      totalFinancing = financiers["total"]!;
      totalGoals = goalsPercent["total"]!;
      totalExecuted = totalsExecuted["total"]!;
    });
    setState(() {
      loading = false;
    });

    for (SProject p in projects) {
      totalBudget = totalBudget + fromCurrency(p.budget);
    }

    indicators = await getProgrammesIndicators(programme!.uuid);
    setState(() {});
  }

  void getProfile(user) async {
    await Profile.getProfile(user.email!).then((value) {
      profile = value;
      //print(profile?.mainRole);
    });
  }

  @override
  void initState() {
    super.initState();
    programme = widget.programme;
    _mainMenu = mainMenu(context, "/projects");
    loadProgrammeProjects();

    final user = FirebaseAuth.instance.currentUser!;
    getProfile(user);
    createLog("Acceso a programa: ${programme!.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          _mainMenu!,
          programmeHeader(),
          loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    programmeGraphs(),
                    programmeProjects(context),
                  ],
                )
          //programmeList(context),
        ],
      ),
    ));
  }

  Widget programmeHeader() {
    return Container(
        padding: const EdgeInsets.only(left: 20, top: 20),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(programme!.logo),
            Container(
              padding: const EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(programme!.title, 16,
                      bold: FontWeight.bold, textColor: headerListTitleColor),
                  space(height: 10),
                  customText(programme!.description, 14),
                ],
              ),
            ),
            goPage(context, "Volver", const ProjectsPage(),
                Icons.arrow_circle_left_outlined),
          ],
        ));
  }

/*-------------------------------------------------------------
                      PROGRAMME GRAPHS
  -------------------------------------------------------------*/
  Widget programmeGraphs() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          row1(),
          space(height: 20),
          row2(),
          space(height: 10),
          row3(),
        ],
      ),
    );
  }

  Widget row1() {
    return Row(
      children: [
        diag1(),
        diag2(),
        diag3(),
      ],
    );
  }

  Widget diag1() {
    List<DiagramValues> diagList = [
      DiagramValues("Formulación",
          projStatus[statusFormulation]!.toStringAsFixed(2), diagramColors[0]),
      DiagramValues("Enviados", projStatus[statusSended]!.toStringAsFixed(2),
          diagramColors[1]),
      DiagramValues("Rechazados", projStatus[statusReject]!.toStringAsFixed(2),
          diagramColors[2]),
      DiagramValues("Denegado", projStatus[statusRefuse]!.toStringAsFixed(2),
          diagramColors[3]),
      DiagramValues("Aprobado", projStatus[statusApproved]!.toStringAsFixed(2),
          diagramColors[4]),
      DiagramValues("Iniciado", projStatus[statusStart]!.toStringAsFixed(2),
          diagramColors[5]),
      DiagramValues("Finalizado", projStatus[statusEnds]!.toStringAsFixed(2),
          diagramColors[6]),
      DiagramValues(
          "Justificación",
          projStatus[statusJustification]!.toStringAsFixed(2),
          diagramColors[7]),
      DiagramValues("Cerrado", projStatus[statusClose]!.toStringAsFixed(2),
          diagramColors[8]),
      DiagramValues("Entregado", projStatus[statusDelivery]!.toStringAsFixed(2),
          diagramColors[9]),
    ];

    return SizedBox(
        height: 300,
        width: 440,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          customText("Proyectos por estado", 16,
              bold: FontWeight.bold, textColor: headerListTitleColor),
          pieDiagram(diagList),
        ]));
  }

  Widget diag2() {
    List<DiagramValues> diagList = [
      DiagramValues("Nacional/Publico",
          sourceFinancing["Nacional/Publico"].toString(), diagramColors[0]),
      DiagramValues("Nacional/Privado",
          sourceFinancing["Nacional/Privado"].toString(), diagramColors[1]),
      DiagramValues(
          "Internacional/Publico",
          sourceFinancing["Internacional/Publico"].toString(),
          diagramColors[2]),
      DiagramValues(
          "Nacional/Publico",
          sourceFinancing["Internacional/Privado"].toString(),
          diagramColors[3]),
    ];

    return SizedBox(
        height: 300,
        width: 440,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          customText("Proyectos por ámbito", 16,
              bold: FontWeight.bold, textColor: headerListTitleColor),
          pieDiagram(diagList),
        ]));
  }

  Widget diag3() {
    List<DiagramValues> diagList = [];
    financiers.forEach((key, value) {
      String label = "$key: $value";
      double val = value * 100 / totalFinancing;
      diagList.add(DiagramValues(label, val.toStringAsFixed(2), randomColor()));
    });

    return SizedBox(
      height: 300,
      width: 440,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        customText("Proyectos por financiador", 16,
            bold: FontWeight.bold, textColor: headerListTitleColor),
        pieDiagram(diagList),
      ]),
    );
  }

  Widget row2() {
    List<DiagramValues2> diagList = [];
    for (ProgrammeIndicators ind in indicators) {
      diagList.add(
          DiagramValues2(ind.name, ind.expected, ind.obtained, randomColor()));
    }

    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [programmeImpact()],
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: SizedBox(
                  height: 300,
                  width: 450,
                  //child: barDiagram(diagList),
                  child: indicators.isNotEmpty
                      ? barDiagram(diagList)
                      : Container())),
        ],
      ),
    );
  }

  Widget row3() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: customText("Ejecución Técnica", 16,
                          bold: FontWeight.bold,
                          textColor: headerListTitleColor),
                    ),
                    //space(width: 10),
                    customLinearPercent(
                        context, 3.5, totalGoals, percentBarPrimary)
                  ],
                ),
                programmeProjectList(context),
              ])),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: Column(children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: customText("Ejecución Presupuestaria", 16,
                        bold: FontWeight.bold, textColor: headerListTitleColor),
                  ),
                  //space(width: 10),
                  customLinearPercent(context, 3.5,
                      (totalExecuted / totalFinancing), percentBarPrimary)
                ],
              ),
              programmeFinancierList(context),
            ]),
          ),
        ],
      ),
    );
  }

  Widget programmeProjectList(context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: projects.length,
        itemBuilder: (BuildContext context, int index) {
          SProject proj = projects[index];
          return Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: customText(proj.name, 14),
            ),
            customLinearPercent(
                context, 3.5, goalsPercent[proj.uuid], blueColor),
          ]);
        });
  }

  Widget programmeFinancierList(context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: financiers.length,
        itemBuilder: (BuildContext context, int index) {
          String key = financiers.keys.elementAt(index);
          double percent = (totalsExecuted[key]! > 0)
              ? financiers[key]! / totalsExecuted[key]!
              : 0;
          return key != ("total")
              ? Row(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: customText(key, 14),
                  ),
                  customLinearPercent(context, 3.5, percent, blueColor),
                  //customText(financiers[key].toString(), 14)
                ])
              : Container();
        });
  }

  Widget projectByStatus(context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(width: double.infinity, child: customText("", 14)),
    );
  }

  Widget programmeImpact() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          customText("Impacto (Objetivo Cero)", 16,
              bold: FontWeight.bold, textColor: headerListTitleColor),
          Row(
            children: [
              addBtnRow(
                  context, editProgrammeImpactDialog, {'programme': programme},
                  text: "Editar", icon: Icons.edit),
              addBtnRow(
                  context,
                  editProgrammeIndicatorDialog,
                  {
                    'indicator': ProgrammeIndicators(programme!.uuid),
                  },
                  text: "Añadir indicador",
                  icon: Icons.add_circle_outline),
            ],
          )
        ]),
        customText(programme!.impact, 14),
        space(height: 10),
        programmeIndicatorsRow(context),
      ],
    );
  }

  Widget programmeProjects(context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: projects.length,
            itemBuilder: (BuildContext context, int index) {
              SProject project = projects[index];
              return customCollapse(
                  context, project.name, programmeProjectDetails, project,
                  expanded: true);
            }));
  }

/*-------------------------------------------------------------
                      PROGRAMME IMPACT
  -------------------------------------------------------------*/
  void saveProgrammeImpact(List args) async {
    Programme programme = args[0];
    programme.save();
    setState(() {});
    createLog("Modificado el objetivo 0 del programa: ${programme.name}");
    Navigator.pop(context);
  }

  Future<void> editProgrammeImpactDialog(context, Map<String, dynamic> args) {
    Programme programme = args["programme"];
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Indicador de objetivo"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Impacto (Objetivo Cero)",
                  initial: programme.impact,
                  size: 800,
                  minLines: 2,
                  maxLines: 9999,
                  fieldValue: (String val) {
                    programme.impact = val;
                    //setState(() => indicator.name = val);
                  },
                )
              ]),
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveProgrammeImpact, programme),
          ],
        );
      },
    );
  }

/*-------------------------------------------------------------
                      PROGRAMME INDICATORS
  -------------------------------------------------------------*/
  void saveProgrammeIndicator(List args) async {
    ProgrammeIndicators indicator = args[0];
    //indicator.getFolder();
    indicator.save();
    if (!indicators.contains(indicator)) {
      indicators.add(indicator);
    }
    setState(() {});
    //loadGoals();

    Navigator.pop(context);
  }

  Future<void> editProgrammeIndicatorDialog(
      context, Map<String, dynamic> args) {
    ProgrammeIndicators indicator = args["indicator"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Indicador de objetivo"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: indicator.name,
                  size: 800,
                  minLines: 2,
                  maxLines: 9999,
                  fieldValue: (String val) {
                    indicator.name = val;
                    //setState(() => indicator.name = val);
                  },
                )
              ]),
              space(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Orden",
                  initial: indicator.order.toString(),
                  size: 100,
                  minLines: 2,
                  maxLines: 9999,
                  fieldValue: (String val) {
                    indicator.order = int.parse(val);
                    //setState(() => indicator.name = val);
                  },
                )
              ]),
            ])
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveProgrammeIndicator, indicator),
          ],
        );
      },
    );
  }

  Widget programmeIndicatorsRow(context) {
    if (indicators.isNotEmpty) {
      return Container(
        decoration: tableDecoration,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: false,
            //columnSpacing: 690,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => headerListBgColor),
            headingRowHeight: 40,
            columns: [
              DataColumn(
                label: customText("Orden", 14,
                    bold: FontWeight.bold, textColor: headerListTitleColor),
              ),
              DataColumn(
                label: customText("Nombre", 14,
                    bold: FontWeight.bold, textColor: headerListTitleColor),
              ),
              DataColumn(
                label: customText("Res. Esperado", 14,
                    bold: FontWeight.bold, textColor: headerListTitleColor),
              ),
              DataColumn(
                label: customText("Res. Obtenido", 14,
                    bold: FontWeight.bold, textColor: headerListTitleColor),
              ),
              DataColumn(label: Container())
            ],
            rows: indicators
                .map(
                  (indicator) => DataRow(cells: [
                    DataCell(customText(indicator.order.toString(), 14)),
                    DataCell(customText(indicator.name, 14)),
                    DataCell(customText(indicator.expected.toString(), 14)),
                    DataCell(customText(indicator.obtained.toString(), 14)),
                    DataCell(Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          editBtn(context, editProgrammeIndicatorDialog,
                              {"indicator": indicator, 'programme': programme}),
                          removeBtn(context, removeProgrammeIndicatorDialog,
                              {"indicator": indicator})
                        ]))
                  ]),
                )
                .toList(),
          ),
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  void updateProgrammeIndicators(args) {
    ProgrammeIndicators indicator = args;
    indicators.remove(indicator);
    setState(() {});
  }

  void removeProgrammeIndicatorDialog(context, args) {
    customRemoveDialog(context, args["indicator"], updateProgrammeIndicators,
        args["indicator"]);
    //customRemoveDialog(context, args["indicator"], loadGoals, null);
  }

/*-------------------------------------------------------------
                     PROJECTS
-------------------------------------------------------------*/
  Future<SProject> loadProjectObjects(project) async {
    project.datesObj = await project.getDates();
    project.locationObj = await project.getLocation();
    return project;
  }

  Widget programmeProjectDetails(context, project) {
    return Column(
      children: [
        programmeProjectDetails1(context, project),
        programmeProjectDetails2(context),
        programmeProjectDetails3(context, project),
        space(height: 20),
      ],
    );
  }

  Widget programmeProjectDetails1(context, project) {
    return FutureBuilder(
        future: loadProjectObjects(project),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            SProject proj = snapshot.data!;
            return Column(children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: customText(proj.description, 14),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(children: [
                      Row(children: [
                        customText(proj.locationObj.regionObj.name, 14),
                        customText(", ", 14),
                        customText(proj.locationObj.countryObj.name, 14)
                      ]),
                      Row(children: [
                        customText(
                            DateFormat("dd-MM-yyyy")
                                .format(proj.datesObj.start),
                            14),
                        customText(" - ", 14),
                        customText(
                            DateFormat("dd-MM-yyyy").format(proj.datesObj.end),
                            14)
                      ]),
                    ]),
                  )
                ],
              )
            ]);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget programmeProjectDetails2(context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText("Principales impactos", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              space(height: 10),
              customText("Principales...", 14),
            ]),
      ),
    ]);
  }

  Widget programmeProjectDetails3(context, project) {
    List finList = project.financiersObj;

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          //child: customText("_text", 16),
          child: DataTable(
            sortColumnIndex: 0,
            columns: [
              DataColumn(
                  label: customText("Financiadores", 14,
                      bold: FontWeight.bold, textColor: headerListTitleColor),
                  tooltip: "Financiadores"),
              DataColumn(
                label: customText("Inversión", 14,
                    bold: FontWeight.bold, textColor: headerListTitleColor),
                tooltip: "Inversión",
              ),
              DataColumn(
                  label: customText("Importe", 14,
                      bold: FontWeight.bold, textColor: headerListTitleColor),
                  tooltip: "Importe"),
            ],
            rows: finList
                .map(
                  (finn) => DataRow(cells: [
                    DataCell(customText(finn.name, 14)),
                    DataCell(customText(finn.name, 14)),
                    DataCell(customText(financiers[finn.name].toString(), 14)),
                  ]),
                )
                .toList(),
          ),
        ));
  }
}
