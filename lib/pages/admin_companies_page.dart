// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const companyTitle = "Empresas";
List companies = [];
bool loadingCompany = false;
Widget? _mainMenu;

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingCompany = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingCompany = false;
    });
  }

  void loadCompanies() async {
    setLoading();
    await getCompanies().then((val) {
      companies = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        companyHeader(context),
        loadingCompany
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : companyList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            CARGOS
-------------------------------------------------------------*/
  Widget companyHeader(context) {
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
            addBtn(context, editCompanyDialog, {'company': Company("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveCompany(List args) async {
    Company company = args[0];
    company.save();
    loadCompanies();

    Navigator.pop(context);
  }

  Future<void> editCompanyDialog(context, Map<String, dynamic> args) {
    Company company = args["company"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Empresa"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: company.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => company.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveCompany, company),
          ],
        );
      },
    );
  }

  Widget companyList(context) {
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
          rows: companies
              .map(
                (company) => DataRow(cells: [
                  DataCell(Text(company.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editCompanyDialog, {"company": company}),
                    removeBtn(
                        context, removeCompanyDialog, {"company": company})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeCompanyDialog(context, args) {
    customRemoveDialog(context, args["company"], loadCompanies, null);
  }
}
