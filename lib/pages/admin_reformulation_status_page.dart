import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const reformulationStatusTitle = "Estados de reformulación";
List reformulationStatus = [];
bool loadingReformulationStatus = false;
Widget? _mainMenu;

class ReformulationStatusPage extends StatefulWidget {
  const ReformulationStatusPage({super.key});

  @override
  State<ReformulationStatusPage> createState() =>
      _ReformulationStatusPageState();
}

class _ReformulationStatusPageState extends State<ReformulationStatusPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingReformulationStatus = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingReformulationStatus = false;
    });
  }

  void loadReformulationStatus() async {
    setLoading();
    await getReformulationStatus().then((val) {
      reformulationStatus = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadReformulationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        reformulationStatusHeader(context),
        loadingReformulationStatus
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : reformulationStatusList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                      REFORMULATION STATUS
-------------------------------------------------------------*/
  Widget reformulationStatusHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("ESTADOS DE REFORMULACIÓN", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editReformulationStatusDialog,
                {'status': ReformulationStatus()}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveReformulationStatus(List args) async {
    ReformulationStatus reformulationStatus = args[0];
    reformulationStatus.save();
    loadReformulationStatus();

    Navigator.pop(context);
  }

  Future<void> editReformulationStatusDialog(
      context, Map<String, dynamic> args) {
    ReformulationStatus reformulationStatus = args["status"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Estado"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: reformulationStatus.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => reformulationStatus.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveReformulationStatus, reformulationStatus),
          ],
        );
      },
    );
  }

  Widget reformulationStatusList(context) {
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
          rows: reformulationStatus
              .map(
                (status) => DataRow(cells: [
                  DataCell(Text(status.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editReformulationStatusDialog,
                        {"status": status}),
                    removeBtn(context, removeReformulationStatusDialog,
                        {"status": status})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeReformulationStatusDialog(context, args) {
    customRemoveDialog(context, args["status"], loadReformulationStatus, null);
  }
}
