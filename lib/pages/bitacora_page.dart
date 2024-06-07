import 'package:flutter/material.dart';
import 'package:sic4change/services/bitacora_form.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_bitacora.dart';
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
  /*void loadRisks(value) async {
    await getRisksByProject(value).then((val) {
      risks = val;
    });
    setState(() {});
  }*/

  @override
  initState() {
    super.initState();
    project = widget.project;
    bitacora = Bitacora(project.uuid);
    Bitacora.byProjectUuid(project.uuid).then((val) {
      print(val);
      if (val == null) {
        bitacora = Bitacora(project.uuid);
        bitacora!.save();
      }
      print (bitacora);
      setState(() {});
    });    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        pathHeader(context, project!.name),
        bitacoraHeader(context, project),
        marcoMenu(context, project, "bitacora"),
        contentTab(context, contentBitacora, bitacora),

        //contentTab(context, bitacoraList, project),
        footer(context),
      ]),
    );
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
            //addBtn(context, riskEditDialog, {'risk': Risk(project.uuid)}),
            //space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget contentBitacora (context, Bitacora bitacora) {
    return  SingleChildScrollView(
      child: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: customCollapse(context, const Text("Resumen de los principales cambios", style:TextStyle(fontSize: 18, color:mainColor)), populateSummary, 
                  bitacora, subtitle: "(contexto, actores, modificaciones sustanciales o accidenteales)", expanded: false),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(15),
          child: customCollapse(context, const Text("Retrasos", style:TextStyle(fontSize: 18, color:mainColor)), populateDelays,
                  bitacora, subtitle: "(causas, duración, impacto)", expanded: false),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(15),
          child: customCollapse(context, const Text("Aspectos financieros", style:TextStyle(fontSize: 18, color:mainColor)), populateFinancial,
                  bitacora, subtitle: "(presupuesto, gastos, ingresos)", expanded:  false),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(15),
          child: customCollapse(context, const Text("Aspectos técnicos", style:TextStyle(fontSize: 18, color:mainColor)), populateTechnicals,  
                  bitacora, subtitle: "(avances, problemas, soluciones)", expanded: false),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(15),
          child: customCollapse(context, const Text("Aportes de los socios", style:TextStyle(fontSize: 18, color:mainColor)), populateFromPartners,  
                  bitacora, subtitle: "(aportes, problemas, soluciones)", expanded: false),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(15),
          child: customCollapse(context, const Text("Otros aspectos", style:TextStyle(fontSize: 18, color:mainColor)), populateOthers, 
                  bitacora, subtitle: "(cualquier otro aspecto relevante)", expanded: false),
        ),
        ],
      ),
    );
    
  }


  Future<void> bitacoraEditDialog(context, args) {
    print(args);
    int index = args["index"];
    int type = args["type"];
    final _keysDictionary = ["summary", "delays", "financial", "technicals", "fromPartners", "others"];
    final _titlesDictionary = ["Resumen", "Retrasos", "Aspectos financieros", "Aspectos técnicos", "Aportes de los socios", "Otros aspectos"];
    String keyIndex = _keysDictionary[type % 6];
    Map<String, dynamic> item;

    if (index >= 0) {
      item = bitacora?.toJson()[keyIndex][index];
    }
    else {
      item = {'date': DateTime.now(), 'description': "", 'change': false, 'approved': false};
    }


    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar((item["description"] != "")
              ? 'Editando ${_titlesDictionary[type % 6]}'
              : 'Añadiendo ${_titlesDictionary[type % 6]}'),
          content: BitacoraForm(bitacora: bitacora!, type: type, index: index),
          actions: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              saveBtnForm(context, (args) {
                item = args[0];
                bitacora = args[1];
                if (item["description"] != "") {
                  switch (type) {
                    case 0:
                      if (index >= 0) {
                        bitacora!.summary[index] = item;
                      } else {
                        bitacora!.summary.add(item);
                      }
                      break;
                    case 1:
                      if (index >= 0) {
                        bitacora!.delays[index] = item;
                      } else {
                        bitacora!.delays.add(item);
                      }
                      break;
                    case 2:
                      if (index >= 0) {
                        bitacora!.financial[index] = item;
                      } else {
                        bitacora!.financial.add(item);
                      }
                      break;
                    case 3:
                      if (index >= 0) {
                        bitacora!.technicals[index] = item;
                      } else {
                        bitacora!.technicals.add(item);
                      }
                      break;
                    case 4:
                      if (index >= 0) {
                        bitacora!.fromPartners[index] = item;
                      } else {
                        bitacora!.fromPartners.add(item);
                      }
                      break;
                    case 5:
                      if (index >= 0) {
                        bitacora!.others[index] = item;
                      } else {
                        bitacora!.others.add(item);
                      }
                      break;

                  }

                  bitacora!.save();
                  // loadRisks(risk.project);
                  Navigator.of(context).pop();
                  setState(() {});
                }
              }, [item, bitacora]),
              space(width: 10),
              cancelBtnForm(context),
            ])
          ],
        );
      },
    );
  }



  Widget populateSummary(context, Bitacora bitacora) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal:5, vertical: 5), child:
    Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children:[addBtnRow(context, bitacoraEditDialog, {"index": -1, "type": 0})]),
        for (var item in bitacora.summary) ...[
          Row(children: [
            Expanded(flex: 1, child: Text(item["date"].toDate(),)),
            Expanded(flex: 8, child: Text(item["description"],)),
            Expanded(flex: 1, child: Text(item["change"],)),
            Expanded(flex: 1, child: Text(item["approved"],)),
          ])
        ],
      ],
    ));
    
  }


  Widget populateDelays(context, Bitacora bitacora) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal:5, vertical: 5), child:
    Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children:[addBtnRow(context, (){}, null)]),
        for (var item in bitacora.delays) ...[
          Row(children: [
            Expanded(flex: 1, child: Text(item["date"].toDate(),)),
            Expanded(flex: 8, child: Text(item["description"],)),
            Expanded(flex: 1, child: Text(item["change"],)),
            Expanded(flex: 1, child: Text(item["approved"],)),
          ])
        ],
      ],
    ));
    
  }

  Widget populateFinancial(context, Bitacora bitacora) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal:5, vertical: 5), child:
    Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children:[addBtnRow(context, (){}, null)]),
        for (var item in bitacora.financial) ...[
          Row(children: [
            Expanded(flex: 1, child: Text(item["date"].toDate(),)),
            Expanded(flex: 8, child: Text(item["description"],)),
            Expanded(flex: 1, child: Text(item["change"],)),
            Expanded(flex: 1, child: Text(item["approved"],)),
          ])
        ],
      ],
    ));
    
  }

  Widget populateTechnicals(context, Bitacora bitacora) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal:5, vertical: 5), child:
    Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children:[addBtnRow(context, (){}, null)]),
        for (var item in bitacora.technicals) ...[
          Row(children: [
            Expanded(flex: 1, child: Text(item["date"].toDate(),)),
            Expanded(flex: 8, child: Text(item["description"],)),
            Expanded(flex: 1, child: Text(item["change"],)),
            Expanded(flex: 1, child: Text(item["approved"],)),
          ])
        ],
      ],
    ));
    
  }

  Widget populateFromPartners(context, Bitacora bitacora) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal:5, vertical: 5), child:
    Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children:[addBtnRow(context, (){}, null)]),
        for (var item in bitacora.fromPartners) ...[
          Row(children: [
            Expanded(flex: 1, child: Text(item["date"].toDate(),)),
            Expanded(flex: 8, child: Text(item["description"],)),
            Expanded(flex: 1, child: Text(item["change"],)),
            Expanded(flex: 1, child: Text(item["approved"],)),
          ])
        ],
      ],
    ));
    
  }

  Widget populateOthers(context, Bitacora bitacora) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal:5, vertical: 5), child:
    Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children:[addBtnRow(context, (){}, null)]),
        for (var item in bitacora.others) ...[
          Row(children: [
            Expanded(flex: 1, child: Text(item["date"].toDate(),)),
            Expanded(flex: 8, child: Text(item["description"],)),
            Expanded(flex: 1, child: Text(item["change"],)),
            Expanded(flex: 1, child: Text(item["approved"],)),
          ])
        ],
      ],
    ));
    
  }
 
}
