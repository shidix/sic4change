// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const positionTitle = "Posiciones";
List positions = [];
bool loadingPosition = false;
Widget? _mainMenu;

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingPosition = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingPosition = false;
    });
  }

  void loadPositions() async {
    setLoading();
    positions = await Position.getPositions();
    stopLoading();
    // await getPositions().then((val) {
    //   positions = val;
    //   stopLoading();
    // });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadPositions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        positionHeader(context),
        loadingPosition
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : positionList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            CARGOS
-------------------------------------------------------------*/
  Widget positionHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("CARGOS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editPositionDialog, {'position': Position("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void savePosition(List args) async {
    Position position = args[0];
    position.save();
    loadPositions();

    Navigator.pop(context);
  }

  Future<void> editPositionDialog(context, Map<String, dynamic> args) {
    Position position = args["position"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Posición"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: position.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => position.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, savePosition, position),
          ],
        );
      },
    );
  }

  Widget positionList(context) {
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
          rows: positions
              .map(
                (position) => DataRow(cells: [
                  DataCell(Text(position.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(
                        context, editPositionDialog, {"position": position}),
                    removeBtn(
                        context, removePositionDialog, {"position": position})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removePositionDialog(context, args) {
    customRemoveDialog(context, args["position"], loadPositions, null);
  }
}
