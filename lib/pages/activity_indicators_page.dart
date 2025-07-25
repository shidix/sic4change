import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const pageActivityIndicatorTitle = "Indicadores de actividad";
List aiList = [];

class ActivityIndicatorsPage extends StatefulWidget {
  final Activity? activity;
  const ActivityIndicatorsPage({super.key, this.activity});

  @override
  State<ActivityIndicatorsPage> createState() => _ActivityIndicatorsPageState();
}

class _ActivityIndicatorsPageState extends State<ActivityIndicatorsPage> {
  Activity? activity;
  late final Profile? profile;

  void loadActivityIndicators(value) async {
    // await getActivityIndicatorsByActivity(value).then((val) {
    //   aiList = val;
    // });
    aiList = await ActivityIndicator.getActivityIndicatorsByActivity(value);
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    activity = widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        activityIndicatorPath(context, activity),
        activityIndicatorHeader(context, activity),
        contentTab(context, activityIndicatorList, activity),
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
            addBtn(context, editActivityIndicatorDialog,
                {"indicator": ActivityIndicator(activity.uuid)}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveActivityIndicator(List args) async {
    ActivityIndicator indicator = args[0];
    indicator.save();
    loadActivityIndicators(indicator.activity);

    Navigator.pop(context);
  }

  Future<void> editActivityIndicatorDialog(context, Map<String, dynamic> args) {
    ActivityIndicator indicator = args["indicator"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar((indicator.name != "")
              ? 'Editando Indicador de Actividad'
              : 'Añadiendo Indicador de Actividad'),
          content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: indicator.name,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => indicator.name = val);
                  },
                ),
                space(height: 20),
                CustomTextField(
                  labelText: "Porcentaje",
                  initial: indicator.base,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => indicator.base = val);
                  },
                ),
                space(height: 20),
                CustomTextField(
                  labelText: "Fuente",
                  initial: indicator.source,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => indicator.source = val);
                  },
                ),
              ])),
          actions: <Widget>[
            dialogsBtns(context, saveActivityIndicator, indicator)
          ],
        );
      },
    );
  }

  Widget activityIndicatorList(context, activity) {
    return FutureBuilder(
        future: ActivityIndicator.getActivityIndicatorsByActivity(activity.uuid),
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
      editBtn(context, editActivityIndicatorDialog, {"indicator": indicator}),
      removeBtn(context, removeActivityDialog,
          {"activity": activity.uuid, "indicator": indicator})
    ]);
  }

  void removeActivityDialog(context, args) {
    customRemoveDialog(
        context, args["indicator"], loadActivityIndicators, args["activity"]);
  }
}
