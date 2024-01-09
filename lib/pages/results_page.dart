// ignore_for_file: unused_import, no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
//import 'package:sic4change/pages/results_page.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const pageResultTitle = "Resultados";
List results = [];

class ResultsPage extends StatefulWidget {
  final Goal? goal;
  const ResultsPage({super.key, this.goal});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  Goal? goal;

  void loadResults(value) async {
    await getResultsByGoal(value).then((val) {
      results = val;
      //print(contact_list);
    });
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    goal = widget.goal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        resultPath(context, goal),
        space(height: 20),
        resultHeader(context, goal),
        contentTab(context, resultList, goal),
      ]),
    );
  }

/*-------------------------------------------------------------
                            RESULTS
-------------------------------------------------------------*/
  Widget resultPath(context, _goal) {
    return FutureBuilder(
        future: _goal.getProjectByGoal(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final _path = snapshot.data!;
            return pathHeader(context, _path);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget resultHeader(context, goal) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.name, style: const TextStyle(fontSize: 20)),
              space(height: 20),
              customLinearPercent(context, 1.5, 0.8, Colors.blue),
              space(height: 20)
            ]),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(
                context, editResultDialog, {"goal": goal.uuid, "result": null}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveResult(List args) async {
    Result result = args[0];
    result.save();
    loadResults(result.goal);

    Navigator.pop(context);
  }

  Future<void> editResultDialog(context, HashMap args) {
    Result result = Result(args["goal"]);
    if (args["result"] != null) {
      result = args["result"];
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar((result.name != "")
              ? 'Editando Resultado...'
              : 'Añadiendo Resultado'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: result.name,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => result.name = val);
                  },
                )
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Descripción",
                  initial: result.description,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => result.description = val);
                  },
                )
              ]),
            ]),
            space(height: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Indicador",
                  initial: result.indicatorText,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => result.indicatorText = val);
                  },
                )
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Porcentaje",
                  initial: result.indicatorPercent,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => result.indicatorPercent = val);
                  },
                )
              ]),
            ]),
            space(height: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Fuente",
                  initial: result.source,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => result.source = val);
                  },
                )
              ]),
            ])
          ])),
          actions: <Widget>[dialogsBtns(context, saveResult, result)],
        );
      },
    );
  }

  Widget resultList(context, _goal) {
    return FutureBuilder(
        future: getResultsByGoal(_goal.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            results = snapshot.data!;
            if (results.isNotEmpty) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    Result _result = results[index];
                    return Container(
                      //height: 400,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Color(0xffdfdfdf), width: 2)),
                      ),
                      child: resultRow(context, _result, _goal),
                    );
                  });
            } else {
              return const Text("");
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget resultRow(context, result, goal) {
    double _percent = 0;
    try {
      _percent = double.parse(result.indicatorPercent) / 100;
    } on Exception catch (_) {}

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customText('${result.name}', 14, bold: FontWeight.bold),
            resultRowOptions(context, result, goal),
          ],
        ),
        space(height: 10),
        Text('${result.description}'),
        space(height: 10),
        customRowDivider(),
        space(height: 10),
        customText('Indicador del resultado', 14, bold: FontWeight.bold),
        space(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${result.indicatorText}'),
            CircularPercentIndicator(
              radius: 30.0,
              lineWidth: 8.0,
              percent: _percent,
              center: Text("$_percent %"),
              progressColor: Colors.lightGreen,
            ),
          ],
        ),
        space(height: 10),
        customRowDivider(),
        space(height: 10),
        customText('Fuente', 14, bold: FontWeight.bold),
        space(height: 10),
        Text('${result.source}'),
      ],
    );
  }

  Widget resultRowOptions(context, result, goal) {
    return Row(children: [
      goPageIcon(context, "Actividades", Icons.list_alt,
          ActivitiesPage(result: result)),
      goPageIcon(context, "Tareas", Icons.assignment_rounded,
          ResultTasksPage(result: result)),
      editBtn(context, editResultDialog, {"goal": goal.uuid, "result": result}),
      removeBtn(
          context, removeResultDialog, {"goal": goal.uuid, "result": result})
    ]);
  }

  void removeResultDialog(context, args) {
    customRemoveDialog(context, args["result"], loadResults, args["goal"]);
  }
}
