import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';

const pageResultTitle = "Resultados";
List result_list = [];

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  void loadResults(value) async {
    await getGoalsByProject(value).then((val) {
      result_list = val;
      //print(contact_list);
    });
    setState(() {});
  }

  /*@override
  initState() {
    print("initState Called");
    //await getProjectByGoal
  }*/

  @override
  Widget build(BuildContext context) {
    final Goal? _goal;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _goal = args["goal"];
    } else {
      _goal = null;
    }

    if (_goal == null) return Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        resultPath(context, _goal),
        space(height: 20),
        resultHeader(context, _goal),
        marcoMenu(context, _goal, "marco"),
        Expanded(
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xffdfdfdf),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: resultList(context, _goal),
                )))
      ]),
    );
  }

/*-------------------------------------------------------------
                            RESULTS
-------------------------------------------------------------*/
  Widget resultPath(context, _goal) {
    return FutureBuilder(
        future: _goal.getProjectByGoal(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final _path = snapshot.data!;
            return pathHeader(context, _path);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget resultHeader(context, _goal) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: EdgeInsets.only(left: 40),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_goal.name, style: TextStyle(fontSize: 20)),
              space(height: 20),
              customLinearPercent(context, 1.5, 0.8, Colors.blue),
              space(height: 20)
            ]),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, _goal),
            returnBtn(context),
            //customRowPopBtn(context, "Volver", Icons.arrow_back)
          ],
        ),
      ),
    ]);
  }

  Widget addBtn(context, _goal) {
    return FilledButton(
      onPressed: () {
        _editResultDialog(context, null, _goal);
      },
      style: FilledButton.styleFrom(
        side: const BorderSide(width: 0, color: Color(0xffffffff)),
        backgroundColor: Color(0xffffffff),
      ),
      child: const Column(
        children: [
          Icon(Icons.add, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Añadir",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _saveResult(context, _result, _name, _desc, _indicator_text,
      _indicator_percent, _source, _goal) async {
    /*if (_result != null) {
      await updateResult(_result.id, _result.uuid, _name, _desc,
              _indicator_text, _indicator_percent, _source, _goal.uuid)
          .then((value) async {
        loadResults(_goal.uuid);
      });
    } else {
      await addResult(_name, _desc, _indicator_text, _indicator_percent,
              _source, _goal.uuid)
          .then((value) async {
        loadResults(_goal.uuid);
      });
    }*/
    if (_result != null) _result = Result(_goal);
    _goal.name = _name;
    _goal.description = _desc;
    _goal.indicator_text = _indicator_text;
    _goal.indicator_percent = _indicator_percent;
    _goal.source = _source;
    _goal.save();
    loadResults(_goal.uuid);
    Navigator.of(context).pop();
  }

  Future<void> _editResultDialog(context, _result, _goal) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    TextEditingController iTextController = TextEditingController(text: "");
    TextEditingController iPercentController = TextEditingController(text: "");
    TextEditingController sourceController = TextEditingController(text: "");

    if (_result != null) {
      nameController = TextEditingController(text: _result.name);
      descController = TextEditingController(text: _result.description);
      iTextController = TextEditingController(text: _result.indicator_text);
      iPercentController =
          TextEditingController(text: _result.indicator_percent.toString());
      sourceController = TextEditingController(text: _result.source);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        //bool _main = false;
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Result edit'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Nombre:", 16, textColor: Colors.blue),
                customTextField(nameController, "Nombre..."),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Descripción:", 16, textColor: Colors.blue),
                customTextField(descController, "Descripción..."),
              ]),
            ]),
            space(height: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Indicador:", 16, textColor: Colors.blue),
                customTextField(iTextController, "Indicador..."),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Porcentaje:", 16, textColor: Colors.blue),
                customDoubleField(iPercentController, "Porcentaje...")
              ]),
            ]),
            space(height: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Fuente:", 16, textColor: Colors.blue),
                customTextField(sourceController, "Fuente..."),
              ]),
            ])
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveResult(
                    context,
                    _goal,
                    nameController.text,
                    descController.text,
                    iTextController.text,
                    iPercentController.text,
                    sourceController.text,
                    _goal);
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

  Widget resultList(context, _goal) {
    return FutureBuilder(
        future: getResultsByGoal(_goal.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            result_list = snapshot.data!;
            if (result_list.length > 0) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: result_list.length,
                  itemBuilder: (BuildContext context, int index) {
                    Result _result = result_list[index];
                    return Container(
                      //height: 400,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Color(0xffdfdfdf), width: 2)),
                      ),
                      child: resultRow(context, _result, _goal),
                    );
                  });

              /*return Column(
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
                              itemCount: result_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                Result _result = result_list[index];
                                return Container(
                                  height: 400,
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  child: resultRow(context, _result, _goal),
                                );
                              })))
                ],
              );*/
            } else
              return Text("");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget resultRow(context, _result, _goal) {
    double _percent = 0;
    try {
      _percent = double.parse(_result.indicator_percent) / 100;
    } on Exception catch (_) {}

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_result.name}',
              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
            resultRowOptions(context, _result, _goal),
          ],
        ),
        space(height: 10),
        Text('${_result.description}'),
        space(height: 10),
        customRowDivider(),
        space(height: 10),
        Text(
          'Indicador del resultado',
          style: TextStyle(color: Colors.blueGrey, fontSize: 16),
        ),
        space(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_result.indicator_text}'),
            new CircularPercentIndicator(
              radius: 30.0,
              lineWidth: 8.0,
              percent: _percent,
              center: new Text(_percent.toString() + " %"),
              progressColor: Colors.lightGreen,
            ),
          ],
        ),
        space(height: 10),
        customRowDivider(),
        space(height: 10),
        Text(
          'Fuente',
          style: TextStyle(color: Colors.blueGrey, fontSize: 16),
        ),
        space(height: 10),
        Text('${_result.source}'),
      ],
    );
  }

  Widget resultRowOptions(context, _result, _goal) {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.abc),
          tooltip: 'Activities',
          onPressed: () {
            Navigator.pushNamed(context, "/activities",
                arguments: {'result': _result});
          }),
      IconButton(
          icon: const Icon(Icons.assignment_rounded),
          tooltip: 'Tasks',
          onPressed: () {
            Navigator.pushNamed(context, "/result_tasks",
                arguments: {'result': _result});
          }),
      IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () async {
            _editResultDialog(context, _result, _goal);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Remove',
          onPressed: () {
            _removeResultDialog(context, _result, _goal);
          }),
    ]);
  }

  Future<void> _removeResultDialog(context, _result, _goal) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Remove Result'),
          content: SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                _result.delete();
                loadResults(_goal.uuid);
                Navigator.of(context).pop();
                /*await deleteResult(id).then((value) {
                  loadResults(_goal.uuid);
                  Navigator.of(context).pop();
                  //Navigator.popAndPushNamed(context, "/goals", arguments: {});
                });*/
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
