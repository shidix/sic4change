import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
//import 'package:sic4change/services/firebase_service.dart';
import 'package:sic4change/services/firebase_service_finn.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:uuid/uuid.dart';

const PAGE_FINN_TITLE = "Gestión Económica";
List finn_list = [];
List projects = [];
SProject? _project;
FirebaseFirestore db = FirebaseFirestore.instance;
double totalBudgetProject = 1;
double executedBudgetProject = 0;
//List<Widget> invoicesList = [];

const TextStyle mainText = TextStyle(
  fontFamily: 'Readex Pro',
  color: Color(0xFF00809A),
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const TextStyle secondaryText = TextStyle(
  fontFamily: 'Readex Pro',
  color: Color(0xFF00809A),
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

class FinnsPage extends StatefulWidget {
  const FinnsPage({super.key});

  @override
  State<FinnsPage> createState() => _FinnsPageState();
}

class _FinnsPageState extends State<FinnsPage> {
  Map<String, Map<String, Text>> aportesControllers = {};
  Map<String, Map<String, Text>> distrib_controllers = {};
  Map<String, double> distrib_amount = {};
  Map<String, double> aportes_amount = {};
  List<Widget> invoicesList = [];
  SFinn? finnSelected;

  Text totalBudget = const Text(
    '0.00',
    textAlign: TextAlign.end,
    style: TextStyle(
      fontFamily: 'Readex Pro',
      fontSize: 18,
    ),
  );

  Text totalExecuted = const Text(
    '0 %',
    textAlign: TextAlign.end,
    style: TextStyle(
      fontFamily: 'Readex Pro',
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );

  void loadFinns(value) async {
    // await getFinnsByProject(value).then((val) {
    //   finn_list = val;
    // });
    await SFinn.byProject(value).then((val) {
      finn_list = val;
    });
    for (var partner in _project!.partners) {
      distrib_amount[partner] = 0;
    }
    for (var financier in _project!.financiers) {
      aportes_amount[financier] = 0;
    }
    // _project!.totalBudget().then((value) {totalBudgetProject = value;});

    totalBudget = Text(
      totalBudgetProject.toStringAsFixed(2),
      textAlign: TextAlign.end,
      style: const TextStyle(
        fontFamily: 'Readex Pro',
        fontSize: 18,
      ),
    );

    // totalBudgetProject = max(1,total);
    // executedBudgetProject = totalBudgetProject * 0.75;
    await _project!.totalBudget().then((value) {
      totalBudgetProject = max(1, value);
      executedBudgetProject = value * 0.75;
    });

    double total = 0;
    for (SFinn finn in finn_list) {
      //await getContribByFinn(finn.uuid).then((items)
      await finn.getContrib().then((items) {
        aportesControllers[finn.uuid] = {};
        aportesControllers[finn.uuid]!['Total'] = buttonEditableText("0.00");
        for (FinnContribution item in items) {
          Text labelButton =
              buttonEditableText((item.amount).toStringAsFixed(2));
          aportesControllers[finn.uuid]![item.financier] = labelButton;
          total += item.amount;
          if (aportes_amount.containsKey(item.financier)) {
            aportes_amount[item.financier] =
                (aportes_amount[item.financier]! + item.amount);
          } else {
            aportes_amount[item.financier] = item.amount;
          }
        }
      });

      await FinnDistribution.getByFinn(finn.uuid).then((items) {
        distrib_controllers[finn.uuid] = {};
        distrib_controllers[finn.uuid]!['Total'] = buttonEditableText("0.00");
        for (FinnDistribution item in items) {
          Text labelButton =
              buttonEditableText((item.amount).toStringAsFixed(2));
          distrib_controllers[finn.uuid]![item.partner] = labelButton;
          if (distrib_amount.containsKey(item.partner)) {
            distrib_amount[item.partner] =
                (distrib_amount[item.partner]! + item.amount);
          } else {
            distrib_amount[item.partner] = item.amount;
          }
        }
      });
    }

    totalBudget = Text(
      total.toStringAsFixed(2),
      textAlign: TextAlign.end,
      style: const TextStyle(
        fontFamily: 'Readex Pro',
        fontSize: 18,
      ),
    );

    totalExecuted = Text(
      "${(executedBudgetProject / totalBudgetProject * 100).toStringAsFixed(0)}%",
      textAlign: TextAlign.end,
      style: const TextStyle(
        fontFamily: 'Readex Pro',
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.white,
      ),
    );

    setState(() {});
  }

  void loadProjects() async {
    await getProjects().then((value) {
      projects = value;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _project = null;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      Map args = ModalRoute.of(context)!.settings.arguments as Map;
      _project = args["project"];
    } else {
      _project = null;
    }

    if (_project == null) {
      return const ProjectsPage();
      //return const Page404();
    }

    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        finnHeader(context, _project),
        finnFullPage(context, _project),
      ]),
    );
  }

/*-------------------------------------------------------------
                            FINNS
-------------------------------------------------------------*/
  Widget finnHeader(context, _project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: Text("$PAGE_FINN_TITLE de ${_project.name}.",
            style: const TextStyle(fontSize: 20)),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            finnAddBtn(context, _project),
            customRowPopBtn(context, "Volver", Icons.arrow_back),
          ],
        ),
      ),
    ]);
  }

  Widget finnAddBtn(context, _project) {
    return ElevatedButton(
      onPressed: () {
        _editFinnDialog(context, null, _project);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          const Text(
            "Nueva partida",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _saveFinn(context, _finn, _name, _desc, _parent, _project) {
    _finn ??= SFinn("", const Uuid().v4(), _name, _desc, _parent, _project);

    _finn.name = _name;
    _finn.description = _desc;
    _finn.parent = _parent;
    _finn.project = _project;
    _finn.save();
    loadFinns(_project);
  }

  Future<void> _editFinnDialog(context, _finn, _project) {
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
          title: Card(
              color: Colors.blueGrey,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)))),
          content: SingleChildScrollView(
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
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                _saveFinn(context, _finn, nameController.text,
                    descController.text, _parent, _project.uuid);
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

  Widget finnFullPage(context, project) {
    project = project as SProject;
    List<Container> sourceRows = [];
    // double totalBudgetDouble = max(1, double.parse(totalBudget.data.toString()));
    TextStyle ts = const TextStyle(backgroundColor: Color(0xffffffff));
    for (var financier in project.financiers) {
      if (!aportes_amount.containsKey(financier)) {
        aportes_amount[financier] = 0;
      }
      double percent =
          min(aportes_amount[financier]! / totalBudgetProject * 100, 100);
      Text labelIndicator = Text("${(percent).toStringAsFixed(0)} %",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white));
      sourceRows.add(Container(
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
                    financier,
                    textAlign: TextAlign.start,
                    style: ts,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: LinearPercentIndicator(
                    percent: percent * 0.01,
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
                    "${aportes_amount[financier]!.toStringAsFixed(2)} €",
                    textAlign: TextAlign.end,
                    style: ts,
                  ),
                ),
              ],
            )),
      ));
    }

    List<Container> distrRows = [];

    for (var partner in project.partners) {
      if (!distrib_amount.containsKey(partner)) {
        distrib_amount[partner] = 0;
      }
      double percent =
          min(distrib_amount[partner]! / totalBudgetProject * 100, 100);

      Text labelIndicator = Text("${(percent).toStringAsFixed(0)} %",
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
                    partner,
                    textAlign: TextAlign.start,
                    style: ts,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: LinearPercentIndicator(
                    percent: percent * 0.01,
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
                    "${distrib_amount[partner]!.toStringAsFixed(2)} €",
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
          width: double.infinity,
          child: Card(
              child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Row(mainAxisSize: MainAxisSize.max, children: [
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                            'Listado de Facturas. Partida ${finnSelected!.name} ${finnSelected!.description}',
                            style: secondaryText))),
                Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              Tooltip(
                                  message: 'Añadir factura',
                                  child: IconButton(
                                      onPressed: () {
                                        _addInvoiceDialog(
                                                context, finnSelected!)
                                            .then((value) {
                                          _loadInvoicesByFinn(
                                              context, finnSelected!);
                                          setState(() {});
                                        });
                                      },
                                      icon: const Icon(Icons.add))),
                              Tooltip(
                                  message: 'Cerrar listado',
                                  child: IconButton(
                                      onPressed: () {
                                        finnSelected = null;
                                        invoicesList = [];
                                        setState(() {});
                                      },
                                      icon: const Icon(
                                          Icons.arrow_circle_left_outlined))),
                            ])))),
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
                      children: invoicesList,
                    ),
                  ),
                ],
              )
            ]),
          )));
    }

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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
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
                                                alignment: AlignmentDirectional(
                                                    -1.00, -1.00),
                                                child: Text(
                                                  'Presupuesto Total',
                                                  style: mainText,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 10),
                                                child: LinearPercentIndicator(
                                                  percent:
                                                      executedBudgetProject /
                                                          totalBudgetProject,
                                                  center: totalExecuted,
                                                  lineHeight: 15,
                                                  animation: true,
                                                  animateFromLastPercent: true,
                                                  progressColor:
                                                      Colors.blueGrey,
                                                  backgroundColor: Colors.grey,
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: totalBudget,
                                            ),
                                          ],
                                        ),
                                        const Text(
                                          'Origen del presupuesto',
                                          style: secondaryText,
                                        ),
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
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
                                          'Distribución Presupuesto',
                                          style: mainText,
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

  List<Container> infoFinnGral(data, project) {
    List<Row> rows = [];

    if (data.data is! Future<List>) {
      const TextStyle headerList = TextStyle(
        fontFamily: 'Readex Pro',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

      int wTools = 10;
      int wPartidas = 30;
      int wAportes = 30;
      int wDist = 30;

      String totalAport = "0.00";
      String totalDist = "0.00";

      rows.add(Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
          flex: wPartidas + wTools,
          child: const Text(
            'Partidas',
            textAlign: TextAlign.center,
            style: headerList,
          ),
        ),
        Expanded(
          flex: wAportes,
          child: const Text(
            'Aportes',
            textAlign: TextAlign.center,
            style: headerList,
          ),
        ),
        Expanded(
          flex: wDist,
          child: const Text(
            'Distribución aporte CM',
            textAlign: TextAlign.center,
            style: headerList,
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
      for (String financier in project.financiers) {
        subHeader.add(Expanded(
            flex: fAportes,
            child: Text(financier,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold))));
      }
      int fDist = wDist ~/ (project.partners.length + 1);
      subHeader.add(Expanded(
          flex: fDist,
          child: const Text('Total',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))));
      for (String partner in project.partners) {
        subHeader.add(Expanded(
            flex: fDist,
            child: Text(partner,
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
              _editFinnDialog(context, finn, project);
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
                padding: const EdgeInsets.all(15),
                child: Text(
                  "${finn.name}. ${finn.description}",
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ))));
        Text totalText;
        try {
          totalText = aportesControllers[finn.uuid]!['Total'] as Text;
        } catch (e) {
          totalText = const Text("0.00",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold));
        }
        cells.add(Expanded(flex: fAportes, child: totalText));
        double total = 0;
        for (String financier in project.financiers) {
          Text? labelButton = buttonEditableText("0.00");
          if (aportesControllers.containsKey(finn.uuid)) {
            if (aportesControllers[finn.uuid]!.containsKey(financier)) {
              labelButton = aportesControllers[finn.uuid]![financier];
              total += double.parse((labelButton as Text).data.toString());
            }
          }
          ElevatedButton button = ElevatedButton(
            onPressed: () {
              _editFinnContribDialog(context, finn, financier);
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

        totalAport = total.toStringAsFixed(2);
        int idx = (cells.length - 1 - project.financiers.length) as int;
        cells[idx] = Expanded(
            flex: fAportes,
            child: Text(totalAport,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)));

        // By Partner
        int fDist = wDist ~/ (project.partners.length + 1);
        Text totalDistText = const Text("0.0",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold));
        cells.add(Expanded(flex: fDist, child: totalDistText));
        total = 0;
        for (String partner in project.partners) {
          Text? labelButton = buttonEditableText("0.00");
          if (distrib_controllers.containsKey(finn.uuid)) {
            if (distrib_controllers[finn.uuid]!.containsKey(partner)) {
              labelButton = distrib_controllers[finn.uuid]![partner];
              total += double.parse((labelButton as Text).data.toString());
            }
          }
          ElevatedButton button = ElevatedButton(
            onPressed: () {
              _editFinnDistDialog(context, finn, partner);
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
        totalDist = total.toStringAsFixed(2);
        idx = (cells.length - 1 - project.partners.length) as int;
        cells[idx] = Expanded(
            flex: fDist,
            child: Text(totalDist,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)));

        rows.add(Row(mainAxisSize: MainAxisSize.max, children: cells));
      }

      List<Container> containers = [];
      for (var row in rows) {
        containers.add(Container(color: Colors.white, child: row));
      }

      return containers;
    } else {
      if (aportesControllers.isEmpty) {
        loadFinns(project.uuid);
      }
      return [];
    }
  }

  void _loadInvoicesByFinn(context, SFinn finn) async {
    finnSelected = finn;

    List items = await Invoice.getByFinn(finn.uuid);
    invoicesList = [];

    Row header = const Row(children: [
      Expanded(
          flex: 2,
          child: Text(
            'Número',
            style: secondaryText,
          )),
      Expanded(flex: 2, child: Text('Código', style: secondaryText)),
      Expanded(flex: 2, child: Text('Fecha', style: secondaryText)),
      Expanded(flex: 4, child: Text('Concepto', style: secondaryText)),
      Expanded(
          flex: 2,
          child: Text(
            'Base',
            style: secondaryText,
            textAlign: TextAlign.end,
          )),
      Expanded(
          flex: 2,
          child: Text(
            'Impuestos',
            style: secondaryText,
            textAlign: TextAlign.end,
          )),
      Expanded(
          flex: 2,
          child: Text(
            'Total',
            style: secondaryText,
            textAlign: TextAlign.end,
          )),
      Expanded(
          flex: 1,
          child: Text('', textAlign: TextAlign.end, style: secondaryText)),
    ]);

    invoicesList.add(header);

    for (Invoice invoice in items) {
      invoicesList.add(Row(children: [
        Expanded(flex: 2, child: Text(invoice.number)),
        Expanded(flex: 2, child: Text(invoice.code)),
        Expanded(flex: 2, child: Text(invoice.date)),
        Expanded(flex: 4, child: Text(invoice.concept)),
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
        Expanded(
            flex: 1,
            child: IconButton(
                onPressed: () {
                  //_editInvoiceDialog(context, invoice);
                },
                icon: const Icon(Icons.edit))),
      ]));
    }

    setState(() {});
  }

  Future<void> _editFinnContribDialog(context, finn, financier) {
    final database = db.collection("s4c_finncontrib");
    List<Row> rows = [];
    TextEditingController amount = TextEditingController(text: "0");
    TextEditingController comment = TextEditingController(text: "");
    FinnContribution item;
    item = FinnContribution(
        "", financier, double.parse(amount.text), finn.uuid, comment.text);

    database
        .where("finn", isEqualTo: finn.uuid)
        .where("financier", isEqualTo: financier)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        item = FinnContribution.fromJson(querySnapshot.docs.first.data());
        amount.text = item.amount.toStringAsFixed(2);
        comment.text = item.subject;
      } else {
        item = FinnContribution(
            "", financier, double.parse(amount.text), finn.uuid, comment.text);
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
              padding: const EdgeInsets.all(10), child: Text(financier))),
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
        loadFinns(_project!.uuid);
        Navigator.of(context).pop();
      },
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Card(
              color: Colors.blueGrey,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('${finn.name}. ${finn.description}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)))),
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

  Future<void> _editFinnDistDialog(context, finn, partner) {
    final database = db.collection("s4c_finndistrib");
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
          child:
              Padding(padding: const EdgeInsets.all(10), child: Text(partner))),
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
        loadFinns(_project!.uuid);
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
                String projectUuid = finn.project;
                finn.delete();
                loadFinns(projectUuid);
                Navigator.of(context).pop();
                //Navigator.popAndPushNamed(context, "/finns", arguments: {});
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

  Future<void> _addInvoiceDialog(context, SFinn finn) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir factura a la partida'),
          content: InvoiceForm(
            key: null,
            existingInvoice: Invoice(
              '',
              const Uuid().v4(),
              '',
              '',
              finn.uuid,
              '',
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
              0,
              0,
              0,
              '',
              '',
            ),
          ),
        );
      },
    );
  }
}

SizedBox s4cTitleBar(String title) {
  return SizedBox(
      width: double.infinity,
      child: Card(
          color: Colors.blueGrey,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white)))));
}
