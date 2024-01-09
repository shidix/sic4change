import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const goalPageTitle = "Marco Lógico";
List goals = [];

class GoalsPage extends StatefulWidget {
  final SProject? project;
  const GoalsPage({super.key, this.project});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  SProject? project;
  void loadGoals(value) async {
    await getGoalsByProject(value).then((val) {
      goals = val;
    });
    setState(() {});
  }

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
        //pathHeader(context, _project.name),
        goalPath(context, project),
        goalHeader(context, project),
        marcoMenu(context, project, "marco"),
        contentTab(context, goalList, project),
        footer(context),
      ]),
    );
  }

/*-------------------------------------------------------------
                            GOALS
-------------------------------------------------------------*/
  Widget goalPath(context, project) {
    return pathHeader(context, project.name);
  }

  Widget goalHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: customText(goalPageTitle, 20),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /*addBtn(
                context, editGoalDialog, {'_goal': null, '_project': project}),*/
            addBtn(context, editGoalDialog,
                {'goal': null, 'project': project.uuid}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveGoal(List args) async {
    Goal goal = args[0];
    goal.save();
    loadGoals(goal.project);

    Navigator.pop(context);
  }

  Future<void> editGoalDialog(context, HashMap args) {
    Goal goal = Goal(args["project"]);
    if (args["goal"] == null) {
      goal = args["goal"];
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar(
              (goal.name != "") ? 'Editando Objetivo' : 'Añadiendo Objetivo'),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: goal.name,
                size: 220,
                fieldValue: (String val) {
                  setState(() => goal.name = val);
                },
              )
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Descripción",
                initial: goal.description,
                size: 220,
                fieldValue: (String val) {
                  setState(() => goal.description = val);
                },
              )
            ]),
            Column(children: [
              customText("Principal", 12),
              FormField<bool>(builder: (FormFieldState<bool> state) {
                return Checkbox(
                  value: goal.main,
                  onChanged: (bool? value) {
                    setState(() {
                      goal.main = value!;
                      state.didChange(goal.main);
                    });
                  },
                );
              })
            ]),
          ])),
          actions: <Widget>[dialogsBtns(context, saveGoal, goal)],
        );
      },
    );
  }

  Widget goalList(context, _project) {
    return FutureBuilder(
        future: getGoalsByProject(_project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            goals = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(15),
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: goals.length,
                            itemBuilder: (BuildContext context, int index) {
                              Goal _goal = goals[index];
                              if (_goal.main) {
                                return Container(
                                  height: 120,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xffdfdfdf),
                                            width: 1)),
                                  ),
                                  child: goalRowMain(context, _goal, _project),
                                );
                              } else {
                                return Container(
                                  height: 100,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xffdfdfdf),
                                            width: 1)),
                                  ),
                                  child: goalRow(context, _goal, _project),
                                );
                              }
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

  Widget goalRowMain(context, goal, project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${goal.name}'),
            space(height: 10),
            customLinearPercent(context, 2, 0.8, Colors.green),
            space(height: 10),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.80,
                child: Text(
                  goal.description,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
        goalRowOptions(context, goal, project),
      ],
    );
  }

  Widget goalRow(context, goal, project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${goal.name}'),
            space(height: 10),
            customLinearPercent(context, 2, 0.8, Colors.blue),
          ],
        ),
        goalRowOptions(context, goal, project),
      ],
    );
  }

  Widget goalRowOptions(context, goal, project) {
    return Row(children: [
      goPageIcon(
          context, "Resultados", Icons.list_alt, ResultsPage(goal: goal)),
      editBtn(context, editGoalDialog, {'goal': goal, "project": project.uuid}),
      removeBtn(
          context, removeGoalDialog, {"goal": goal, "project": project.uuid})
    ]);
  }

  void removeGoalDialog(context, args) {
    customRemoveDialog(context, args["goal"], loadGoals, args["project"]);
  }
}
