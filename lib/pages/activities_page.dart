import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/goal_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const PAGE_ACTIVITY_TITLE = "Actividades";
List activity_list = [];

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  /*
  void loadActivities(value) async {
    await getActivitiesByResult(value).then((val) {
      activity_list = val;
    });
    setState(() {});
  }*/

  void loadActivities(_result) async {
    await _result.getActivitiesByResult().then((val) {
      activity_list = val;
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

    if (_result == null) return Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        activityPath(context, _result),
        activityHeader(context, _result),
        goalMenu(context, _result),
        Expanded(
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xffdfdfdf),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: activityList(context, _result),
                )))
      ]),
    );
  }

/*-------------------------------------------------------------
                            ACTIVITY
-------------------------------------------------------------*/
  Widget activityPath(context, _result) {
    return FutureBuilder(
        //future: getProjectByActivity(_result.uuid),
        future: _result.getProjectByActivity(),
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

  Widget activityHeader(context, _result) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.only(left: 40),
          child: Row(children: [
            //Icon(Icons.chevron_right_rounded),
            Text("Actividades",
                style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
          ]),
        ),
      ]),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, _result),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget addBtn(context, _result) {
    return FilledButton(
      onPressed: () {
        _editActivityDialog(context, null, _result);
      },
      style: FilledButton.styleFrom(
        side: const BorderSide(width: 0, color: Color(0xffffffff)),
        backgroundColor: Color(0xffffffff),
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
  }

  void _saveActivity(context, _activity, _name, _result) async {
    /*if (_activity != null) {
      await updateActivity(_activity.id, _activity.uuid, _name, _result.uuid)
          .then((value) async {
        loadActivities(_result.uuid);
      });
    } else {
      await addActivity(_name, _result.uuid).then((value) async {
        loadActivities(_result.uuid);
      });
    }*/
    if (_activity == null) _activity = Activity(_result);
    _activity.name = _name;
    _activity.save();
    loadActivities(_result);
    Navigator.of(context).pop();
  }

  Future<void> _editActivityDialog(context, _activity, _result) {
    TextEditingController nameController = TextEditingController(text: "");

    if (_activity != null) {
      nameController = TextEditingController(text: _activity.name);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
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
                _saveActivity(context, _activity, nameController.text, _result);
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

  Widget activityList(context, _result) {
    return FutureBuilder(
        //future: getActivitiesByResult(_result.uuid),
        future: getActivitiesByResult(_result.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            activity_list = snapshot.data!;
            if (activity_list.length > 0) {
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
                              itemCount: activity_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                Activity _activity = activity_list[index];
                                return Container(
                                  height: 100,
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xffdfdfdf))),
                                  ),
                                  child:
                                      activityRow(context, _activity, _result),
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

  Widget activityRow(context, _activity, _result) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_activity.name}',
              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
            activityRowOptions(context, _activity, _result),
          ],
        ),
      ],
    );
  }

  Widget activityRowOptions(context, _activity, _result) {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.align_horizontal_left),
          tooltip: 'Indicators',
          onPressed: () {
            Navigator.pushNamed(context, "/activity_indicators",
                arguments: {'activity': _activity});
          }),
      IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () async {
            _editActivityDialog(context, _activity, _result);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Remove',
          onPressed: () {
            _removeActivityDialog(context, _activity, _result);
          }),
    ]);
  }

  Future<void> _removeActivityDialog(context, _activity, _result) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Remove Activity'),
          content: SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                _activity.delete();
                loadActivities(_result);
                Navigator.of(context).pop();
                /*await deleteActivity(id).then((value) {
                  loadActivities(_result.uuid);
                  Navigator.of(context).pop();
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
