import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
// import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const zoneTitle = "Zonas";
List zones = [];
bool loadingZone = false;
Widget? _mainMenu;

class ZonePage extends StatefulWidget {
  const ZonePage({super.key});

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingZone = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingZone = false;
    });
  }

  void loadZones() async {
    setLoading();
    await getZones().then((val) {
      zones = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        zoneHeader(context),
        loadingZone
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : zoneList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            ZONES
-------------------------------------------------------------*/
  Widget zoneHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("ZONAS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editZoneDialog, {'zone': Zone("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveZone(List args) async {
    Zone zone = args[0];
    zone.save();
    loadZones();

    Navigator.pop(context);
  }

  Future<void> editZoneDialog(context, Map<String, dynamic> args) {
    Zone zone = args["zone"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Zonas"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: zone.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => zone.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveZone, zone),
          ],
        );
      },
    );
  }

  Widget zoneList(context) {
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
          rows: zones
              .map(
                (zone) => DataRow(cells: [
                  DataCell(Text(zone.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editZoneDialog, {"zone": zone}),
                    removeBtn(context, removeZoneDialog, {"zone": zone})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeZoneDialog(context, args) {
    customRemoveDialog(context, args["zone"], loadZones, null);
  }
}
