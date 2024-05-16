// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/projects_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/project_info_menu_widget.dart';

String s4cUuid = "b1b0c5a8-d0f0-4b43-a50b-33aef2249d00";
const projectInfoTitle = "Detalles del Proyecto";
//SProject? project;
bool projLoading = true;

class ProjectInfoPage extends StatefulWidget {
  final SProject? project;
  const ProjectInfoPage({super.key, this.project});

  @override
  State<ProjectInfoPage> createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
  SProject? project;

  void loadProject() async {
    setState(() {
      projLoading = false;
    });

    await project!.reload().then((val) {
      /*Navigator.popAndPushNamed(context, "/project_info",
          arguments: {"project": val});*/
      setState(() {
        project = val;
        projLoading = true;
      });
    });
  }

  @override
  initState() {
    super.initState();
    project = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    /*if (ModalRoute.of(context)!.settings.arguments != null) {
      Map args = ModalRoute.of(context)!.settings.arguments as Map;
      project = args["project"];
    } else {
      project = null;
    }

    if (project == null) return const Page404();*/

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          projectInfoHeader(context, project),
          profileMenu(context, project, "info"),
          projLoading
              ? contentTab(context, projectInfoDetails, {"project": project})
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget projectInfoHeader(context, project) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            customText(project.name, 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              addBtn(context, _callProjectEditDialog, project,
                  icon: Icons.edit, text: "Editar"),
              space(width: 10),
              //returnBtn(context),
              goPage(context, "Volver", const ProjectsPage(),
                  Icons.arrow_circle_left_outlined),
            ])
          ]),
          space(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("En ejecución:", 16),
                    space(height: 5),
                    customLinearPercent(context, 2.3, 0.8, percentBarPrimary),
                  ],
                ),
                space(width: 50),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Presupuesto total:   ${project.budget} €", 16),
                  space(height: 5),
                  customLinearPercent(context, 2.3, 0.8, blueColor),
                ]),
              ],
            ),
          ),
          space(height: 20)
        ]));
  }

  /*Widget projectInfoMenu(context, _project) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          menuTabSelect(context, "Datos generales", "/project_info",
              {'project': _project}),
          menuTab(context, "Comunicación con el financiador",
              "/project_reformulation", {'project': _project}),
        ],
      ),
    );
  }*/

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget projectManagerProgramme(context, _project) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 3.2,
              //width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Responsable del proyecto", 14,
                      bold: FontWeight.bold),
                  space(height: 5),
                  //customText(_project.managerObj.name, 14),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 3.2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Programa", 14, bold: FontWeight.bold),
                    space(height: 5),
                    customText(_project.programmeObj.name, 14),
                  ])),
          const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Estado", 14, bold: FontWeight.bold),
                    space(height: 5),
                    customText(_project.statusObj.name, 14),
                  ])),

          /*const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          space(width: 10),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar proyecto',
            onPressed: () {
              _callProjectEditDialog(context, _project);
            },
          )*/
        ],
      ),
    );
  }

  Widget projectAuditEvaluation(context, _project) {
    var audit = _project.audit == true ? "Si" : "No";
    var evaluation = _project.evaluation == true ? "Si" : "No";
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Auditoría", 14, bold: FontWeight.bold),
                  space(height: 5),
                  customText(audit, 14),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Evaluación", 14, bold: FontWeight.bold),
            space(height: 5),
            customText(evaluation, 14),
          ]),
        ],
      ),
    );
  }

  Widget projectFinanciersHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Financiador/es", 15, bold: FontWeight.bold),
      addBtnRow(context, callFinancierEditDialog, {"project": project},
          text: "Añadir financiador", icon: Icons.add_circle_outline),
      /*IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir financiador',
        onPressed: () {
          callFinancierEditDialog(context, _project);
        },
      )*/
    ]);
  }

  //Widget projectFinanciers(context, project) {
  Widget projectFinanciers(context) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: project!.financiersObj.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customText('${project?.financiersObj[index].name}', 14),
                    removeBtn(context, removeFinancierDialog,
                        {"financier": project?.financiersObj[index]})
                    /*IconButton(
                      icon: const Icon(
                        Icons.remove_circle,
                        size: 14,
                      ),
                      tooltip: 'Eliminar financiador',
                      onPressed: () async {
                        project!.financiers
                            .remove(project!.financiersObj[index].uuid);
                        project!.updateProjectFinanciers();
                        //loadProject(project);
                        //                    _removeFinancier(context, _project);
                      },
                    )*/
                  ]));
        });
  }

  Widget projectPartnersHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Socios", 15, bold: FontWeight.bold),
      addBtnRow(context, callPartnerEditDialog, {"project": project},
          text: "Añadir socio", icon: Icons.add_circle_outline),
      /*IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir socio',
        onPressed: () {
          callPartnerEditDialog(context, project);
        },
      )*/
    ]);
  }

  Widget projectPartners(context, project) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: project.partnersObj.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText('${project.partnersObj[index].name}', 14),
                removeBtn(context, removePartnerDialog,
                    {"partner": project?.partnersObj[index]}),
                /*IconButton(
                  icon: const Icon(
                    Icons.remove,
                    size: 12,
                  ),
                  tooltip: 'Eliminar financiador',
                  onPressed: () async {
                    project.partners.remove(project.partnersObj[index].uuid);
                    project.updateProjectPartners();
                    loadProject();
                  },
                )*/
              ]);
        });
  }

  Widget projectInfoDates(context, project) {
    return FutureBuilder(
        future: getProjectDatesByProject(project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            var dates = snapshot.data!;
            return Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                customText("Fechas", 15, bold: FontWeight.bold),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar fechas',
                  onPressed: () {
                    callDatesEditDialog(context, project);
                  },
                )
              ]),
              Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      customText("Aprobación", 14, bold: FontWeight.bold),
                      customText("Inicio", 14, bold: FontWeight.bold),
                      customText("Finalización", 14, bold: FontWeight.bold),
                      customText("Justificación", 14, bold: FontWeight.bold),
                      customText("Informes de seguimiento", 14,
                          bold: FontWeight.bold),
                    ]),
                    TableRow(children: [
                      customText(
                          DateFormat("dd-MM-yyyy").format(dates.approved), 14),
                      customText(
                          DateFormat("dd-MM-yyyy").format(dates.start), 14),
                      customText(
                          DateFormat("dd-MM-yyyy").format(dates.end), 14),
                      customText(
                          DateFormat("dd-MM-yyyy").format(dates.justification),
                          14),
                      customText(
                          DateFormat("dd-MM-yyyy").format(dates.delivery), 14),
                    ])
                  ]),
            ]);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget projectInfoLocation(context, project) {
    return FutureBuilder(
        future: getProjectLocationByProject(project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            var loc = snapshot.data!;
            return Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                customText("Ubicación", 15, bold: FontWeight.bold),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar ubicación',
                  onPressed: () {
                    _callLocationEditDialog(context, project);
                  },
                )
              ]),
              Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      customText("País", 14, bold: FontWeight.bold),
                      customText("Provincia", 14, bold: FontWeight.bold),
                      customText("Comunidad", 14, bold: FontWeight.bold),
                      customText("Municipio", 14, bold: FontWeight.bold),
                    ]),
                    TableRow(children: [
                      customText(loc.countryObj.name, 14),
                      customText(loc.provinceObj.name, 14),
                      customText(loc.regionObj.name, 14),
                      customText(loc.townObj.name, 14),
                    ])
                  ])
            ]);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget projectInfoDetails(context, args) {
    SProject proj = args["project"];
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                projectManagerProgramme(context, proj),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                customText("Breve descripción del proyecto", 14,
                    bold: FontWeight.bold),
                space(height: 5),
                customText(proj.description, 14),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                customText("Convocatoria", 14, bold: FontWeight.bold),
                space(height: 5),
                customText(proj.announcement, 14),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                customText("Ámbito del proyecto", 14, bold: FontWeight.bold),
                space(height: 5),
                customText(proj.ambit, 14),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectAuditEvaluation(context, proj),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectFinanciersHeader(context, proj),
                projectFinanciers(context),
                //projectFinanciers(context, proj),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectPartnersHeader(context, proj),
                projectPartners(context, proj),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectInfoDates(context, proj),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectInfoLocation(context, proj),
              ],
            )));
  }

/*--------------------------------------------------------------------*/
/*                           EDIT PROJECT                             */
/*--------------------------------------------------------------------*/
  // void _saveProject(context, project, _announcement, _ambit) async {
  //   //_project ??= SProject("", _name, _desc, _type, _budget, _manager,
  //   //    _programme, _announcement, _ambit, _audit, _evaluation);

  //   project.save();
  //   loadProject(project);
  // }

  void saveProject(List args) async {
    SProject proj = args[0];
    proj.save();
    loadProject();

    Navigator.pop(context);
  }

  void _callProjectEditDialog(context, project) async {
    List<KeyValue> ambits = await getAmbitsHash();
    List<KeyValue> types = await getProjectTypesHash();
    List<KeyValue> status = await getProjectStatusHash();
    List<KeyValue> contacts = await getContactsByOrgHash(s4cUuid);
    List<KeyValue> programmes = await getProgrammesHash();
    editProjectDialog(
        context, project, ambits, types, status, contacts, programmes);
  }

  Future<void> editProjectDialog(
      context, proj, ambits, types, status, contacts, programmes) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Project edit'),
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar proyecto'),
          content: SingleChildScrollView(
            child: Column(children: [
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Nombre',
                    size: 900,
                    minLines: 2,
                    maxLines: 9999,
                    initial: proj.name,
                    fieldValue: (String val) {
                      proj.name = val;
                      /*setState(() {
                        proj.name = val;
                      });*/
                    },
                  ),
                ]),
              ]),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Descripción',
                    size: 900,
                    minLines: 2,
                    maxLines: 9999,
                    initial: proj.description,
                    fieldValue: (String val) {
                      proj.description = val;
                      /*setState(() {
                        proj.description = val;
                      });*/
                    },
                  ),
                ]),
              ]),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Tipología',
                    size: 440,
                    selected: proj.typeObj.toKeyValue(),
                    options: types,
                    onSelectedOpt: (String val) {
                      proj.type = val;
                      /*setState(() {
                        proj.type = val;
                      });*/
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Presupuesto',
                    size: 440,
                    initial: proj.budget,
                    fieldValue: (String val) {
                      proj.budget = val;
                      /*setState(() {
                        proj.budget = val;
                      });*/
                    },
                  ),
                ]),
              ]),
              space(height: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Responsable',
                    size: 220,
                    selected: proj.managerObj.toKeyValue(),
                    options: contacts,
                    onSelectedOpt: (String val) {
                      proj.manager = val;
                      /*setState(() {
                        proj.manager = val;
                      });*/
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Programa',
                    size: 220,
                    selected: proj.programmeObj.toKeyValue(),
                    options: programmes,
                    onSelectedOpt: (String val) {
                      proj.programme = val;
                      /*setState(() {
                        proj.programme = val;
                      });*/
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Convocatoria',
                    size: 220,
                    initial: proj.announcement,
                    fieldValue: (String val) {
                      proj.announcement = val;
                      /*setState(() {
                        proj.announcement = val;
                      });*/
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Ámbito',
                    size: 220,
                    selected: proj.ambitObj.toKeyValue(),
                    options: ambits,
                    onSelectedOpt: (String val) {
                      proj.ambit = val;
                      /*setState(() {
                        proj.ambit = val;
                      });*/
                    },
                  ),

                  /*CustomTextField(
                    labelText: 'Ámbito',
                    size: 220,
                    initial: project.ambit,
                    fieldValue: (String val) {
                      setState(() {
                        project.ambit = val;
                      });
                    },
                  ),*/
                ]),
              ]),
              space(height: 20),
              Row(
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdown(
                          labelText: 'Estado',
                          size: 220,
                          selected: proj.statusObj.toKeyValue(),
                          options: status,
                          onSelectedOpt: (String val) {
                            proj.status = val;
                            /*setState(() {
                        proj.type = val;
                      });*/
                          },
                        ),
                      ]),
                  space(width: 20),
                  customText("Auditoría:", 16, textColor: Colors.blue),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: proj.audit,
                      onChanged: (bool? value) {
                        proj.audit = value!;
                        state.didChange(proj.audit);
                        /*setState(() {
                          state.didChange(proj.audit);
                        });*/
                      },
                    );
                  }),
                  space(width: 20),
                  customText("Evaluación:", 16, textColor: Colors.blue),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: proj.evaluation,
                      onChanged: (bool? value) {
                        proj.evaluation = value!;
                        state.didChange(proj.evaluation);
                        /*setState(() {
                          proj.evaluation = value!;
                          state.didChange(proj.evaluation);
                        });*/
                      },
                    );
                  }),
                ],
              )
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveProject, project)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           FINACIERS                                */
  /*--------------------------------------------------------------------*/
  void saveFinancier(List args) async {
    project!.updateProjectFinanciers();
    //Financier.getByUuid(args[0].text).then((value) {
    Organization.byUuid(args[0].text).then((value) {
      project?.financiersObj.add(value);
      setState(() {});
    });
    Navigator.pop(context);
  }

  void removeFinancierDialog(context, Map<String, dynamic> args) {
    Organization financier = args["financier"];
    customRemoveDialog(context, null, removeFinancier, financier);
  }

  void removeFinancier(financier) async {
    project!.financiers.remove(financier.uuid);
    project!.financiersObj.remove(financier);
    project!.updateProjectFinanciers();
    setState(() {});
    //loadProject();

    //project.updateProjectFinanciers();
    //loadProject(project);
  }

  void callFinancierEditDialog(context, Map<String, dynamic> args) async {
    SProject project = args["project"];
    //List<KeyValue> financiers = await getOrganizationsHash();
    List<KeyValue> financiers = await getFinanciersHash();
    editProjectFinancierDialog(context, project, financiers);
  }

  Future<void> editProjectFinancierDialog(context, project, financiers) {
    TextEditingController controller = TextEditingController(text: "");
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Añadir financiador'),
          content: SingleChildScrollView(
            child: Column(children: [
              CustomDropdown(
                labelText: 'Financiador',
                size: 220,
                selected: KeyValue("", ""),
                options: financiers,
                onSelectedOpt: (String val) {
                  project?.financiers.add(val);
                  controller.text = val;
                },
              ),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveFinancier, controller)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           PARTNERS                                 */
  /*--------------------------------------------------------------------*/
  /*void savePartner(List args) async {
    SProject project = args[0];
    project.updateProjectPartners();
    loadProject();
  }*/

  /*void _removePartner(context, project) async {
    project.updateProjectPartners();
    loadProject(project);
  }*/

  void savePartner(List args) async {
    project!.updateProjectPartners();
    Organization.byUuid(args[0].text).then((value) {
      project?.partnersObj.add(value);
      setState(() {});
    });
    Navigator.pop(context);
  }

  void removePartnerDialog(context, Map<String, dynamic> args) {
    customRemoveDialog(context, null, removePartner, args["partner"]);
  }

  void removePartner(partner) async {
    project!.partners.remove(partner.uuid);
    project!.partnersObj.remove(partner);
    project!.updateProjectPartners();
    setState(() {});
  }

  void callPartnerEditDialog(context, Map<String, dynamic> args) async {
    SProject project = args["project"];
    //List<KeyValue> contacts = await getContactsHash();
    //List<KeyValue> orgs = await getOrganizationsHash();
    List<KeyValue> orgs = await getPartnersHash();
    editProjectPartnerDialog(context, project, orgs);
    //editProjectPartnerDialog(context, project, contacts);
  }

  Future<void> editProjectPartnerDialog(context, project, orgs) {
    TextEditingController controller = TextEditingController(text: "");
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Añadir socio'),
          content: SingleChildScrollView(
            child: Column(children: [
              CustomDropdown(
                labelText: 'Socio',
                size: 220,
                selected: KeyValue("", ""),
                options: orgs,
                onSelectedOpt: (String val) {
                  project?.partners.add(val);
                  controller.text = val;
                  /*setState(() {
                    project?.partners.add(val);
                  });*/
                },
              ),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, savePartner, controller)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           DATES                                    */
  /*--------------------------------------------------------------------*/
  void saveDates(List args) async {
    ProjectDates dates = args[0];
    dates.save();
    loadProject();

    Navigator.pop(context);
  }

  void callDatesEditDialog(context, project) async {
    ProjectDates dates = await getProjectDatesByProject(project.uuid);
    editProjectDatesDialog(context, dates);
    /*await getProjectDatesByProject(project.uuid).then((value) async {
      editProjectDatesDialog(context, value);
    });*/
  }

  Future<void> editProjectDatesDialog(context, dates) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar fechas'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Aprobación',
                        selectedDate: dates.approved,
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            dates.approved = date;
                          });
                        },
                      )),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Inicio',
                        selectedDate: dates!.start,
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            dates!.start = date;
                          });
                        },
                      )),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Fin',
                        selectedDate: dates!.end,
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            dates!.end = date;
                          });
                        },
                      )),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Justificación',
                        selectedDate: dates!.justification,
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            dates!.justification = date;
                          });
                        },
                      )),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Informe de seguimiento',
                        selectedDate: dates!.delivery,
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            dates!.delivery = date;
                          });
                        },
                      )),
                ]),
                space(width: 20),
              ]),
            );
          }),
          actions: <Widget>[dialogsBtns(context, saveDates, dates)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           LOCATION                                 */
  /*--------------------------------------------------------------------*/
  void saveLocation(List args) async {
    ProjectLocation loc = args[0];
    loc.save();
    loadProject();

    Navigator.pop(context);
  }

  void _callLocationEditDialog(context, project) async {
    List<KeyValue> countries = await getCountriesHash();
    List<KeyValue> provinces = await getProvincesHash();
    List<KeyValue> regions = await getRegionsHash();
    List<KeyValue> towns = await getTownsHash();
    await getProjectLocationByProject(project.uuid).then((value) async {
      editProjectLocationDialog(
          context, value, project, countries, provinces, regions, towns);
    });
  }

  Future<void> editProjectLocationDialog(
      context, loc, project, countries, provinces, regions, towns) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Add location'),
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Añadir localización'),
          content: SingleChildScrollView(
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'País',
                  size: 220,
                  selected: loc.countryObj.toKeyValue(),
                  options: countries,
                  onSelectedOpt: (String val) {
                    setState(() {
                      loc.country = val;
                    });
                  },
                ),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Provincia',
                  size: 220,
                  selected: loc.provinceObj.toKeyValue(),
                  options: provinces,
                  onSelectedOpt: (String val) {
                    setState(() {
                      loc.province = val;
                    });
                  },
                ),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Comunidad',
                  size: 220,
                  selected: loc.regionObj.toKeyValue(),
                  options: regions,
                  onSelectedOpt: (String val) {
                    setState(() {
                      loc.region = val;
                    });
                  },
                ),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Municipio',
                  size: 220,
                  selected: loc.townObj.toKeyValue(),
                  options: towns,
                  onSelectedOpt: (String val) {
                    setState(() {
                      loc.town = val;
                    });
                  },
                ),
              ]),
              space(width: 20),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveLocation, loc)],
        );
      },
    );
  }
}

  /*Widget customDateField(context, dateController) {
    return SizedBox(
        width: 220,
        child: TextField(
          controller: dateController, //editing controller of this TextField
          decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Enter Date" //label text of field
              ),
          readOnly: true, //set it true, so that user will not able to edit text
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(
                    2000), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2101));

            if (pickedDate != null) {
              //print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);
              //print(formattedDate); //formatted date output using intl package =>  2021-03-16

              setState(() {
                dateController.text = formattedDate;
              });
            } else {}
          },
        ));
  }*/

