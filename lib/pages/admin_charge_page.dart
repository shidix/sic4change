import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const chargeTitle = "Cargos";
List charges = [];
bool loadingCharge = false;
Widget? _mainMenu;

class ChargePage extends StatefulWidget {
  const ChargePage({super.key});

  @override
  State<ChargePage> createState() => _ChargePageState();
}

class _ChargePageState extends State<ChargePage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingCharge = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingCharge = false;
    });
  }

  void loadCharges() async {
    setLoading();
    await getContactCharges().then((val) {
      charges = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadCharges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        chargeHeader(context),
        loadingCharge
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : chargeList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            CARGOS
-------------------------------------------------------------*/
  Widget chargeHeader(context) {
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
            addBtn(context, editChargeDialog, {'charge': ContactCharge("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveCharge(List args) async {
    ContactCharge charge = args[0];
    charge.save();
    loadCharges();

    Navigator.pop(context);
  }

  Future<void> editChargeDialog(context, Map<String, dynamic> args) {
    ContactCharge charge = args["charge"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Cargo"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: charge.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => charge.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveCharge, charge),
          ],
        );
      },
    );
  }

  Widget chargeList(context) {
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
          rows: charges
              .map(
                (charge) => DataRow(cells: [
                  DataCell(Text(charge.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editChargeDialog, {"charge": charge}),
                    removeBtn(context, removeChargeDialog, {"charge": charge})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeChargeDialog(context, args) {
    customRemoveDialog(context, args["charge"], loadCharges, null);
  }
}
