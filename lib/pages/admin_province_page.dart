import 'dart:async';

import 'package:flutter/material.dart';
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
  List<Country> countries = [];
  List<Region> regions = [];

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
    provinces = await Province.getProvinces();
    regions = await Region.getRegions() as List<Region>;
    countries = await Country.getCountries() as List<Country>;
    stopLoading();
    // await getProvinces().then((val) {
    //   provinces = val;
    //   stopLoading();
    // });
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
    if (province.region.isEmpty && regions.isNotEmpty) {
      province.region = regions.first.id;
    }
    Region region = regions.firstWhere((reg) => reg.id == province.region,
        orElse: () => (regions.isNotEmpty
            ? regions.first
            : Region("-- No hay regiones --")));
    Country country = countries.firstWhere((coun) => coun.id == region.country,
        orElse: () => (countries.isNotEmpty
            ? countries.first
            : Country("-- No hay países --")));
    List<Region> filteredRegions =
        regions.where((reg) => reg.country == country.id).toList();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  titlePadding: const EdgeInsets.all(0),
                  title: s4cTitleBar("Provincia"),
                  content: SingleChildScrollView(
                      child: Column(children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            labelText: "Nombre",
                            initial: province.name,
                            size: 900,
                            minLines: 2,
                            maxLines: 9999,
                            fieldValue: (String val) {
                              setState(() => province.name = val);
                            },
                          ),
                          space(height: 10),
                          DropdownButtonFormField(
                              decoration: const InputDecoration(
                                labelText: "País",
                                border: OutlineInputBorder(),
                              ),
                              items: countries
                                  .map((country) => DropdownMenuItem(
                                        value: country.id,
                                        child: Text(country.name),
                                      ))
                                  .toList(),
                              value: country.id,
                              isExpanded: true,
                              hint: const Text("País"),
                              onChanged: (value) {
                                Country selected = countries.firstWhere(
                                    (coun) => coun.id == value,
                                    orElse: () => Country(""));
                                filteredRegions = regions
                                    .where((reg) => reg.country == selected.id)
                                    .toList();
                                setState(() {
                                  country = selected;
                                  if (region.country != country.id) {
                                    region = filteredRegions.isNotEmpty
                                        ? filteredRegions.first
                                        : Region("-- No hay regiones --");
                                    province.region = region.id;
                                  }
                                });
                              }),
                          space(height: 10),
                          DropdownButtonFormField(
                              items: filteredRegions
                                  .map((region) => DropdownMenuItem(
                                        value: region.id,
                                        child: Text(region.name),
                                      ))
                                  .toList(),
                              decoration: const InputDecoration(
                                labelText: "Región",
                                border: OutlineInputBorder(),
                              ),
                              value: region.id,
                              isExpanded: true,
                              hint: const Text("Región"),
                              onChanged: (value) {
                                Region selected = filteredRegions.firstWhere(
                                    (reg) => reg.id == value,
                                    orElse: () => Region(""));
                                country = countries.firstWhere(
                                    (coun) => coun.id == selected.country,
                                    orElse: () => Country(""));
                                setState(() {
                                  region = selected;
                                  province.region = region.id;
                                });
                              }),
                        ]),
                  ])),
                  actions: <Widget>[
                    dialogsBtns(context, saveProvince, province),
                  ],
                ));
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
              WidgetStateColor.resolveWith((states) => headerListBgColor),
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
