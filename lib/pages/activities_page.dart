import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const pageActivityTitle = "Actividades";
List activities = [];

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  void loadActivities(_result) async {
    await _result.getActivitiesByResult().then((val) {
      activities = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Result? _result;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _result = args["result"];
    } else {
      _result = null;
    }

    if (_result == null) return const Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        activityPath(context, _result),
        activityHeader(context, _result),
        //marcoMenu(context, _result, "marco"),
        contentTab(context, activityList, _result),
        /*Expanded(
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: greyColor,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: activityList(context, _result),
                )))*/
      ]),
    );
  }

/*-------------------------------------------------------------
                            ACTIVITY
-------------------------------------------------------------*/
  Widget activityPath(context, result) {
    return FutureBuilder(
        future: result.getProjectByActivity(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final path = snapshot.data!;
            return pathHeader(context, path);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget activityHeader(context, result) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.only(left: 40),
          child: Row(children: [
            customText("Actividades", 18),
          ]),
        ),
      ]),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //addBtn(context, result),
            addBtn(context, _editActivityDialog,
                {"activity": null, "result": result}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  /*Widget addBtn(context, _result) {
    return FilledButton(
      onPressed: () {
        _editActivityDialog(context, null, _result);
      },
      style: FilledButton.styleFrom(
        side: const BorderSide(width: 0, color: Color(0xffffffff)),
        backgroundColor: const Color(0xffffffff),
      ),
      child: const Column(
        children: [
          Icon(Icons.add, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Añadir",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }*/

  void _saveActivity(context, activity, name, result) async {
    activity ??= Activity(result);
    activity.name = name;
    activity.save();
    loadActivities(result);
    Navigator.of(context).pop();
  }

  Future<void> _editActivityDialog(context, HashMap args) {
    Result result = args["result"];
    TextEditingController nameController = TextEditingController(text: "");

    if (args["activity"] != null) {
      nameController = TextEditingController(text: args["activity"].name);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Activity edit'),
          content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                customText("Nombre:", 16, textColor: Colors.blue),
                customTextField(nameController, "Nombre..."),
              ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveActivity(
                    context, args["activity"], nameController.text, result);
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

  Widget activityList(context, result) {
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
            } else
              return Text("");
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
            activityRowOptions(context, activity, result),
          ],
        ),
      ],
    );
  }

  Widget activityRowOptions(context, activity, result) {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.align_horizontal_left),
          tooltip: 'Indicadores',
          onPressed: () {
            Navigator.pushNamed(context, "/activity_indicators",
                arguments: {'activity': activity});
          }),
      editBtn(context, _editActivityDialog,
          {"activity": activity, "result": result}),
      /*IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Editar',
          onPressed: () async {
            _editActivityDialog(context, activity, result);
          }),*/
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Borrar',
          onPressed: () {
            _removeActivityDialog(context, activity, result);
          }),
    ]);
  }

  Future<void> _removeActivityDialog(context, activity, result) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Borrar actividad'),
          content: const SingleChildScrollView(
            child: Text("Esta seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Borrar'),
              onPressed: () async {
                activity.delete();
                loadActivities(result);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
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
