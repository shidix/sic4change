import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/firebase_service.dart';
import 'package:sic4change/services/models.dart';
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
      //print(contact_list);
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
      //initialData:getFinnsByProject(project.uuid),
      future:getFinnsByProject(project.uuid),
      builder: ((context, snapshot) {   
        const TextStyle headerList =  TextStyle(fontFamily: 'Readex Pro', fontSize: 18, fontWeight: FontWeight.bold,);
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
                      decoration: BoxDecoration( shape: BoxShape.rectangle, ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded( child: Align( alignment: AlignmentDirectional(-1.00, -1.00), child: Text( 'Presupuesto Total', style: TextStyle( fontFamily: 'Readex Pro', fontSize: 18, ), ), ), ),
                                Expanded( child: Align( alignment: AlignmentDirectional( 1.00, -1.00), child: Padding(padding: const EdgeInsets.only(right:100), child:Text( '70.702,01 €', style: TextStyle( fontFamily: 'Readex Pro', fontSize: 18, ), ), ), ),),
                              ],
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: LinearPercentIndicator(
                                percent: 0.5,
                                width: MediaQuery.sizeOf(context).width * 0.40,
                                lineHeight: 12,
                                animation: true,
                                animateFromLastPercent: true,
                                progressColor: Color(0xFF00809A),
                                backgroundColor: Color(0xFFEBECEF),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const Align(
                              alignment: AlignmentDirectional(-1.00, 0.00),
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
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
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.5,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 20, 0),
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
                                            alignment: const AlignmentDirectional( 0.00, -1.00),
                                            child: LinearPercentIndicator(
                                              percent: 0.5,
                                              width: MediaQuery.sizeOf(context) .width * 0.15,
                                              lineHeight: 15,
                                              animation: true,
                                              animateFromLastPercent: true,
                                              progressColor: const Color(0xFF00809A),
                                              backgroundColor: const Color(0xFFEBECEF),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: AlignmentDirectional( 1.00, -1.00),
                                            child: Text( '10.000,00 €', textAlign: TextAlign.start, style: TextStyle( backgroundColor: Color(0xffffffff)), ),
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
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(flex: 6, child: Text('Partidas', textAlign: TextAlign.center, style: headerList,),),
              Expanded(flex: 8, child: Text('Aportes', textAlign: TextAlign.center, style: headerList,),),
              Expanded( flex: 6, child: Text( 'Distribución aporte CM', textAlign: TextAlign.center, style: headerList, ), ),
              Expanded(flex:1,  child:Padding(padding: EdgeInsets.only(top:10), child:Text(''),),),
            ],
          ),
        ),
        Padding(
          padding:const EdgeInsets.only(top:20), 
        child:
          Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 2,
              child: ListView(
                  padding: EdgeInsets.zero,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: mylist(snapshot.data, project),
                ),
            ),
          ],
        ),
        ),
      ],
    );
      })
  );
  }

  List<Row> mylist(data, project)
  {
   // loadFinns(project.uuid);
    print (project.financiers);
    ElevatedButton button = ElevatedButton(
      onPressed: () {_editFinnDialog(context, null, null);},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: const Icon(Icons.edit, color: Colors.black54, size: 20,),
    );
    List<Row> rows = [];
    List<Expanded> cells = [];
    List<List <String>> list = [
                          ['', 'Total', 'CM', 'S4C', 'FVMG', 'Madres Guía', 'Total', 'S4C', 'FVMG'],
                          // ['B.3.1. Funcionamiento, Materiales y suministros no inventariables','15855','15855','0','0','15855','5767','10088' ],
                          // ['B.3.2. Funcionamiento, Materiales y suministros no inventariables','15855','15855','0','0','15855','5767','10088' ],
                          // ['B.3.3. Funcionamiento, Materiales y suministros no inventariables','15855','15855','0','0','15855','5767','10088' ],
                          // ['B.3.4. Funcionamiento, Materiales y suministros no inventariables','15855','15855','0','0','15855','5767','10088' ],
                          // ['B.3.1. Funcionamiento, Materiales y suministros no inventariables','15855','15855','0','0','15855','5767','10088' ],
                          // ['B.3.2. Funcionamiento, Materiales y suministros no inventariables','15855','15855','0','0','15855','5767','10088' ],
                          // ['B.3.3. Funcionamiento, Materiales y suministros no inventariables','15855','15855','0','0','15855','5767','10088' ],
                          // ['B.3.4. Funcionamiento, Materiales y suministros no inventariables','15855','15855','0','0','15855','5767','10088' ],
                          ];

    if (data != null) {
      for (var i in data) {
        list.add(["${i.name} ${i.description}", '15855','15855','0','0','0','15855','5767','10088']);
      }
    }
    int rowsindex = 0;
    for (var row in list) {
      cells = [];
      int counter=0;
      TextStyle style = const TextStyle();
      if (rowsindex == 0) { style = const TextStyle(fontWeight: FontWeight.bold);}
      var textAlign = TextAlign.center;
      for (String i in row) {
        //print(i);
        int flex = 2;

        if (counter == 0) { 
          flex = 6; textAlign = TextAlign.left;
        }
        else {
          flex = 2; textAlign = TextAlign.center;
        }

        cells.add(Expanded(flex:flex,  child:Padding(padding: const EdgeInsets.only(top:10), child:Text(i,textAlign: textAlign,style:style,),),));
        counter += 1;
      }
      if ( rowsindex > 0 ) {
        cells.add(Expanded(flex:1,  child:Padding(padding: const EdgeInsets.only(top:10), child:button))); 
      }
      else {
        cells.add(Expanded(flex:1,  child:Padding(padding: const EdgeInsets.only(top:10), child:Text('',textAlign: textAlign,style:style,),),));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.max, children: cells, ),);
      rowsindex += 1;
    }
    return rows;
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
