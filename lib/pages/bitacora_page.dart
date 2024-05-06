import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

//const riskPageTitle = "Riesgos";
//List risks = [];

class BitacoraPage extends StatefulWidget {
  final SProject? project;
  const BitacoraPage({super.key, this.project});

  @override
  State<BitacoraPage> createState() => _BitacoraPageState();
}

class _BitacoraPageState extends State<BitacoraPage> {
  SProject? project;
  /*void loadRisks(value) async {
    await getRisksByProject(value).then((val) {
      risks = val;
    });
    setState(() {});
  }*/

  @override
  initState() {
    super.initState();
    project = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        pathHeader(context, project!.name),
        bitacoraHeader(context, project),
        marcoMenu(context, project, "bitacora"),
        Center(
          child: customText("Under construction!", 16),
        ),
        //contentTab(context, bitacoraList, project),
        footer(context),
      ]),
    );
  }

/*-------------------------------------------------------------
                            RISKS
-------------------------------------------------------------*/
  Widget bitacoraHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //addBtn(context, riskEditDialog, {'risk': Risk(project.uuid)}),
            //space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  /*void saveRisk(List args) async {
    Risk risk = args[0];
    risk.save();
    loadRisks(risk.project);

    Navigator.pop(context);
  }

  Future<void> riskEditDialog(context, Map<String, dynamic> args) {
    Risk risk = args["risk"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar(
              (risk.name != "") ? 'Editando Riesgo' : 'Añadiendo Riesgo'),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: risk.name,
                size: 220,
                fieldValue: (String val) {
                  setState(() => risk.name = val);
                },
              )
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Descripción",
                initial: risk.description,
                size: 220,
                fieldValue: (String val) {
                  setState(() => risk.description = val);
                },
              )
            ]),
            Column(children: [
              customText("¿Ocurrió?", 12),
              FormField<bool>(builder: (FormFieldState<bool> state) {
                return Checkbox(
                  value: risk.occur,
                  onChanged: (bool? value) {
                    setState(() {
                      risk.occur = value!;
                      state.didChange(risk.occur);
                    });
                  },
                );
              })
            ]),
          ])),
          actions: <Widget>[dialogsBtns(context, saveRisk, risk)],
        );
      },
    );
  }*/

  /*Widget bitacoraList(context, project) {
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
  }*/

  /* Widget riskRow(context, risk, project) {
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
          editBtn(context, riskEditDialog, {"risk": risk}),
          removeBtn(context, removeRiskDialog,
              {"risk": risk, "project": project.uuid})
        ])
      ],
    );
  }

  void removeRiskDialog(context, args) {
    customRemoveDialog(context, args["risk"], loadRisks, args["project"]);
  }*/
}
