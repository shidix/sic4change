import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/finn_form.dart';
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
  List finnList = [];
  SProject? _project;

  Map<String, Map> invoicesSummary = {};
  List aportesItems = [];
  List distribItems = [];
  Map<String, SFinn> finnHash = {};
  Map<String, SFinn> finnUuidHash = {};

  List<String> withChildrens = [];

  List<Widget> invoicesList = [];
  List invoicesItems = [];
  SFinn? finnSelected;
  double totalBudgetProject = 0;
  Widget? invoicesContainer;
  Widget? summaryContainer;
  Widget? finnContainer;
  Widget? aportesSummaryContainer;
  Widget? distribSummaryContainer;

  double getAporte(String finnUuid, [String? financierUuid]) {
    double aporte = 0;
    SFinn finn = finnUuidHash[finnUuid]!;
    for (FinnContribution item in aportesItems) {
      SFinn itemFinn = finnUuidHash[item.finn]!;
      if ((itemFinn.name.startsWith(finn.name)) &&
          (financierUuid == null || item.financier == financierUuid)) {
        aporte += item.amount;
      }
    }
    return aporte;
  }

  double getDistrib(String finnUuid, [String? partnerUuid]) {
    double distrib = 0;
    SFinn finn = finnUuidHash[finnUuid]!;
    for (FinnDistribution item in distribItems) {
      SFinn itemFinn = finnUuidHash[item.finn]!;
      if (((itemFinn.name.startsWith(finn.name)) &&
              (!withChildrens.contains(itemFinn.name))) &&
          (partnerUuid == null || item.partner == partnerUuid)) {
        distrib += item.amount;
      }
    }
    return distrib;
  }

  Widget populateAportesSummaryContainer() {
    Map<String, double> aportesTotalByFinancier = {};
    for (var financier in _project!.financiers) {
      aportesTotalByFinancier[financier] = 0;
    }

    double totalAportes = 0;
    for (FinnContribution contribution in aportesItems) {
      if (aportesTotalByFinancier.containsKey(contribution.financier)) {
        aportesTotalByFinancier[contribution.financier] =
            aportesTotalByFinancier[contribution.financier]! +
                contribution.amount;
      } else {
        aportesTotalByFinancier[contribution.financier] = contribution.amount;
      }
      totalAportes += contribution.amount;
    }
    if (fromCurrency(_project!.budget) != totalAportes) {
      _project!.budget = toCurrency(totalAportes).replaceAll("€", "");
      _project!.save();
    }

    totalBudgetProject = totalAportes;
    double percentExecuted = 0;
    if (totalBudgetProject > 0) {
      percentExecuted = executedBudgetProject / totalBudgetProject;
    }

    List<Widget> sourceRows = [];
    for (Financier financier in _project!.financiersObj) {
      if (!aportesTotalByFinancier.containsKey(financier.uuid)) {
        aportesTotalByFinancier[financier.uuid] = 0;
      }
      double aporte = aportesTotalByFinancier[financier.uuid]!;
      double aportePercent =
          (totalBudgetProject == 0) ? 0 : aporte / totalBudgetProject;
      sourceRows.add(Row(children: [
        Expanded(flex: 2, child: Text(financier.name)),
        Expanded(
            flex: 2,
            child: LinearPercentIndicator(
              percent: min(aportePercent, 1),
              center: Text("${(aportePercent * 100).toStringAsFixed(0)} %",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              lineHeight: 20,
              animation: true,
              animateFromLastPercent: true,
              progressColor: percentBarPrimary,
              backgroundColor: Colors.grey,
              padding: EdgeInsets.zero,
            )),
        Expanded(
            flex: 1, child: Text(toCurrency(aporte), textAlign: TextAlign.end)),
      ]));
      if (_project!.financiersObj.last != financier) {
        sourceRows.add(const Divider(thickness: 1, color: Colors.white));
      }
    }

    return Card(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
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
                                color: Colors.white)
                           ),
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
                      child: Text(toCurrency(totalBudgetProject),
                          textAlign: TextAlign.end, style: mainText)),
                ]),
                const Divider()
              ] +
              sourceRows),
    ));
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
      SFinn finn = finnUuidHash[distribution.finn]!;
      if (withChildrens.contains(finn.name)) {
        continue;
      }
      if (distribTotalByPartner.containsKey(distribution.partner)) {
        distribTotalByPartner[distribution.partner] =
            distribTotalByPartner[distribution.partner]! + distribution.amount;
      } else {
        distribTotalByPartner[distribution.partner] = distribution.amount;
      }
      totalDistrib += distribution.amount;
    }

    double totalExecuted = 0;
    double percentExecuted = 0;

    List<Widget> sourceRows = [];
    for (Contact partner in _project!.partnersObj) {
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
              progressColor: distribPercent < 1 ? percentBarPrimary : dangerColor,
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
                          style: (percentExecuted < 1) ? mainText.copyWith(fontSize: mainText.fontSize! - 2): mainText.copyWith(fontSize: mainText.fontSize! - 2, color: dangerColor))),
                ]),
                const Divider()
              ] +
              sourceRows),
    ));
  }

  Widget populateFinnContainer() {
    int widthFinn = 3;
    List<Widget> finnRows = [];
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
          for (Financier financier in _project!.financiersObj)
            Expanded(
                flex: 1,
                child: Text(financier.name,
                    textAlign: TextAlign.start, style: headerListStyle)),
          const Expanded(
              flex: 1,
              child: Text("Ejecución",
                  textAlign: TextAlign.start, style: headerListStyle)),
          for (Contact partner in _project!.partnersObj)
            Expanded(
                flex: 1,
                child: Text(partner.name,
                    textAlign: TextAlign.start, style: headerListStyle)),
        ]));
    finnRows.add(headerRow);
    finnRows.add(const Divider(thickness: 1, color: Colors.grey));
    for (SFinn finn in finnList) {
      int level = finn.getLevel();
      if ((finnList.first != finn) && (level == 1)) {
        finnRows.add(const Divider());
      }
      Map<dynamic, dynamic> summary = {"total": 0};
      if (level == 1) {
        summary = {"total": getAporte(finn.uuid)};
      } else {
        summary = {"total": getAporte(finn.uuid)};
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
                            _editFinnDialog([context, finn, _project]);
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
            for (Financier financier in _project!.financiersObj)
              Expanded(
                  flex: 1,
                  child: withChildrens.contains(finn.name)
                      ? Text(toCurrency(getAporte(finn.uuid, financier.uuid)),
                          textAlign: TextAlign.start,
                          style: level == 1 ? trunkStyle : leafStyle)
                      : Row(children: [
                          Text(toCurrency(getAporte(finn.uuid, financier.uuid)),
                              textAlign: TextAlign.start,
                              style: finn.getLevel() == 1
                                  ? trunkStyle
                                  : leafStyle),
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
                        ? (getDistrib(finn.uuid) > getAporte(finn.uuid))
                            ? trunkStyle.copyWith(color: dangerColor)
                            : trunkStyle
                        : (getDistrib(finn.uuid) > getAporte(finn.uuid))
                            ? leafStyle.copyWith(color: dangerColor)
                            : leafStyle)),
            for (Contact partner in _project!.partnersObj)
              Expanded(
                  flex: 1,
                  child: withChildrens.contains(finn.name)
                      ? Text(toCurrency(getDistrib(finn.uuid, partner.uuid)),
                          textAlign: TextAlign.start,
                          style: level == 1 ? trunkStyle : leafStyle)
                      : Row(children: [
                          Text(toCurrency(getDistrib(finn.uuid, partner.uuid)),
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
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: finnRows),
    ));
  }

  Future<void> reloadState() async {
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
    totalBudgetProject = fromCurrency(_project!.budget);
    executedBudgetProject = 0;

    finnContainer = const Center(child: CircularProgressIndicator());
    invoicesContainer = Container(width: 0);
    aportesSummaryContainer = populateAportesSummaryContainer();
    distribSummaryContainer = populateDistribSummaryContainer();
    summaryContainer = populateSummaryContainer();

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

      invoicesByPartner().then((value) {
        reloadState();
      });
    });
  }

  Future<double> invoicesByPartner() async {
    List finnUuids = finnList.map((e) => e.uuid).toList();
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
    if (_project != null) {
      return Scaffold(
          body: SingleChildScrollView(
        child: Column(children: [
          mainMenu(context),
          finnHeader(context, _project),
          Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(flex: 1, child: aportesSummaryContainer!),
                  Expanded(flex: 1, child: distribSummaryContainer!),
                ]),
                Row(children: [
                  Expanded(flex: 1, child: finnContainer!),
                ]),
                invoicesContainer!,
              ]),
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
    return actionButtonVertical(context, 'Nueva partida', _editFinnDialog,
        Icons.add, [context, null, _project]);
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
    finnList.sort((a, b) => (a.name).compareTo(b.name));
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

  Widget populateSummaryContainer() {
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

  Future<void> _editFinnContribDialog(context, finn, financierObj) {
    List<Row> rows = [];
    TextEditingController amount = TextEditingController(text: "0");
    TextEditingController comment = TextEditingController(text: "");
    FinnContribution item;
    item = FinnContribution("", financierObj.uuid, double.parse(amount.text),
        finn.uuid, comment.text);

    for (FinnContribution contribution in aportesItems) {
      if ((contribution.finn == finn.uuid) &&
          (contribution.financier == financierObj.uuid)) {
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

    TextButton saveButton = TextButton(
      child: const Text('Guardar'),
      onPressed: () async {
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
}
