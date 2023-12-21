import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const pageActivityIndicatorTitle = "Indicadores de actividad";
List aiList = [];

class ActivityIndicatorsPage extends StatefulWidget {
  const ActivityIndicatorsPage({super.key});

  @override
  State<ActivityIndicatorsPage> createState() => _ActivityIndicatorsPageState();
}

class _ActivityIndicatorsPageState extends State<ActivityIndicatorsPage> {
  void loadActivityIndicators(value) async {
    await getActivityIndicatorsByActivity(value).then((val) {
      aiList = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Activity? activity;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      activity = args["activity"];
    } else {
      activity = null;
    }

    if (activity == null) return const Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        activityIndicatorPath(context, activity),
        activityIndicatorHeader(context, activity),
        //marcoMenu(context, activity, "marco"),
        contentTab(context, activityIndicatorList, activity),

        /*Expanded(
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xffdfdfdf),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: activityIndicatorList(context, activity),
                )))*/
      ]),
    );
  }

/*-------------------------------------------------------------
                        ACTIVITY INDICATORS
-------------------------------------------------------------*/
  Widget activityIndicatorPath(context, activity) {
    return FutureBuilder(
        future: getProjectByActivityIndicator(activity.uuid),
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

  Widget activityIndicatorHeader(context, activity) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: customText(activity.name, 20),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //addBtn(context, activity),
            addBtn(context, _editActivityIndicatorDialog,
                {"indicator": null, "activity": activity}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  /*Widget addBtn(context, activity) {
    return FilledButton(
      onPressed: () {
        _editActivityIndicatorDialog(context, null, activity);
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

  void _saveActivityIndicator(
      context, indicator, name, percent, source, activity) async {
    indicator ??= ActivityIndicator(activity);
    activity.name = name;
    activity.percent = percent;
    activity.source = source;
    activity.save();
    loadActivityIndicators(activity.uuid);
    Navigator.of(context).pop();
  }

  Future<void> _editActivityIndicatorDialog(context, HashMap args) {
    Activity activity = args["activity"];
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController percentController = TextEditingController(text: "");
    TextEditingController sourceController = TextEditingController(text: "");

    if (args["indicator"] != null) {
      ActivityIndicator indicator = args["indicator"];
      nameController = TextEditingController(text: indicator.name);
      percentController = TextEditingController(text: indicator.percent);
      sourceController = TextEditingController(text: indicator.source);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Indicador de Actividad'),
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
                _saveActivityIndicator(
                    context,
                    args["indicator"],
                    nameController.text,
                    percentController.text,
                    sourceController.text,
                    activity);
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

  Widget activityIndicatorList(context, activity) {
    return FutureBuilder(
        future: getActivityIndicatorsByActivity(activity.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            aiList = snapshot.data!;
            if (aiList.isNotEmpty) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: aiList.length,
                  itemBuilder: (BuildContext context, int index) {
                    ActivityIndicator indicator = aiList[index];
                    return Container(
                      //height: 300,
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Color(0xffdfdfdf))),
                      ),
                      child: activityIndicatorRow(context, indicator, activity),
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

  Widget activityIndicatorRow(context, indicator, activity) {
    double percent = 0;
    try {
      percent = double.parse(indicator.percent) / 100;
    } on Exception catch (_) {}

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          customText('Indicador de actividad', 14, bold: FontWeight.bold),
          activityIndicatorRowOptions(context, indicator, activity),
        ]),
        space(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${indicator.name}'),
                  space(height: 20),
                  customText('Fuente', 14, bold: FontWeight.bold),
                  space(height: 10),
                  Text('${indicator.source}'),
                ]),
            CircularPercentIndicator(
              radius: 30.0,
              lineWidth: 8.0,
              percent: percent,
              center: Text(indicator.percent + " %"),
              progressColor: Colors.lightGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget activityIndicatorRowOptions(context, indicator, activity) {
    return Row(children: [
      editBtn(context, _editActivityIndicatorDialog,
          {"indicator": indicator, "activity": activity}),
      /*IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Editar',
          onPressed: () async {
            _editActivityIndicatorDialog(context, indicator, activity);
          }),*/
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Borrar',
          onPressed: () {
            _removeActivityIndicatorDialog(context, indicator, activity);
          }),
    ]);
  }

  Future<void> _removeActivityIndicatorDialog(
      context, indicator, activity) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Borrar Indicador de Actividad'),
          content: const SingleChildScrollView(
            child: Text("Está seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Borrar'),
              onPressed: () async {
                indicator.delete();
                loadActivityIndicators(activity.uuid);
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
