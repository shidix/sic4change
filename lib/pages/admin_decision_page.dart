import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const decisionTitle = "Poder de decisión";
List decisions = [];
bool loadingDecision = false;
Widget? _mainMenu;

class DecisionPage extends StatefulWidget {
  const DecisionPage({super.key});

  @override
  State<DecisionPage> createState() => _DecisionPageState();
}

class _DecisionPageState extends State<DecisionPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingDecision = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingDecision = false;
    });
  }

  void loadDecisions() async {
    setLoading();
    await getContactDecisions().then((val) {
      decisions = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadDecisions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        decisionHeader(context),
        loadingDecision
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : decisionList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            DECISIONES
-------------------------------------------------------------*/
  Widget decisionHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("PODER DE DECISIÓN", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(
                context, editDecisionDialog, {'decision': ContactDecision("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveDecision(List args) async {
    ContactDecision decision = args[0];
    decision.save();
    loadDecisions();

    Navigator.pop(context);
  }

  Future<void> editDecisionDialog(context, Map<String, dynamic> args) {
    ContactDecision decision = args["decision"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Poder de decisión"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: decision.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => decision.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveDecision, decision),
          ],
        );
      },
    );
  }

  Widget decisionList(context) {
    return Container(
      decoration: tableDecoration,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          sortColumnIndex: 0,
          showCheckboxColumn: false,
          headingRowColor:
              MaterialStateColor.resolveWith((states) => headerListBgColor),
          headingRowHeight: 40,
          columns: [
            DataColumn(
              label: customText("Nombre", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(label: Container()),
          ],
          rows: decisions
              .map(
                (decision) => DataRow(cells: [
                  DataCell(Text(decision.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(
                        context, editDecisionDialog, {"decision": decision}),
                    removeBtn(
                        context, removeDecisionDialog, {"decision": decision})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeDecisionDialog(context, args) {
    customRemoveDialog(context, args["decision"], loadDecisions, null);
  }
}
