import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const regionTitle = "Comunidades";
List regions = [];
bool loadingRegion = false;
Widget? _mainMenu;

class RegionPage extends StatefulWidget {
  const RegionPage({super.key});

  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage>
    with SingleTickerProviderStateMixin {
  List<Country> countries = [];
  List<Province> provinces = [];

  void setLoading() {
    setState(() {
      loadingRegion = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingRegion = false;
    });
  }

  void loadRegions() async {
    setLoading();
    regions = await Region.getRegions();
    countries = await Country.getCountries() as List<Country>;
    provinces = await Province.getProvinces() as List<Province>;
    stopLoading();
    // await getRegions().then((val) {
    //   regions = val;
    //   stopLoading();
    // });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        regionHeader(context),
        loadingRegion
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : regionList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            COMUNIDADES
-------------------------------------------------------------*/
  Widget regionHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("COMUNIDADES", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editRegionDialog, {'region': Region("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveRegion(List args) async {
    Region region = args[0];
    region.save();
    loadRegions();

    Navigator.pop(context);
  }

  Future<void> editRegionDialog(context, Map<String, dynamic> args) {
    Region region = args["region"];
    Country country = countries.isNotEmpty
        ? countries.firstWhere((c) => c.id == region.country, orElse: () {
            return countries.first;
          })
        : Country("-- No hay países --");

    if (region.country.isEmpty && countries.isNotEmpty) {
      region.country = countries.first.id;
    } else if (region.country.isNotEmpty) {
      country = countries.firstWhere((c) => c.id == region.country, orElse: () {
        return countries.first;
      });
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  titlePadding: const EdgeInsets.all(0),
                  title: s4cTitleBar("Región"),
                  content: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        CustomTextField(
                          labelText: "Nombre",
                          initial: region.name,
                          size: 900,
                          minLines: 2,
                          maxLines: 9999,
                          fieldValue: (String val) {
                            setState(() => region.name = val);
                          },
                        ),
                        space(height: 10),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            labelText: "País",
                            border: OutlineInputBorder(),
                          ),
                          items: countries
                              .map((e) => DropdownMenuItem(
                                    value: e.id,
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          value: country.id,
                          hint: const Text("País"),
                          onChanged: (value) {
                            Country selected =
                                countries.firstWhere((c) => c.id == value);
                            region.country = selected.id;
                            setState(() {});
                          },
                        )
                      ])),
                  actions: <Widget>[
                    dialogsBtns(context, saveRegion, region),
                  ],
                ));
      },
    );
  }

  Widget regionList(context) {
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
          rows: regions
              .map(
                (region) => DataRow(cells: [
                  DataCell(Text(region.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editRegionDialog, {"region": region}),
                    removeBtn(context, removeRegionDialog, {"region": region})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeRegionDialog(context, args) {
    customRemoveDialog(context, args["region"], loadRegions, null);
  }
}
