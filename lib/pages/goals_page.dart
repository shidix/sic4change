import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/firebase_service.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/goal_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const PAGE_GOAL_TITLE = "Marco Lógico";
List goal_list = [];

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  void loadGoals(value) async {
    await getGoalsByProject(value).then((val) {
      goal_list = val;
      //print(contact_list);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final SProject? _project;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _project = args["project"];
    } else {
      _project = null;
    }

    if (_project == null) return Page404();

    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        goalHeader(context, _project),
        goalMenu(context, _project),
        Expanded(
            child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: goalList(context, _project),
                )))
      ]),
    );
  }

/*-------------------------------------------------------------
                            GOALS
-------------------------------------------------------------*/
  Widget goalHeader(context, _project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: EdgeInsets.only(left: 40),
        child: Text(PAGE_GOAL_TITLE + " de " + _project.name,
            style: TextStyle(fontSize: 20)),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            goalAddBtn(context, _project),
            customRowBtn(context, "Volver", Icons.arrow_back, "/projects", {})
          ],
        ),
      ),
    ]);
  }

  Widget goalAddBtn(context, _project) {
    return ElevatedButton(
      onPressed: () {
        _editGoalDialog(context, null, _project);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          Text(
            "Add goal",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _saveGoal(context, _goal, _name, _desc, _main, _project) async {
    if (_goal != null) {
      await updateGoal(_goal.id, _goal.uuid, _name, _desc, _main, _project.uuid)
          .then((value) async {
        loadGoals(_project.uuid);
      });
    } else {
      await addGoal(_name, _desc, _main, _project.uuid).then((value) async {
        loadGoals(_project.uuid);
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _editGoalDialog(context, _goal, _project) {
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
          title: const Text('Goal edit'),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            customTextField(nameController, "Enter name"),
            space(width: 20),
            customTextField(descController, "Enter description"),
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
            goal_list = snapshot.data!;
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
                            itemCount: goal_list.length,
                            itemBuilder: (BuildContext context, int index) {
                              Goal _goal = goal_list[index];
                              if (_goal.main)
                                return Container(
                                  height: 100,
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  child: goalRowMain(context, _goal, _project),
                                );
                              else
                                return Container(
                                  height: 100,
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  child: goalRow(context, _goal, _project),
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

  Widget goalRowMain(context, _goal, _project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_goal.name}'),
            space(height: 10),
            new LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 500,
              animation: true,
              lineHeight: 10.0,
              animationDuration: 2500,
              percent: 0.8,
              //center: Text("80.0%"),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.green,
            ),
            space(height: 10),
            Text(_goal.description),
          ],
        ),
        Row(children: [
          IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () async {
                _editGoalDialog(context, _goal, _project);
              }),
          IconButton(
              icon: const Icon(Icons.remove_circle),
              tooltip: 'Remove',
              onPressed: () {
                _removeGoalDialog(context, _goal.id, _project);
              }),
        ]),
      ],
    );
  }

  Widget goalRow(context, _goal, _project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_goal.name}'),
            space(height: 10),
            new LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 500,
              animation: true,
              lineHeight: 10.0,
              animationDuration: 2500,
              percent: 0.8,
              //center: Text("80.0%"),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.blue,
            ),
          ],
        ),
        Row(children: [
          IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () async {
                _editGoalDialog(context, _goal, _project);
              }),
          IconButton(
              icon: const Icon(Icons.remove_circle),
              tooltip: 'Remove',
              onPressed: () {
                _removeGoalDialog(context, _goal.id, _project);
              }),
        ]),
      ],
    );
  }

  Future<void> _removeGoalDialog(context, id, _project) async {
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
                await deleteGoal(id).then((value) {
                  loadGoals(_project.uuid);
                  Navigator.of(context).pop();
                  //Navigator.popAndPushNamed(context, "/goals", arguments: {});
                });
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
