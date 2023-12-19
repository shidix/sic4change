import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const goalPageTitle = "Marco Lógico";
List goals = [];

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  void loadGoals(value) async {
    await getGoalsByProject(value).then((val) {
      goals = val;
      //print(contact_list);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final SProject? project;

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
        //pathHeader(context, _project.name),
        goalPath(context, project),
        goalHeader(context, project),
        marcoMenu(context, project, "marco"),
        contentTab(context, goalList, project),
        /*Expanded(
            child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xffdfdfdf),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: goalList(context, project),
                )))*/
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
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(
                context, _editGoalDialog, {'_goal': null, '_project': project}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  // Widget addBtn2(context, _project) {
  //   return FilledButton(
  //     onPressed: () {
  //       _editGoalDialog(
  //           context, {'_goal': null, '_project': _project} as HashMap);
  //     },
  //     style: FilledButton.styleFrom(
  //       side: const BorderSide(width: 0, color: Color(0xffffffff)),
  //       backgroundColor: Color(0xffffffff),
  //     ),
  //     child: const Column(
  //       children: [
  //         Icon(Icons.add, color: Colors.black54),
  //         SizedBox(height: 5),
  //         Text(
  //           "Añadir",
  //           style: TextStyle(color: Colors.black54, fontSize: 12),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _saveGoal(context, _goal, _name, _desc, _main, _project) async {
    if (_goal == null) _goal = Goal(_project);
    _goal.name = _name;
    _goal.description = _desc;
    _goal.main = _main;
    _goal.save();
    loadGoals(_project.uuid);
    Navigator.of(context).pop();
  }

  Future<void> _editGoalDialog(context, HashMap args) {
    Goal? _goal = args["_goal"];
    SProject _project = args["_project"];
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    bool _main = false;

    if (_goal != null) {
      nameController = TextEditingController(text: _goal.name);
      descController = TextEditingController(text: _goal.description);
      _main = _goal.main;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        //bool _main = false;
        return AlertDialog(
          // <-- SEE HERE
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar(
              (_goal != null) ? 'Editando Objetivo' : 'Añadiendo Objetivo'),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Nombre:", 16, textColor: Colors.blue),
              customTextField(nameController, "Nombre..."),
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Descripción:", 16, textColor: Colors.blue),
              customTextField(descController, "Descripción..."),
            ]),
            FormField<bool>(builder: (FormFieldState<bool> state) {
              return Checkbox(
                value: _main,
                onChanged: (bool? value) {
                  setState(() {
                    _main = value!;
                    state.didChange(_main);
                  });
                },
              );
            })
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveGoal(context, _goal, nameController.text,
                    descController.text, _main, _project);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
            Container(
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
      IconButton(
          icon: const Icon(Icons.list_alt),
          tooltip: 'Results',
          onPressed: () {
            Navigator.pushNamed(context, "/results", arguments: {'goal': goal});
          }),
      IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () async {
            _editGoalDialog(
                context, {'_goal': goal, '_project': project} as HashMap);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Remove',
          onPressed: () {
            _removeGoalDialog(context, goal, project);
          }),
    ]);
  }

  Future<void> _removeGoalDialog(context, _goal, _project) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Remove Goal'),
          content: SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                _goal.delete();
                loadGoals(_project.uuid);
                Navigator.of(context).pop();
                /*await deleteGoal(id).then((value) {
                  loadGoals(_project.uuid);
                  Navigator.of(context).pop();
                  //Navigator.popAndPushNamed(context, "/goals", arguments: {});
                });*/
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
