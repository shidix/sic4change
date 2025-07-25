import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const reformulationTypeTitle = "Tipos de reformulación";
List reformulationTypes = [];
bool loadingReformulationTypes = false;
Widget? _mainMenu;

class ReformulationTypePage extends StatefulWidget {
  const ReformulationTypePage({super.key});

  @override
  State<ReformulationTypePage> createState() => _ReformulationTypePageState();
}

class _ReformulationTypePageState extends State<ReformulationTypePage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingReformulationTypes = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingReformulationTypes = false;
    });
  }

  void loadReformulationTypes() async {
    setLoading();
    await ReformulationType.getReformulationTypes().then((val) {
      reformulationTypes = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadReformulationTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        reformulationTypeHeader(context),
        loadingReformulationTypes
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : reformulationTypeList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                      REFORMULATION TYPES
-------------------------------------------------------------*/
  Widget reformulationTypeHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("TIPOS DE REFORMULACIÓN", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editReformulationTypeDialog,
                {'type': ReformulationType()}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveReformulationType(List args) async {
    ReformulationType reformulationType = args[0];
    reformulationType.save();
    loadReformulationTypes();

    Navigator.pop(context);
  }

  Future<void> editReformulationTypeDialog(context, Map<String, dynamic> args) {
    ReformulationType reformulationType = args["type"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Tipo"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: reformulationType.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => reformulationType.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveReformulationType, reformulationType),
          ],
        );
      },
    );
  }

  Widget reformulationTypeList(context) {
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
          rows: reformulationTypes
              .map(
                (reformulationType) => DataRow(cells: [
                  DataCell(Text(reformulationType.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editReformulationTypeDialog,
                        {"type": reformulationType}),
                    removeBtn(context, removeReformulationTypeDialog,
                        {"type": reformulationType})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeReformulationTypeDialog(context, args) {
    customRemoveDialog(context, args["type"], loadReformulationTypes, null);
  }
}
