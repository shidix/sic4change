// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/activity_indicators_page.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const pageActivityTitle = "Actividades";
List activities = [];

class ActivitiesPage extends StatefulWidget {
  final Result? result;
  const ActivitiesPage({super.key, this.result});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  Result? result;
  Profile? currentProfile;

  void loadActivities(value) async {
    await Activity.getActivitiesByResult(value).then((val) {
      activities = val;
    });
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    result = widget.result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile>(
        future: (currentProfile != null)
            ? Future.value(currentProfile)
            : Profile.getProfile(FirebaseAuth.instance.currentUser!.email!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            currentProfile = snapshot.data!;
          } else {
            currentProfile = Profile.getEmpty();
          }
          return Scaffold(
            body:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              mainMenu(context, currentProfile),
              activityPath(context, result),
              activityHeader(context, result),
              contentTab(context, activityList, result),
              footer(context)
            ]),
          );
        });
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
            addBtn(context, editActivityDialog,
                {"activity": Activity(result.uuid)}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveActivity(List args) async {
    Activity activity = args[0];
    activity.save();
    loadActivities(activity.result);

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
          title: s4cTitleBar((activity.name != "")
              ? 'Editando Actividad'
              : 'Añadiendo Actividad'),
          content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: activity.name,
                  size: 220,
                  fieldValue: (String val) {
                    setState(() => activity.name = val);
                  },
                )
              ])),
          actions: <Widget>[dialogsBtns(context, saveActivity, activity)],
        );
      },
    );
  }

  Widget activityList(context, result) {
    return FutureBuilder(
        future: Activity.getActivitiesByResult(result.uuid),
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
            activityRowOptions(context, activity, result),
          ],
        ),
      ],
    );
  }

  Widget activityRowOptions(context, activity, result) {
    return Row(children: [
      /*IconButton(
          icon: const Icon(Icons.align_horizontal_left),
          tooltip: 'Indicadores',
          onPressed: () {
            Navigator.pushNamed(context, "/activity_indicators",
                arguments: {'activity': activity});
          }),*/
      goPageIcon(context, "Indicadores", Icons.list_alt,
          ActivityIndicatorsPage(activity: activity)),
      editBtn(context, editActivityDialog, {"activity": activity}),
      removeBtn(context, removeActivityDialog,
          {"result": result.uuid, "activity": activity})
    ]);
  }

  void removeActivityDialog(context, args) {
    customRemoveDialog(
        context, args["activity"], loadActivities, args["result"]);
  }
}
