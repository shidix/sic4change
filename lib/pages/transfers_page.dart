import 'dart:core';
import 'dart:math';

// import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/finn_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:uuid/uuid.dart';

class TransfersPage extends StatefulWidget {
  final SProject? project;
  final user = FirebaseAuth.instance.currentUser!;
  final List? finnItems;
  final List? distribItems;
  final List? aportesItems;

  TransfersPage({
    Key? key,
    this.project,
    this.finnItems,
    this.aportesItems,
    this.distribItems,
  }) : super(key: key);

  @override
  createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  SProject? currentProject;
  BankTransfer? currentTransfer;
  List<BankTransfer> bankTransfers = [];
  Widget? contentContainer;
  Widget? headerContainer;
  Widget? listBankTransfersContainer;
  List? finnItems;
  List? distribItems;
  List? aportesItems;

  @override
  void initState() {
    super.initState();
    finnItems = widget.finnItems;
    distribItems = widget.distribItems;
    aportesItems = widget.aportesItems;
    listBankTransfersContainer = const Expanded(child: Text('No hay datos'));

    if (widget.project != null) {
      currentProject = widget.project;
      contentContainer = contentContainerPopulate(context);
      headerContainer = headerContainerPopulate(context);
      BankTransfer.getByProject(currentProject!.uuid).then((value) {
        bankTransfers = value;
        listBankTransfersContainer = listBankTransfers(context);
        contentContainer = contentContainerPopulate(context);
        setState(() {});
      });
    } else {
      contentContainer = const Expanded(
          child: Center(
              child: Text(
        'No hay proyecto seleccionado',
        style: mainText,
      )));
      headerContainer =
          const Center(child: Text('No hay proyecto seleccionado'));
      SProject.getByUuid("1234").then((value) {
        // FIXME: Remove hardcoded project
        currentProject = value;
        BankTransfer.getByProject(currentProject!.uuid).then((value) {
          bankTransfers = value;
          setState(() {
            listBankTransfersContainer = listBankTransfers(context);
            contentContainer = contentContainerPopulate(context);
          });
        });
        currentProject!.reload().then((value) {
          setState(() {
            contentContainer = contentContainerPopulate(context);
            headerContainer = headerContainerPopulate(context);
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentProject == null) {
      return Scaffold(
          body: Column(children: [
        mainMenu(context, widget.user),
        contentContainer!,
      ]));
    }
    return Scaffold(
      body: Column(children: [
        mainMenu(context, widget.user),
        topButtons(context),
        headerContainer!,
        contentContainer!,
      ]),
    );
  }

  Contact getContact(uuid) {
    for (var partner in currentProject!.partnersObj) {
      if (partner.uuid == uuid) {
        return partner;
      }
    }
    return Contact("", "", "", "", "");
  }

  Financier getFinancier(uuid) {
    for (var financier in currentProject!.financiersObj) {
      if (financier.uuid == uuid) {
        return financier;
      }
    }
    return Financier("");
  }

  void addTransfer() {
    BankTransfer bankTransfer = BankTransfer.getEmpty();
    bankTransfer.uuid = const Uuid().v4();
    bankTransfer.project = currentProject!.uuid;
    bankTransfer.concept = "Concepto";
    bankTransfer.date = DateTime.now();
    bankTransfer.amountSource = Random().nextDouble() * 20000;
    bankTransfer.commissionSource = Random().nextDouble() * 0.04;
    bankTransfer.exchangeSource = (0.97 + Random().nextDouble() * 0.06);
    bankTransfer.amountIntermediary =
        bankTransfer.amountSource * bankTransfer.exchangeSource -
            bankTransfer.commissionSource;
    bankTransfer.commissionIntermediary = Random().nextDouble() * 0.04;
    bankTransfer.exchangeIntermediary =
        1 / (0.26 + Random().nextDouble() * 0.04);
    bankTransfer.amountDestination =
        bankTransfer.amountIntermediary * bankTransfer.exchangeIntermediary -
            bankTransfer.commissionIntermediary;
    bankTransfer.commissionDestination = Random().nextDouble() * 0.04;

    bankTransfer.save();
    setState(() {});
  }

  void addBankTransferDialog(context) {
    _addBankTransferDialog(context).then((value) {
      if (value != null) {
        setState(() {
          if ((value.id == "") && (bankTransfers.contains(value))) {
            bankTransfers.remove(value);
          } else {
            if (!bankTransfers.contains(value)) {
              bankTransfers.add(value);
            }
          }
          currentTransfer = null;
          listBankTransfersContainer = listBankTransfers(context);
          contentContainer = contentContainerPopulate(context);
        });
      }
    });
  }

  Future<BankTransfer?> _addBankTransferDialog(context) {
    if (currentTransfer == null) {
      currentTransfer = BankTransfer.getEmpty();
      currentTransfer!.emissor = currentProject!.financiers[0];
      currentTransfer!.receiver = currentProject!.partners[0];
      currentTransfer!.project = currentProject!.uuid;
      currentTransfer!.date = DateTime.now();
    }

    return showDialog<BankTransfer>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir transferencia'),
          content: BankTransferForm(
            key: null,
            existingBankTransfer: currentTransfer,
            project: currentProject,
          ),
        );
      },
    );
  }

  Widget topButtons(BuildContext context) {
    List<Widget> buttons = [
      actionButtonVertical(context, "Nueva transferencia",
          addBankTransferDialog, Icons.add, context),
      space(width: 10),
      actionButtonVertical(context, 'Volver', () {
        Navigator.pop(context);
      }, Icons.arrow_circle_left_outlined, null)
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  Widget contentContainerPopulate(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
                child: Column(children: [
              listHeaderBankTransfers(context),
              listBankTransfersContainer!,
              totalSummary(context),
            ]))));
  }

  Widget listHeaderBankTransfers(BuildContext context) {
    return const ListTile(
        tileColor: Colors.white,
        titleTextStyle: mainText,
        title: Column(children: [
          Row(children: [
            Expanded(flex: 1, child: Text('Emisor')),
            Expanded(flex: 1, child: Text('Receptor')),
            Expanded(flex: 1, child: Text('Concepto')),
            Expanded(flex: 1, child: Text('Fecha')),
            Expanded(
                flex: 1, child: Text('Enviado', textAlign: TextAlign.right)),
            Expanded(
                flex: 1, child: Text('Intermedio', textAlign: TextAlign.right)),
            Expanded(
                flex: 1, child: Text('Recibido', textAlign: TextAlign.right)),
            Expanded(flex: 1, child: Text('')),
          ]),
          Divider(color: Colors.blueGrey),
        ]));
  }

  Widget listBankTransfers(BuildContext context) {
    if (bankTransfers.isNotEmpty) {
      return Expanded(
          child: ListView.separated(
              itemCount: bankTransfers.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                            getFinancier(bankTransfers[index].emissor).name)),
                    Expanded(
                        flex: 1,
                        child: Text(
                            getContact(bankTransfers[index].receiver).name)),
                    Expanded(
                        flex: 1, child: Text(bankTransfers[index].concept)),
                    Expanded(
                        flex: 1,
                        child: Text(DateFormat('dd-MM-yyyy')
                            .format(bankTransfers[index].date))),
                    Expanded(
                        flex: 1,
                        child: Text(
                          "${bankTransfers[index].amountSource.toStringAsFixed(2).padLeft(10)} ${bankTransfers[index].currencySource.padRight(7)}",
                          textAlign: TextAlign.right,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          "${bankTransfers[index].amountIntermediary.toStringAsFixed(2).padLeft(10)} ${bankTransfers[index].currencyIntermediary.padRight(7)}",
                          textAlign: TextAlign.right,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          "${bankTransfers[index].amountDestination.toStringAsFixed(2).padLeft(10)} ${bankTransfers[index].currencyDestination.padRight(7)}",
                          textAlign: TextAlign.right,
                        )),
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          iconSize: 18,
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            currentTransfer = bankTransfers[index];
                            addBankTransferDialog(context);
                          },
                        ))
                  ]),
                  // onTap: () {
                  //   currentTransfer = bankTransfers[index];
                  //   addBankTransferDialog(context);
                  // },
                );
              }));
    } else {
      return const Expanded(child: Text('No hay datos'));
    }
  }

  Widget totalSummary(BuildContext context) {
    if (bankTransfers.isNotEmpty) {
      List<String> currencies = [];
      Map<String, double> fromSource = {};
      Map<String, double> fromIntermediary = {};
      Map<String, double> fromDestination = {};

      for (var transfer in bankTransfers) {
        if (!currencies.contains(transfer.currencySource)) {
          currencies.add(transfer.currencySource);
        }
        if (!currencies.contains(transfer.currencyIntermediary)) {
          currencies.add(transfer.currencyIntermediary);
        }
        if (!currencies.contains(transfer.currencyDestination)) {
          currencies.add(transfer.currencyDestination);
        }
        if (fromSource[transfer.currencySource] == null) {
          fromSource[transfer.currencySource] = 0;
        }
        if (fromIntermediary[transfer.currencyIntermediary] == null) {
          fromIntermediary[transfer.currencyIntermediary] = 0;
        }
        if (fromDestination[transfer.currencyDestination] == null) {
          fromDestination[transfer.currencyDestination] = 0;
        }
        fromSource[transfer.currencySource] =
            fromSource[transfer.currencySource]! + transfer.amountSource;
        fromIntermediary[transfer.currencyIntermediary] =
            fromIntermediary[transfer.currencyIntermediary]! +
                transfer.amountIntermediary;
        fromDestination[transfer.currencyDestination] =
            fromDestination[transfer.currencyDestination]! +
                transfer.amountDestination;
      }

      for (var currency in currencies) {
        if (!fromSource.containsKey(currency)) {
          fromSource[currency] = 0;
        }
        if (!fromIntermediary.containsKey(currency)) {
          fromIntermediary[currency] = 0;
        }
        if (!fromDestination.containsKey(currency)) {
          fromDestination[currency] = 0;
        }
      }

      List<Widget> rows = [];
      List<Widget> headers = [];
      headers.add(const Row(children: [
        Expanded(flex: 1, child: Text('Moneda')),
        Expanded(flex: 1, child: Text('Enviado', textAlign: TextAlign.right)),
        Expanded(
            flex: 1, child: Text('Intermedio', textAlign: TextAlign.right)),
        Expanded(flex: 1, child: Text('Recibido', textAlign: TextAlign.right)),
      ]));
      headers.add(const Divider(color: mainColor, thickness: 2));
      for (var currency in currencies) {
        rows.add(Row(children: [
          Expanded(
              flex: 1,
              child: Text(
                currency,
                style: normalText,
              )),
          Expanded(
              flex: 1,
              child: Text(fromSource[currency]!.toStringAsFixed(2),
                  style: normalText, textAlign: TextAlign.right)),
          Expanded(
              flex: 1,
              child: Text(fromIntermediary[currency]!.toStringAsFixed(2),
                  style: normalText, textAlign: TextAlign.right)),
          Expanded(
              flex: 1,
              child: Text(fromDestination[currency]!.toStringAsFixed(2),
                  style: normalText, textAlign: TextAlign.right)),
        ]));
      }
      return Row(children: [
        Expanded(flex: 1, child: Container()),
        Expanded(
            flex: 2,
            child: Card(
                child: ListTile(
              tileColor: Colors.white,
              titleTextStyle: mainText,
              title: Column(children: headers),
              subtitleTextStyle: secondaryText,
              subtitle: Column(
                children: rows,
              ),
            ))),
        Expanded(flex: 1, child: Container())
      ]);
    }
    return const Expanded(child: Text('No hay datos'));
  }

  Widget headerContainerPopulate(BuildContext context) {
    List<Widget> rows = [];
    List<Widget> headers = [];

    Map<String, double> byFinancier = {};
    List<String> financiers = [];
    double totalAmount = fromCurrency(currentProject!.budget);

    for (FinnContribution aporte in aportesItems!) {
      if (!financiers.contains(aporte.financier)) {
        financiers.add(aporte.financier);
      }
      if (!byFinancier.containsKey(aporte.financier)) {
        byFinancier[aporte.financier] = 0;
      }
      byFinancier[aporte.financier] =
          byFinancier[aporte.financier]! + aporte.amount;
    }

    headers.add(Row(children: [
      const Expanded(
          flex: 1,
          child: Text('Origen del presupuesto total', style: mainText)),
      Expanded(
          flex: 1,
          child: Text(toCurrency(totalAmount),
              style: mainText, textAlign: TextAlign.right)),
    ]));
    headers.add(const Divider(color: mainColor, thickness: 2));
    for (var financier in financiers) {
      rows.add(Row(children: [
        Expanded(
            flex: 1,
            child: Text(
              getFinancier(financier).name,
              style: normalText,
            )),
        Expanded(
            flex: 1,
            child: Text(toCurrency(byFinancier[financier]!),
                style: normalText, textAlign: TextAlign.right)),
      ]));
    }
    return Card(
        child: Row(children: [
      const Expanded(flex: 1, child: Card()),
      Expanded(
          flex: 2,
          child: Card(
            child: ListTile(
                tileColor: Colors.white,
                titleTextStyle: mainText,
                title: Column(children: headers),
                subtitleTextStyle: secondaryText,
                subtitle: Column(
                  children: rows,
                )),
          )),
      const Expanded(flex: 1, child: Card()),
    ]));
  }
}
