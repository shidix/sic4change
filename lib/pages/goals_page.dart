import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
bool loadingGoal = false;
Widget? _mainMenu;

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
  //late TabController _tabController;

  void setLoading() {
    setState(() {
      loadingGoal = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingGoal = false;
    });
  }

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
    _mainMenu = mainMenu(context);
    //_tabController = TabController(vsync: this, length: 2);
    //_tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //mainMenu(context),
        _mainMenu!,
        //pathHeader(context, _project.name),
        goalPath(context, project),
        goalHeader(context, project),
        marcoMenu(context, project, "marco"),
        loadingGoal
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : contentTab(context, goalList, project),
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
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
              child: Column(children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
            space(height: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: goal.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => goal.name = val);
                },
              )
            ]),
            space(height: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Descripción",
                initial: goal.description,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => goal.description = val);
                },
              )
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
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 15,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${goal.name}'),
                  space(height: 10),
                  customLinearPercent(context, 2, 0.8, Colors.blue),
                ],
              )),
          Expanded(flex: 1, child: goalRowOptions(context, goal, project)),
        ],
      ),
      customCollapse(context, "Resultados", resultList, goal, expanded: false)
    ]);
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

  Future<void> removeGoalDialog(context, args) {
    //customRemoveDialog(context, args["goal"], loadGoals, args["project"]);
    //customRemoveDialog(context, args["goal"], loadGoals, null);
    Goal goal = args["goal"];
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: s4cTitleBar('Borrar objetivo'),
            content: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  customText("Se va a borrar el objetivo ${goal.name}.", 16,
                      bold: FontWeight.bold),
                  space(height: 20),
                  customText("En concreto se borrara:", 16),
                  space(height: 10),
                  customText(
                      "- Información relacionadad con los resultados asociados al objetivo",
                      16),
                  space(height: 10),
                  customText(
                      "- Información relacionada con las actividades asociadas al objetivo",
                      16),
                  space(height: 10),
                  customText(
                      "- Información relacionada con los indicacores asociados al objetivo",
                      16),
                  space(height: 20),
                  customText(
                      "- Información relacionada con las tareas asociadas al objetivo",
                      16),
                  space(height: 20),
                  customText(
                      "Esta información NO será recuperable, ¿está seguro/a de que desea borrarla?",
                      16,
                      bold: FontWeight.bold),
                ])),
            actions: <Widget>[
              Row(children: [
                Expanded(
                  flex: 5,
                  child: actionButton(context, "Borrar", removeGoal,
                      Icons.save_outlined, [goal]),
                ),
                space(width: 10),
                Expanded(
                    flex: 5,
                    child: actionButton(
                        context, "Cancelar", cancelItem, Icons.cancel, context))
              ]),
            ],
          );
        });
  }

  void removeGoal(List args) async {
    setLoading();
    Navigator.pop(context);

    Goal goal = args[0];

    List resultList = await getResultsByGoal(goal.uuid);
    for (Result res in resultList) {
      //Indicadores de resultado
      List riList = await getResultIndicatorsByResult(res.uuid);
      for (ResultIndicator ri in riList) {
        ri.delete();
      }

      //Actividades del resultado
      List actList = await getActivitiesByResult(res.uuid);
      for (Activity act in actList) {
        //Indicadores de la actividad
        List aiList = await getActivityIndicatorsByActivity(act.uuid);
        for (ActivityIndicator ai in aiList) {
          ai.delete();
        }
        act.delete();
      }

      //Tareas del resultado
      List taskList = await getResultTasksByResult(res.uuid);
      for (ResultTask task in taskList) {
        task.delete();
      }
      res.delete();
    }
    goal.delete();
    stopLoading();
    //loadProjects();
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
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: result.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
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
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => result.description = val);
                },
              )
            ]),
            space(height: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Fuente",
                  initial: result.source,
                  size: 900,
                  minLines: 2,
                  maxLines: 9999,
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
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        addBtnRow(context, editResultDialog, {"result": Result(goal.uuid)},
            text: "Añadir resultado", icon: Icons.add_circle_outline),
      ]),
      FutureBuilder(
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
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: rowDecorationGreen,
                        child: Column(children: [
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
          }))
    ]);
  }

  Widget resultRow(context, result, goal) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Fuente", 14, bold: FontWeight.bold),
                    space(height: 5),
                    customText('${result.source}', 14),
                  ])),
          customColumnDivider(),
          editBtn(context, editResultDialog, {"result": result}),
          removeBtn(context, removeResultDialog,
              {"goal": goal.uuid, "result": result})
        ])),
        resultIndicatorsHeader(context, result),
        resultIndicators(context, result),
        resultActivitiesHeader(context, result),
        resultActivities(context, result),
      ],
    );
  }

  Future<void> removeResultDialog(context, args) {
    Result result = args["result"];
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: s4cTitleBar('Borrar resultado'),
            content: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  customText("Se va a borrar el objetivo ${result.name}.", 16,
                      bold: FontWeight.bold),
                  space(height: 20),
                  customText("En concreto se borrara:", 16),
                  space(height: 10),
                  customText(
                      "- Información relacionada con las actividades asociadas al resultado",
                      16),
                  space(height: 10),
                  customText(
                      "- Información relacionada con los indicacores asociados al resultado",
                      16),
                  space(height: 20),
                  customText(
                      "- Información relacionada con las tareas asociadas al resultado",
                      16),
                  space(height: 20),
                  customText(
                      "Esta información NO será recuperable, ¿está seguro/a de que desea borrarla?",
                      16,
                      bold: FontWeight.bold),
                ])),
            actions: <Widget>[
              Row(children: [
                Expanded(
                  flex: 5,
                  child: actionButton(context, "Borrar", removeResult,
                      Icons.save_outlined, [result]),
                ),
                space(width: 10),
                Expanded(
                    flex: 5,
                    child: actionButton(
                        context, "Cancelar", cancelItem, Icons.cancel, context))
              ]),
            ],
          );
        });
  }

  void removeResult(List args) async {
    setLoading();
    Navigator.pop(context);

    Result res = args[0];

    //Indicadores de resultado
    List riList = await getResultIndicatorsByResult(res.uuid);
    for (ResultIndicator ri in riList) {
      ri.delete();
    }

    //Actividades del resultado
    List actList = await getActivitiesByResult(res.uuid);
    for (Activity act in actList) {
      //Indicadores de la actividad
      List aiList = await getActivityIndicatorsByActivity(act.uuid);
      for (ActivityIndicator ai in aiList) {
        ai.delete();
      }
      act.delete();
    }

    //Tareas del resultado
    List taskList = await getResultTasksByResult(res.uuid);
    for (ResultTask task in taskList) {
      task.delete();
    }

    res.delete();
    loadGoals();
    stopLoading();
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
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: indicator.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => indicator.name = val);
                },
              )
            ]),
            space(height: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Valor",
                initial: indicator.value,
                size: 900,
                minLines: 1,
                maxLines: 1,
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
        //columnSpacing: 690,
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
          DataColumn(label: Container()),
          /*DataColumn(
              label: customText("Acciones", 14,
                  bold: FontWeight.bold,
                  textColor: headerListTitleColor,
                  align: TextAlign.end),
              tooltip: "Acciones"),*/
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
                  editBtn(context, editResultIndicatorDialog,
                      {"indicator": indicator}),
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Row(children: [
                  Expanded(
                      flex: 1,
                      child: CustomTextField(
                        labelText: "Nombre",
                        initial: activity.name,
                        size: 900,
                        minLines: 2,
                        maxLines: 9999,
                        fieldValue: (String val) {
                          setState(() => activity.name = val);
                        },
                      ))
                ]),
                space(height: 10),
                Row(
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            labelText: "Usuarios",
                            initial: activity.users,
                            size: 900,
                            fieldValue: (String val) {
                              setState(() => activity.users = val);
                            },
                          )
                        ]),
                    space(width: 20),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 220,
                              child: DateTimePicker(
                                labelText: 'Aprobación',
                                selectedDate: activity.iniDate,
                                onSelectedDate: (DateTime date) {
                                  setState(() {
                                    activity.iniDate = date;
                                  });
                                },
                              )),
                        ]),
                    space(width: 20),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 220,
                              child: DateTimePicker(
                                labelText: 'Aprobación',
                                selectedDate: activity.endDate,
                                onSelectedDate: (DateTime date) {
                                  setState(() {
                                    activity.endDate = date;
                                  });
                                },
                              )),
                        ]),
                  ],
                ),
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
        //columnSpacing: 1320,
        headingRowColor:
            MaterialStateColor.resolveWith((states) => headerListBgColor),
        columns: [
          DataColumn(
              label: customText("Nombre", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              tooltip: "Nombre"),
          DataColumn(
              label: customText("Inicio", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              tooltip: "Inicio"),
          DataColumn(
              label: customText("Fin", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              tooltip: "Fin"),
          DataColumn(
              label: customText("Usuarios", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              tooltip: "Usuarios"),
          DataColumn(label: Container()),
          /*DataColumn(
              label: customText("Acciones", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              tooltip: "Acciones"),*/
        ],
        rows: items
            .map(
              (item) => DataRow(cells: [
                DataCell(customText("${item.name}", 14)),
                DataCell(customText(
                    DateFormat("dd-MM-yyyy").format(item.iniDate), 14)),
                DataCell(customText(
                    DateFormat("dd-MM-yyyy").format(item.endDate), 14)),
                DataCell(customText("${item.users}", 14)),
                DataCell(
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  /*goPageIcon(context, "Ver", Icons.view_compact,
                          TaskInfoPage(task: task)),*/
                  editBtn(context, editActivityDialog, {"activity": item}),
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
}
