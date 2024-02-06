import 'dart:html';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

class _GoalsPageState extends State<GoalsPage>
    with SingleTickerProviderStateMixin {
  SProject? project;
  /*late TabController tabController;
  static const List<Tab> myTabs = <Tab>[
    Tab(text: "Actividades"),
    Tab(text: "Tareas"),
  ];*/
  late TabController _tabController;

  void loadGoals() async {
    await getGoalsByProject(project!.uuid).then((val) {
      goals = val;
    });
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    project = widget.project;
    _tabController = TabController(vsync: this, length: 2);
    //_tabController = TabController(vsync: this, length: myTabs.length);
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
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      /*Container(
        padding: const EdgeInsets.only(left: 40),
        child: customText(goalPageTitle, 20),
      ),*/
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /*addBtn(
                context, editGoalDialog, {'_goal': null, '_project': project}),*/
            addBtn(context, editGoalDialog, {'goal': Goal(project.uuid)}),
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
    loadGoals();

    Navigator.pop(context);
  }

  Future<void> editGoalDialog(context, Map<String, dynamic> args) {
    Goal goal = args["goal"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Objetivo"),
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
          actions: <Widget>[
            dialogsBtns(context, saveGoal, goal),
          ],
        );
      },
    );
  }

  Widget goalList(context, project) {
    return FutureBuilder(
        future: getGoalsByProject(project.uuid),
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
                        padding: const EdgeInsets.all(15),
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: goals.length,
                            itemBuilder: (BuildContext context, int index) {
                              Goal goal = goals[index];
                              if (goal.main) {
                                return Column(children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    decoration: rowDecoration,
                                    child: goalRowMain(context, goal, project),
                                  ),
                                ]);
                              } else {
                                return Container(
                                  //height: 100,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  decoration: rowDecoration,
                                  child: goalRow(context, goal, project),
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
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText('Objetivo General', 14, bold: FontWeight.bold),
              space(height: 10),
              customText('${goal.name}', 14),
              space(height: 10),
              customLinearPercent(context, 2, 0.8, percentBarPrimary),
              space(height: 10),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Text(
                    goal.description,
                    overflow: TextOverflow.ellipsis,
                  )),
              space(height: 10),
            ],
          ),
          goalRowOptions(context, goal, project),
        ],
      ),
      customCollapse(context, "Resultados", resultList, goal)
    ]);
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
      /*goPageIcon(
          context, "Resultados", Icons.list_alt, ResultsPage(goal: goal)),*/
      editBtn(context, editGoalDialog, {'goal': goal}),
      removeBtn(
          context, removeGoalDialog, {"goal": goal, "project": project.uuid})
    ]);
  }

  void removeGoalDialog(context, args) {
    //customRemoveDialog(context, args["goal"], loadGoals, args["project"]);
    customRemoveDialog(context, args["goal"], loadGoals, null);
  }

  /*-------------------------------------------------------------
                            RESULTS
  -------------------------------------------------------------*/
  void saveResult(List args) async {
    Result result = args[0];
    result.save();
    loadGoals();

    Navigator.pop(context);
  }

  Future<void> editResultDialog(context, Map<String, dynamic> args) {
    Result result = args["result"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar((result.name != "")
              ? 'Editando Resultado'
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

  Widget resultList(context, goal) {
    return FutureBuilder(
        future: getResultsByGoal(goal.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            results = snapshot.data!;
            if (results.isNotEmpty) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: results.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    Result result = results[index];
                    return Container(
                      //height: 400,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      /*decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Color(0xffdfdfdf), width: 2)),
                      ),*/
                      decoration: rowDecorationGreen,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            /*editBtn(context, editResultDialog, {"result": Result(goal.uuid)},
                icon: Icons.add),*/
                            addBtnRow(context, editResultDialog,
                                {"result": Result(goal.uuid)},
                                text: "Añadir resultado",
                                icon: Icons.add_circle_outline),
                          ],
                        ),
                        resultRow(context, result, goal),
                      ]),
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
    /*double percent = 0;
    try {
      percent = double.parse(result.indicatorPercent) / 100;
    } on Exception catch (_) {}*/

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customText('${result.name}', 14, bold: FontWeight.bold),
            resultRowOptions(context, result, goal),
          ],
        ),
        space(height: 10),
        Text('${result.description}'),
        space(height: 10),
        customText('Fuente', 14, bold: FontWeight.bold),
        space(height: 10),
        Text('${result.source}'),
        space(height: 10),*/
        IntrinsicHeight(
            child: Row(children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText('${result.name}', 14, bold: FontWeight.bold),
                  space(height: 5),
                  customText('${result.description}', 14),
                ],
              )),
          space(width: 10),
          customColumnDivider(),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Fuente", 14, bold: FontWeight.bold),
            space(height: 5),
            customText('${result.source}', 14),
          ]),
        ])),
        resultIndicatorsHeader(context, result),
        resultIndicators(context, result),
        resultActivitiesHeader(context, result),
        resultActivities(context, result),

        //customRowDivider(),
        //space(height: 10),
        /*customText('Indicador del resultado', 14, bold: FontWeight.bold),
        space(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${result.indicatorText}'),
            CircularPercentIndicator(
              radius: 30.0,
              lineWidth: 8.0,
              percent: percent,
              center: Text("$percent %"),
              progressColor: Colors.lightGreen,
            ),
          ],
        ),
        space(height: 10),*/
        //customRowDivider(),
        /*TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: customText("Activiades", 14)),
            Tab(child: customText("Tareas", 14))
          ],
        ),
        SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                activityList(context, result),
                taskList(context, result),
              ],
            )),*/
      ],
    );
  }

  Widget resultRowOptions(context, result, goal) {
    return Row(children: [
      /*goPageIcon(context, "Actividades", Icons.list_alt,
          ActivitiesPage(result: result)),
      goPageIcon(context, "Tareas", Icons.assignment_rounded,
          ResultTasksPage(result: result)),*/
      editBtn(context, editResultDialog, {"result": result}),
      removeBtn(
          context, removeResultDialog, {"goal": goal.uuid, "result": result})
    ]);
  }

  void removeResultDialog(context, args) {
    customRemoveDialog(context, args["result"], loadGoals, args["goal"]);
  }

  /*-------------------------------------------------------------
                            RESULTS INDICATORS
  -------------------------------------------------------------*/
  void saveResultIndicator(List args) async {
    ResultIndicator indicator = args[0];
    indicator.save();
    loadGoals();

    Navigator.pop(context);
  }

  Future<void> editResultIndicatorDialog(context, Map<String, dynamic> args) {
    ResultIndicator indicator = args["indicator"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Indicador de resultado"),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: indicator.name,
                size: 220,
                fieldValue: (String val) {
                  setState(() => indicator.name = val);
                },
              )
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Valor",
                initial: indicator.value,
                size: 220,
                fieldValue: (String val) {
                  setState(() => indicator.value = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveResultIndicator, indicator),
          ],
        );
      },
    );
  }

  Widget resultIndicatorsHeader(context, result) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Indicadores", 15, bold: FontWeight.bold),
      addBtnRow(context, editResultIndicatorDialog,
          {'indicator': ResultIndicator(result.uuid)},
          text: "Añadir indicador", icon: Icons.add_circle_outline),
    ]);
  }

  Widget resultIndicators(context, result) {
    return FutureBuilder(
        future: getResultIndicatorsByResult(result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List indicators = snapshot.data!;
            if (indicators.isNotEmpty) {
              return Container(child: resultIndicatorsRow(context, indicators));
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

  Widget resultIndicatorsRow(context, List indicators) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        sortColumnIndex: 0,
        showCheckboxColumn: false,
        columnSpacing: 690,
        headingRowColor:
            MaterialStateColor.resolveWith((states) => headerListBgColor),
        columns: [
          DataColumn(
              label: customText("Nombre", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              tooltip: "Nombre"),
          DataColumn(
            label: customText("Valor", 14,
                bold: FontWeight.bold, textColor: headerListTitleColor),
            tooltip: "Valor",
          ),
          DataColumn(
              label: customText("Acciones", 14,
                  bold: FontWeight.bold,
                  textColor: headerListTitleColor,
                  align: TextAlign.end),
              tooltip: "Acciones"),
        ],
        rows: indicators
            .map(
              (indicator) => DataRow(cells: [
                DataCell(Text(indicator.name)),
                DataCell(Text(indicator.value)),
                DataCell(
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  /*goPageIcon(context, "Ver", Icons.view_compact,
                          TaskInfoPage(task: task)),*/
                  removeBtn(context, removeResultIndicatorDialog,
                      {"indicator": indicator})
                ]))
              ]),
            )
            .toList(),
      ),
    );
  }

  void removeResultIndicatorDialog(context, args) {
    customRemoveDialog(context, args["indicator"], loadGoals, null);
  }

  /*-------------------------------------------------------------
                            ACTIVITIES
  -------------------------------------------------------------*/
  void saveActivity(List args) async {
    Activity activity = args[0];
    activity.save();
    loadGoals();

    Navigator.pop(context);
  }

  Future<void> editActivityDialog(context, Map<String, dynamic> args) {
    Activity activity = args["activity"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Actividad"),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: activity.name,
                size: 220,
                fieldValue: (String val) {
                  setState(() => activity.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveActivity, activity),
          ],
        );
      },
    );
  }

  Widget resultActivitiesHeader(context, result) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Actividades", 15, bold: FontWeight.bold),
      addBtnRow(
          context, editActivityDialog, {'activity': Activity(result.uuid)},
          text: "Añadir actividad", icon: Icons.add_circle_outline),
    ]);
  }

  Widget resultActivities(context, result) {
    return FutureBuilder(
        future: getActivitiesByResult(result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List items = snapshot.data!;
            if (items.isNotEmpty) {
              return Container(child: resultActivityRow(context, items));
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

  Widget resultActivityRow(context, List items) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        sortColumnIndex: 0,
        showCheckboxColumn: false,
        columnSpacing: 1320,
        headingRowColor:
            MaterialStateColor.resolveWith((states) => headerListBgColor),
        columns: [
          DataColumn(
              label: customText("Nombre", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              tooltip: "Nombre"),
          DataColumn(
              label: customText("Acciones", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              tooltip: "Acciones"),
        ],
        rows: items
            .map(
              (item) => DataRow(cells: [
                DataCell(customText("${item.name}", 14)),
                DataCell(
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  /*goPageIcon(context, "Ver", Icons.view_compact,
                          TaskInfoPage(task: task)),*/
                  removeBtn(context, removeActivityDialog, {"item": item})
                ]))
              ]),
            )
            .toList(),
      ),
    );
  }

  void removeActivityDialog(context, args) {
    customRemoveDialog(context, args["item"], loadGoals, null);
  }

  /*-------------------------------------------------------------
                            ACTIVITIES
  -------------------------------------------------------------*/
/*  Widget activityList(context, result) {
    return FutureBuilder(
        future: getActivitiesByResult(result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            activities = snapshot.data!;
            if (activities.isNotEmpty) {
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
                              itemCount: activities.length,
                              itemBuilder: (BuildContext context, int index) {
                                Activity activity = activities[index];
                                return Container(
                                  height: 100,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xffdfdfdf))),
                                  ),
                                  child: activityRow(context, activity, result),
                                );
                              })))
                ],
              );
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

  Widget activityRow(context, activity, result) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customText('${activity.name}', 16),
            //activityRowOptions(context, activity, result),
          ],
        ),
      ],
    );
  }

  /*-------------------------------------------------------------
                            TASKS
  -------------------------------------------------------------*/
  Widget taskList(context, result) {
    return FutureBuilder(
        future: getResultTasksByResult(result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            result_task_list = snapshot.data!;
            if (result_task_list.isNotEmpty) {
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
                              itemCount: result_task_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                ResultTask task = result_task_list[index];
                                return Container(
                                  height: 80,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xffdfdfdf))),
                                  ),
                                  child: taskRow(context, task, result),
                                );
                              })))
                ],
              );
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

  Widget taskRow(context, task, result) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customText('${task.name}', 16),
            //taskRowOptions(context, task, result),
          ],
        ),
      ],
    );
  }*/
}
