// ignore_for_file: constant_identifier_names, no_leading_underscores_for_local_identifiers
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/pages/invoices_pages.dart';
import 'package:sic4change/services/finn_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:uuid/uuid.dart';

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
  SProject? _project;
  Map<String, Organization> financiers = {};
  Map<String, Organization> partners = {};
  SFinnInfo finnInfo = SFinnInfo("", "", "");
  String tracker = "";

  List finnList = [];
  Map<String, Map> invoicesSummary = {};
  List aportesItems = [];
  List distribItems = [];
  Map<String, int> mapLevels = {};
  Map<String, bool> mapOnHover = {};

  // Map<String, SFinn> finnHash = {};
  // Map<String, SFinn> finnUuidHash = {};

  List<String> withChildrens = [];

  List<Widget> invoicesList = [];
  List invoicesItems = [];
  SFinn? finnSelected;
  String? financierUuidSelected;
  double totalBudgetProject = 0;

  Widget? invoicesContainer = Container();
  Widget? summaryContainer = Container();
  // Widget? finnContainer = Container();
  Widget? aportesSummaryContainer = Container();
  Widget? distribSummaryContainer = Container();
  Widget? finnanciersContainer = Container();
  Widget? partnersContainer = Container();

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    loadInitialData();
  }

  void loadInitialData() {
    Invoice.newTracker().then((val) {
      tracker = val;
    });
    getOrganizations().then((val) {
      for (Organization item in val) {
        if (_project!.financiers.contains(item.uuid)) {
          financiers[item.uuid] = item;
        }
        if (_project!.partners.contains(item.uuid)) {
          partners[item.uuid] = item;
        }
      }
      SFinnInfo.byProject(_project!.uuid).then((val) {
        if (val != null) {
          finnInfo = val;
          finnList = getAllFinns();
          for (Distribution dist in finnInfo.distributions) {
            dist.updateMapinvoices();
          }
        } else {
          finnInfo = SFinnInfo("", const Uuid().v4(), _project!.uuid);
          finnInfo.save();
        }
        aportesSummaryContainer = populateAportesSummaryContainer();

        if (mounted) {
          setState(() {
            finnList = getAllFinns();
          });
        }
      });

      totalBudgetProject = fromCurrency(_project!.budget);
      executedBudgetProject = 0;
      invoicesContainer = Container(width: 0);
      finnanciersContainer = populateFinnanciersContainer();
      partnersContainer = populatePartnersContainer();
      distribSummaryContainer = populateDistribSummaryContainer();
      summaryContainer = populateSummaryContainer();
    });
  }

  bool belongsTo(SFinn finn, String financierUuid) {
    Map<String, String> equivalencies = {};
    for (String financier in _project!.financiers) {
      equivalencies[financier] = financier;
    }
    return (equivalencies[financierUuid] == finn.orgUuid);
  }

  double getDistrib(String finnUuid, [String? partnerUuid]) {
    double distrib = 0;
    return distrib;
  }

  bool checkFinnInDistributions(finn) {
    for (Distribution dist in finnInfo.distributions) {
      if (dist.finn == finn.uuid) {
        return true;
      }
    }
    return false;
  }

  void notAllowedDialog(context, msg) {
    msg ??= "No se puede realizar la operación solicitada.";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Operación no permitida'),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        });
  }

  Widget populateAportesSummaryContainer() {
    double percentExecuted = 0.0;
    totalBudgetProject = 0;
    List<Widget> sourceRows = [];
    if (finnInfo.project == "") {
      return const Center(child: CircularProgressIndicator());
    } else {
      for (SFinn partida in finnInfo.partidas) {
        totalBudgetProject += partida.getAmountContrib();
      }
      if (_project!.budget != toCurrency(totalBudgetProject)) {
        _project!.budget = toCurrency(totalBudgetProject);
        _project!.save();
      }

      for (Organization org in financiers.values) {
        double totalExecuted = 0;
        double percentExecuted = 0;
        for (SFinn finn in finnInfo.partidas) {
          if (finn.orgUuid == org.uuid) {
            totalExecuted += finn.getAmountContrib();
          }
        }
        if (totalBudgetProject > 0) {
          percentExecuted = totalExecuted / totalBudgetProject;
        }
        sourceRows.add(Row(children: [
          Expanded(flex: 2, child: Text(org.name)),
          Expanded(
              flex: 2,
              child: LinearPercentIndicator(
                percent: min(percentExecuted, 1),
                center: Text("${(percentExecuted * 100).toStringAsFixed(0)} %",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                lineHeight: 20,
                animation: true,
                animateFromLastPercent: true,
                progressColor:
                    percentExecuted < 1 ? percentBarPrimary : dangerColor,
                backgroundColor: Colors.grey,
                padding: EdgeInsets.zero,
              )),
          Expanded(
              flex: 1,
              child: Text(toCurrency(totalExecuted),
                  textAlign: TextAlign.end, style: mainText)),
        ]));
        if (financiers.values.last != org) {
          sourceRows.add(const Divider(thickness: 1, color: Colors.white));
        }
      }

      return Card(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                  Row(children: [
                    const Expanded(
                        flex: 2,
                        child: Text("Presupuesto total", style: mainText)),
                    Expanded(
                        flex: 2,
                        child: LinearPercentIndicator(
                          percent: min(percentExecuted, 1),
                          center: Text(
                              "${(percentExecuted * 100).toStringAsFixed(0)} %",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          lineHeight: 20,
                          animation: true,
                          animateFromLastPercent: true,
                          progressColor: percentExecuted < 1
                              ? percentBarPrimary
                              : dangerColor,
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.zero,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(toCurrency(totalBudgetProject),
                            textAlign: TextAlign.end, style: mainText)),
                  ]),
                  const Divider()
                ] +
                sourceRows),
      ));
    }
  }

  Widget populateDistribSummaryContainer() {
    Map<String, double> distribTotalByPartner = {};
    double totalDistrib = 0;
    for (var partner in _project!.partners) {
      distribTotalByPartner[partner] = 0;
    }
    invoicesSummary = {};

    double totalExecuted = 0;
    double percentExecuted = 0;

    List<Widget> sourceRows = [];
    //for (Contact partner in _project!.partnersObj) {
    for (Organization partner in _project!.partnersObj) {
      double executedByPartnerAmount = 0;
      if (invoicesSummary.containsKey(partner.uuid)) {
        executedByPartnerAmount = invoicesSummary[partner.uuid]!['total'];
      }
      if (!distribTotalByPartner.containsKey(partner.uuid)) {
        distribTotalByPartner[partner.uuid] = 0;
      }
      totalExecuted += executedByPartnerAmount;

      double distrib = distribTotalByPartner[partner.uuid]!;
      double distribPercent =
          (distrib == 0) ? 0 : executedByPartnerAmount / distrib;
      sourceRows.add(Row(children: [
        Expanded(flex: 1, child: Text(partner.name)),
        Expanded(
            flex: 2,
            child: LinearPercentIndicator(
              percent: min(distribPercent, 1),
              center: Text("${(distribPercent * 100).toStringAsFixed(0)} %",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              lineHeight: 20,
              animation: true,
              animateFromLastPercent: true,
              progressColor:
                  distribPercent < 1 ? percentBarPrimary : dangerColor,
              backgroundColor: Colors.grey,
              padding: EdgeInsets.zero,
            )),
        Expanded(
            flex: 2,
            child: Text(
                "${toCurrency(executedByPartnerAmount)} de ${toCurrency(distrib)}",
                textAlign: TextAlign.end)),
      ]));
      if (_project!.partnersObj.last != partner) {
        sourceRows.add(const Divider(thickness: 1, color: Colors.white));
      }
    }

    if (totalDistrib > 0) {
      percentExecuted = totalExecuted / totalDistrib;
    }

    return Card(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
          children: [
                Row(children: [
                  const Expanded(
                      flex: 1, child: Text("Asignado", style: mainText)),
                  Expanded(
                      flex: 2,
                      child: LinearPercentIndicator(
                        percent: min(percentExecuted, 1),
                        center: Text(
                            "${(percentExecuted * 100).toStringAsFixed(0)} %",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        lineHeight: 20,
                        animation: true,
                        animateFromLastPercent: true,
                        progressColor: (percentExecuted < 1)
                            ? percentBarPrimary
                            : dangerColor,
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.zero,
                      )),
                  Expanded(
                      flex: 2,
                      child: Text(
                          "${toCurrency(totalExecuted)} de ${toCurrency(totalDistrib)}",
                          textAlign: TextAlign.end,
                          style: (percentExecuted < 1)
                              ? mainText.copyWith(
                                  fontSize: mainText.fontSize! - 2)
                              : mainText.copyWith(
                                  fontSize: mainText.fontSize! - 2,
                                  color: dangerColor))),
                ]),
                const Divider()
              ] +
              sourceRows),
    ));
  }

  Future<void> reloadState() async {
    finnList.sort((a, b) {
      if (a.orgUuid == b.orgUuid) {
        return a.name.compareTo(b.name);
      } else {
        return a.orgUuid.compareTo(b.orgUuid);
      }
    });

    if (distribItems.isEmpty) {
      await FinnDistribution.getByProject(_project!.uuid).then((val) {
        distribItems = val;
      });
    }
    if (invoicesItems.isEmpty) {
      await invoicesByPartner().then((val) {});
    }

    if (mounted) {
      setState(() {
        aportesSummaryContainer = populateAportesSummaryContainer();
        distribSummaryContainer = populateDistribSummaryContainer();
        // finnContainer = populateFinnContainer();
        // invoicesContainer = populateInvoicesContainer();
        finnanciersContainer = populateFinnanciersContainer();
        partnersContainer = populatePartnersContainer();
      });
    }
  }

  List getAllFinns() {
    List items = [];
    if (finnInfo.partidas.isEmpty) {
      return items;
    }
    List queue = finnInfo.partidas.map((e) => e).toList();
    for (SFinn item in queue) {
      mapLevels[item.uuid] = 0;
      mapOnHover[item.uuid] = false;
    }

    while (queue.isNotEmpty) {
      SFinn item = queue.removeAt(0);
      items.add(item);
      int pos = 0;
      for (SFinn child in item.partidas) {
        mapLevels[child.uuid] = mapLevels[item.uuid]! + 1;
        mapOnHover[child.uuid] = false;
        queue.insert(pos, child);
        pos += 1;
      }
    }
    return items;
  }

  void removeFinn(context, finn) {
    List queue = [];

    for (SFinn item in finnInfo.partidas) {
      if (item.uuid == finn.uuid) {
        finnInfo.partidas.remove(item);
        finnInfo.save();
      }
      queue.add(item);
    }
    while (queue.isNotEmpty) {
      SFinn item = queue.removeAt(0);
      for (SFinn child in item.partidas) {
        if (child.uuid == finn.uuid) {
          item.partidas.remove(child);
          finnInfo.partidas.remove(child);
        }
        queue.add(child);
      }
    }
    finnInfo.save();

    finn.delete();
    finnList.remove(finn);
    reloadState();
  }

  List<SFinn> finnRecursive(SFinn finn) {
    List<SFinn> items = [];
    items.add(finn);
    finn.partidas.sort(
      (a, b) {
        if (a.orgUuid == b.orgUuid) {
          return a.name.compareTo(b.name);
        } else {
          return a.orgUuid.compareTo(b.orgUuid);
        }
      },
    );
    for (SFinn child in finn.partidas) {
      items.addAll(finnRecursive(child));
    }
    return items;
  }

  Widget finnancierSummaryCard(Organization item) {
    List<Widget> rows = [];
    TextStyle currentStyle;
    List mapStyles = [
      FontWeight.w700,
      FontWeight.w500,
      FontWeight.w300,
      FontWeight.w100,
    ];
    List<SFinn> filtered = [];

    finnInfo.partidas.sort((a, b) {
      if (a.orgUuid == b.orgUuid) {
        return a.name.compareTo(b.name);
      } else {
        return a.orgUuid.compareTo(b.orgUuid);
      }
    });

    for (SFinn finn in finnInfo.partidas) {
      if (finn.orgUuid == item.uuid) {
        filtered.addAll(finnRecursive(finn));
      }
    }

    int counter = 0;

    for (SFinn finn in filtered) {
      if (finn.orgUuid == item.uuid) {
        currentStyle = cellsListStyle.copyWith(
            fontWeight: mapStyles[mapLevels[finn.uuid]!]);
        if ((mapLevels[finn.uuid] == 0) && (rows.isNotEmpty)) {
          counter = 0;
          rows.add(const Divider(thickness: 1, color: Colors.grey));
        }

        rows.add(Container(
            color: (counter % 2 == 0) ? Colors.white : Colors.grey[100],
            child: Row(children: [
              Expanded(
                  flex: 6,
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.0 + 20.0 * (mapLevels[finn.uuid]!),
                          vertical: 0),
                      child: Text("${finn.name}. ${finn.description}",
                          style: currentStyle))),
              Expanded(
                  flex: 2,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      child: (finn.getAmountContrib() == finn.contribution)
                          ? Text(
                              toCurrency(finn.getAmountContrib()),
                              textAlign: TextAlign.right,
                              style: currentStyle,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                (finn.contribution > finn.getAmountContrib())
                                    ? Tooltip(
                                        message:
                                            'El valor nominal (${toCurrency(finn.contribution)}) es mayor que la suma de las subpartidas',
                                        child: const Icon(
                                          Icons.arrow_upward,
                                          color: warningColor,
                                          size: 14,
                                        ))
                                    : Tooltip(
                                        message:
                                            'El valor nominal (${toCurrency(finn.contribution)}) es menor que la suma de las subpartidas',
                                        child: const Icon(Icons.arrow_downward,
                                            color: dangerColor, size: 14)),
                                space(width: 5),
                                Text(
                                  toCurrency(finn.getAmountContrib()),
                                  textAlign: TextAlign.right,
                                  style: (finn.contribution >
                                          finn.getAmountContrib())
                                      ? currentStyle.copyWith(
                                          color: warningColor)
                                      : currentStyle.copyWith(
                                          color: dangerColor),
                                ),
                              ],
                            ))),
              Expanded(
                  flex: 2,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      child: Text(
                        toCurrency(finnInfo.getDistribByFinn(finn)),
                        textAlign: TextAlign.right,
                        style: currentStyle,
                      ))),
              Expanded(
                flex: 3,
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Row(children: [
                      Expanded(
                          flex: 3,
                          child: Text(
                            toCurrency(getDistrib(finn.uuid)),
                            textAlign: TextAlign.right,
                            style: currentStyle,
                          )),
                      Expanded(
                        flex: 1,
                        child: Text(
                          ((finn.getAmountContrib() != 0) &&
                                  (getDistrib(finn.uuid) != 0))
                              ? (getDistrib(finn.uuid) >=
                                      finn.getAmountContrib())
                                  ? "100%"
                                  : "${(getDistrib(finn.uuid) / finn.getAmountContrib() * 100).toStringAsFixed(0)}%"
                              : "0%",
                          textAlign: TextAlign.right,
                          style: currentStyle,
                        ),
                      )
                    ])),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 0, right: 10.0 + 15.0 * (mapLevels[finn.uuid]!)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          iconBtn(context, addFinnDialog, [item, finn],
                              icon: Icons.add, text: 'Añadir subpartida'),
                          iconBtn(context, (context, args) {
                            _editFinnDialog(context, finn).then((value) {
                              if (value == null) {
                                return;
                              }
                              if (finn.id == "") {
                                finnList.remove(finn);
                              }
                              finnSelected = null;
                              finnInfo.save();
                              reloadState();
                            });
                          }, finn, icon: Icons.edit_outlined),
                          ((finn.partidas.isEmpty) &&
                                  (!checkFinnInDistributions(finn)))
                              ? removeConfirmBtn(context, removeFinn, finn)
                              : removeBtn(context, notAllowedDialog,
                                  'Debe eliminar subpartidas'),
                          if ((finn.partidas.isEmpty) &&
                              (_project!.partners.isNotEmpty))
                            iconBtn(context, addDistribDialog,
                                {'finn': finn, 'index': -1},
                                icon: Icons.send_outlined,
                                text: 'Distribuir a socio')
                          else
                            iconBtn(context, (context, args) {}, null,
                                icon: null, text: 'Con subpartidas'),
                        ])),
              ),
            ])));

        counter += 1;
      }
    }

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(
            color: headerListBgColorIndicator,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(children: [
            Container(
                decoration: BoxDecoration(
                    color: headerListBgColorIndicator,
                    borderRadius: BorderRadius.circular(0.0),
                    border: Border.all(
                        color: headerListBgColorIndicator, width: 1.0)),
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.name,
                              style: headerListStyle.copyWith(
                                  color: Colors.white)),
                        ]))),
            space(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              addBtnRow(context, addFinnDialog, [item, null])
            ]),
            const Divider(thickness: 1, color: Colors.grey),
            Container(
                color: headerListBgColor,
                child: const Row(children: [
                  Expanded(
                      flex: 6,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text(
                            "Partida",
                            style: headerListStyle,
                          ))),
                  Expanded(
                      flex: 2,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Aportación",
                                  style: headerListStyle,
                                  textAlign: TextAlign.right),
                            ],
                          ))),
                  Expanded(
                      flex: 2,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Asignado",
                                  style: headerListStyle,
                                  textAlign: TextAlign.right),
                            ],
                          ))),
                  Expanded(
                      flex: 3,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Row(children: [
                            Expanded(
                                flex: 3,
                                child: Text("Ejecutado",
                                    style: headerListStyle,
                                    textAlign: TextAlign.right)),
                            Expanded(
                                flex: 1,
                                child: Text("%",
                                    style: headerListStyle,
                                    textAlign: TextAlign.right)),
                          ]))),
                  Expanded(
                      flex: 3,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                ])),
            const Divider(thickness: 1, color: Colors.grey),
            ...rows,
            // const Divider(thickness: 1, color: Colors.grey),
          ]),
        ));
  }

  Widget getInfoFinanciers(context, args) {
    List<Row> rows = [];
    for (Organization item in financiers.values) {
      rows.add(Row(children: [
        Expanded(flex: 1, child: finnancierSummaryCard(item)),
      ]));
    }
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.isNotEmpty
                ? rows
                : [
                    const Center(
                        child: Text("No hay partidas financieras asignadas"))
                  ]));
  }

  Widget populateFinnanciersContainer() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: customCollapse(
          context,
          Text("Aportes presupuestarios por financiador (${financiers.length})",
              style: const TextStyle(
                  fontSize: 18, color: mainColor, fontWeight: FontWeight.bold)),
          getInfoFinanciers,
          {},
          subtitle:
              "Listado de partidas financieras asignadas por cada financiador",
          expanded: false),
    );
  }

  // Partners info

  void removeDistrib(context, dist) {
    finnInfo.distributions.remove(dist);
    finnInfo.save();
    if (mounted) {
      setState(() {
        partnersContainer = populatePartnersContainer();
      });
    }
  }

  Future<void> listInvoices(context, Distribution? item) async {
    List<Invoice> invoices = [];
    if (item == null) {
      invoices =
          //await Invoice.all();
          await Invoice.afterDate(DateTime(DateTime.now().year - 1, 1, 1));
    } else {
      invoices = item.invoices;
    }
    invoices.sort((a, b) => a.date.compareTo(b.date));

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: s4cTitleBar('Listado de facturas', context),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade50),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
                    itemCount: invoices.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        if (item == null) {
                          return Container(
                              color: headerListBgColor,
                              child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  child: Row(children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text('Tracker',
                                            style: headerListStyle)),
                                    Expanded(
                                        flex: 1,
                                        child: Text('Número',
                                            style: headerListStyle)),
                                    Expanded(
                                        flex: 1,
                                        child: Text('Fecha',
                                            style: headerListStyle)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Base',
                                          style: headerListStyle,
                                          textAlign: TextAlign.right,
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: Text('Impuestos',
                                            style: headerListStyle,
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                        flex: 1,
                                        child: Text('Total',
                                            style: headerListStyle,
                                            textAlign: TextAlign.right)),
                                    Expanded(flex: 1, child: Text('')),
                                  ])));
                        } else {
                          return Container(
                              color: headerListBgColor,
                              child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Text('Tracker',
                                              style: headerListStyle)),
                                      Expanded(
                                          flex: 1,
                                          child: Text('Número',
                                              style: headerListStyle)),
                                      Expanded(
                                          flex: 1,
                                          child: Text('Fecha',
                                              style: headerListStyle)),
                                      Expanded(
                                          flex: 1,
                                          child: Text('Base',
                                              style: headerListStyle,
                                              textAlign: TextAlign.right)),
                                      Expanded(
                                          flex: 1,
                                          child: Text('Impuestos',
                                              style: headerListStyle,
                                              textAlign: TextAlign.right)),
                                      Expanded(
                                          flex: 1,
                                          child: Text('Total',
                                              style: headerListStyle,
                                              textAlign: TextAlign.right)),
                                      Expanded(
                                        flex: 1,
                                        child: Text('% Imputado',
                                            style: headerListStyle,
                                            textAlign: TextAlign.right),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Text('¿Taxes?',
                                              style: headerListStyle,
                                              textAlign: TextAlign.center)),
                                      Expanded(
                                          flex: 1,
                                          child: Text('Imputado',
                                              style: headerListStyle,
                                              textAlign: TextAlign.right)),
                                      Expanded(flex: 1, child: Text('')),
                                    ],
                                  )));
                        }
                      }

                      Invoice invoice = invoices[index - 1];
                      InvoiceDistrib dist;
                      if (item != null) {
                        dist = InvoiceDistrib.fromJson(
                            item.mapinvoices[invoice.uuid]);
                      } else {
                        dist = InvoiceDistrib('', '', invoice.uuid, '', 0);
                      }

                      double imputado = (dist.taxes)
                          ? invoice.total * dist.percentaje * 0.01
                          : invoice.base * dist.percentaje * 0.01;

                      Row buttons = Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Button for edit invoice
                          iconBtn(context, (context, args) {
                            _editInvoiceDialog(context, args).then((value) {
                              if (value == null) {
                                return;
                              }
                              reloadState();
                            });
                          }, invoice,
                              icon: Icons.edit_outlined,
                              text: 'Editar factura'),
                          // Button for remove invoice
                          removeConfirmBtn(context, (context, args) {
                            Invoice item = args as Invoice;
                            item.delete();
                            reloadState();
                          }, invoice),
                        ],
                      );

                      if (item == null) {
                        return Container(
                            color: (index % 2 == 0)
                                ? Colors.white
                                : Colors.grey[100],
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1, child: Text(invoice.tracker)),
                                    Expanded(
                                        flex: 1, child: Text(invoice.number)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(DateFormat('dd/MM/yyyy')
                                            .format(invoice.date))),
                                    Expanded(
                                        flex: 1,
                                        child: Text(toCurrency(invoice.base),
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(toCurrency(invoice.taxes),
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(toCurrency(invoice.total),
                                            textAlign: TextAlign.right)),
                                    Expanded(flex: 1, child: buttons),
                                  ],
                                )));
                      } else {
                        return Container(
                            color: (index % 2 == 0)
                                ? Colors.white
                                : Colors.grey[100],
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1, child: Text(invoice.tracker)),
                                    Expanded(
                                        flex: 1, child: Text(invoice.number)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(DateFormat('dd/MM/yyyy')
                                            .format(invoice.date))),
                                    Expanded(
                                        flex: 1,
                                        child: Text(toCurrency(invoice.base),
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(toCurrency(invoice.taxes),
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(toCurrency(invoice.total),
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            dist.percentaje.toStringAsFixed(2),
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(dist.taxes ? 'Sí' : 'No',
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(toCurrency(imputado),
                                            textAlign: TextAlign.right)),
                                    Expanded(flex: 1, child: buttons),
                                  ],
                                )));
                      }
                    },
                  ),
                ),
              ));
        });
  }

  Widget getInfoPartners(context, args) {
    List<Widget> rows = [];
    for (Organization partner in _project!.partnersObj) {
      rows.add(Row(children: [
        Expanded(flex: 1, child: partnerSummaryCard(partner)),
      ]));
    }

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.isNotEmpty
                ? rows
                : [
                    const Center(
                        child: Text("No se ha efectuado ninguna asignación."))
                  ]));
  }

  Widget partnerSummaryCard(Organization item) {
    List<Widget> rows = [];
    // TextStyle currentStyle;
    List<Distribution> filtered = [];
    for (Distribution dist in finnInfo.distributions) {
      if (dist.partner.uuid == item.uuid) {
        filtered.add(dist);
      }
    }

    filtered.sort((a, b) {
      if (a.finn.orgUuid == b.finn.orgUuid) {
        return a.finn.name.compareTo(b.finn.name);
      } else {
        return a.finn.orgUuid.compareTo(b.finn.orgUuid);
      }
    });

    for (Distribution dist in filtered) {
      double executed = dist.getExecuted();
      double executedPercent = (dist.amount == 0) ? 0 : executed / dist.amount;
      Organization financier = financiers[dist.finn.orgUuid]!;
      if (dist.partner.uuid == item.uuid) {
        rows.add(Row(children: [
          Expanded(
              flex: 2,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: Text(financier.name, style: cellsListStyle))),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Text("${dist.finn.name}. ${dist.finn.description}",
                  style: cellsListStyle),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Text(DateFormat('dd/MM/yyyy').format(dist.date),
                  style: cellsListStyle, textAlign: TextAlign.right),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Text(
                toCurrency(dist.amount),
                style: cellsListStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      toCurrency(executed),
                      style: cellsListStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${(executedPercent * 100).toStringAsFixed(0)} %",
                      style: cellsListStyle,
                      textAlign: TextAlign.right,
                    ),
                  )
                ])),
          ),
          Expanded(
              flex: 2,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (dist.mapinvoices.keys.isNotEmpty)
                  iconBtn(context, listInvoices, dist,
                      icon: Icons.list,
                      text: '${dist.mapinvoices.keys.length} facturas')
                else
                  iconBtn(context, (context, args) {}, dist,
                      icon: Icons.list,
                      text: 'No hay facturas',
                      color: Colors.grey),
                iconBtn(context, _addInvoiceDialog, dist,
                    icon: Icons.euro_outlined, text: 'Agregar factura'),
                editBtn(context, addDistribDialog, {
                  'finn': dist.finn,
                  'index': finnInfo.distributions.indexOf(dist)
                }),
                removeConfirmBtn(context, removeDistrib, dist)
              ])),
        ]));
      }
    }
    return Card(
        //Partner card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(
            color: headerListBgColorIndicator,
            width: 1.0,
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(children: [
              Container(
                  decoration: BoxDecoration(
                      color: headerListBgColorIndicator,
                      borderRadius: BorderRadius.circular(0.0),
                      border: Border.all(
                          color: headerListBgColorIndicator, width: 1.0)),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.name,
                                style: headerListStyle.copyWith(
                                    color: Colors.white)),
                          ]))),
              const Divider(thickness: 1, color: Colors.grey),
              Container(
                  color: headerListBgColor,
                  child: Row(children: [
                    const Expanded(
                        flex: 2,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            child: Text(
                              "Financiador",
                              style: headerListStyle,
                            ))),
                    const Expanded(
                        flex: 2,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            child: Text("Partida",
                                style: headerListStyle,
                                textAlign: TextAlign.left))),
                    const Expanded(
                        flex: 1,
                        child: Text("Fecha",
                            style: headerListStyle,
                            textAlign: TextAlign.right)),
                    const Expanded(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            child: Text("Importe",
                                style: headerListStyle,
                                textAlign: TextAlign.right))),
                    const Expanded(
                      flex: 2,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Row(children: [
                            Expanded(
                                flex: 3,
                                child: Text("Ejecutado",
                                    style: headerListStyle,
                                    textAlign: TextAlign.right)),
                            Expanded(
                                flex: 1,
                                child: Text("%",
                                    style: headerListStyle,
                                    textAlign: TextAlign.right)),
                          ])),
                    ),
                    // const Divider(thickness: 1, color: Colors.grey),
                    Expanded(flex: 2, child: Container())
                  ])),
              const Divider(thickness: 1, color: Colors.grey),
              ...rows,
              space(height: 10),
            ])));
  }

  Widget populatePartnersContainer() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: customCollapse(
          context,
          Text(
              "Distribución presupuestaria por socio (${_project!.partnersObj.length})",
              style: const TextStyle(
                  fontSize: 18, color: mainColor, fontWeight: FontWeight.bold)),
          getInfoPartners,
          {},
          subtitle: "Listado de partidas financieras asignadas a cada socio",
          expanded: false),
    );
  }

  Future<double> invoicesByPartner() async {
    // List finnUuids = finnList.map((e) => e.uuid).toList();
    List finnUuids = getAllFinns().map((e) => e.uuid).toList();
    await Invoice.getByFinn(finnUuids).then((value) {
      invoicesItems = value;
    });
    invoicesSummary = {};

    for (var item in invoicesSummary.values) {
      executedBudgetProject += item['total']!;
    }
    return executedBudgetProject;
  }

  @override
  Widget build(BuildContext context) {
    finnList = getAllFinns();
    finnanciersContainer = populateFinnanciersContainer();
    partnersContainer = populatePartnersContainer();
    if (_project != null) {
      return Scaffold(
          body: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              mainMenu(context),
              finnHeader(context, _project),
              Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: aportesSummaryContainer!),
                          Expanded(flex: 1, child: distribSummaryContainer!),
                        ]),
                    Row(
                      children: [
                        Expanded(flex: 1, child: finnanciersContainer!),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(flex: 1, child: partnersContainer!),
                      ],
                    ),
                    invoicesContainer!,
                  ]),
              footer(context),
            ]),
      ));
    } else {
      return const ProjectsPage();
    }
  }

/*-------------------------------------------------------------
                            FINNS
-------------------------------------------------------------*/
  Widget finnHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: Text(
            (_project != null)
                ? "$PAGE_FINN_TITLE de ${project!.name}."
                : "Esperando datos...",
            style: const TextStyle(fontSize: 20)),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            transferButton(context, project),
            space(width: 10),
            //invoicesButton(context, project),
            goPage(
                context, 'Facturas', const InvoicePage(), Icons.euro_outlined),
            space(width: 10),
            // finnAddBtn(context, project),
            // space(width: 10),
            goPage(context, 'Volver', const ProjectsPage(),
                Icons.arrow_circle_left_outlined),
          ],
        ),
      ),
    ]);
  }

  Widget transferButton(context, _project) {
    void goTransfer(project) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => TransfersPage(
                    project: project,
                    finnItems: finnList,
                    aportesItems: aportesItems,
                    distribItems: distribItems,
                  ))));
    }

    return actionButtonVertical(
        context, 'Transferencias', goTransfer, Icons.euro_outlined, _project);
  }

  Widget invoicesButton(context, _project) {
    void goInvoices(project) {
      listInvoices(context, null);
    }

    return actionButtonVertical(
        context, 'Facturas', goInvoices, Icons.euro_outlined, _project);
  }

  Widget populateSummaryContainer() {
    aportesSummaryContainer ??= populateAportesSummaryContainer();
    distribSummaryContainer ??= populateDistribSummaryContainer();
    return Row(children: [
      Expanded(flex: 1, child: aportesSummaryContainer!),
      Expanded(flex: 1, child: distribSummaryContainer!),
    ]);
  }

// ------------------ INVOICES ------------------
  // Widget populateInvoicesContainer() {
  //   Text headerField(String title, [alignment = TextAlign.start]) {
  //     return Text(title, textAlign: alignment, style: headerListStyle);
  //   }

  //   return Container(width: double.infinity);
  // }

  Widget rowFromInvoice(Invoice invoice) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        child: Row(children: [
          // Expanded(
          //     flex: 2,
          //     child: Text(finnUuidHash.containsKey(invoice.finn)
          //         ? finnUuidHash[invoice.finn]!.name
          //         : '')),
          Expanded(flex: 2, child: Text(invoice.number)),
          Expanded(flex: 2, child: Text(invoice.code)),
          Expanded(
              flex: 2,
              child: Text(DateFormat('dd-MM-yyyy').format(invoice.date))),
          Expanded(flex: 4, child: Text(invoice.concept)),
          Expanded(
              flex: 2,
              child: Text(
                toCurrency(invoice.base, invoice.currency),
                textAlign: TextAlign.end,
              )),
          Expanded(
              flex: 2,
              child: Text(
                toCurrency(invoice.taxes, invoice.currency),
                textAlign: TextAlign.end,
              )),
          Expanded(
              flex: 2,
              child: Text(
                toCurrency(invoice.total, invoice.currency),
                textAlign: TextAlign.end,
              )),

          Expanded(
              flex: 1,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        _editInvoiceDialog(context, invoice).then((value) {
                          if ((value != null) && (value.id == "")) {
                            invoicesItems.remove(invoice);
                          }
                          reloadState();
                        });
                      },
                      icon: const Icon(Icons.edit)))),
        ]));
  }

// ------------------ DIALOGS ------------------
  Future<Invoice?> _addInvoiceDialog(context, Distribution dist) {
    return showDialog<Invoice>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir factura', context),
          content: InvoiceForm(
            key: null,
            existingInvoice: null,
            partner: dist.partner,
            tracker: tracker,
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        InvoiceDistrib.getByDistributionAndInvoice(dist.uuid, value.uuid)
            .then((item) {
          showDialog<InvoiceDistrib>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Porcentaje asignado'),
                content: InvoiceDistributionForm(
                  key: null,
                  item: item,
                ),
              );
            },
          ).then((value) {
            if (value != null) {
              dist.mapinvoices[value.invoice] = value.toJson();
              dist.save();
              finnInfo.distributions[finnInfo.distributions.indexOf(dist)] =
                  dist;
              finnInfo.save();
              if (mounted) {
                setState(() {
                  partnersContainer = populatePartnersContainer();
                });
              }
            }
          });
        });
      }
      return value;
    });
  }

  Future<Invoice?> _editInvoiceDialog(context, Invoice invoice) {
    return showDialog<Invoice>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: s4cTitleBar('Editar factura', context, Icons.edit),
            content: InvoiceForm(
                existingInvoice: invoice, partner: partners.values.first));
      },
    );
  }

  void addFinnDialog(context, [args]) {
    Organization financier = args[0];
    SFinn? parent = args[1];

    _addFinnDialog(context, financier).then((value) {
      if (value != null) {
        if (!finnList.contains(value)) {
          finnList.add(value);
          // finnHash[value.name] = value;
          // finnUuidHash[value.uuid] = value;
        }
        if (parent == null) {
          for (SFinn finn in finnInfo.partidas) {
            if (finn.uuid == value.uuid) {
              finnInfo.partidas.remove(finn);
              break;
            }
          }
          finnInfo.partidas.add(value);
        } else {
          value.parent = parent.uuid;
          for (SFinn finn in parent.partidas) {
            if (finn.uuid == value.uuid) {
              parent.partidas.remove(finn);
              break;
            }
          }
          parent.partidas.add(value);
          parent.save();
        }
        finnInfo.save();

        reloadState();
      }
    });
  }

  Future<SFinn?> _addFinnDialog(context, [Organization? financier]) {
    return showDialog<SFinn>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir partida', context),
          content: SFinnForm(
            key: null,
            project: _project!,
            financiers: financiers,
            financier: financier,
            existingFinn: SFinn.getEmpty()..project = _project!.uuid,
          ),
        );
      },
    );
  }

  Future<SFinn?> _editFinnDialog(context, SFinn finn) {
    return showDialog<SFinn>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: s4cTitleBar('Editar partida', context, Icons.edit),
            content: SFinnForm(
              key: null,
              project: _project!,
              existingFinn: finn,
              financier: financiers[finn.orgUuid],
              financiers: financiers,
            ));
      },
    );
  }

  Future<void> addDistribDialog(context, args) async {
    SFinn finn = args['finn'];
    int index = args['index'];

    return showDialog<SFinnInfo>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Añadir distribución'),
            content: SingleChildScrollView(
              child: DistributionForm(
                  info: finnInfo,
                  finn: finn,
                  project: _project!,
                  partners: partners.values.toList(),
                  index: index),
            ),
          );
        }).then((value) {
      if (value != null) {
        finnInfo = value;
        if (mounted) {
          setState(() {
            partnersContainer = populatePartnersContainer();
          });
        }
      }
    });
  }
}
