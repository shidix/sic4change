import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/firebase_service_finn.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


const PAGE_FINN_TITLE = "Gestión Económica";
FirebaseFirestore db = FirebaseFirestore.instance;
double executedBudgetProject = 0;


class FinnsPage extends StatefulWidget {
  const FinnsPage({super.key, required this.project});

  final SProject? project;

  @override
  State<FinnsPage> createState() => _FinnsPageState();
}

class _FinnsPageState extends State<FinnsPage> {
  //List projects = [];
  List finnList = [];
  SProject? _project;


  Map<String, Map<String, Text>> aportesControllers = {};
  Map<String, Map<String, Text>> distribControllers = {};
  Map<String, double> distrib_amount = {};
  Map<String, double> aportes_amount = {};
  Map<String, Map> distribSummary = {};
  Map<String, Map> invoicesSummary = {};
  Map<String, Map> aportesSummary = {};
  Map<String, Map> finnSummary = {};
  Map<String, SFinn> finnHash = {};
  Map<String, SFinn> finnUuidHash = {};

  List<String> withChildrens = [];

  List<Widget> invoicesList = [];
  SFinn? finnSelected;
  double totalBudgetProject = 0;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    totalBudgetProject = 0;
    executedBudgetProject = 0;

    SFinn.byProject(_project!.uuid).then((val) {
      finnList = val;
      for (SFinn finn in finnList) {
        finnHash[finn.name] = finn;
        finnUuidHash[finn.uuid] = finn;
        String parentCode = finn.parentCode();
        if (finnHash.containsKey(parentCode)) {
          if (finn.parent != finnHash[parentCode]!.uuid) {
            finn.parent = finnHash[parentCode]!.uuid;
            finn.save();
          }
          if (!withChildrens.contains(parentCode)) {
            withChildrens.add(parentCode);
          }
        }
      }
      aportesByFinnancier().then((value) {
        if (mounted) {
          setState(() {
            totalBudgetProject = totalBudgetProject;
          });
        }
      });
      distribByPartner().then((value) {
        invoicesByPartner().then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      });
      loadFinns(_project!.uuid);
    });
  }

  void reloadState() {
    distrib_amount = {};
    aportes_amount = {};
    distribSummary = {};
    invoicesSummary = {};
    aportesSummary = {};
    finnSummary = {};
    totalBudgetProject = 0;
    executedBudgetProject = 0;

    SFinn.byProject(_project!.uuid).then((val) {
      finnList = val;
      for (SFinn finn in finnList) {
        finnHash[finn.name] = finn;
        String parentCode = finn.parentCode();
        if (finnHash.containsKey(parentCode)) {
          if (finn.parent != finnHash[parentCode]!.uuid) {
            finn.parent = finnHash[parentCode]!.uuid;
            finn.save();
          }
          if (!withChildrens.contains(parentCode)) {
            withChildrens.add(parentCode);
          }
        }
      }
      aportesByFinnancier().then((value) {
        if (mounted) {
          setState(() {
            totalBudgetProject = totalBudgetProject;
          });
        }
      });
      distribByPartner().then((value) {
        invoicesByPartner().then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      });
      loadFinns(_project!.uuid);
    });
  }

  Future<Map> aportesByFinnancier() async {
    totalBudgetProject = 0;
    for (SFinn item in finnList) {
      if (item.getLevel() == 1) {
        await item.getTotalContrib().then((aportes) {
          finnSummary[item.uuid] = aportes;
          for (String financierUuid in aportes.keys) {
            if (financierUuid != "total") {
              if (aportesSummary.containsKey(financierUuid)) {
                aportesSummary[financierUuid]!['total'] +=
                    aportes[financierUuid]!;
              } else {
                aportesSummary[financierUuid] = {
                  "total": aportes[financierUuid]
                };
              }
            }
          }
          totalBudgetProject += aportes["total"]!;
        });
      }
    }
    _project!.budget = toCurrency(totalBudgetProject).replaceAll("€", "");
    _project!.save();
    return aportesSummary;
  }

  Future<double> invoicesByPartner() async {
    for (String partnerUuid in _project!.partners) {
      await Invoice.getSummaryByPartner(partnerUuid, project: _project!.uuid)
          .then((value) {
        invoicesSummary[partnerUuid] = value;
      });
    }
    for (var item in invoicesSummary.values) {
      executedBudgetProject += item['total']!;
    }
    return executedBudgetProject;
  }

  Future<void> distribByPartner() async {
    for (String partnerUuid in _project!.partners) {
      await FinnDistribution.getSummaryByPartner(partnerUuid,
              project: _project!.uuid)
          .then((value) {
        distribSummary[partnerUuid] = value;
      });
    }
  }

  Future<void> loadFinns(value) async {
    // finnList = [];
    aportesControllers = {};
    distribControllers = {};
    distrib_amount = {};
    aportes_amount = {};

    for (var financier in _project!.financiers) {
      if (aportesSummary.containsKey(financier)) {
        aportes_amount[financier] = aportesSummary[financier]!['total']!;
      } else {
        aportes_amount[financier] = 0;
      }
    }

    for (var partner in _project!.partners) {
      if (distribSummary.containsKey(partner)) {
        distrib_amount[partner] = distribSummary[partner]!['total']!;
      } else {
        distrib_amount[partner] = 0;
      }
    }

    for (SFinn finn in finnList) {
      await finn.getContrib().then((items) {
        double totalByFinn = 0;
        aportesControllers[finn.uuid] = {};
        for (FinnContribution item in items) {
          Text labelButton = buttonEditableText(toCurrency(item.amount));
          aportesControllers[finn.uuid]![item.financier] = labelButton;
          totalByFinn += item.amount;
        }
        aportesControllers[finn.uuid]!['Total'] =
            buttonEditableText(toCurrency(totalByFinn));
      });

      await FinnDistribution.getByFinn(finn.uuid).then((items) {
        double totalByFinn = 0;
        distribControllers[finn.uuid] = {};
        for (FinnDistribution item in items) {
          Text labelButton = buttonEditableText(toCurrency(item.amount));
          distribControllers[finn.uuid]![item.partner] = labelButton;
          totalByFinn += item.amount;
        }
        distribControllers[finn.uuid]!['Total'] =
            buttonEditableText(toCurrency(totalByFinn));
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_project != null) {
      return Scaffold(
          body: SingleChildScrollView(
        child: Column(children: [
          mainMenu(context),
          finnHeader(context, _project),
          finnFullPage(context, _project),
        ]),
      ));
    } else {
      return const ProjectsPage();
    }
  }

/*-------------------------------------------------------------
                            FINNS
-------------------------------------------------------------*/
  Widget finnHeader(context, _project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: Text(
            (_project != null)
                ? "$PAGE_FINN_TITLE de ${_project!.name}."
                : "Esperando datos...",
            style: const TextStyle(fontSize: 20)),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            transferButton(context, _project),
            space(width: 10),
            finnAddBtn(context, _project),
            space(width: 10),
            goPage(context, 'Volver', const ProjectsPage(),
                Icons.arrow_circle_left_outlined),
//            finnBackButton(context),
          ],
        ),
      ),
    ]);
  }

  Widget finnAddBtn(context, _project) {
    return actionButtonVertical(context, 'Nueva partida', _editFinnDialog,
        Icons.add, [context, null, _project]);
  }

  Widget finnBackButton(context) {
    return actionButtonVertical(context, 'Volver', () {
      Navigator.pop(context);
    }, Icons.arrow_circle_left_outlined, null);
  }

  Widget transferButton(context, _project) {
    void goTransfer(project) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => TransfersPage(
                    project: project,
                  ))));
    }

    return actionButtonVertical(
        context, 'Transferencias', goTransfer, Icons.euro_outlined, _project);
  }

  void _saveFinn(context, _finn, _name, _desc, _parent, _project) {
    _finn ??= SFinn("", const Uuid().v4(), _name, _desc, _parent, _project);

    _finn.name = _name;
    _finn.description = _desc;
    _finn.parent = _parent;
    _finn.project = _project;
    _finn.save();
    //loadFinns(_project);
    reloadState();
  }

  Future<void> _editFinnDialog(args) {
    //context, _finn, _project
    SFinn? _finn = args[1];
    SProject _project = args[2];

    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    String _parent = "";
    String title = "Nueva partida financiera";

    if (_finn != null) {
      nameController = TextEditingController(text: _finn.name);
      descController = TextEditingController(text: _finn.description);
      _parent = _finn.parent;
      title = "Editar partida financiera";
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar(title, context),
          content: SingleChildScrollView(
              child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(children: [
              const Row(
                children: <Widget>[
                  Expanded(flex: 20, child: Text('Código')),
                  Spacer(flex: 5),
                  Expanded(flex: 75, child: Text("Descripción"))
                ],
              ),
              Row(children: <Widget>[
                Expanded(
                    flex: 20, child: customTextField(nameController, "Código")),
                const Spacer(flex: 5),
                Expanded(
                    flex: 75,
                    child: customTextField(descController, "Descripción"))
              ]),
            ]),
          )),
          actions: <Widget>[
            Row(children: [
              Expanded(flex: 3, child: Container()),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: saveBtnForm(context, () {
                        _saveFinn(context, _finn, nameController.text,
                            descController.text, _parent, _project.uuid);
                        Navigator.of(context).pop();
                      }))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: cancelBtnForm(context))),
            ]),
          ],
        );
      },
    );
  }

  Widget finnFullPage(context, SProject? project) {
    List<Container> sourceRows = [];
    TextStyle ts = const TextStyle(backgroundColor: Colors.white);
    if (project == null) {
      return const Text("Esperando datos...");
    } else {
      for (var financierObj in project.financiersObj) {
        String financier = financierObj.uuid;
        if (!aportesSummary.containsKey(financier)) {
          aportes_amount[financier] = 0;
        } else {
          aportes_amount[financier] = aportesSummary[financier]!['total']!;
        }
        double realPercent = totalBudgetProject > 0
            ? aportes_amount[financier]! / totalBudgetProject * 100
            : 0;
        double percent = min(realPercent, 100);
        Text labelIndicator = Text("${realPercent.toStringAsFixed(0)} %",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white));
        sourceRows.add(Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${financierObj.name} aporta",
                      textAlign: TextAlign.start,
                      style: ts,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: LinearPercentIndicator(
                      percent: percent > 0 ? percent * 0.01 : 0,
                      center: labelIndicator,
                      lineHeight: 15,
                      animation: true,
                      animateFromLastPercent: true,
                      progressColor: Colors.blueGrey,
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      toCurrency(aportes_amount[financier]!),
                      textAlign: TextAlign.end,
                      style: ts,
                    ),
                  ),
                ],
              )),
        ));
      }

      List<Container> distrRows = [];

      for (var partnerObj in project.partnersObj) {
        String partner = partnerObj.uuid;
        if (!distrib_amount.containsKey(partner)) {
          distrib_amount[partner] = 0;
        }

        double percent = 0;
        double executed = 0;
        double assigned = 0;
        double realPercent = 0;
        if (invoicesSummary.containsKey(partner)) {
          executed = invoicesSummary[partner]!['total']!;
          assigned = distribSummary[partner]!['total'];
          realPercent = assigned > 0 ? executed / assigned * 100 : 0;
          percent = min(realPercent, 100);
        }

        Text labelIndicator = Text("${(realPercent).toStringAsFixed(0)} %",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white));
        distrRows.add(Container(
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      partnerObj.name,
                      textAlign: TextAlign.start,
                      style: ts,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: LinearPercentIndicator(
                      percent: percent > 0 ? percent * 0.01 : 0,
                      center: labelIndicator,
                      lineHeight: 15,
                      animation: true,
                      animateFromLastPercent: true,
                      progressColor:
                          (percent < 100) ? Colors.blueGrey : dangerColor,
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      executed > 0
                          ? "${toCurrency(executed)} de ${toCurrency(assigned)}"
                          : "0.00 €  ${toCurrency(assigned)}",
                      textAlign: TextAlign.end,
                      style: ts,
                    ),
                  ),
                ],
              )),
        ));
      }
      Widget invoicesContainer = Container(width: double.infinity);

      if (finnSelected != null) {
        invoicesContainer = SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
                child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Column(children: [
                Row(children: [
                  Expanded(
                      flex: 20,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                              'Listado de Facturas. Partida ${finnSelected!.name} ${finnSelected!.description}',
                              style: titleText))),
                  Expanded(flex:1, child: Align(alignment: Alignment.centerRight, child: Tooltip(message:AppLocalizations.of(context)!.addInvoice , child: IconButton(
                      onPressed: () {
                        _addInvoiceDialog(context, finnSelected!).then((value) {
                          _loadInvoicesByFinn(context, finnSelected!);
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline))))),
                  Expanded(flex:1, child: Align(alignment: Alignment.centerRight, child: Tooltip(message:'Cerrar listado', child: IconButton(
                      onPressed: () {
                        finnSelected = null;
                        invoicesList = [];
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.arrow_circle_left_outlined))))),
                ]),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: (invoicesList.isNotEmpty)
                            ? invoicesList
                            : [
                                const Center(child:Padding(padding: EdgeInsets.all(50), child: Text(
                                  'No hay facturas para esta partida',
                                  style: mainText
                                )))
                              ],
                      ),
                    ),
                  ],
                )
              ]),
            )));
      }

      double realPercentExecuted = totalBudgetProject > 0
          ? executedBudgetProject / totalBudgetProject
          : 0;
      double percentExecuted = min(realPercentExecuted, 1);
      Text totalExecuted = Text(
        "${(realPercentExecuted * 100).toStringAsFixed(0)}%",
        textAlign: TextAlign.end,
        style: percentText,
      );
      return FutureBuilder(
          initialData: SFinn.byProject(project.uuid),
          future: SFinn.byProject(project.uuid),
          builder: ((context, snapshot) {
            return Column(children: [
              Card(
                  child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            20, 0, 20, 0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 20, 20, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.00, -1.00),
                                                  child: Text(
                                                    'Presupuesto Total',
                                                    style: mainText,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0, bottom: 0),
                                                  child: LinearPercentIndicator(
                                                    percent: percentExecuted,
                                                    center: totalExecuted,
                                                    lineHeight: 15,
                                                    animation: true,
                                                    animateFromLastPercent:
                                                        true,
                                                    progressColor:
                                                        percentExecuted < 1
                                                            ? Colors.blueGrey
                                                            : dangerColor,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  toCurrency(
                                                      totalBudgetProject),
                                                  textAlign: TextAlign.end,
                                                  style: const TextStyle(
                                                    fontFamily: 'Readex Pro',
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // const Text(
                                          //   'Origen del presupuesto',
                                          //   style: secondaryText,
                                          // ),
                                          const Divider(
                                              thickness: 1, color: Colors.grey),

                                          ListView(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            children: sourceRows,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            20, 0, 20, 0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 20, 20, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Ejecución del Presupuesto',
                                            style: mainText,
                                          ),
                                          const Divider(
                                            thickness: 1,
                                            color: Colors.grey,
                                          ),
                                          ListView(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            children: distrRows,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: infoFinnGral(snapshot, project),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
              invoicesContainer,
            ]);
          }));
    }
  }

  List<Container> infoFinnGral(data, SProject project) {
    List<Row> rows = [];

    if (data.data is! Future<List>) {
      int wTools = 10;
      int wPartidas = 30;
      int wAportes = 30;
      int wDist = 30;

      rows.add(Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
          flex: wPartidas + wTools,
          child: const Text(
            'Partidas',
            textAlign: TextAlign.center,
            style: titleText,
          ),
        ),
        Expanded(
          flex: wAportes,
          child: const Text(
            'Aportes',
            textAlign: TextAlign.center,
            style: titleText,
          ),
        ),
        Expanded(
          flex: wDist,
          child: const Text(
            'Distribución aportes',
            textAlign: TextAlign.center,
            style: titleText,
          ),
        ),
      ]));

      List<Expanded> subHeader = [];
      subHeader.add(Expanded(
          flex: wPartidas + wTools,
          child: const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                '',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ))));

      int fAportes = wAportes ~/ (project.financiers.length + 1);
      subHeader.add(Expanded(
          flex: fAportes,
          child: const Text('Total',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))));
      for (Financier financier in project.financiersObj) {
        subHeader.add(Expanded(
            flex: fAportes,
            child: Text(financier.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold))));
      }
      int fDist = wDist ~/ (project.partners.length + 1);
      subHeader.add(Expanded(
          flex: fDist,
          child: const Text('Total',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))));
      for (Contact partner in project.partnersObj) {
        subHeader.add(Expanded(
            flex: fDist,
            child: Text(partner.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold))));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.max, children: subHeader));

      for (SFinn finn in data.data) {
        List<Expanded> cells = [];
        IconButton buttonFinnInvoices = IconButton(
          icon: const Icon(Icons.list),
          onPressed: () {
            _loadInvoicesByFinn(context, finn);
          },
        );
        IconButton buttonFinnEdit = IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _editFinnDialog([context, finn, project]);
            });
        IconButton buttonFinnRemove = IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _removeFinnDialog(context, finn);
          },
        );
        cells.add(Expanded(
            flex: wTools ~/ 3,
            child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: buttonFinnInvoices)));
        cells.add(Expanded(
            flex: wTools ~/ 3,
            child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: buttonFinnEdit)));
        cells.add(Expanded(
            flex: wTools ~/ 3,
            child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: buttonFinnRemove)));

        cells.add(Expanded(
            flex: wPartidas,
            child: Padding(
                padding: EdgeInsets.only(
                    bottom: 15,
                    top: 15,
                    right: 5,
                    left: 15.0 * finn.getLevel()),
                child: Text(
                  "${finn.name}. ${finn.description}",
                  textAlign: TextAlign.left,
                  style: (finn.getLevel() == 1)
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null,
                ))));
        if (!withChildrens.contains(finn.name)) {
          Text totalText = Text(toCurrency(0),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold));
          cells.add(Expanded(flex: fAportes, child: totalText));
          double total = 0;
          for (Financier financierObj in project.financiersObj) {
            String financier = financierObj.uuid;
            Text? labelButton = buttonEditableText(toCurrency(0));
            if (aportesControllers.containsKey(finn.uuid)) {
              if (aportesControllers[finn.uuid]!.containsKey(financier)) {
                labelButton = aportesControllers[finn.uuid]![financier];
                total += fromCurrency((labelButton as Text).data.toString());
              }
            }
            ElevatedButton button = ElevatedButton(
              onPressed: () {
                _editFinnContribDialog(context, finn, financierObj);
              },
              style: buttonEditableTextStyle(),
              child: labelButton,
            );
            cells.add(Expanded(
                flex: fAportes,
                child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: button)));
          }

          int idx = (cells.length - 1 - project.financiers.length);
          cells[idx] = Expanded(
              flex: fAportes,
              child: Text(
                toCurrency(total),
                textAlign: TextAlign.center,
              ));

          // By Partner
          int fDist = wDist ~/ (project.partners.length + 1);
          Text totalDistText = Text(
            toCurrency(0),
            textAlign: TextAlign.center,
          );
          cells.add(Expanded(flex: fDist, child: totalDistText));
          total = 0;
          for (Contact partnerObj in project.partnersObj) {
            String partner = partnerObj.uuid;
            Text? labelButton = buttonEditableText(toCurrency(0));
            if (distribControllers.containsKey(finn.uuid)) {
              if (distribControllers[finn.uuid]!.containsKey(partner)) {
                labelButton = distribControllers[finn.uuid]![partner];
                total += fromCurrency((labelButton as Text).data.toString());
              }
            }
            ElevatedButton button = ElevatedButton(
              onPressed: () {
                _editFinnDistDialog(context, finn, partnerObj);
              },
              style: buttonEditableTextStyle(),
              child: labelButton,
            );
            cells.add(Expanded(
                flex: fDist,
                child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: button)));
          }
          idx = (cells.length - 1 - project.partners.length);
          cells[idx] = Expanded(
              flex: fDist,
              child: Text(
                toCurrency(total),
                textAlign: TextAlign.center,
              ));

          rows.add(Row(mainAxisSize: MainAxisSize.max, children: cells));
        } else {
          cells.add(Expanded(
              flex: fAportes,
              child: Text(
                  toCurrency(finnSummary[finn.uuid] != null
                      ? finnSummary[finn.uuid]!['total']
                      : 0),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold))));
          for (String financierUuid in project.financiers) {
            try {
              cells.add(Expanded(
                  flex: fAportes,
                  child: Text(
                      toCurrency(finnSummary[finn.uuid] != null
                          ? finnSummary[finn.uuid]![financierUuid]
                          : 0),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold))));
            } catch (e) {
              cells.add(Expanded(
                  flex: fAportes,
                  child: Text(toCurrency(0),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold))));
            }
          }

          cells.add(Expanded(
              flex: wDist,
              child: Text(toCurrency(0),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold))));
          rows.add(Row(mainAxisSize: MainAxisSize.max, children: cells));
        }
      }

      List<Container> containers = [];
      for (var row in rows) {
        containers.add(Container(color: Colors.white, child: row));
      }

      return containers;
    } else {
      // if (aportesControllers.isEmpty) {
      //   loadFinns(project.uuid);
      // }
      return [];
    }
  }

  void _loadInvoicesByFinn(context, SFinn finn) async {
    finnSelected = finn;

    Text headerField(String title, [alignment=TextAlign.start]) {
      return Text(title,
          textAlign: alignment,
          style: headerListText);
    }

    List items = await Invoice.getByFinn(finn.uuid);
    invoicesList = [];
    if (items.isNotEmpty) {


      Row header = Row(children: [
        Expanded(flex: 2, child: headerField('Partida')),
        Expanded(flex: 2, child: headerField('Número')),
        Expanded(flex: 2, child: headerField('Código')),
        Expanded(flex: 2, child: headerField('Fecha')),
        Expanded(flex: 5, child: headerField('Concepto')),
        Expanded(flex: 2, child: headerField('Base', TextAlign.end)),
        Expanded(flex: 2, child: headerField('Impuestos', TextAlign.end)),
        Expanded(flex: 2, child: headerField('Total', TextAlign.end)),
        Expanded(flex: 2, child: headerField('', TextAlign.end)),
      ]);

      invoicesList.add(header);
      items.sort((a, b) => (a.date).compareTo(b.date));
      for (Invoice invoice in items) {
        invoicesList.add(MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () {
                  _viewInvoiceDialog(context, invoice);
                },
                child: Row(children: [
                  Expanded(flex: 2, child: Text(finnUuidHash.containsKey(invoice.finn)?finnUuidHash[invoice.finn]!.name:'')),
                  Expanded(flex: 2, child: Text(invoice.number)),
                  Expanded(flex: 2, child: Text(invoice.code)),
                  Expanded(flex: 2, child: Text(invoice.date)),
                  Expanded(flex: 5, child: Text(invoice.concept)),
                  Expanded(
                      flex: 2,
                      child: Text(
                        "${invoice.base.toStringAsFixed(2)} €",
                        textAlign: TextAlign.end,
                      )),
                  Expanded(
                      flex: 2,
                      child: Text(
                        "${invoice.taxes.toStringAsFixed(2)} €",
                        textAlign: TextAlign.end,
                      )),
                  Expanded(
                      flex: 2,
                      child: Text(
                        "${invoice.total.toStringAsFixed(2)} €",
                        textAlign: TextAlign.end,
                      )),
                  Expanded(flex:1, child: Align(alignment: Alignment.centerRight, child: IconButton(
                      onPressed: () {
                        _viewInvoiceDialog(context, invoice);
                      },
                      icon: const Icon(Icons.info_outline)))),
                  Expanded(flex:1, child: Align(alignment: Alignment.centerRight, child: IconButton(
                      onPressed: () {
                        _editInvoiceDialog(context, invoice).then((value) {
                          _loadInvoicesByFinn(context, finn);
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                      icon: const Icon(Icons.edit)))),
                ]))));
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _editFinnContribDialog(context, finn, financierObj) {
    final database = db.collection("s4c_finncontrib");
    List<Row> rows = [];
    TextEditingController amount = TextEditingController(text: "0");
    TextEditingController comment = TextEditingController(text: "");
    FinnContribution item;
    item = FinnContribution("", financierObj.uuid, double.parse(amount.text),
        finn.uuid, comment.text);

    database
        .where("finn", isEqualTo: finn.uuid)
        .where("financier", isEqualTo: financierObj.uuid)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        item = FinnContribution.fromJson(querySnapshot.docs.first.data());
        amount.text = item.amount.toStringAsFixed(2);
        comment.text = item.subject;
      } else {
        item = FinnContribution("", financierObj.uuid,
            double.parse(amount.text), finn.uuid, comment.text);
      }
    });

    rows.add(const Row(children: [
      Expanded(
          flex: 1,
          child:
              Padding(padding: EdgeInsets.all(10), child: Text('Financiador'))),
      Expanded(
          flex: 1,
          child:
              Padding(padding: EdgeInsets.all(10), child: Text('Comentario'))),
      Expanded(
          flex: 1,
          child: Padding(padding: EdgeInsets.all(10), child: Text('Cantidad'))),
    ]));

    amount.text = "0";
    rows.add(Row(children: [
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(financierObj.name))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: customTextField(comment, 'Comentario'))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: customDoubleField(amount, ''))),
    ]));

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('${finn.name}. ${finn.description}', context),
          content: SingleChildScrollView(
            child: Column(children: rows),
          ),
          actions: <Widget>[
            Row(children: [
              Expanded(flex: 3, child: Container()),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: saveBtnForm(context, () {
                        item.amount = double.parse(amount.text);
                        item.subject = comment.text;
                        item.save();
                        //loadFinns(_project!.uuid);
                        reloadState();
                        Navigator.of(context).pop();
                      }))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: cancelBtnForm(context))),
            ])
          ],
        );
      },
    );
  }

  Future<void> _editFinnDistDialog(context, finn, partnerObj) {
    final database = db.collection("s4c_finndistrib");
    String partner = partnerObj.uuid;
    List<Row> rows = [];
    TextEditingController amount = TextEditingController(text: "0");
    TextEditingController comment = TextEditingController(text: "");
    FinnDistribution item = FinnDistribution(
        "", partner, double.parse(amount.text), finn.uuid, comment.text);

    database
        .where("finn", isEqualTo: finn.uuid)
        .where("partner", isEqualTo: partner)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        item = FinnDistribution.fromJson(querySnapshot.docs.first.data());
        amount.text = item.amount.toStringAsFixed(2);
        comment.text = item.subject;
      } else {
        item = FinnDistribution(
            "", partner, double.parse(amount.text), finn.uuid, comment.text);
      }
    });

    rows.add(const Row(children: [
      Expanded(
          flex: 1,
          child: Padding(padding: EdgeInsets.all(10), child: Text('Socio'))),
      Expanded(
          flex: 1,
          child:
              Padding(padding: EdgeInsets.all(10), child: Text('Comentario'))),
      Expanded(
          flex: 1,
          child: Padding(padding: EdgeInsets.all(10), child: Text('Cantidad'))),
    ]));

    amount.text = "0";
    rows.add(Row(children: [
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(10), child: Text(partnerObj.name))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: customTextField(comment, 'Comentario'))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: customDoubleField(amount, ''))),
    ]));

    TextButton saveButton = TextButton(
      child: const Text('Guardar'),
      onPressed: () async {
        item.amount = double.parse(amount.text);
        item.subject = comment.text;
        item.save();
        //loadFinns(_project!.uuid);
        reloadState();
        Navigator.of(context).pop();
      },
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('${finn.name}. ${finn.description}'),
          content: SingleChildScrollView(
            child: Column(children: rows),
          ),
          actions: <Widget>[
            saveButton,
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFinnDialog(context, finn) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Eliminar partida'),
          content: const Text(
              "Si confirma la acción, eliminará la partida seleccionada."),
          actions: <Widget>[
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () async {
                finn.delete();
                reloadState();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewInvoiceDialog(context, Invoice invoice) {
    return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          String title = "Factura ${invoice.number}";
          return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: s4cTitleBar(title, context),
              content: InvoiceDetail(key: null, invoice: invoice));
        });
  }

  Future<void> _addInvoiceDialog(context, SFinn finn) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir factura a la partida', context),
          content: InvoiceForm(
            key: null,
            partners: _project!.partnersObj,
            existingInvoice: Invoice.getEmpty()..finn = finn.uuid,
          ),
        );
      },
    );
  }

  Future<void> _editInvoiceDialog(context, Invoice invoice) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: s4cTitleBar('Editar factura', context),
            content: InvoiceForm(
                existingInvoice: invoice, partners: _project!.partnersObj));
      },
    );
  }
}
