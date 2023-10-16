import 'dart:collection';
import 'dart:html';

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
      body: 

         Column(children: [
         mainMenu(context),
         finnHeader(context, _project),
         finnStatus(context, _project),
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

  Widget finnStatus(context, project) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: AlignmentDirectional(-1.00, -1.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(60, 30, 60, 0),
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * 0.1,
                decoration: BoxDecoration(
                  //color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.00, -1.00),
                      child: Text(
                        'Gestión Económica',
                        style: TextStyle(
                              fontFamily: 'Readex Pro',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(-1.00, 0.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(60, 0, 0, 0),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.25,
                height: MediaQuery.sizeOf(context).height * 0.1,
                decoration: BoxDecoration(
                  //color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Align(
                  alignment: AlignmentDirectional(-1.00, -1.00),
                  child: Stack(
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.00, -1.00),
                        child: Text(
                          'Presupuesto Total',
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(1.00, -1.00),
                        child: Text(
                          '70.702,01 €',
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-1.00, 0.00),
                        child: LinearPercentIndicator(
                          percent: 0.5,
                          width: MediaQuery.sizeOf(context).width * 0.25,
                          lineHeight: 12,
                          animation: true,
                          animateFromLastPercent: true,
                          // progressColor: FlutterFlowTheme.of(context).secondary,
                          // backgroundColor:
                          //     FlutterFlowTheme.of(context).secondaryText,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-1.00, 1.00),
                        child: Text(
                          '50% (de ejecución económica)',
                          style: TextStyle(
                                fontFamily: 'Readex Pro',
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(60, 0, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [],
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [],
                ),
              ],
            ),
          ),
        ],
      );
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
                              if (_finn.parent == "")
                                return Container(
                                  height: 100,
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  child: finnRowMain(context, _finn, _project),
                                );
                              else
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
