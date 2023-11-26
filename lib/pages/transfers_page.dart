// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:uuid/uuid.dart';

class TransfersPage extends StatefulWidget {
  SProject? project;

  TransfersPage({Key? key, this.project}) : super(key: key);

  @override
  _TransfersPageState createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  SProject? currentProject;

  @override
  void initState() {
    super.initState();
    SProject.getByUuid('6fbe1b21-eaf2-43ca-a496-d1e9dd2171c9').then((value) {
      setState(() {
        widget.project = value;
      });
    });
    print(widget.project!.name);
  }

  @override
  Widget build(BuildContext context) {
    currentProject = widget.project;
    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        topButtons(context),
        ListHeaderBankTransfers(context),
        ListBankTransfers(context),
      ]),
    );
  }

  void addTransfer() {
    BankTransfer bankTransfer = BankTransfer(
        "",
        Uuid().v4(),
        "",
        "",
        widget.project!.uuid,
        "Concepto",
        DateTime.now().toString(),
        100,
        1,
        0,
        "");

    bankTransfer.save();
    setState(() {});
  }

  void test() {
    BankTransfer.getByProject(widget.project!.uuid).then((value) {
      print(value.length);
    });
  }

  Widget topButtons(BuildContext context) {
    Widget button;
    if (currentProject == null) {
      button = addButton(context, "Nueva transferencia", "/transfers", {});
    } else {
      button = addButton(context, "Nueva Transferencia", "/transfers", {
        'project': currentProject,
      });
      currentProject = SProject("", "");
    }
    List<Widget> buttons = [
      actionButton(context, "Test", addTransfer, null),
      button,
      space(width: 10),
      backButton(context),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  Widget ListHeaderBankTransfers(BuildContext context) {
    return ListTile(
        title: Row(children: [
      Expanded(flex: 1, child: Text("Concepto")),
      Expanded(flex: 1, child: Text("Fecha")),
      Expanded(flex: 1, child: Text("Importe"))
    ]));
  }

  Widget ListBankTransfers(BuildContext context) {
    return FutureBuilder<List<BankTransfer>>(
        future: BankTransfer.getByProject(widget.project!.uuid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        subtitle: Row(children: [
                          Expanded(
                              flex: 1,
                              child: Text(snapshot.data![index].concept)),
                          Expanded(
                              flex: 1, child: Text(snapshot.data![index].date)),
                          Expanded(
                              flex: 1,
                              child: Text(snapshot.data![index].amount
                                  .toStringAsFixed(2)))
                        ]),
                        onTap: () {
                          Navigator.pushNamed(context, '/transfers',
                              arguments: {
                                'project': widget.project,
                                'transfer': snapshot.data![index]
                              });
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
