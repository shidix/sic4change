import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
// import 'package:sic4change/pages/contacts_page.dart';
//import 'package:sic4change/custom_widgets/custom_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //bool _main = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      body: Column(
        children: [
          mainMenu(context, user),
          Container(
            height: 10,
          ),
          // topButtons(context),
          Row(
            children: [
              Expanded(flex: 1, child: workTimeRecordering(context)),
              Expanded(flex: 1, child: workTimeRecordering(context)),
            ],
          )
        ],
      ),
    );
  }

  Widget topButtons(BuildContext context) {
    List<Widget> buttons = [
      actionButton(context, "Imprimir", printSummary, Icons.print, context),
      space(width: 10),
      backButton(context),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  Future<void> printSummary(context) {
    print("printSummary");
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Imprimir'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Imprimir resumen'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Imprimir'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget workTimeRecordering(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Card(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child: Icon(Icons.access_time,
                                    color: Colors.black),
                              )),
                            )),
                        Expanded(
                            flex: 5,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Registro de jornada",
                                            style: mainText,
                                          )),
                                      Text(
                                          DateFormat('EEE, d/M/yyyy')
                                              .format(DateTime.now()),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black45)),
                                    ]))),
                        Expanded(
                            flex: 2,
                            child: actionButton(
                                context,
                                "Iniciar jornada",
                                printSummary,
                                Icons.play_circle_outline_sharp,
                                context)),
                      ],
                    )),
                Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Text(
                                              DateFormat('EEE, d/M/yyyy')
                                                  .format(DateTime.now().add(
                                                      Duration(
                                                          days: -1 * index))),
                                              style: normalText,
                                            )),
                                      )),
                                  const Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "8:00",
                                          style: normalText,
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "16:00",
                                          style: normalText,
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "8",
                                          style: normalText,
                                          textAlign: TextAlign.center,
                                        )),
                                  ),
                                ],
                              ));
                        })),
              ],
            )));
  }
}
