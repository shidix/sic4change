import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:sic4change/services/models.dart';
// import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const townTitle = "Zonas";
List towns = [];
bool loadingTown = false;
Widget? _mainMenu;

class TownPage extends StatefulWidget {
  const TownPage({super.key});

  @override
  State<TownPage> createState() => _TownPageState();
}

class _TownPageState extends State<TownPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingTown = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingTown = false;
    });
  }

  void loadTowns() async {
    setLoading();
    towns = await Town.getTowns();
    stopLoading();
    // await getTowns().then((val) {
    //   towns = val;
    //   stopLoading();
    // });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadTowns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        townHeader(context),
        loadingTown
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : townList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            TOWNS
-------------------------------------------------------------*/
  Widget townHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("MUNICIPIOS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editTownDialog, {'town': Town("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveTown(List args) async {
    Town town = args[0];
    town.save();
    loadTowns();

    Navigator.pop(context);
  }

  Future<void> editTownDialog(context, Map<String, dynamic> args) {
    Town town = args["town"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Municipio"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: town.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => town.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveTown, town),
          ],
        );
      },
    );
  }

  Widget townList(context) {
    return Container(
      decoration: tableDecoration,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          sortColumnIndex: 0,
          showCheckboxColumn: false,
          headingRowColor:
              WidgetStateColor.resolveWith((states) => headerListBgColor),
          headingRowHeight: 40,
          columns: [
            DataColumn(
              label: customText("Nombre", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(label: Container()),
          ],
          rows: towns
              .map(
                (town) => DataRow(cells: [
                  DataCell(Text(town.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editTownDialog, {"town": town}),
                    removeBtn(context, removeTownDialog, {"town": town})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeTownDialog(context, args) {
    customRemoveDialog(context, args["town"], loadTowns, null);
  }
}
