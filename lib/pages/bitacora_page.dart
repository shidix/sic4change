import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/form_bitacora.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_bitacora.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

class BitacoraPage extends StatefulWidget {
  final SProject project;
  const BitacoraPage({super.key, required this.project});

  @override
  State<BitacoraPage> createState() => _BitacoraPageState();
}

class _BitacoraPageState extends State<BitacoraPage> {
  late SProject project;
  Bitacora? bitacora;
  final labelsHeader = [
    "Fecha",
    "Descripción",
    "Cambio sustancial",
    "Aprobado"
  ];

  @override
  initState() {
    super.initState();
    project = widget.project;
    Bitacora.byProjectUuid(project.uuid).then((val) {
      if (val == null) {
        bitacora = Bitacora(project.uuid);
        bitacora!.save();
      } else {
        bitacora = val;
      }
      setState(() {});
    });
    createLog("Acceso a Bitácora de la iniciativa: ${project.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            mainMenu(context),
            pathHeader(context, project.name),
            bitacoraHeader(context, project),
            marcoMenu(context, project, "bitacora"),
            (bitacora != null)
                ? contentTab(context, contentBitacora, bitacora)
                : Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator()),
            footer(context),
          ]),
    ));
  }

/*-------------------------------------------------------------
                            RISKS
-------------------------------------------------------------*/
  Widget bitacoraHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget contentBitacora(context, Bitacora bitacora) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: customCollapse(
                context,
                const Text("Resumen de los principales cambios",
                    style: TextStyle(fontSize: 18, color: mainColor)),
                populateSummary,
                bitacora,
                subtitle:
                    "(contexto, actores, modificaciones sustanciales o accidenteales)",
                expanded: true),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: customCollapse(
                context,
                const Text("Retrasos producidos en la intevención y por qué",
                    style: TextStyle(fontSize: 18, color: mainColor)),
                populateDelays,
                bitacora,
                subtitle: "(causas, duración, impacto)",
                expanded: false),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: customCollapse(
                context,
                const Text("Aspectos de gestión financiera/administrativa",
                    style: TextStyle(fontSize: 18, color: mainColor)),
                populateFinancial,
                bitacora,
                subtitle: "(presupuesto, gastos, ingresos)",
                expanded: false),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: customCollapse(
                context,
                const Text("Aspectos técnicos",
                    style: TextStyle(fontSize: 18, color: mainColor)),
                populateTechnicals,
                bitacora,
                subtitle: "(avances, problemas, soluciones)",
                expanded: false),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: customCollapse(
                context,
                const Text("Aspectos relacionados con los socios",
                    style: TextStyle(fontSize: 18, color: mainColor)),
                populateFromPartners,
                bitacora,
                subtitle: "(aportes, problemas, soluciones)",
                expanded: false),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: customCollapse(
                context,
                const Text("Otros cambios/aspectos a recoger",
                    style: TextStyle(fontSize: 18, color: mainColor)),
                populateOthers,
                bitacora,
                subtitle: "(cualquier otro aspecto relevante)",
                expanded: false),
          ),
        ],
      ),
    );
  }

  Future<void> bitacoraEditDialog(context, args) {
    int index = args["index"];
    int type = args["type"];
    final keysDictionary = [
      "summary",
      "delays",
      "financial",
      "technicals",
      "fromPartners",
      "others"
    ];
    final titlesDictionary = [
      "Resumen",
      "Retrasos",
      "Aspectos financieros",
      "Aspectos técnicos",
      "Aportes de los socios",
      "Otros aspectos"
    ];

    String keyIndex = keysDictionary[type % 6];
    Map<String, dynamic> item;

    if (index >= 0) {
      item = bitacora?.toJson()[keyIndex][index];
    } else {
      item = {
        'date': DateTime.now(),
        'description': "",
        'change': false,
        'approved': false
      };
    }

    return showDialog<Bitacora>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar((item["description"] != "")
              ? 'Editando ${titlesDictionary[type % 6]}'
              : 'Añadiendo ${titlesDictionary[type % 6]}'),
          content: BitacoraForm(bitacora: bitacora!, type: type, index: index),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {});
      }
    });
  }

  Widget populateSummary(context, Bitacora bitacora) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[0], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 8,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[1], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[2], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[3], 16,
                          bold: FontWeight.bold))),
              addBtnRow(context, bitacoraEditDialog, {"index": -1, "type": 0})
            ]),
            for (var item in bitacora.summary) ...[
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          DateFormat('dd/MM/yyyy')
                              .format(getDate(item["date"])),
                        ))),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          item["description"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["change"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["approved"],
                        ))),
                // actions in expanded
                Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          editBtn(context, bitacoraEditDialog, {
                            "index": bitacora.summary.indexOf(item),
                            "type": 0
                          }),
                          removeConfirmBtn(context, () {
                            bitacora.summary.remove(item);
                            bitacora.save();
                            setState(() {});
                          }, null)
                        ])),
              ])
            ],
          ],
        ));
  }

  // Populate delays
  Widget populateDelays(context, Bitacora bitacora) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[0], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 8,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[1], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[2], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[3], 16,
                          bold: FontWeight.bold))),
              addBtnRow(context, bitacoraEditDialog, {"index": -1, "type": 1})
            ]),
            for (var item in bitacora.delays) ...[
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          DateFormat('dd/MM/yyyy')
                              .format(getDate(item["date"])),
                        ))),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          item["description"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["change"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["approved"],
                        ))),
                // actions in expanded
                Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          editBtn(context, bitacoraEditDialog, {
                            "index": bitacora.delays.indexOf(item),
                            "type": 1
                          }),
                          removeConfirmBtn(context, () {
                            bitacora.delays.remove(item);
                            bitacora.save();
                            setState(() {});
                          }, null),
                        ])),
              ])
            ],
          ],
        ));
  }

  // Populate financial
  Widget populateFinancial(context, Bitacora bitacora) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[0], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 8,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[1], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[2], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[3], 16,
                          bold: FontWeight.bold))),
              addBtnRow(context, bitacoraEditDialog, {"index": -1, "type": 2})
            ]),
            for (var item in bitacora.financial) ...[
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          DateFormat('dd/MM/yyyy')
                              .format(getDate(item["date"])),
                        ))),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          item["description"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["change"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["approved"],
                        ))),
                // actions in expanded
                Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          editBtn(context, bitacoraEditDialog, {
                            "index": bitacora.delays.indexOf(item),
                            "type": 2
                          }),
                          removeConfirmBtn(context, () {
                            bitacora.financial.remove(item);
                            bitacora.save();
                            setState(() {});
                          }, null),
                        ])),
              ])
            ],
          ],
        ));
  }

  // Populate technicals
  Widget populateTechnicals(context, Bitacora bitacora) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[0], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 8,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[1], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[2], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[3], 16,
                          bold: FontWeight.bold))),
              addBtnRow(context, bitacoraEditDialog, {"index": -1, "type": 3})
            ]),
            for (var item in bitacora.technicals) ...[
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          DateFormat('dd/MM/yyyy')
                              .format(getDate(item["date"])),
                        ))),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          item["description"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["change"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["approved"],
                        ))),
                // actions in expanded
                Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          editBtn(context, bitacoraEditDialog, {
                            "index": bitacora.technicals.indexOf(item),
                            "type": 3
                          }),
                          removeConfirmBtn(context, () {
                            bitacora.technicals.remove(item);
                            bitacora.save();
                            setState(() {});
                          }, null)
                        ])),
              ])
            ],
          ],
        ));
  }

  // Populate fromPartners
  Widget populateFromPartners(context, Bitacora bitacora) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[0], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 8,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[1], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[2], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[3], 16,
                          bold: FontWeight.bold))),
              addBtnRow(context, bitacoraEditDialog, {"index": -1, "type": 4})
            ]),
            for (var item in bitacora.fromPartners) ...[
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          DateFormat('dd/MM/yyyy')
                              .format(getDate(item["date"])),
                        ))),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          item["description"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["change"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["approved"],
                        ))),
                // actions in expanded
                Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          editBtn(context, bitacoraEditDialog, {
                            "index": bitacora.fromPartners.indexOf(item),
                            "type": 4
                          }),
                          removeConfirmBtn(context, () {
                            bitacora.fromPartners.remove(item);
                            bitacora.save();
                            setState(() {});
                          }, null)
                        ])),
              ])
            ],
          ],
        ));
  }

  // Populate others
  Widget populateOthers(context, Bitacora bitacora) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[0], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 8,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[1], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[2], 16,
                          bold: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: customText(labelsHeader[3], 16,
                          bold: FontWeight.bold))),
              addBtnRow(context, bitacoraEditDialog, {"index": -1, "type": 5})
            ]),
            for (var item in bitacora.others) ...[
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          DateFormat('dd/MM/yyyy')
                              .format(getDate(item["date"])),
                        ))),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          item["description"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["change"],
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIcon(
                          item["approved"],
                        ))),
                // actions in expanded
                Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          editBtn(context, bitacoraEditDialog, {
                            "index": bitacora.others.indexOf(item),
                            "type": 5
                          }),
                          removeConfirmBtn(context, () {
                            bitacora.others.remove(item);
                            bitacora.save();
                            setState(() {});
                          }, null)
                        ])),
              ])
            ],
          ],
        ));
  }
}
