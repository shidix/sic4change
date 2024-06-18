import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const provinceTitle = "Provincias";
List provinces = [];
bool loadingProvince = false;
Widget? _mainMenu;

class ProvincePage extends StatefulWidget {
  const ProvincePage({super.key});

  @override
  State<ProvincePage> createState() => _ProvincePageState();
}

class _ProvincePageState extends State<ProvincePage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingProvince = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingProvince = false;
    });
  }

  void loadProvinces() async {
    setLoading();
    await getProvinces().then((val) {
      provinces = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadProvinces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        provinceHeader(context),
        loadingProvince
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : provinceList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            PROVINCES
-------------------------------------------------------------*/
  Widget provinceHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("PROVINCIAS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editProvinceDialog, {'province': Province("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveProvince(List args) async {
    Province province = args[0];
    province.save();
    loadProvinces();

    Navigator.pop(context);
  }

  Future<void> editProvinceDialog(context, Map<String, dynamic> args) {
    Province province = args["province"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Provincia"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: province.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => province.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveProvince, province),
          ],
        );
      },
    );
  }

  Widget provinceList(context) {
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
          rows: provinces
              .map(
                (province) => DataRow(cells: [
                  DataCell(Text(province.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(
                        context, editProvinceDialog, {"province": province}),
                    removeBtn(
                        context, removeProvinceDialog, {"province": province})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeProvinceDialog(context, args) {
    customRemoveDialog(context, args["province"], loadProvinces, null);
  }
}
