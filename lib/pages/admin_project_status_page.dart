import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const statusTitle = "Estados";
List projectStatus = [];
bool loadingStatus = false;
Widget? _mainMenu;

class ProjectStatusPage extends StatefulWidget {
  const ProjectStatusPage({super.key});

  @override
  State<ProjectStatusPage> createState() => _ProjectStatusPageState();
}

class _ProjectStatusPageState extends State<ProjectStatusPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingStatus = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingStatus = false;
    });
  }

  void loadProjectStatus() async {
    setLoading();
    projectStatus = await ProjectStatus.getProjectStatus();
    stopLoading();
    // await getProjectStatus().then((val) {
    //   projectStatus = val;
    //   stopLoading();
    // });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadProjectStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        projectStatusHeader(context),
        loadingStatus
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : projectStatusList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                      PROJECT STATUS
-------------------------------------------------------------*/
  Widget projectStatusHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("ESTADOS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editProjectStatusDialog,
                {'status': ProjectStatus("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveProjectStatus(List args) async {
    ProjectStatus projectStatus = args[0];
    projectStatus.save();
    loadProjectStatus();

    Navigator.pop(context);
  }

  Future<void> editProjectStatusDialog(context, Map<String, dynamic> args) {
    ProjectStatus projectStatus = args["status"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Estado"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Row(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Nombre",
                    initial: projectStatus.name,
                    size: 440,
                    //minLines: 2,
                    //maxLines: 9999,
                    fieldValue: (String val) {
                      setState(() => projectStatus.name = val);
                    },
                  )
                ]),
                space(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Color",
                    initial: projectStatus.color,
                    size: 440,
                    //minLines: 2,
                    //maxLines: 9999,
                    fieldValue: (String val) {
                      setState(() => projectStatus.color = val);
                    },
                  )
                ]),
              ],
            )
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveProjectStatus, projectStatus),
          ],
        );
      },
    );
  }

  Widget projectStatusList(context) {
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
            DataColumn(
              label: customText("Color", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(label: Container()),
          ],
          rows: projectStatus
              .map(
                (status) => DataRow(cells: [
                  DataCell(Text(status.name)),
                  DataCell(Text(status.color)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(
                        context, editProjectStatusDialog, {"status": status}),
                    removeBtn(
                        context, removeProjectStatusDialog, {"status": status})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeProjectStatusDialog(context, args) {
    customRemoveDialog(context, args["status"], loadProjectStatus, null);
  }
}
