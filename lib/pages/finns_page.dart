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

const PAGE_FINN_TITLE = "Gestión Económica";
List finn_list = [];

class FinnsPage extends StatefulWidget {
  const FinnsPage({super.key});

  @override
  State<FinnsPage> createState() => _FinnsPageState();
}

class _FinnsPageState extends State<FinnsPage> {
  void loadFinns(value) async {
    await getFinnsByProject(value).then((val) {
      finn_list = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final SProject? _project;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _project = args["project"];
    } else {
      _project = null;
    }

    if (_project == null) return Page404();

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
            //customRowBtn(context, "Volver", Icons.arrow_back, "/projects", {})
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


  Widget finnList(context, _project) {
    return FutureBuilder(
        future: getFinnsByProject(_project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            finn_list = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(15),
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: finn_list.length,
                            itemBuilder: (BuildContext context, int index) {
                              SFinn _finn = finn_list[index];
                              if (_finn.parent == "") {
                                return Container(
                                  height: 100,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  child: finnRowMain(context, _finn, _project),
                                );
                              } else
                                return Container(
                                  height: 100,
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  child: finnRow(context, _finn, _project),
                                );
                            }))),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget finnRowMain(context, _finn, _project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_finn.name}'),
            space(height: 10),
            new LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 500,
              animation: true,
              lineHeight: 10.0,
              animationDuration: 2500,
              percent: 0.8,
              //center: Text("80.0%"),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.green,
            ),
            space(height: 10),
            Text(_finn.description),
          ],
        ),
        finnRowOptions(context, _finn, _project),
      ],
    );
  }

  Widget finnRow(context, _finn, _project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_finn.name}'),
            space(height: 10),
            new LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 500,
              animation: true,
              lineHeight: 10.0,
              animationDuration: 2500,
              percent: 0.8,
              //center: Text("80.0%"),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.blue,
            ),
          ],
        ),
        finnRowOptions(context, _finn, _project),
      ],
    );
  }

  Widget finnRowOptions(context, _finn, _project) {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.list_alt),
          tooltip: 'Results',
          onPressed: () {
            Navigator.pushNamed(context, "/results",
                arguments: {'finn': _finn});
          }),
      IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () async {
            _editFinnDialog(context, _finn, _project);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Remove',
          onPressed: () {
            _removeFinnDialog(context, _finn.id, _project);
          }),
    ]);
  }

  Widget finnFullPage(context, project) {
    return FutureBuilder(
        initialData: getFinnsByProject(project.uuid),
        future: getFinnsByProject(project.uuid),
        builder: ((context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.max,

            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: AlignmentDirectional(-1.00, -1.00),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.46,
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
                                      Expanded(
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
                                            padding:  EdgeInsets.only(
                                                right: 100),
                                            child: Text( project.budget, style: const TextStyle( fontFamily: 'Readex Pro', fontSize: 18, ), ),
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
                        ),
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
                              width: MediaQuery.sizeOf(context).width * 0.5,
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
                                      children: [
                                        Container(
                                          width: 100,
                                          decoration: const BoxDecoration(
                                            color: Color(0xffffffff),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'Financiación propia',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      backgroundColor:
                                                          Color(0xffffffff)),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          0.00, -1.00),
                                                  child: LinearPercentIndicator(
                                                    percent: 0.5,
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        0.15,
                                                    lineHeight: 15,
                                                    animation: true,
                                                    animateFromLastPercent:
                                                        true,
                                                    progressColor:
                                                        const Color(0xFF00809A),
                                                    backgroundColor:
                                                        const Color(0xFFEBECEF),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                              const Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.00, -1.00),
                                                  child: Text(
                                                    '10.000,00 €',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        backgroundColor:
                                                            Color(0xffffffff)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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

    if (data.data is! Future<List>) 
    {
      const TextStyle headerList = TextStyle( fontFamily: 'Readex Pro', fontSize: 18, fontWeight: FontWeight.bold, );



      int w_partidas = 35;
      int w_aportes = 30;
      int w_dist = 30;
      int w_tools = 5;

      rows.add(Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded( flex: w_partidas, child: const Text( 'Partidas', textAlign: TextAlign.center, style: headerList, ), ),
        Expanded( flex: w_aportes, child: const Text( 'Aportes', textAlign: TextAlign.center, style: headerList, ), ),
        Expanded( flex: w_dist, child: const Text( 'Distribución aporte CM', textAlign: TextAlign.center, style: headerList, ), ),
        Expanded( flex: w_tools, child: const Padding( padding: EdgeInsets.only(top: 10, bottom: 10), child: Text(''), ), ),
      ]));

      List<Expanded> subHeader = [];
      subHeader.add(Expanded( flex: w_partidas, child:  const Padding(padding: EdgeInsets.all(15), child:Text( '', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold), ))));

      int f_aportes = w_aportes ~/ (project.financiers.length + 1);
      subHeader.add(Expanded( flex: f_aportes, child: const Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
      for (String financier in project.financiers) {
        subHeader.add(Expanded( flex: f_aportes, child: Text(financier, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
      }
      int f_dist = w_dist ~/ (project.partners.length + 1);
      subHeader.add(Expanded( flex: f_dist, child: const Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
      for (String partner in project.partners) {
        subHeader.add(Expanded( flex: f_dist, child: Text(partner, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
      }
      subHeader.add(Expanded( flex: w_tools, child: const Text('', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
      rows.add(Row(mainAxisSize: MainAxisSize.max, children: subHeader));

      for (SFinn finn in data.data) {
        List<Expanded> cells = [];
        cells.add(Expanded( flex: w_partidas, child: Padding(padding: const EdgeInsets.all(15), child: Text( "${finn.name}. ${finn.description}", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold), ))));
        cells.add(Expanded( flex: f_aportes, child: Text((Random().nextDouble()*15000).toStringAsFixed(2), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
        for (String financier in project.financiers) {
          cells.add(Expanded( flex: f_aportes, child: Text((Random().nextDouble()*15000).toStringAsFixed(2), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
        }
        int f_dist = w_dist ~/ (project.partners.length + 1);
        cells.add(Expanded( flex: f_dist, child:  Text((Random().nextDouble()*15000).toStringAsFixed(2), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
        for (String partner in project.partners) {
          cells.add(Expanded( flex: f_dist, child: Text((Random().nextDouble()*15000).toStringAsFixed(2), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))));
        }
        ElevatedButton button = ElevatedButton(
          onPressed: () { _editFinnRowDialog(context, finn, project); },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: Colors.white,
          ),
          child: const Icon( Icons.edit, color: Colors.black54, size: 20, ),
        );
        cells.add(Expanded(flex: w_tools,  child:Padding(padding: const EdgeInsets.only(top:10), child:button)));
        rows.add(Row(mainAxisSize: MainAxisSize.max, children: cells));
      }

      List <Container> containers = [];
      for (var row in rows)
      {
        containers.add(Container(color: Colors.white,child:row));
      }

      return containers;
    }
    else {
      return [];
    }
  }

   Future<void> _editFinnRowDialog(context, finn, project) {

    List <Row> rows = [];
    rows.add(const Row(children:[
                Expanded(flex:1, child: Padding(padding:EdgeInsets.all(10), child: Text('Financiador'))),
                Expanded(flex:1, child: Padding(padding:EdgeInsets.all(10), child: Text('Comentario'))),
                Expanded(flex:1, child: Padding(padding:EdgeInsets.all(10), child: Text('Cantidad'))),
              ]));
    for (var financier in project.financiers) {

      rows.add(Row(children:[
                  Expanded(flex:1, child: Padding(padding:EdgeInsets.all(10), child: Text(financier))),
                  Expanded(flex:1, child: Padding(padding:EdgeInsets.all(10), child: customTextField(TextEditingController(text:"",), 'Comentario'))),
          //        Expanded(flex:1, child: Padding(padding:EdgeInsets.all(10), child: TextField(decoration:InputDecoration(labelText:'Test'), inputFormatters: [FilteringTextInputFormatter.digitsOnly],))),
                  Expanded(flex:1, child: Padding(padding:EdgeInsets.all(10), child: customDoubleField(TextEditingController(text:""), 'Cantiidad'))),
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
          title: Card(color:Colors.blueGrey, child: Padding(padding:const EdgeInsets.all(10), 
            child:Text('${finn.name}. ${finn.description}', style:const TextStyle(fontWeight:FontWeight.bold, fontSize: 18, color: Colors.white))
            )),
          content: SingleChildScrollView(child: Column(children: rows ),),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                Future<List> aux = FinnContribution.getByFinnAndFinancier(finn.uuid, 'SIC4Changes');
                print("TEST");
                print(aux.then((value) => print(value)));
                for (Row row in rows.skip(1)) {
                  Text financier = (((row.children[0] as Expanded).child as Padding).child as Text);
                  TextEditingController subject = ((((row.children[1] as Expanded).child as Padding).child as SizedBox).child as TextField).controller as TextEditingController;
                  TextEditingController amount = ((((row.children[2] as Expanded).child as Padding).child as SizedBox).child as TextField).controller as TextEditingController;

                  try {

                    //FinnContribution item = FinnContribution("", financier.data.toString(), amount as double, finn, subject as String);
                    FinnContribution item = FinnContribution("496848bb-0cb2-4370-88f4-eb6b63302738", financier.data.toString(), double.parse(amount.text), finn.uuid, subject.text);
                   // item.save();
                    
                    print ("OK");
                  } on Exception catch (e) {
                    print ("ERROR");
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

List<FinnContribution> _getContribByFinn(String finnuuid)  {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<FinnContribution> items = [];
  final database = db.collection("s4c_finncontrib");
  final query = database.where("finn", isEqualTo: finnuuid).get().then(
    (querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final item = FinnContribution.fromJson(data);
        items.add(item);
      }
    }
  );
  return items;
}