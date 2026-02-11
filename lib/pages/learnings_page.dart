// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/learning_form.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_learning.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/marco_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/path_header_widget.dart';
import 'package:uuid/uuid.dart';

class LearningsPage extends StatefulWidget {
  final SProject? project;
  const LearningsPage({super.key, this.project});

  @override
  State<LearningsPage> createState() => _LearningsPageState();
}

class _LearningsPageState extends State<LearningsPage> {
  SProject? project;
  LearningInfo? learningInfo;
  Widget mainContainer = Container();
  Widget pathContainer = Container();
  Widget marcoContainer = Container();
  Widget footerContainer = Container();
  Widget learningsContainer = Container();
  Widget contentContainer = Container();

  @override
  initState() {
    project = widget.project;
    LearningInfo.byProject(project!.uuid).then((value) {
      learningInfo = value;
      mainContainer = mainMenu(context);
      pathContainer = pathHeader(context, project!.name);
      learningsContainer = learningsHeader(context, project);
      marcoContainer = marcoMenu(context, project, "learnings");
      contentContainer = contentTab(context, contentLearning, value);
      footerContainer = footer(context);
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
    createLog("Acceso a Aprendizajes de la iniciativa: ${project!.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        mainContainer,
        pathContainer,
        learningsContainer,
        marcoContainer,
        contentContainer,
        footerContainer,
      ]),
    ));
  }

/*-------------------------------------------------------------
                            RISKS
-------------------------------------------------------------*/
  Widget contentLearning(context, LearningInfo? learningIngo) {
    Widget learningTable = Container();

    if (learningInfo != null) {
      learningTable = Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              children: [
                    const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Text('Descripción',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Tipo de acción',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('Fecha',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(flex: 1, child: Text("")),
                          ],
                        )),
                    const Divider()
                  ] +
                  List.generate(
                      learningInfo!.items.length,
                      (index) => Container(
                          color: (index % 2 == 0)
                              ? Colors.grey[100]
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            child: Row(children: [
                              Expanded(
                                flex: 6,
                                child: Text(
                                    learningInfo!.items[index].description,
                                    maxLines: 10),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(learningInfo!.items[index].kind),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(DateFormat('dd/MM/yyyy').format(
                                    getDate(learningInfo!.items[index].date))),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    editBtn(context, learningEditDialog,
                                        {'index': index}),
                                    removeConfirmBtn(
                                        context, removeLearning, index),
                                  ],
                                ),
                              ),
                            ]),
                          )))));
    }

    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtnRow(context, learningEditDialog, {'index': -1}),
            space(width: 10),
          ],
        ),
      ),
      Row(children: [
        Expanded(
            flex: 1,
            child: (learningInfo!.items.isNotEmpty
                ? learningTable
                : const Padding(
                    padding: EdgeInsets.all(50),
                    child: Center(
                        child: Text("No hay aprendizajes registrados.")))))
      ]),
    ]);
  }

  Widget learningsHeader(context, project) {
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

  Future<void> learningEditDialog(context, args) async {
    int index = args['index'];
    Learning learning = (index == -1)
        ? Learning(const Uuid().v4(), project!.uuid, "", "", DateTime.now())
        : learningInfo!.items[index];

    return showDialog<Learning>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar(
              (index >= 0) ? 'Editando Aprendizaje' : 'Añadiendo Aprendizaje'),
          content: LearningForm(item: learning),
        );
      },
    ).then((value) {
      if (value != null) {
        learningInfo!.updateLearning(value);
        contentContainer = contentTab(context, contentLearning, learningInfo);

        setState(() {});
      }
    });
  }

  void removeLearning(context, index) {
    learningInfo!.removeLearning(learningInfo!.items[index]);
    contentContainer = contentTab(context, contentLearning, learningInfo);

    setState(() {});
  }
}
