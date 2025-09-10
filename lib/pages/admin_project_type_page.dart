import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const projectTypeTitle = "Tipos";
List projectTypes = [];
bool loadingProjectTypes = false;
Widget? _mainMenu;

class ProjectTypePage extends StatefulWidget {
  const ProjectTypePage({super.key});

  @override
  State<ProjectTypePage> createState() => _ProjectTypePageState();
}

class _ProjectTypePageState extends State<ProjectTypePage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingProjectTypes = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingProjectTypes = false;
    });
  }

  void loadProjectTypes() async {
    setLoading();
    projectTypes = await ProjectType.getProjectTypes();
    stopLoading();
    // await getProjectTypes().then((val) {
    //   projectTypes = val;
    //   stopLoading();
    // });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadProjectTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        projectTypeHeader(context),
        loadingProjectTypes
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : projectTypeList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                      PROJECT TYPES
-------------------------------------------------------------*/
  Widget projectTypeHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("TIPOS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editProjectTypeDialog, {'type': ProjectType("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveProjectType(List args) async {
    ProjectType projectType = args[0];
    projectType.save();
    loadProjectTypes();

    Navigator.pop(context);
  }

  Future<void> editProjectTypeDialog(context, Map<String, dynamic> args) {
    ProjectType projectType = args["type"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Tipo"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: projectType.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => projectType.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveProjectType, projectType),
          ],
        );
      },
    );
  }

  Widget projectTypeList(context) {
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
          rows: projectTypes
              .map(
                (projectType) => DataRow(cells: [
                  DataCell(Text(projectType.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(
                        context, editProjectTypeDialog, {"type": projectType}),
                    removeBtn(
                        context, removeProjectTypeDialog, {"type": projectType})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeProjectTypeDialog(context, args) {
    customRemoveDialog(context, args["type"], loadProjectTypes, null);
  }
}
