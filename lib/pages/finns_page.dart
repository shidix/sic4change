import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/firebase_service.dart';
import 'package:sic4change/services/firebase_service_finn.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:uuid/uuid.dart';

const PAGE_FINN_TITLE = "Gestión Económica";
List finn_list = [];
List projects = [];
SProject? _project;
FirebaseFirestore db = FirebaseFirestore.instance;

class FinnsPage extends StatefulWidget {
  const FinnsPage({super.key});

  @override
  State<FinnsPage> createState() => _FinnsPageState();
}

class _FinnsPageState extends State<FinnsPage> {
  Map<String, Map<String, Text>> aportes_controllers = {};
  Map<String, Map<String, Text>> distrib_controllers = {};
  Map<String, double> distrib_amount = {};
  Map<String, double> aportes_amount = {};
  Text totalBudget = const Text( '0.00', style:  TextStyle( fontFamily: 'Readex Pro', fontSize: 18, ), );
  void loadFinns(value) async {
    await getFinnsByProject(value).then((val) {
      finn_list = val;
    });
    for (var partner in _project!.partners) {
      distrib_amount[partner] = 0;
    }
    for (var financier in _project!.financiers) {
      aportes_amount[financier] = 0;
    }

    double total = 0;
    for (SFinn finn in finn_list) {
      await getContribByFinn(finn.uuid).then((items) {
        aportes_controllers[finn.uuid] = {};
        aportes_controllers[finn.uuid]!['Total'] = buttonEditableText("0.00");
        for (FinnContribution item in items) {
          Text labelButton =
              buttonEditableText((item.amount).toStringAsFixed(2));
          aportes_controllers[finn.uuid]![item.financier] = labelButton;
          total += item.amount;
          if (aportes_amount.containsKey(item.financier)) {
            aportes_amount[item.financier] = (aportes_amount[item.financier]! + item.amount);
          }
          else {
            aportes_amount[item.financier] = item.amount;

          }
        }
      });

      await FinnDistribution.getByFinn(finn.uuid).then((items) {
        distrib_controllers[finn.uuid] = {};
        distrib_controllers[finn.uuid]!['Total'] = buttonEditableText("0.00");
        for (FinnDistribution item in items) {
          Text labelButton =
              buttonEditableText((item.amount).toStringAsFixed(2));
          distrib_controllers[finn.uuid]![item.partner] = labelButton;
          if (distrib_amount.containsKey(item.partner)) {
            distrib_amount[item.partner] = (distrib_amount[item.partner]! + item.amount);
          }
          else {
            distrib_amount[item.partner] = item.amount;

          }
        }
      });
    }

    totalBudget = Text(
      total.toStringAsFixed(2),
      style: const TextStyle(
        fontFamily: 'Readex Pro',
        fontSize: 18,
      ),
    );

    setState(() {});
  }

  void loadProjects() async {
    await getProjects().then((value) {
      projects = value;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //final SProject? _project;
    final List items = [];

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _project = args["project"];
    } else {
      _project = null;
    }

    if (_project == null) {
      return Page404();
    }

    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        finnHeader(context, _project),
        finnFullPage(context, _project),
      ]),
    );
  }

/*-------------------------------------------------------------
                            FINNS
-------------------------------------------------------------*/
  Widget finnHeader(context, _project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: Text("$PAGE_FINN_TITLE de ${_project.name}.",
            style: TextStyle(fontSize: 20)),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            finnAddBtn(context, _project),
            customRowPopBtn(context, "Volver", Icons.arrow_back),
          ],
        ),
      ),
    ]);
  }

  Widget finnAddBtn(context, _project) {
    return ElevatedButton(
      onPressed: () {
        _editFinnDialog(context, null, _project);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          const Text(
            "Nueva partida",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _saveFinn(context, _finn, _name, _desc, _parent, _project) async {
    if (_finn != null) {
      await updateFinn(
              _finn.id, _finn.uuid, _name, _desc, _parent, _project.uuid)
          .then((value) async {
        loadFinns(_project.uuid);
      });
    } else {
      await addFinn(_name, _desc, _parent, _project.uuid).then((value) async {
        loadFinns(_project.uuid);
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _editFinnDialog(context, _finn, _project) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    String _parent = "";

    if (_finn != null) {
      nameController = TextEditingController(text: _finn.name);
      descController = TextEditingController(text: _finn.description);
      _parent = _finn.parent;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Nueva partida'),
          content: SingleChildScrollView(
            child: Column(children: [
              Row(
                children: <Widget>[
                  const Text('Nombre'),
                  space(width: 150),
                  const Text("Descripción")
                ],
              ),
              Row(children: <Widget>[
                customTextField(nameController, "Nombre"),
                space(width: 20),
                customTextField(descController, "Descripción")
              ]),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveFinn(context, _finn, nameController.text,
                    descController.text, _parent, _project);
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

  Widget finnFullPage(context, project) {
    List<Container> source_rows = [];
    double totalBudgetDouble =  max(1,double.parse(totalBudget.data.toString()));
    TextStyle ts =  const TextStyle( backgroundColor: Color(0xffffffff));
    for (var financier in project.financiers) {
      if (!aportes_amount.containsKey(financier))
      {
        aportes_amount[financier] = 0;
      }
      source_rows.add(
        Container(
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
          child: Padding(padding: EdgeInsets.all(5),child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded( flex: 1, child: Text( financier, textAlign: TextAlign.start, style: ts, ), ),
              Expanded(
                flex: 2,
                child: LinearPercentIndicator(
                    percent: aportes_amount[financier]! / totalBudgetDouble,
                    center:Text("${(aportes_amount[financier]! / totalBudgetDouble * 100).toStringAsFixed(0)} %", style:TextStyle(fontWeight: FontWeight.bold)),
                    lineHeight: 15,
                    animation: true,
                    animateFromLastPercent: true,
                    progressColor: const Color(0xFF00809A),
                    backgroundColor: const Color(0xFFEBECEF),
                    padding: EdgeInsets.zero,
                  ),
              ),
              Expanded(
                flex: 1,
                child: Text("${aportes_amount[financier]!.toStringAsFixed(2)} €", textAlign: TextAlign.end, style: ts, ),
              ),
            ],
          )),
        )
      );
    }

    return FutureBuilder(
        initialData:
            getFinnsByProject(project.uuid),
        future: getFinnsByProject(project.uuid),
        builder: ((context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(flex:1,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex:1, child:
                        Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            //width: MediaQuery.sizeOf(context).width * 0.47,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Align(
                                          alignment: AlignmentDirectional(
                                              -1.00, -1.00),
                                          child: Text(
                                            'Presupuesto Total',
                                            style: TextStyle(
                                              fontFamily: 'Readex Pro',
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(1.00, -1.00),
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(right: 100),
                                            child: totalBudget,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 10, 0, 0),
                                    child: LinearPercentIndicator(
                                      percent: 0.5,
                                      width: MediaQuery.sizeOf(context).width *
                                          0.40,
                                      lineHeight: 12,
                                      animation: true,
                                      animateFromLastPercent: true,
                                      progressColor: Color(0xFF00809A),
                                      backgroundColor: Color(0xFFEBECEF),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const Align(
                                    alignment:
                                        AlignmentDirectional(-1.00, 0.00),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 5, 0, 0),
                                      child: Text(
                                        '50% (de ejecución económica)',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                        Expanded( flex:1, child:
                        Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          //color: FlutterFlowTheme.of(context).secondaryBackground,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                            child: Container(
                              //width: MediaQuery.sizeOf(context).width * 0.5,
                              height: 100,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 20, 20, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Origen del presupuesto total',
                                      style: TextStyle(
                                        fontFamily: 'Readex Pro',
                                        color: Color(0xFF00809A),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      children: source_rows,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 2,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: mylist(snapshot, project),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }));
  }

  List<Container> mylist(data, project) {
    List<Row> rows = [];

    if (data.data is! Future<List>) {
      const TextStyle headerList = TextStyle(
        fontFamily: 'Readex Pro',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

      int wPartidas = 35;
      int wAportes = 30;
      int wDist = 30;

      String totalAport = "0.00";
      String totalDist = "0.00";

      rows.add(Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
          flex: wPartidas,
          child: const Text(
            'Partidas',
            textAlign: TextAlign.center,
            style: headerList,
          ),
        ),
        Expanded(
          flex: wAportes,
          child: const Text(
            'Aportes',
            textAlign: TextAlign.center,
            style: headerList,
          ),
        ),
        Expanded(
          flex: wDist,
          child: const Text(
            'Distribución aporte CM',
            textAlign: TextAlign.center,
            style: headerList,
          ),
        ),
      ]));

      List<Expanded> subHeader = [];
      subHeader.add(Expanded(
          flex: wPartidas,
          child: const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                '',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ))));

      int f_aportes = wAportes ~/ (project.financiers.length + 1);
      subHeader.add(Expanded(
          flex: f_aportes,
          child: const Text('Total',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))));
      for (String financier in project.financiers) {
        subHeader.add(Expanded(
            flex: f_aportes,
            child: Text(financier,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold))));
      }
      int f_dist = wDist ~/ (project.partners.length + 1);
      subHeader.add(Expanded(
          flex: f_dist,
          child: const Text('Total',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold))));
      for (String partner in project.partners) {
        subHeader.add(Expanded(
            flex: f_dist,
            child: Text(partner,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold))));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.max, children: subHeader));

      for (SFinn finn in data.data) {
        // aportes_controllers[finn.uuid] = {};
        List<Expanded> cells = [];

        cells.add(Expanded( flex: wPartidas, child: Padding( padding: const EdgeInsets.all(15), child: Text( "${finn.name}. ${finn.description}", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold), ))));
        var totalText = Text("0.00", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
        try {
          totalText = aportes_controllers[finn.uuid]!['Total'] as Text;
        } catch (e) {};
        cells.add(Expanded(flex: f_aportes, child: totalText));
        double total = 0;
        for (String financier in project.financiers) {
          Text? labelButton = buttonEditableText("0.00");
          if (aportes_controllers.containsKey(finn.uuid)) {
            if (aportes_controllers[finn.uuid]!.containsKey(financier)) {
              labelButton = aportes_controllers[finn.uuid]![financier];
              total += double.parse((labelButton as Text).data.toString());
            }
          }
          ElevatedButton button = ElevatedButton(
            onPressed: () {
              _editFinnRowDialog(context, finn, financier);
            },
            style: buttonEditableTextStyle(),
            child: labelButton,
          );
          cells.add(Expanded(
              flex: f_aportes,
              child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 5), child: button)));
        }

        totalAport = total.toStringAsFixed(2);
        int idx = (cells.length - 1 - project.financiers.length) as int; 
        cells[idx] = Expanded( flex: f_aportes, child: Text(totalAport, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)));

        // By Partner
        int f_dist = wDist ~/ (project.partners.length + 1);
        Text totalDistText = Text("0.0", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold));
        cells.add(Expanded( flex: f_dist, child: totalDistText));
        total = 0;
        for (String partner in project.partners) {
          Text? labelButton = buttonEditableText("0.00");
          if (distrib_controllers.containsKey(finn.uuid)) {
            if (distrib_controllers[finn.uuid]!.containsKey(partner)) {
              labelButton = distrib_controllers[finn.uuid]![partner];
              total += double.parse((labelButton as Text).data.toString());
            }
          }
          ElevatedButton button = ElevatedButton(
            onPressed: () {
              _editFinnDistDialog(context, finn, partner);
            },
            style: buttonEditableTextStyle(),
            child: labelButton,
          );
          cells.add(Expanded(
              flex: f_dist,
              child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 5), child: button)));
        }
        totalDist = total.toStringAsFixed(2);
        idx = (cells.length - 1 - project.partners.length) as int; 
        cells[idx] = Expanded( flex: f_dist, child: Text(totalDist, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)));

        rows.add(Row(mainAxisSize: MainAxisSize.max, children: cells));
      }

      List<Container> containers = [];
      for (var row in rows) {
        containers.add(Container(color: Colors.white, child: row));
      }

      return containers;
    } else {
      if (aportes_controllers.isEmpty) {
        loadFinns(project.uuid);
      }
      return [];
    }
  }

  Future<void> _editFinnRowDialog(context, finn, financier) {
    final database = db.collection("s4c_finncontrib");
    List<Row> rows = [];
    TextEditingController amount = TextEditingController(text: "0");
    TextEditingController comment = TextEditingController(text: "");
    FinnContribution item;
    item = FinnContribution(
        "", financier, double.parse(amount.text), finn.uuid, comment.text);

    database.where("finn", isEqualTo: finn.uuid).where("financier", isEqualTo: financier).get()
      .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          item = FinnContribution.fromJson(querySnapshot.docs.first.data());
          amount.text = item.amount.toStringAsFixed(2);
          comment.text = item.subject;
        } else {
          item = FinnContribution(
              "", financier, double.parse(amount.text), finn.uuid, comment.text);
        }
    });

    rows.add(const Row(children: [
      Expanded(
          flex: 1,
          child:
              Padding(padding: EdgeInsets.all(10), child: Text('Financiador'))),
      Expanded(
          flex: 1,
          child:
              Padding(padding: EdgeInsets.all(10), child: Text('Comentario'))),
      Expanded(
          flex: 1,
          child: Padding(padding: EdgeInsets.all(10), child: Text('Cantidad'))),
    ]));

    amount.text = "0";
    rows.add(Row(children: [
      Expanded(
          flex: 1,
          child: Padding(padding: EdgeInsets.all(10), child: Text(financier))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: customTextField(comment, 'Comentario'))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: customDoubleField(amount, ''))),
    ]));

    TextButton saveButton = TextButton(
      child: const Text('Guardar'),
      onPressed: () async {
        item.amount = double.parse(amount.text);
        item.subject = comment.text;
        item.save();
        loadFinns(_project!.uuid);
        Navigator.of(context).pop();
      },
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          title: Card(
              color: Colors.blueGrey,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('${finn.name}. ${finn.description}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)))),
          content: SingleChildScrollView(
            child: Column(children: rows),
          ),
          actions: <Widget>[
            saveButton,
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

  Future<void> _editFinnDistDialog(context, finn, partner) {
    final database = db.collection("s4c_finndistrib");
    List<Row> rows = [];
    TextEditingController amount = TextEditingController(text: "0");
    TextEditingController comment = TextEditingController(text: "");
    // FinnContribution item;
    FinnDistribution item = FinnDistribution(
        "", partner, double.parse(amount.text), finn.uuid, comment.text);

    final query = database
        .where("finn", isEqualTo: finn.uuid)
        .where("partner", isEqualTo: partner)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        item = FinnDistribution.fromJson(querySnapshot.docs.first.data());
        amount.text = item.amount.toStringAsFixed(2);
        comment.text = item.subject;
      } else {
        item = FinnDistribution(
            "", partner, double.parse(amount.text), finn.uuid, comment.text);
      }
    });

    rows.add(const Row(children: [
      Expanded(
          flex: 1,
          child:
              Padding(padding: EdgeInsets.all(10), child: Text('Socio'))),
      Expanded(
          flex: 1,
          child:
              Padding(padding: EdgeInsets.all(10), child: Text('Comentario'))),
      Expanded(
          flex: 1,
          child: Padding(padding: EdgeInsets.all(10), child: Text('Cantidad'))),
    ]));

    amount.text = "0";
    rows.add(Row(children: [
      Expanded(
          flex: 1,
          child: Padding(padding: EdgeInsets.all(10), child: Text(partner))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: customTextField(comment, 'Comentario'))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: customDoubleField(amount, ''))),
    ]));

    TextButton saveButton = TextButton(
      child: const Text('Guardar'),
      onPressed: () async {
        item.amount = double.parse(amount.text);
        item.subject = comment.text;
        item.save();
        loadFinns(_project!.uuid);
        Navigator.of(context).pop();
      },
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          title: Card(
              color: Colors.blueGrey,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('${finn.name}. ${finn.description}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)))),
          content: SingleChildScrollView(
            child: Column(children: rows),
          ),
          actions: <Widget>[
            saveButton,
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


  void _saveFinnContrib(context, _finn, _name, _desc, _parent, _project) async {
    if (_finn != null) {
      await updateFinn(
              _finn.id, _finn.uuid, _name, _desc, _parent, _project.uuid)
          .then((value) async {
        loadFinns(_project.uuid);
      });
    } else {
      await addFinn(_name, _desc, _parent, _project.uuid).then((value) async {
        loadFinns(_project.uuid);
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _removeFinnDialog(context, id, _project) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Remove Finn'),
          content: SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                await deleteFinn(id).then((value) {
                  loadFinns(_project.uuid);
                  Navigator.of(context).pop();
                  //Navigator.popAndPushNamed(context, "/finns", arguments: {});
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

List<FinnContribution> _getContribByFinn(String finnuuid) {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<FinnContribution> items = [];
  final database = db.collection("s4c_finncontrib");
  final query =
      database.where("finn", isEqualTo: finnuuid).get().then((querySnapshot) {
    for (var doc in querySnapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final item = FinnContribution.fromJson(data);
      items.add(item);
    }
  });
  return items;
}

ButtonStyle buttonEditableTextStyle() {
  return ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    backgroundColor: Colors.white,
  );
}

Text buttonEditableText(String textButton) {
  return Text(textButton,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey));
}

Future<void> _editFinnRowDialog2(context, finn, project) {
  List<Row> rows = [];
  rows.add(const Row(children: [
    Expanded(
        flex: 1,
        child:
            Padding(padding: EdgeInsets.all(10), child: Text('Financiador'))),
    Expanded(
        flex: 1,
        child: Padding(padding: EdgeInsets.all(10), child: Text('Comentario'))),
    Expanded(
        flex: 1,
        child: Padding(padding: EdgeInsets.all(10), child: Text('Cantidad'))),
  ]));
  for (var financier in project.financiers) {
    rows.add(Row(children: [
      Expanded(
          flex: 1,
          child: Padding(padding: EdgeInsets.all(10), child: Text(financier))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: customTextField(
                  TextEditingController(
                    text: "",
                  ),
                  'Comentario'))),
      //        Expanded(flex:1, child: Padding(padding:EdgeInsets.all(10), child: TextField(decoration:InputDecoration(labelText:'Test'), inputFormatters: [FilteringTextInputFormatter.digitsOnly],))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: customDoubleField(
                  TextEditingController(text: ""), 'Cantiidad'))),
    ]));
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      // List <FinnContribution> listContrib =  _getContribByFinn(finn.uuid);
      // print(listContrib);
      return AlertDialog(
        // <-- SEE HERE
        title: Card(
            color: Colors.blueGrey,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text('${finn.name}. ${finn.description}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white)))),
        content: SingleChildScrollView(
          child: Column(children: rows),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              Future<List> aux = FinnContribution.getByFinnAndFinancier(
                  finn.uuid, 'SIC4Changes');
              print("TEST");
              print(aux.then((value) => print(value)));
              for (Row row in rows.skip(1)) {
                Text financier =
                    (((row.children[0] as Expanded).child as Padding).child
                        as Text);
                TextEditingController subject =
                    ((((row.children[1] as Expanded).child as Padding).child
                                as SizedBox)
                            .child as TextField)
                        .controller as TextEditingController;
                TextEditingController amount =
                    ((((row.children[2] as Expanded).child as Padding).child
                                as SizedBox)
                            .child as TextField)
                        .controller as TextEditingController;

                try {
                  //FinnContribution item = FinnContribution("", financier.data.toString(), amount as double, finn, subject as String);
                  FinnContribution item = FinnContribution(
                      "496848bb-0cb2-4370-88f4-eb6b63302738",
                      financier.data.toString(),
                      double.parse(amount.text),
                      finn.uuid,
                      subject.text);
                  // item.save();

                  print("OK");
                } on Exception catch (e) {
                  print("ERROR");
                  print(e.runtimeType);
                }
                print("Debug 2");
                // _saveFinnContrib(context, finn, ,
                //     descController.text, parent, "");
              }
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
