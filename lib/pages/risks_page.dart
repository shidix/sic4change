import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_risks.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const riskPageTitle = "Riesgos";
List risks = [];

class RisksPage extends StatefulWidget {
  const RisksPage({super.key});

  @override
  State<RisksPage> createState() => _RisksPageState();
}

class _RisksPageState extends State<RisksPage> {
  void loadRisks(value) async {
    await getRisksByProject(value).then((val) {
      risks = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SProject? project;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      project = args["project"];
    } else {
      project = null;
    }

    if (project == null) return const Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        pathHeader(context, project.name),
        riskHeader(context, project),
        marcoMenu(context, project, "risk"),
        contentTab(context, riskList, project),
        footer(context),
      ]),
    );
  }

/*-------------------------------------------------------------
                            RISKS
-------------------------------------------------------------*/
  Widget riskHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: customText(riskPageTitle, 20),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, callRiskDialog, {"risk": null, "project": project}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void callRiskDialog(context, HashMap args) {
    riskEditDialog(context, args["risk"], args["project"]);
  }

  void saveRisk(context, risk, name, desc, occur, project) async {
    risk ??= Risk(project.uuid);
    risk.name = name;
    risk.description = desc;
    risk.occur = occur;
    risk.save();
    loadRisks(project.uuid);
    Navigator.of(context).pop();
  }

  Future<void> riskEditDialog(context, risk, project) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    bool occur = false;

    if (risk != null) {
      nameController = TextEditingController(text: risk.name);
      descController = TextEditingController(text: risk.description);
      occur = risk.occur;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(editText),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText(nameText, 16, textColor: mainColor),
              customTextField(nameController, nameText),
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText(descText, 16, textColor: mainColor),
              customTextField(descController, descText),
            ]),
            FormField<bool>(builder: (FormFieldState<bool> state) {
              return Checkbox(
                value: occur,
                onChanged: (bool? value) {
                  setState(() {
                    occur = value!;
                    state.didChange(occur);
                  });
                },
              );
            })
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text(saveText),
              onPressed: () async {
                saveRisk(context, risk, nameController.text,
                    descController.text, occur, project);
              },
            ),
            cancelBtn(context),
          ],
        );
      },
    );
  }

  Widget riskList(context, project) {
    return FutureBuilder(
        future: getRisksByProject(project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            risks = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: risks.length,
                            itemBuilder: (BuildContext context, int index) {
                              Risk risk = risks[index];
                              return Container(
                                height: 100,
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xffdfdfdf), width: 1)),
                                ),
                                child: riskRow(context, risk, project),
                              );
                            }))),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget riskRow(context, risk, project) {
    Icon occurIcon = (risk.occur)
        ? const Icon(Icons.check_circle_outline, color: Colors.green)
        : const Icon(Icons.remove_circle_outline, color: Colors.red);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText('${risk.name}', 16, bold: FontWeight.bold),
              space(height: 10),
              Text(risk.description),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText('¿Ocurrió?', 14, bold: FontWeight.bold),
            space(height: 10),
            occurIcon,
          ],
        ),
        Row(children: [
          /*IconButton(
          icon: const Icon(Icons.list_alt),
          tooltip: 'Results',
          onPressed: () {
            Navigator.pushNamed(context, "/results",
                arguments: {'goal': risk});
          }),*/
          editBtn(context, callRiskDialog, {"risk": risk, "project": project}),
          removeBtn(context, removeRiskDialog,
              {"risk": risk, "project": project.uuid})
        ])
      ],
    );
  }

  void removeRiskDialog(context, args) {
    customRemoveDialog(context, args["risk"], loadRisks, args["project"]);
  }
}
