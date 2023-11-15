import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/goal_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const PAGE_ACTIVITY_INDICATOR_TITLE = "Indicadores de actividad";
List ai_list = [];

class ActivityIndicatorsPage extends StatefulWidget {
  const ActivityIndicatorsPage({super.key});

  @override
  State<ActivityIndicatorsPage> createState() => _ActivityIndicatorsPageState();
}

class _ActivityIndicatorsPageState extends State<ActivityIndicatorsPage> {
  void loadActivityIndicators(value) async {
    await getActivityIndicatorsByActivity(value).then((val) {
      ai_list = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Activity? _activity;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _activity = args["activity"];
    } else {
      _activity = null;
    }

    if (_activity == null) return Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        activityIndicatorPath(context, _activity),
        activityIndicatorHeader(context, _activity),
        goalMenu(context, _activity),
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
                  child: activityIndicatorList(context, _activity),
                )))
      ]),
    );
  }

/*-------------------------------------------------------------
                        ACTIVITY INDICATORS
-------------------------------------------------------------*/
  Widget activityIndicatorPath(context, _activity) {
    return FutureBuilder(
        future: getProjectByActivityIndicator(_activity.uuid),
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

  Widget activityIndicatorHeader(context, _activity) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: EdgeInsets.only(left: 40),
        child: Text(_activity.name, style: TextStyle(fontSize: 20)),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, _activity),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget addBtn(context, _activity) {
    return FilledButton(
      onPressed: () {
        _editActivityIndicatorDialog(context, null, _activity);
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

  void _saveActivityIndicator(
      context, _indicator, _name, _percent, _source, _activity) async {
    /*if (_indicator != null) {
      await updateActivityIndicator(_indicator.id, _indicator.uuid, _name,
              _percent, _source, _activity.uuid)
          .then((value) async {
        loadActivityIndicators(_activity.uuid);
      });
    } else {
      await addActivityIndicator(_name, _percent, _source, _activity.uuid)
          .then((value) async {
        loadActivityIndicators(_activity.uuid);
      });
    }*/
    if (_indicator != null) _indicator = ActivityIndicator(_activity);
    _activity.name = _name;
    _activity.percent = _percent;
    _activity.source = _source;
    _activity.save();
    loadActivityIndicators(_activity.uuid);
    Navigator.of(context).pop();
  }

  Future<void> _editActivityIndicatorDialog(context, _indicator, _activity) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController percentController = TextEditingController(text: "");
    TextEditingController sourceController = TextEditingController(text: "");

    if (_indicator != null) {
      nameController = TextEditingController(text: _indicator.name);
      percentController = TextEditingController(text: _indicator.percent);
      sourceController = TextEditingController(text: _indicator.source);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Activity indicator edit'),
          content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                customText("Nombre:", 16, textColor: Colors.blue),
                customTextField(nameController, "Nombre..."),
                space(height: 20),
                customText("Porcentaje:", 16, textColor: Colors.blue),
                customTextField(percentController, "Porcentaje..."),
                space(height: 20),
                customText("Fuente:", 16, textColor: Colors.blue),
                customTextField(sourceController, "Fuente..."),
              ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveActivityIndicator(context, _indicator, nameController.text,
                    percentController.text, sourceController.text, _activity);
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

  Widget activityIndicatorList(context, _activity) {
    return FutureBuilder(
        future: getActivityIndicatorsByActivity(_activity.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            ai_list = snapshot.data!;
            if (ai_list.length > 0) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: ai_list.length,
                  itemBuilder: (BuildContext context, int index) {
                    ActivityIndicator _indicator = ai_list[index];
                    return Container(
                      //height: 300,
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Color(0xffdfdfdf))),
                      ),
                      child:
                          activityIndicatorRow(context, _indicator, _activity),
                    );
                  });

              /*return Column(
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
                              itemCount: ai_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                ActivityIndicator _indicator = ai_list[index];
                                return Container(
                                  height: 300,
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  child: activityIndicatorRow(
                                      context, _indicator, _activity),
                                );
                              })))
                ],
              );*/
            } else
              return Text("");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget activityIndicatorRow(context, _indicator, _activity) {
    double _percent = 0;
    try {
      _percent = double.parse(_indicator.percent) / 100;
    } on Exception catch (_) {}

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'Indicador de actividad',
            style: TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),
          activityIndicatorRowOptions(context, _indicator, _activity),
        ]),
        space(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_indicator.name}'),
                  space(height: 20),
                  Text(
                    'Fuente',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                  ),
                  space(height: 10),
                  Text('${_indicator.source}'),
                ]),
            new CircularPercentIndicator(
              radius: 30.0,
              lineWidth: 8.0,
              percent: _percent,
              center: new Text(_indicator.percent + " %"),
              progressColor: Colors.lightGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget activityIndicatorRowOptions(context, _indicator, _activity) {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () async {
            _editActivityIndicatorDialog(context, _indicator, _activity);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Remove',
          onPressed: () {
            _removeActivityIndicatorDialog(context, _indicator, _activity);
          }),
    ]);
  }

  Future<void> _removeActivityIndicatorDialog(
      context, _indicator, _activity) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Remove Activity Indicator'),
          content: SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                _indicator.delete();
                loadActivityIndicators(_activity.uuid);
                Navigator.of(context).pop();
                /*await deleteActivityIndicator(id).then((value) {
                  loadActivityIndicators(_activity.uuid);
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
