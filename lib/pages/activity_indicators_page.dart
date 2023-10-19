import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/firebase_service_marco.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
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
      body: Column(children: [
        mainMenu(context),
        activityIndicatorPath(context, _activity),
        activityIndicatorHeader(context, _activity),
        //goalMenu(context, _goal),
        Expanded(
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
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
            //activityIndicatorAddBtn(context, _activity),
            //customRowPopBtn(context, "Volver", Icons.arrow_back)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Añadir indicador',
              onPressed: () {
                _editActivityIndicatorDialog(context, null, _activity);
              },
            ),
            returnBtn(context),
            //customRowPopBtn(context, "Volver", Icons.arrow_back)
          ],
        ),
      ),
    ]);
  }

  /*Widget activityIndicatorAddBtn(context, _activity) {
    return ElevatedButton(
      onPressed: () {
        _editActivityIndicatorDialog(context, null, _activity);
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
            "Add activity indicator",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }*/

  void _saveActivityIndicator(
      context, _indicator, _name, _percent, _source, _activity) async {
    if (_indicator != null) {
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
    }
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
              child: Column(children: [
            customTextField(nameController, "Enter name"),
            customTextField(percentController, "Enter percent"),
            customTextField(sourceController, "Enter source"),
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
            _removeActivityIndicatorDialog(context, _indicator.id, _activity);
          }),
    ]);
  }

  Future<void> _removeActivityIndicatorDialog(context, id, _activity) async {
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
                await deleteActivityIndicator(id).then((value) {
                  loadActivityIndicators(_activity.uuid);
                  Navigator.of(context).pop();
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
