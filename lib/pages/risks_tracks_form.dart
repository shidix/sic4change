import 'package:flutter/material.dart';
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
  Map<String, dynamic> tracking = {"description": "", "date": ""};
  Widget newItemContainer = Container();
  Widget btnNewTracking = Container();

  @override
  void initState() {
    super.initState();
    tracking = {"description": "", "date": ""};
    resetNewItemContainer();
  }

  void resetNewItemContainer() {
    newItemContainer = Container();
    btnNewTracking = actionButton(context, "Nuevo seguimiento", () {
      populateNewItemContainer();
    }, Icons.add_outlined, null);
    setState(() {});
  }

  void populateNewItemContainer() {
    btnNewTracking = Container();

    Widget error = Container();
    if ((tracking["description"] == "") ^ (tracking["date"] == "")) {
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
              flex: 7,
              child: CustomTextField(
                  labelText: 'Descripción 2',
                  initial: tracking["description"],
                  size: 220,
                  fieldValue: (String val) {
                    tracking["description"] = val;
                  })),
          Expanded(
              flex: 2,
              child: CustomTextField(
                  labelText: 'Fecha (dd-mm-aaaa)',
                  initial: tracking["date"],
                  size: 220,
                  fieldValue: (String val) {
                    tracking["date"] = val;
                  })),
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
                      if (tracking["description"] == "" &&
                          tracking["date"] == "") {
                        resetNewItemContainer();
                        return;
                      }
                      if (tracking["description"] == "" ||
                          tracking["date"] == "") {
                        populateNewItemContainer();
                        return;
                      } else {
                        mitigation["trackings"].add(tracking);

                        risk.save();
                        tracking = {"description": "", "date": ""};
                        resetNewItemContainer();
                      }
                    }, null)
                  ],
                ),
              )),
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
        tracking["date"] = "";
      }
      if (!tracking.containsKey("description")) {
        tracking["description"] = "";
      }

      trackingList.add(Row(
        children: [
          Expanded(flex: 7, child: customText(tracking["description"], 14)),
          Expanded(
              flex: 2,
              child: customText(tracking["date"], 14, align: TextAlign.center)),
          Expanded(
              flex: 1,
              child: removeConfirmBtn(context, removeTracking,
                  {"mitigation": mitigation, "index": counter, "risk": risk}))
        ],
      ));
      counter += 1;
    }
    if (counter == 0) {
      trackingList.add(Row(children: [
        Expanded(
            flex: 1, child: customText("No hay seguimientos registrados", 14))
      ]));
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

    return SingleChildScrollView(
      child: Column(
        children: [newItemContainer] + trackingList,
      ),
    );
  }
}
