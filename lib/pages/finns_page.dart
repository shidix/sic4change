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
  Map<String, SFinn> finnHash = {};
  Map<String, SFinn> finnUuidHash = {};

  List<String> withChildrens = [];

  List<Widget> invoicesList = [];
  List invoicesItems = [];
  SFinn? finnSelected;
  String? financierUuidSelected;
  double totalBudgetProject = 0;

  Widget? invoicesContainer = Container();
  Widget? summaryContainer = Container();
  Widget? finnContainer = Container();
  Widget? aportesSummaryContainer = Container();
  Widget? distribSummaryContainer = Container();
  Widget? finnanciersContainer = Container();

  bool belongsTo(SFinn finn, String financierUuid) {
    Map<String, String> equivalencies = {};
    for (String financier in _project!.financiers) {
      equivalencies[financier] = financier;
    }
    return (equivalencies[financierUuid] == finn.orgUuid);
  }

  // double getAporte(String finnUuid, [String? financierUuid]) {
  //   Map<String, String> equivalencies = {};
  //   for (Organization financier in financiers.values) {
  //     if (_project!.financiers.contains(financier.uuid)) {
  //       equivalencies[financier.uuid] = financier.uuid;
  //     }
  //   }
  //   double aporte = 0;
  //   try {
  //     SFinn finn = finnUuidHash[finnUuid]!;
  //     aportesItems.sort((a, b) {
  //       a = finnUuidHash[a.finn];
  //       b = finnUuidHash[b.finn];
  //       return b.name.length.compareTo(a.name.length);
  //     });
  //     for (FinnContribution item in aportesItems) {
  //       SFinn itemFinn = finnUuidHash[item.finn]!;
  //       if (((itemFinn.name.startsWith(finn.name)) &&
  //               (itemFinn.orgUuid == finn.orgUuid)) &&
  //           (financierUuid == null ||
  //               item.financier == financierUuid ||
  //               equivalencies[item.financier] == financierUuid)) {
  //         if (itemFinn.name != finn.name) {
  //           aporte += item.amount;
  //         } else {
  //           if (aporte == 0) {
  //             aporte += item.amount;
  //           }
  //         }
  //       }
  //     }
  //   } catch (e, stacktrace) {
  //     print("Error: $e");
  //     print(stacktrace);
  //   }
  //   return aporte;
  // }

  double getDistrib(String finnUuid, [String? partnerUuid]) {
    Map<String, String> equivalencies = {};
    double distrib = 0;

    // for (Organization partner in _project!.partnersObj) {
    //   equivalencies[partner.uuid] = partner.uuid;
    // }
    // double distrib = 0;
    // SFinn finn = finnUuidHash[finnUuid]!;
    // for (FinnDistribution item in distribItems) {
    //   SFinn itemFinn = finnUuidHash[item.finn]!;
    //   if (itemFinn.orgUuid != finn.orgUuid) {
    //     continue;
    //   }

    //   if (((itemFinn.name.startsWith(finn.name)) &&
    //           (!withChildrens.contains(itemFinn.name))) &&
    //       (partnerUuid == null ||
    //           item.partner == partnerUuid ||
    //           equivalencies[item.partner] == partnerUuid)) {
    //     distrib += item.amount;
    //   }
    // }
    return distrib;
  }

  Widget populateAportesSummaryContainer() {
    double percentExecuted = 0.0;
    totalBudgetProject = 0;
    List<Widget> sourceRows = [];
    if (finnInfo.project == "") {
      return const Center(child: CircularProgressIndicator());
    } else {
      for (Organization org in financiers.values) {
        for (SFinn finn in finnInfo.partidas) {
          if (finn.orgUuid == org.uuid) {
            for (FinnContribution contribInfo in finn.contributions) {
              aportesItems.add(contribInfo);
            }
          }
        }
      }

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

    for (FinnDistribution distribution in distribItems) {
      if (!finnUuidHash.containsKey(distribution.finn)) {
        distribution.delete();
        continue;
      }
      SFinn finn = finnUuidHash[distribution.finn]!;
      if (withChildrens.contains(finn.name)) {
        continue;
      } else {
        if (distribTotalByPartner.containsKey(distribution.partner)) {
          distribTotalByPartner[distribution.partner] =
              distribTotalByPartner[distribution.partner]! +
                  distribution.amount;
        } else {
          distribTotalByPartner[distribution.partner] = distribution.amount;
        }
        totalDistrib += distribution.amount;
      }
    }

    // if (_project!.assignedBudget != totalDistrib) {
    //   _project!.assignedBudget = totalDistrib;
    //   _project!.save();
    // }

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

  Widget populateFinnContainer() {
    int widthFinn = 3;
    List<Widget> finnRows = [];
    if (financierUuidSelected != null) {
      Container headerRow = Container(
          color: headerListBgColor,
          child: Row(children: [
            Expanded(
                flex: widthFinn,
                child: const Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 15, top: 15),
                    child: Text("Partida", style: headerListStyle))),
            const Expanded(
                flex: 1,
                child: Text("Aportaciones",
                    textAlign: TextAlign.start, style: headerListStyle)),
            const Expanded(
                flex: 1,
                child: Text("Ejecución",
                    textAlign: TextAlign.start, style: headerListStyle)),
            //for (Contact partner in _project!.partnersObj)
            for (Organization partner in _project!.partnersObj)
              Expanded(
                  flex: 1,
                  child: Text(partner.name,
                      textAlign: TextAlign.start, style: headerListStyle)),
          ]));
      finnRows.add(headerRow);
      finnRows.add(const Divider(thickness: 1, color: Colors.grey));
      for (SFinn finn in finnList) {
        if (finn.orgUuid != financierUuidSelected) {
          continue;
        }
        int level = finn.getLevel();
        if ((finnList.first != finn) && (level == 1)) {
          finnRows.add(const Divider());
        }
        Map<dynamic, dynamic> summary = {"total": 0};
        if (level == 1) {
          summary = {"total": finn.getAmountContrib()};
        } else {
          summary = {"total": finn.getAmountContrib()};
        }
        TextStyle trunkStyle =
            cellsListStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 15);
        TextStyle leafStyle = cellsListStyle;
        String finnTitle = "${finn.name}. ${finn.description}";
        String suffix = "";
        if (finnTitle.length > 45) {
          suffix = "...";
        }

        finnRows.add(SizedBox(
            height: 30,
            child: Row(children: [
              Expanded(
                  flex: widthFinn,
                  child: Padding(
                      padding: EdgeInsets.only(left: finn.getLevel() * 15),
                      child: Row(children: [
                        Tooltip(
                            message: finnTitle,
                            child: Text(
                                finnTitle.substring(
                                        0, min(finnTitle.length, 45)) +
                                    suffix,
                                style: level == 1 ? trunkStyle : leafStyle)),
                        IconButton(
                            onPressed: () {
                              // _editFinnDialog([context, finn, _project]);
                              _editFinnDialog(context, finn).then((value) {
                                if (value == null) {
                                  return;
                                }
                                if (finn.id == "") {
                                  finnList.remove(finn);
                                  finnHash.remove(finn.name);
                                  finnUuidHash.remove(finn.uuid);
                                }
                                finnSelected = null;
                                reloadState();
                              });
                            },
                            icon: const Icon(Icons.edit, size: 15)),
                        IconButton(
                            onPressed: () {
                              finnSelected = finn;
                              reloadState();
                            },
                            icon: const Icon(Icons.list, size: 15))
                      ]))),
              Expanded(
                  flex: 1,
                  child: Text(toCurrency(summary["total"]),
                      textAlign: TextAlign.start,
                      style: level == 1 ? trunkStyle : leafStyle)),
              for (Organization financier in _project!.financiersObj)
                if (belongsTo(finn, financier.uuid))
                  Expanded(
                      flex: 1,
                      child: withChildrens.contains(finn.name)
                          ? Text(toCurrency(finn.getAmountContrib()),
                              textAlign: TextAlign.start,
                              style: level == 1 ? trunkStyle : leafStyle)
                          : Row(children: [
                              Text(toCurrency(finn.getAmountContrib()),
                                  textAlign: TextAlign.start,
                                  style: level == 1 ? trunkStyle : leafStyle),
                              space(width: 5),
                              IconButton(
                                  onPressed: () {
                                    _editFinnContribDialog(
                                        context, finn, financier);
                                  },
                                  icon: const Icon(Icons.edit, size: 15))
                            ])),
              Expanded(
                  flex: 1,
                  child: Text(toCurrency(getDistrib(finn.uuid)),
                      textAlign: TextAlign.start,
                      style: level == 1
                          ? (getDistrib(finn.uuid) > finn.getAmountContrib())
                              ? trunkStyle.copyWith(color: dangerColor)
                              : trunkStyle
                          : (getDistrib(finn.uuid) > finn.getAmountContrib())
                              ? leafStyle.copyWith(color: dangerColor)
                              : leafStyle)),
              //for (Contact partner in _project!.partnersObj)
              for (Organization partner in _project!.partnersObj)
                Expanded(
                    flex: 1,
                    child: withChildrens.contains(finn.name)
                        ? Text(toCurrency(getDistrib(finn.uuid, partner.uuid)),
                            textAlign: TextAlign.start,
                            style: level == 1 ? trunkStyle : leafStyle)
                        : Row(children: [
                            Text(
                                toCurrency(getDistrib(finn.uuid, partner.uuid)),
                                textAlign: TextAlign.start,
                                style: level == 1 ? trunkStyle : leafStyle),
                            space(width: 5),
                            IconButton(
                                onPressed: () {
                                  _editFinnDistDialog(context, finn, partner);
                                },
                                icon: const Icon(Icons.edit, size: 15))
                          ]))
            ])));
        //finnRows.add(const Divider(thickness: 1, color: Colors.grey));
      }
    } else {
      // finnRows.add(
      //     const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      //   Icon(
      //     Icons.ads_click,
      //   ),

      //   Text("Seleccione un financiador o una partida para ver los detalles")
      // ]));
      // finnRows.add(const Divider(thickness: 1, color: Colors.grey));
    }
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: finnRows),
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
    if (aportesItems.isEmpty) {
      await FinnContribution.getByProject(_project!.uuid).then((val) {
        aportesItems = val;
      });
    }
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
        finnContainer = populateFinnContainer();
        invoicesContainer = populateInvoicesContainer();
        finnanciersContainer = populateFinnanciersContainer();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    loadInitialData();
  }

  void loadInitialData() {
    SFinnInfo.byProject(_project!.uuid).then((val) {
      if (val != null) {
        finnInfo = val;
        finnList = getAllFinns();
      } else {
        finnInfo = SFinnInfo("", const Uuid().v4(), _project!.uuid);
        finnInfo.save();
      }
      if (mounted) {
        setState(() {
          finnList = getAllFinns();
        });
      }
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
    });

    totalBudgetProject = fromCurrency(_project!.budget);
    executedBudgetProject = 0;

    finnContainer = const Center(child: CircularProgressIndicator());
    invoicesContainer = Container(width: 0);

    finnanciersContainer = populateFinnanciersContainer();
    if (aportesItems.isEmpty) {
      FinnContribution.getByProject(_project!.uuid).then((val) {
        aportesItems = val;
        reloadState();
      });
    } else {
      aportesSummaryContainer = populateAportesSummaryContainer();
    }

    distribSummaryContainer = populateDistribSummaryContainer();
    summaryContainer = populateSummaryContainer();

    // SFinn.byProject(_project!.uuid).then((val) {
    //   finnList = val;

    //   for (SFinn finn in finnList) {
    //     finnHash[finn.name] = finn;
    //     finnUuidHash[finn.uuid] = finn;
    //     String parentCode = finn.parentCode();
    //     if (finnHash.containsKey(parentCode)) {
    //       if (finn.parent != finnHash[parentCode]!.uuid) {
    //         finn.parent = finnHash[parentCode]!.uuid;
    //         finn.save();
    //       }
    //       if (!withChildrens.contains(parentCode)) {
    //         withChildrens.add(parentCode);
    //       }
    //     }
    //   }

    //   invoicesByPartner().then((value) {
    //     reloadState();
    //   });
    // });
  }

  List getAllFinns() {
    List items = [];
    if (finnInfo.partidas.isEmpty) {
      return items;
    }
    List queue = finnInfo.partidas.map((e) => e).toList();

    while (queue.isNotEmpty) {
      SFinn item = queue.removeAt(0);
      items.add(item);
      int pos = 0;
      for (SFinn child in item.partidas) {
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
    finnHash.remove(finn.name);
    finnUuidHash.remove(finn.uuid);
    reloadState();
  }

  Widget finnancierSummaryCard(Organization item) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(
            color: headerListBgColorIndicator,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(children: [
            Container(
                color: headerListBgColorIndicator,
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("Presupuesto",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                  Expanded(
                      flex: 2,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("Ejecutado",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("%",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Text("",
                              style: headerListStyle,
                              textAlign: TextAlign.right))),
                ])),
            const Divider(thickness: 1, color: Colors.grey),
            for (SFinn finn in finnList)
              (finn.orgUuid == item.uuid) && (finn.getLevel() >= -1)
                  ? Row(children: [
                      Expanded(
                          flex: 5,
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.0 + 50.0 * (finn.getLevel()),
                                  vertical: 0),
                              child: Text("${finn.name}. ${finn.description}",
                                  style: (finn.getLevel() == 0)
                                      ? cellsListStyle.copyWith(
                                          fontWeight: FontWeight.bold)
                                      : cellsListStyle))),
                      Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              child: Text(
                                toCurrency(finn.getAmountContrib()),
                                textAlign: TextAlign.right,
                                style: (finn.getLevel() == 0)
                                    ? cellsListStyle.copyWith(
                                        fontWeight: FontWeight.bold)
                                    : cellsListStyle,
                              ))),
                      Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              child: Text(
                                toCurrency(getDistrib(finn.uuid)),
                                textAlign: TextAlign.right,
                                style: (finn.getLevel() == 0)
                                    ? cellsListStyle.copyWith(
                                        fontWeight: FontWeight.bold)
                                    : cellsListStyle,
                              ))),
                      Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            child: ((finn.getAmountContrib() != 0) &&
                                    (getDistrib(finn.uuid) != 0))
                                ? (getDistrib(finn.uuid) >=
                                        finn.getAmountContrib())
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
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            child: Row(children: [
                              iconBtn(context, addFinnDialog, [item, finn],
                                  icon: Icons.add),
                              iconBtn(context, (context, finn) {
                                _editFinnDialog(context, finn).then((value) {
                                  if (value == null) {
                                    return;
                                  }
                                  if (finn.id == "") {
                                    finnList.remove(finn);
                                    finnHash.remove(finn.name);
                                    finnUuidHash.remove(finn.uuid);
                                  }
                                  finnSelected = null;
                                  finnInfo.save();
                                  reloadState();
                                });
                              }, finn, icon: Icons.edit_outlined),
                              removeConfirmBtn(context, removeFinn, finn)
                            ])),
                      ),
                    ])
                  : Container(),
            const Divider(thickness: 1, color: Colors.grey),
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
    return customCollapse(context, "Aportes presupuestarios por financiador",
        getInfoFinanciers, {});
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
                    Row(children: [
                      Expanded(flex: 1, child: finnContainer!),
                    ]),
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
            finnAddBtn(context, project),
            space(width: 10),
            goPage(context, 'Volver', const ProjectsPage(),
                Icons.arrow_circle_left_outlined),
          ],
        ),
      ),
    ]);
  }

  Widget finnAddBtn(context, _project) {
    return actionButtonVertical(
        context, 'Nueva partida', addFinnDialog, Icons.add, [null, null]);
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

  void _saveFinn(context, _finn, _name, _desc, _parent, _project) {
    _finn ??= SFinn("", const Uuid().v4(), _name, _desc, _parent, _project);

    _finn.name = _name;
    _finn.description = _desc;
    _finn.parent = _parent;
    _finn.project = _project;
    _finn.save();
    if (!finnList.contains(_finn)) {
      finnList.add(_finn);
      finnHash[_finn.name] = _finn;
      finnUuidHash[_finn.uuid] = _finn;
    }
    // finnList.sort((a, b) => (a.name).compareTo(b.name));

    reloadState();
  }

  Future<void> _editFinnDialog2(args) {
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

  Widget populateSummaryContainer() {
    aportesSummaryContainer ??= populateAportesSummaryContainer();
    distribSummaryContainer ??= populateDistribSummaryContainer();
    return Row(children: [
      Expanded(flex: 1, child: aportesSummaryContainer!),
      Expanded(flex: 1, child: distribSummaryContainer!),
    ]);
  }

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
        for (Invoice invoice in invoicesItems) {
          SFinn finn = finnUuidHash[invoice.finn]!;
          if (finn.name.startsWith(finnSelected!.name)) {
            invoicesToShow.add(invoice);
          }
        }
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
          Expanded(
              flex: 2,
              child: Text(finnUuidHash.containsKey(invoice.finn)
                  ? finnUuidHash[invoice.finn]!.name
                  : '')),
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

  Future<void> _editFinnContribDialog(context, SFinn finn, financierObj) {
    List<Row> rows = [];
    TextEditingController amount = TextEditingController(text: "0");
    TextEditingController comment = TextEditingController(text: "");
    FinnContribution item;
    item = FinnContribution("", financierObj.uuid, double.parse(amount.text),
        finn.uuid, comment.text);

    for (FinnContribution contribution in aportesItems) {
      if ((contribution.finn == finn.uuid)) {
        item = contribution;
        amount.text = item.amount.toStringAsFixed(2);
        comment.text = item.subject;
      }
    }

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
                        item.finn = finn.uuid;
                        item.financier = finn.orgUuid;
                        item.save();
                        if (!aportesItems.contains(item)) {
                          aportesItems.add(item);
                        }
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
    String partner = partnerObj.uuid;
    List<Row> rows = [];
    TextEditingController amount = TextEditingController(text: "0");
    TextEditingController comment = TextEditingController(text: "");
    FinnDistribution item = FinnDistribution(
        "", partner, double.parse(amount.text), finn.uuid, comment.text);

    for (FinnDistribution distribution in distribItems) {
      if ((distribution.finn == finn.uuid) &&
          (distribution.partner == partner)) {
        item = distribution;
        amount.text = item.amount.toStringAsFixed(2);
        comment.text = item.subject;
      }
    }

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

    Widget saveButton = saveBtnForm(
      context,
      () async {
        item.amount = double.parse(amount.text);
        item.subject = comment.text;
        item.save();
        if (!distribItems.contains(item)) {
          distribItems.add(item);
        }
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
              Row(
                children: [
                  Expanded(flex: 3, child: Container()),
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: saveButton)),
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: cancelBtnForm(context))),
                ],
              )
            ]);
      },
    );
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
          finnHash[value.name] = value;
          finnUuidHash[value.uuid] = value;
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
