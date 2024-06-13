// ignore_for_file: constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/finn_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
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
  SProject? _project;
  Map<String, Organization> financiers = {};
  Map<String, Organization> partners = {};
  SFinnInfo finnInfo = SFinnInfo("", "", "");

  List finnList = [];
  Map<String, Map> invoicesSummary = {};
  List aportesItems = [];
  List distribItems = [];
  Map<String, int> mapLevels = {};

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
    for (Invoice invoice in invoicesItems) {
      if (invoicesSummary.containsKey(invoice.partner)) {
        invoicesSummary[invoice.partner]!['total'] +=
            invoice.total * invoice.imputation * 0.01;
      } else {
        invoicesSummary[invoice.partner] = {
          "total": invoice.total * invoice.imputation * 0.01
        };
      }
    }

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
/*
    if (aportesItems.isEmpty) {
      await FinnContribution.getByProject(_project!.uuid).then((val) {
        aportesItems = val;
      });
    }
*/
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
        invoicesContainer = populateInvoicesContainer();
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
    }

    while (queue.isNotEmpty) {
      SFinn item = queue.removeAt(0);
      items.add(item);
      int pos = 0;
      for (SFinn child in item.partidas) {
        mapLevels[child.uuid] = mapLevels[item.uuid]! + 1;
        queue.insert(pos, child);
        pos += 1;
      }
    }
    return items;
  }

  void removeFinn(context, finn) {
    List items = [];
    List queue = [];
    for (SFinn item in finnInfo.partidas) {
      if (item.uuid == finn.uuid) {
        finnInfo.partidas.remove(item);
      }
      queue.add(item);
    }
    while (queue.isNotEmpty) {
      SFinn item = queue.removeAt(0);
      items.add(item);
      for (SFinn child in item.partidas) {
        if (child.uuid == finn.uuid) {
          item.partidas.remove(child);
        }
        queue.add(child);
      }
    }
    finnInfo.save();

    finn.delete();
    finnList.remove(finn);
    // finnHash.remove(finn.name);
    // finnUuidHash.remove(finn.uuid);
    reloadState();
  }

  Widget finnancierSummaryCard(Organization item) {
    List<Widget> rows = [];
    TextStyle currentStyle;
    for (SFinn finn in finnList) {
      if (finn.orgUuid == item.uuid) {
        if (mapLevels[finn.uuid] == 0) {
          currentStyle = cellsListStyle.copyWith(fontWeight: FontWeight.bold);
        } else {
          currentStyle = cellsListStyle;
        }
        if (finn.contribution > finn.getAmountContrib()) {
          currentStyle = currentStyle.copyWith(color: warningColor);
        } else if (finn.contribution < finn.getAmountContrib()) {
          currentStyle = currentStyle.copyWith(color: dangerColor);
        }

        rows.add(Row(children: [
          Expanded(
              flex: 5,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5.0 + 20.0 * (mapLevels[finn.uuid]!),
                      vertical: 0),
                  child: Text("${finn.name}. ${finn.description}",
                      style: currentStyle))),
          Expanded(
              flex: 2,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Text(toCurrency(finn.contribution),
                      textAlign: TextAlign.right, style: currentStyle))),
          Expanded(
              flex: 2,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Text(
                    toCurrency(finn.getAmountContrib()),
                    textAlign: TextAlign.right,
                    style: currentStyle,
                  ))),
          Expanded(
              flex: 2,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Text(
                    toCurrency(getDistrib(finn.uuid)),
                    textAlign: TextAlign.right,
                    style: currentStyle,
                  ))),
          Expanded(
            flex: 1,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: ((finn.getAmountContrib() != 0) &&
                        (getDistrib(finn.uuid) != 0))
                    ? (getDistrib(finn.uuid) >= finn.getAmountContrib())
                        ? Text(
                            "100%",
                            style: dangerText.copyWith(
                                fontSize: dangerText.fontSize! - 2),
                            textAlign: TextAlign.right,
                          )
                        : Text(
                            "${(getDistrib(finn.uuid) / finn.getAmountContrib() * 100).toStringAsFixed(0)}%",
                            textAlign: TextAlign.right,
                          )
                    : const Text(
                        "0%",
                        textAlign: TextAlign.right,
                      )),
          ),
          Expanded(
            flex: 2,
            child: Padding(
                padding: EdgeInsets.only(
                    left: 10, right: 10.0 + 20.0 * (mapLevels[finn.uuid]!)),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  iconBtn(context, addFinnDialog, [item, finn],
                      icon: Icons.add, text: 'Añadir subpartida'),
                  iconBtn(context, (context, args) {
                    _editFinnDialog(context, finn).then((value) {
                      if (value == null) {
                        return;
                      }
                      if (finn.id == "") {
                        finnList.remove(finn);
                        // finnHash.remove(finn.name);
                        // finnUuidHash.remove(finn.uuid);
                      }
                      finnSelected = null;
                      finnInfo.save();
                      reloadState();
                    });
                  }, finn, icon: Icons.edit_outlined),
                  removeConfirmBtn(context, removeFinn, finn)
                ])),
          ),
        ]));
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
                child: Row(children: [
                  const Expanded(
                      flex: 5,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              iconBtn(context, (context, args) {}, [],
                                  icon: Icons.info,
                                  text: "Lo que se indica en la partida",
                                  iconSize: 14),
                              const Text("Nominal",
                                  style: headerListStyle,
                                  textAlign: TextAlign.right),
                            ],
                          ))),
                  Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              iconBtn(context, (context, args) {}, [],
                                  icon: Icons.info,
                                  text: "Lo que se suman las subpartidas",
                                  iconSize: 14),
                              const Text("Subpartidas",
                                  style: headerListStyle,
                                  textAlign: TextAlign.right),
                            ],
                          ))),
                  const Expanded(
                      flex: 2,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("Ejecutado",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                  const Expanded(
                      flex: 1,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("%",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                  const Expanded(
                      flex: 2,
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

  Widget getInfoPartners(context, args) {
    List<Row> rows = [];
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
                        child: Text("No hay partidas financieras asignadas"))
                  ]));
  }

  Widget partnerSummaryCard(Organization item) {
    List<Widget> rows = [];
    TextStyle currentStyle;
    for (SFinn finn in finnList) {
      if (finn.orgUuid == item.uuid) {
        if (finn.getLevel() == 0) {
          currentStyle = cellsListStyle.copyWith(fontWeight: FontWeight.bold);
        } else {
          currentStyle = cellsListStyle;
        }
        if (finn.contribution > finn.getAmountContrib()) {
          currentStyle = currentStyle.copyWith(color: warningColor);
        } else if (finn.contribution < finn.getAmountContrib()) {
          currentStyle = currentStyle.copyWith(color: dangerColor);
        }

        rows.add(Row(children: [
          Expanded(
              flex: 5,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5.0 + 50.0 * (finn.getLevel()), vertical: 0),
                  child: Text("${finn.name}. ${finn.description}",
                      style: currentStyle))),
          Expanded(
              flex: 2,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Text(toCurrency(finn.contribution),
                      textAlign: TextAlign.right, style: currentStyle))),
          Expanded(
              flex: 2,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Text(
                    toCurrency(finn.getAmountContrib()),
                    textAlign: TextAlign.right,
                    style: currentStyle,
                  ))),
          Expanded(
              flex: 2,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Text(
                    toCurrency(getDistrib(finn.uuid)),
                    textAlign: TextAlign.right,
                    style: currentStyle,
                  ))),
          Expanded(
            flex: 1,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: ((finn.getAmountContrib() != 0) &&
                        (getDistrib(finn.uuid) != 0))
                    ? (getDistrib(finn.uuid) >= finn.getAmountContrib())
                        ? Text(
                            "100%",
                            style: dangerText.copyWith(
                                fontSize: dangerText.fontSize! - 2),
                            textAlign: TextAlign.right,
                          )
                        : Text(
                            "${(getDistrib(finn.uuid) / finn.getAmountContrib() * 100).toStringAsFixed(0)}%",
                            textAlign: TextAlign.right,
                          )
                    : const Text(
                        "0%",
                        textAlign: TextAlign.right,
                      )),
          ),
          Expanded(
            flex: 2,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  iconBtn(context, addFinnDialog, [item, finn],
                      icon: Icons.add, text: 'Añadir subpartida'),
                  iconBtn(context, (context, args) {
                    _editFinnDialog(context, finn).then((value) {
                      if (value == null) {
                        return;
                      }
                      if (finn.id == "") {
                        finnList.remove(finn);
                        // finnHash.remove(finn.name);
                        // finnUuidHash.remove(finn.uuid);
                      }
                      finnSelected = null;
                      finnInfo.save();
                      reloadState();
                    });
                  }, finn, icon: Icons.edit_outlined),
                  removeConfirmBtn(context, removeFinn, finn)
                ])),
          ),
        ]));
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
                child: Row(children: [
                  const Expanded(
                      flex: 5,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              iconBtn(context, (context, args) {}, [],
                                  icon: Icons.info,
                                  text: "Lo que se indica en la partida",
                                  iconSize: 14),
                              const Text("Nominal",
                                  style: headerListStyle,
                                  textAlign: TextAlign.right),
                            ],
                          ))),
                  Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              iconBtn(context, (context, args) {}, [],
                                  icon: Icons.info,
                                  text: "Lo que se suman las subpartidas",
                                  iconSize: 14),
                              Text("Subpartidas",
                                  style: headerListStyle.copyWith(
                                      color: Colors.white),
                                  textAlign: TextAlign.right),
                            ],
                          ))),
                  const Expanded(
                      flex: 2,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("Ejecutado",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                  const Expanded(
                      flex: 1,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("%",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                  const Expanded(
                      flex: 2,
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

  Widget populatePartnersContainer() {
    List<Widget> rows = [];
    for (Organization partner in _project!.partnersObj) {
      rows.add(Row(children: [
        Expanded(flex: 1, child: partnerSummaryCard(partner)),
      ]));
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: customCollapse(
          context,
          Text(
              "Distribución presupuestaria por socio (${_project!.partnersObj.length})",
              style: const TextStyle(
                  fontSize: 18, color: mainColor, fontWeight: FontWeight.bold)),
          //getInfoPartners,
          (context, args) {
        return Container();
      }, {},
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
    for (Invoice invoice in invoicesItems) {
      if (invoicesSummary.containsKey(invoice.partner)) {
        invoicesSummary[invoice.partner]!['total'] +=
            invoice.total * invoice.imputation * 0.01;
      } else {
        invoicesSummary[invoice.partner] = {
          "total": invoice.total * invoice.imputation * 0.01
        };
      }
    }
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
            invoicesButton(context, project),
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Próximamente'),
            content:
                const Text('Este contenido estará disponible próximamente.'),
            actions: [
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
  Widget populateInvoicesContainer() {
    Text headerField(String title, [alignment = TextAlign.start]) {
      return Text(title, textAlign: alignment, style: headerListStyle);
    }

    if (finnSelected != null) {
      invoicesList = [];
      if (invoicesItems.isNotEmpty) {
        Row header = Row(children: [
          Expanded(flex: 2, child: headerField('Partida')),
          Expanded(flex: 2, child: headerField('Número')),
          Expanded(flex: 2, child: headerField('Código')),
          Expanded(flex: 2, child: headerField('Fecha')),
          Expanded(
              flex: 4,
              child: headerField(AppLocalizations.of(context)!.concept)),
          Expanded(
              flex: 2,
              child: headerField(AppLocalizations.of(context)!.partner)),
          Expanded(flex: 2, child: headerField('Base', TextAlign.end)),
          Expanded(flex: 2, child: headerField('Impuestos', TextAlign.end)),
          Expanded(flex: 2, child: headerField('Total', TextAlign.end)),
          Expanded(flex: 1, child: headerField('%', TextAlign.end)),
          Expanded(flex: 1, child: headerField('', TextAlign.end)),
        ]);

        invoicesList.add(header);
        invoicesList.add(const Divider(
          height: 5,
          color: Colors.black,
        ));
        invoicesItems.sort((a, b) => (a.date).compareTo(b.date));
        List invoicesToShow = [];

        for (Invoice invoice in invoicesToShow) {
          invoicesList.add(rowFromInvoice(invoice));
          if (!(invoice == invoicesToShow.last)) {
            invoicesList.add(const Divider(
              height: 5,
              color: Colors.grey,
            ));
          }
        }
      }

      return SizedBox(
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
                Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: withChildrens.contains(finnSelected!.name)
                            ? Container()
                            : Tooltip(
                                message:
                                    AppLocalizations.of(context)!.addInvoice,
                                child: IconButton(
                                    onPressed: () {
                                      _addInvoiceDialog(context, finnSelected!)
                                          .then((value) {
                                        if (value != null) {
                                          if (!invoicesItems.contains(value)) {
                                            invoicesItems.add(value);
                                          }
                                          reloadState();
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                        Icons.add_circle_outline))))),
                Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Tooltip(
                            message: 'Cerrar listado',
                            child: IconButton(
                                onPressed: () {
                                  finnSelected = null;
                                  invoicesList = [];
                                  reloadState();
                                },
                                icon: const Icon(
                                    Icons.arrow_circle_left_outlined))))),
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
                              const Center(
                                  child: Padding(
                                      padding: EdgeInsets.all(50),
                                      child: Text(
                                          'No hay facturas para esta partida',
                                          style: mainText)))
                            ],
                    ),
                  ),
                ],
              )
            ]),
          )));
    } else {
      return Container(width: double.infinity);
    }
  }

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
                  (getObject(_project!.partnersObj, invoice.partner) as Contact)
                      .name)),
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
              child: Text(
                "${invoice.imputation.toStringAsFixed(0)}%",
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

  Future<Invoice?> _addInvoiceDialog(context, SFinn finn) {
    return showDialog<Invoice>(
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

  Future<Invoice?> _editInvoiceDialog(context, Invoice invoice) {
    return showDialog<Invoice>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: s4cTitleBar('Editar factura', context, Icons.edit),
            content: InvoiceForm(
                existingInvoice: invoice, partners: _project!.partnersObj));
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
}
