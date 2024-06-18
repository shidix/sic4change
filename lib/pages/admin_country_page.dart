import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const countryTitle = "Paises";
List countries = [];
bool loadingCountries = false;
Widget? _mainMenu;

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingCountries = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingCountries = false;
    });
  }

  void loadCountries() async {
    setLoading();
    await getCountries().then((val) {
      countries = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        countryHeader(context),
        loadingCountries
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : countryList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            PAISES
-------------------------------------------------------------*/
  Widget countryHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("PAISES", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editCountryDialog, {'country': Country("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveCountry(List args) async {
    Country country = args[0];
    country.save();
    loadCountries();

    Navigator.pop(context);
  }

  Future<void> editCountryDialog(context, Map<String, dynamic> args) {
    Country country = args["country"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("País"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: country.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => country.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveCountry, country),
          ],
        );
      },
    );
  }

  Widget countryList(context) {
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
          rows: countries
              .map(
                (country) => DataRow(cells: [
                  DataCell(Text(country.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editCountryDialog, {"country": country}),
                    removeBtn(
                        context, removeCountryDialog, {"country": country})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeCountryDialog(context, args) {
    customRemoveDialog(context, args["country"], loadCountries, null);
  }
}
