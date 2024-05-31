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

  @override
  void initState() {
    super.initState();
    tracking = {"description": "", "date": ""};
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

    List<Row> trackingList = [
      Row(children: [
        Expanded(
            flex: 1,
            child: customText("Nuevo seguimiento ${DateTime.now()}", 16,
                bold: FontWeight.bold, textColor: mainColor))
      ]),
    ];

    // add header for list of trackings

    trackingList.add(Row(
      children: [
        Expanded(
            flex: 7,
            child: CustomTextField(
                labelText: 'Descripción',
                initial: tracking["description"],
                size: 220,
                fieldValue: (String val) {
                  tracking["description"] = val;
                })),
        Expanded(
            flex: 2,
            child: CustomTextField(
                labelText: 'Fecha (dd-mm-aaaa)',
                initial: "",
                size: 220,
                fieldValue: (String val) {
                  tracking["date"] = val;
                })),
        Expanded(
            flex: 1,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              saveBtn(context, () {
                mitigation["trackings"].add(tracking);
                risk.save();
                tracking = {"description": "", "date": ""};

                setState(() {});
              }, null)
            ])),
      ],
    ));

    trackingList += [
      Row(children: [Expanded(flex: 1, child: space(height: 40))]),
      Row(children: [
        Expanded(
            flex: 1,
            child: customText("Listado de seguimientos", 16,
                bold: FontWeight.bold, textColor: mainColor))
      ]),
      Row(children: [Expanded(flex: 1, child: Divider())]),
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
              child: removeBtn(context, removeTracking,
                  {"mitigation": mitigation, "index": counter, "risk": risk}))
        ],
      ));
      counter += 1;
    }

    return SingleChildScrollView(
      child: Column(
        children: trackingList,
      ),
    );
  }
}
