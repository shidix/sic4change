import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:sic4change/services/models.dart';
// import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const townTitle = "Municipios";
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
  List<Country> countries = [];
  List<Region> regions = [];
  List<Province> provinces = [];

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
    countries = await Country.getCountries() as List<Country>;
    regions = await Region.getRegions() as List<Region>;
    provinces = await Province.getProvinces() as List<Province>;
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
    List<Province> filteredProvinces = provinces;
    List<Region> filteredRegions = regions;

    Province province = provinces.firstWhere((prov) => prov.id == town.province,
        orElse: () => (provinces.isNotEmpty
            ? provinces.first
            : Province("-- No hay provincias --")));
    if (town.province.isEmpty && provinces.isNotEmpty) {
      town.province = provinces.first.id;
    }
    Region region = regions.firstWhere((reg) => reg.id == province.region,
        orElse: () => (regions.isNotEmpty
            ? regions.first
            : Region("-- No hay regiones --")));
    Country country = countries.firstWhere((coun) => coun.id == region.country,
        orElse: () => (countries.isNotEmpty
            ? countries.first
            : Country("-- No hay países --")));

    if (town.province.isEmpty && provinces.isNotEmpty) {
      town.province = province.id;
    }

    if ((filteredProvinces.isEmpty) ||
        (filteredRegions.isEmpty) ||
        (countries.isEmpty)) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: s4cTitleBar("Municipio"),
            content: const Text(
                "Debe crear primero un país, una región y una provincia antes de crear un municipio."),
            actions: <Widget>[
              dialogsBtns(context, () {
                Navigator.pop(context);
              }, null),
            ],
          );
        },
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  titlePadding: const EdgeInsets.all(0),
                  title: s4cTitleBar("Municipio"),
                  content: SingleChildScrollView(
                      child: Column(children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            labelText: "Nombre",
                            initial: town.name,
                            size: 900,
                            minLines: 2,
                            maxLines: 9999,
                            fieldValue: (String val) {
                              setState(() => town.name = val);
                            },
                          ),
                          space(height: 10),
                          DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: "País",
                              border: OutlineInputBorder(),
                            ),
                            items: countries
                                .map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    ))
                                .toList(),
                            value: country.id,
                            hint: const Text("País"),
                            onChanged: (value) {
                              Country selected =
                                  countries.firstWhere((c) => c.id == value);
                              if (selected.id == country.id) return;
                              filteredRegions = regions
                                  .where((r) => r.country == selected.id)
                                  .toList();

                              // Check if region.id is in filteredRegions
                              if (!filteredRegions
                                  .any((r) => r.id == region.id)) {
                                region = filteredRegions.isNotEmpty
                                    ? filteredRegions.first
                                    : Region("-- No hay regiones --");

                                filteredProvinces = provinces
                                    .where((p) => p.region == region.id)
                                    .toList();
                                if (!filteredProvinces
                                    .any((p) => p.id == province.id)) {
                                  province = filteredProvinces.isNotEmpty
                                      ? filteredProvinces.first
                                      : Province("-- No hay provincias --");
                                }
                              }
                              setState(() {
                                country = selected;
                                region = region;
                                province = province;
                                town.province = province.id;
                              });
                            },
                          ),
                          space(height: 10),
                          DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: "Región",
                              border: OutlineInputBorder(),
                            ),
                            items: filteredRegions
                                .map((r) => DropdownMenuItem(
                                      value: r.id,
                                      child: Text(r.name),
                                    ))
                                .toList(),
                            value: region.id,
                            hint: const Text("Región"),
                            onChanged: (value) {
                              Region selected =
                                  regions.firstWhere((r) => r.id == value);
                              filteredProvinces = provinces
                                  .where((p) => p.region == selected.id)
                                  .toList();
                              if (!filteredProvinces
                                  .any((p) => p.id == province.id)) {
                                province = filteredProvinces.isNotEmpty
                                    ? filteredProvinces.first
                                    : Province("-- No hay provincias --");
                              }
                              country = countries.firstWhere(
                                  (c) => c.id == selected.country,
                                  orElse: () => Country("-- No hay países --"));

                              setState(() {
                                country = country;
                                region = selected;
                                town.province = province.id;
                              });
                            },
                          ),
                          space(height: 10),
                          DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: "Provincia",
                              border: OutlineInputBorder(),
                            ),
                            items: provinces
                                .where((p) => p.region == (region.id))
                                .map((p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(p.name),
                                    ))
                                .toList(),
                            value: town.province,
                            hint: const Text("Provincia"),
                            onChanged: (value) {
                              province = provinces.firstWhere(
                                  (p) => p.id == value,
                                  orElse: () => (provinces.isNotEmpty
                                      ? provinces.first
                                      : Province("-- No hay provincias --")));
                              region = regions.firstWhere(
                                  (r) => r.id == province.region,
                                  orElse: () => (regions.isNotEmpty
                                      ? regions.first
                                      : Region("-- No hay regiones --")));
                              country = countries.firstWhere(
                                  (c) => c.id == region.country,
                                  orElse: () => (countries.isNotEmpty
                                      ? countries.first
                                      : Country("-- No hay países --")));
                              setState(() {
                                province = province;
                                region = region;
                                country = country;
                                town.province = province.id;
                              });
                            },
                          ),
                        ]),
                  ])),
                  actions: <Widget>[
                    dialogsBtns(context, saveTown, town),
                  ],
                ));
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
