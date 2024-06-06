import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_risks.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class RisksTracksForm extends StatefulWidget {
  final Risk? risk;
  final int? index;

  const RisksTracksForm({Key? key, this.risk, this.index}) : super(key: key);
  @override
  _RisksTracksFormState createState() => _RisksTracksFormState();
}

class _RisksTracksFormState extends State<RisksTracksForm> {
  final formKey = GlobalKey<FormState>();

  Map<String, dynamic> tracking = {"description": "", "date": null};
  Widget newItemContainer = Container();
  Widget btnNewTracking = Container();
  bool newTracking = false;

  @override
  void initState() {
    super.initState();
    tracking = {"description": "", "date": null};
    resetNewItemContainer();
  }

  void resetNewItemContainer() {
    newItemContainer = Container();
    btnNewTracking = actionButton(context, "Nuevo seguimiento", () {
      setState(() {
        newTracking = true;
      });
    }, Icons.add_outlined, null);
    setState(() {});
  }

  void populateNewItemContainer() {
    btnNewTracking = Container();

    if (tracking["date"] == null) {
      tracking["date"] = DateTime.now();
    }

    Widget error = Container();
    if ((tracking["description"] == "")) {
      error = Row(children: [
        Expanded(
            flex: 1,
            child: customText("Debe completar todos los campos", 14,
                textColor: Colors.red))
      ]);
    }

    newItemContainer = Column(children: [
      Row(children: [
        Expanded(
            flex: 1,
            child: customText("Nuevo seguimiento", 16,
                bold: FontWeight.bold, textColor: mainColor))
      ]),
      const Row(children: [Expanded(flex: 1, child: Divider())]),
      Row(
        children: [
          Expanded(
              flex: 6,
              child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: CustomTextField(
                      labelText: 'Descripción',
                      initial: tracking["description"],
                      size: 220,
                      fieldValue: (String val) {
                        tracking["description"] = val;
                      }))),
          Expanded(
              flex: 2,
              child: ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text("Fecha"),
                subtitle:
                    Text(DateFormat('dd/MM/yyyy').format(tracking["date"])),
                onTap: () async {
                  DateTime dateTracking = tracking["date"];
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: dateTracking,
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101));
                  print(1);

                  setState(() {
                    tracking["date"] = picked;
                  });
                },
              )),
          Expanded(
              flex: 1,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    saveBtn(context, () {
                      Risk risk = widget.risk!;
                      Map<String, dynamic> mitigation =
                          risk.extraInfo["mitigations"][widget.index!];
                      if (tracking["description"] == "") {
                        setState(() {});
                        return;
                      } else {
                        mitigation["trackings"].add(tracking);

                        risk.save();
                        tracking = {"description": "", "date": DateTime.now()};
                        setState(() {
                          newTracking = false;
                        });
                      }
                    }, null)
                  ],
                ),
              )),
          Expanded(
              flex: 1,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    actionButtonVertical(context, 'Cancelar', () {
                      resetNewItemContainer();
                    }, Icons.cancel, null)
                  ],
                ),
              ))
        ],
      ),
      error,
      Row(children: [Expanded(flex: 1, child: space(height: 40))]),
    ]);
    setState(() {});
  }

  void removeTracking(context, args) {
    Map<String, dynamic> mitigation = args["mitigation"];
    int index = args["index"];
    Risk risk = args["risk"];
    mitigation["trackings"].removeAt(index);

    setState(() {
      risk.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    Risk risk = widget.risk!;
    int index = widget.index!;

    Map<String, dynamic> mitigation = risk.extraInfo["mitigations"][index];
    if (!mitigation.containsKey("trackings")) {
      mitigation["trackings"] = [];
    }

    if (newTracking) {
      populateNewItemContainer();
    } else {
      resetNewItemContainer();
    }

    // check if tracking["date"] is string
    if (tracking["date"] is String) {
      try {
        tracking["date"] = DateTime.parse(tracking["date"]);
      } catch (e) {
        tracking["date"] = DateTime.now();
      }
    }

    List<Row> trackingList = [];

    trackingList += [
      Row(children: [Expanded(flex: 1, child: space(height: 10))]),
      Row(children: [
        Expanded(
            flex: 1,
            child: customText("Listado de seguimientos", 16,
                bold: FontWeight.bold, textColor: mainColor))
      ]),
      const Row(children: [Expanded(flex: 1, child: Divider())]),
    ];

    if (mitigation["trackings"].isEmpty) {
      trackingList.add(Row(children: [
        Expanded(
            flex: 1, child: customText("No hay seguimientos registrados", 14))
      ]));
    } else {
      trackingList.add(Row(
        children: [
          Expanded(
              flex: 7,
              child: customText('Descripción', 14, bold: FontWeight.bold)),
          Expanded(
              flex: 2,
              child: customText('Fecha', 14,
                  align: TextAlign.center, bold: FontWeight.bold)),
          Expanded(flex: 1, child: Container())
        ],
      ));

      int counter = 0;
      for (var tracking in mitigation["trackings"]) {
        if (!tracking.containsKey("date")) {
          tracking["date"] = DateTime.now();
        }
        if (!tracking.containsKey("description")) {
          tracking["description"] = "";
        }

        if (tracking["date"] is Timestamp) {
          tracking["date"] = tracking["date"].toDate();
        }
        if (tracking["date"] is String) {
          try {
            tracking["date"] = DateTime.parse(tracking["date"]);
          } catch (e) {
            // sustiruir los '-' por '/'

            tracking["date"] = DateFormat('dd/MM/yyyy')
                .parse(tracking["date"].replaceAll('-', '/'));
          }
        }

        trackingList.add(Row(
          children: [
            Expanded(flex: 7, child: customText(tracking["description"], 14)),
            Expanded(
                flex: 2,
                child: customText(
                    DateFormat('dd/MM/yyyy').format(tracking["date"]), 14,
                    align: TextAlign.center)),
            Expanded(
                flex: 1,
                child: removeConfirmBtn(context, removeTracking,
                    {"mitigation": mitigation, "index": counter, "risk": risk}))
          ],
        ));
        counter += 1;
      }
    }

    trackingList
        .add(Row(children: [Expanded(flex: 1, child: space(height: 40))]));
    trackingList.add(Row(children: [
      Expanded(flex: 3, child: Container()),
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: btnNewTracking)),
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: actionButton(context, 'Cerrar', () {
                Navigator.of(context).pop();
              }, Icons.cancel, null))),
    ]));

    return Form(
      key: formKey,
      child: SingleChildScrollView(
          child: Column(
        children: [newItemContainer] + trackingList,
      )),
    );
  }
}
