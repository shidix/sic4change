import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const stakeholderTitle = "Stakeholders";
List stakeholders = [];
bool loadingStakeholder = false;
Widget? _mainMenu;

class StakeholderPage extends StatefulWidget {
  const StakeholderPage({super.key});

  @override
  State<StakeholderPage> createState() => _StakeholderPageState();
}

class _StakeholderPageState extends State<StakeholderPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingStakeholder = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingStakeholder = false;
    });
  }

  void loadStakeholders() async {
    setLoading();
    await getContactStakeholders().then((val) {
      stakeholders = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadStakeholders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        stakeholderHeader(context),
        loadingStakeholder
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : stakeholderList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                          STAKEHOLDERS
-------------------------------------------------------------*/
  Widget stakeholderHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("STAKEHOLDERS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editStakeholderDialog,
                {'stakeholder': ContactStakeholder("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveStakeholder(List args) async {
    ContactStakeholder stakeholder = args[0];
    stakeholder.save();
    loadStakeholders();

    Navigator.pop(context);
  }

  Future<void> editStakeholderDialog(context, Map<String, dynamic> args) {
    ContactStakeholder stakeholder = args["stakeholder"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Stakeholder"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: stakeholder.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => stakeholder.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveStakeholder, stakeholder),
          ],
        );
      },
    );
  }

  Widget stakeholderList(context) {
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
          rows: stakeholders
              .map(
                (stakeholder) => DataRow(cells: [
                  DataCell(Text(stakeholder.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(context, editStakeholderDialog,
                        {"stakeholder": stakeholder}),
                    removeBtn(context, removeStakeholderDialog,
                        {"stakeholder": stakeholder})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeStakeholderDialog(context, args) {
    customRemoveDialog(context, args["stakeholder"], loadStakeholders, null);
  }
}
