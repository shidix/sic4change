// import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sic4change/services/firebase_service_finn.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:uuid/uuid.dart';

class TransfersPage extends StatefulWidget {
  final SProject? project;

  TransfersPage({Key? key, this.project}) : super(key: key);

  @override
  _TransfersPageState createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  SProject? currentProject;
  BankTransfer? currentTransfer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentProject = widget.project;
    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        topButtons(context),
        contentContainer(context),
        // ListHeaderBankTransfers(context),
        // ListBankTransfers(context),
      ]),
    );
  }

  Contact getContact(uuid) {
    for (var partner in widget.project!.partnersObj) {
      if (partner.uuid == uuid) {
        return partner;
      }
    }
    return Contact("", "", "", "", "");
  }

  Financier getFinancier(uuid) {
    for (var financier in widget.project!.financiersObj) {
      if (financier.uuid == uuid) {
        return financier;
      }
    }
    return Financier("");
  }

  void addTransfer() {
    BankTransfer bankTransfer = BankTransfer("", "", "", "", "", "", "", "", "",
        0, 0, 0, 0, 0, 0, 0, 0, "Euro", "Euro", "Euro", "");
    bankTransfer.uuid = const Uuid().v4();
    bankTransfer.project = widget.project!.uuid;
    bankTransfer.concept = "Concepto";
    bankTransfer.date = DateTime.now().toString();
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
      setState(() {
        currentTransfer = null;
      });
    });
  }

  Future<void> _addBankTransferDialog(context) {
    if (currentTransfer == null) {
      currentTransfer = BankTransfer("", const Uuid().v4(), "", "", "", "", "",
          "", "", 0, 0, 0, 0, 0, 0, 0, 0, "Euro", "Euro", "Euro", "");
      currentTransfer!.emissor = widget.project!.financiersObj[0].uuid;
      currentTransfer!.receiver = widget.project!.partnersObj[0].uuid;
      currentTransfer!.project = widget.project!.uuid;
      currentTransfer!.date = DateTime.now().toString();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir transferencia'),
          content: BankTransferForm(
            key: null,
            existingBankTransfer: currentTransfer,
            project: widget.project,
          ),
        );
      },
    );
  }

  void test() {
    BankTransfer.getByProject(widget.project!.uuid).then((value) {
      print(value.length);
    });
  }

  Widget topButtons(BuildContext context) {
    List<Widget> buttons = [
      actionButton(context, "Nueva transferencia", addBankTransferDialog,
          Icons.add, context),
      space(width: 10),
      backButton(context),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  Widget contentContainer(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
                child: Column(children: [
              listHeaderBankTransfers(context),
              listBankTransfers(context),
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
            Expanded(flex: 1, child: Text('Enviado')),
            Expanded(flex: 1, child: Text('Intermedio')),
            Expanded(flex: 1, child: Text('Recibido')),
          ]),
          Divider(color: Colors.blueGrey),
        ]));
  }

  Widget listBankTransfers(BuildContext context) {
    return FutureBuilder<List<BankTransfer>>(
        future: BankTransfer.getByProject(widget.project!.uuid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                  getFinancier(snapshot.data![index].emissor)
                                      .name)),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  getContact(snapshot.data![index].receiver)
                                      .name)),
                          Expanded(
                              flex: 1,
                              child: Text(snapshot.data![index].concept)),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  snapshot.data![index].date.substring(0, 10))),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "${snapshot.data![index].amountSource.toStringAsFixed(2)} ${snapshot.data![index].currencySource}",
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  "${snapshot.data![index].amountIntermediary.toStringAsFixed(2)} ${snapshot.data![index].currencyIntermediary}")),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  "${snapshot.data![index].amountDestination.toStringAsFixed(2)} ${snapshot.data![index].currencyDestination}")),
                        ]),
                        onTap: () {
                          currentTransfer = snapshot.data![index];
                          addBankTransferDialog(context);
                        },
                      );
                    }));
          } else {
            return const Expanded(child: Text('No hay datos'));
            // return Center(child: CircularProgressIndicator());
          }
        });
  }
}
