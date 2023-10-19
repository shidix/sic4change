import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/services/firebase_service.dart';

const PROJECT_INFO_TITLE = "Detalles del Proyecto";

class ProjectInfoPage extends StatefulWidget {
  const ProjectInfoPage({super.key});

  @override
  State<ProjectInfoPage> createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          projectInfoHeader(context, _project),
          projectInfoMenu(context, _project),
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: projectInfoDetails(context, _project),
                  )))
        ],
      ),
    );
  }

  Widget projectInfoHeader(context, _project) {
    return Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_project.name, style: TextStyle(fontSize: 20)),
          space(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("En ejecución:", 16, textColor: Colors.green),
                    space(height: 5),
                    customLinearPercent(context, 2.3, 0.8, Colors.green),
                  ],
                ),
                space(width: 50),
                /* VerticalDivider(
                  width: 10,
                  color: Colors.grey,
                ),*/
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Presupuesto total:   ${_project.budget} €", 16),
                  space(height: 5),
                  customLinearPercent(context, 2.3, 0.8, Colors.blue),
                ]),
              ],
            ),
          ),
          Divider(color: Colors.grey),
        ]));
  }

  Widget projectInfoMenu(context, _project) {
    return Container(
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: [
            menuTabSelect(context, "Datos generales", "/project_info",
                {'project': _project}),
            menuTab(context, "Reformulaciones", "/project_info",
                {'project': _project}),
          ],
        ),
      ),
    );
  }

  Widget projectFinanciers(context, _project) {
    return Expanded(
        child: ListView.builder(
            //padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _project.financiers.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_project.financiers[index]}'),
                        /*IconButton(
                        icon: const Icon(
                          Icons.remove,
                          size: 12,
                        ),
                        tooltip: 'Eliminar financiador',
                        onPressed: () async {
                          _project.financiers.remove(_list[index]);
                          _removeFinancier(context, _project);
                        },
                      )*/
                      ]));
            }));
  }

  Widget projectManagerFinancer(context, _project) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Responsable del proyecto:", 16,
                      textColor: Colors.grey),
                  space(height: 5),
                  customText(_project.manager, 16),
                ],
              )),
          VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Programa:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(_project.programme, 16),
          ]),
        ],
      ),
    );
  }

  Widget projectInfoDates(context, _project) {
    /*return Row(
      children: [
        Container(
            width: MediaQuery.of(context).size.width / 6,
            child: Column(
              children: [
                customText("Fecha de aprobación", 16, textColor: Colors.grey),
                space(height: 5),
                customText("---", 16),
              ],
            )),
        Container(
            width: MediaQuery.of(context).size.width / 6,
            child: Column(
              children: [
                customText("Fecha de inicio", 16, textColor: Colors.grey),
                space(height: 5),
                customText("---", 16),
              ],
            )),
        Container(
            width: MediaQuery.of(context).size.width / 6,
            child: Column(
              children: [
                customText("Fecha de finalización", 16, textColor: Colors.grey),
                space(height: 5),
                customText("---", 16),
              ],
            )),
        Container(
            width: MediaQuery.of(context).size.width / 6,
            child: Column(
              children: [
                customText("Fecha de Justificación", 16,
                    textColor: Colors.grey),
                space(height: 5),
                customText("---", 16),
              ],
            )),
        Container(
            width: MediaQuery.of(context).size.width / 5,
            child: Column(
              children: [
                customText("Fecha de entrega de informes y seguimiento", 16,
                    textColor: Colors.grey),
                space(height: 5),
                customText("---", 16),
              ],
            ))
      ],
    );*/
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      //border: TableBorder.all(color: Colors.black),
      children: [
        TableRow(children: [
          customText("Fecha de aprobación", 16, textColor: Colors.grey),
          customText("Fecha de inicio", 16, textColor: Colors.grey),
          customText("Fecha de finalización", 16, textColor: Colors.grey),
          customText("Fecha de Justificación", 16, textColor: Colors.grey),
          customText("Fecha de entrega de informes y seguimiento", 16,
              textColor: Colors.grey),
        ]),
        TableRow(children: [
          customText("---", 16),
          customText("---", 16),
          customText("---", 16),
          customText("---", 16),
          customText("---", 16),
        ])
      ],
    );
  }

  Widget projectInfoDetails(context, _project) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            projectManagerFinancer(context, _project),
            space(height: 5),
            Divider(
              color: Colors.grey,
            ),
            space(height: 5),
            customText("Financiador/es:", 16, textColor: Colors.grey),
            projectFinanciers(context, _project),
            space(height: 5),
            Divider(
              color: Colors.grey,
            ),
            space(height: 5),
            customText("Breve descripción del proyecto:", 16,
                textColor: Colors.grey),
            space(height: 5),
            customText(_project.description, 16),
            space(height: 5),
            Divider(
              color: Colors.grey,
            ),
            space(height: 5),
            projectInfoDates(context, _project),
          ],
        ));
  }
}
