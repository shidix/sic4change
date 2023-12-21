// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const projectInfoTitle = "Detalles del Proyecto";
SProject? project;
bool projLoading = true;

class ProjectInfoPage extends StatefulWidget {
  const ProjectInfoPage({super.key});

  @override
  State<ProjectInfoPage> createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
  void loadProject(project) async {
    setState(() {
      projLoading = false;
    });

    await project.reload().then((val) {
      Navigator.popAndPushNamed(context, "/project_info",
          arguments: {"project": val});
      setState(() {
        projLoading = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      project = args["project"];
    } else {
      project = null;
    }

    if (project == null) return const Page404();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          projectInfoHeader(context, project),
          projectInfoMenu(context, project),
          projLoading
              ? contentTab(context, projectInfoDetails, null)
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
              returnBtn(context),
            ])
          ]),
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
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Presupuesto total:   ${project.budget} €", 16),
                  space(height: 5),
                  customLinearPercent(context, 2.3, 0.8, Colors.blue),
                ]),
              ],
            ),
          ),
          space(height: 20)
        ]));
  }

  Widget projectInfoMenu(context, _project) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          menuTabSelect(context, "Datos generales", "/project_info",
              {'project': _project}),
          menuTab(context, "Reformulaciones", "/project_reformulation",
              {'project': _project}),
        ],
      ),
    );
  }

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget projectManagerProgramme(context, _project) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Responsable del proyecto:", 14,
                      bold: FontWeight.bold),
                  space(height: 5),
                  customText(_project.managerObj.name, 14),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Programa:", 14, bold: FontWeight.bold),
                    space(height: 5),
                    customText(_project.programmeObj.name, 14),
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
                  customText("Auditoría:", 14, bold: FontWeight.bold),
                  space(height: 5),
                  customText(audit, 14),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Evaluación:", 14, bold: FontWeight.bold),
            space(height: 5),
            customText(evaluation, 14),
          ]),
        ],
      ),
    );
  }

  Widget projectFinanciersHeader(context, _project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Financiador/es:", 15, bold: FontWeight.bold),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir financiador',
        onPressed: () {
          callFinancierEditDialog(context, _project);
        },
      )
    ]);
  }

  Widget projectFinanciers(context, project) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: project.financiersObj.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customText('${project.financiersObj[index].name}', 14),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar financiador',
                      onPressed: () async {
                        project.financiers
                            .remove(project.financiersObj[index].uuid);
                        project.updateProjectFinanciers();
                        loadProject(project);
                        //                    _removeFinancier(context, _project);
                      },
                    )
                  ]));
        });
  }

  Widget projectPartnersHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Socios:", 15, bold: FontWeight.bold),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir socio',
        onPressed: () {
          callPartnerEditDialog(context, project);
        },
      )
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
                IconButton(
                  icon: const Icon(
                    Icons.remove,
                    size: 12,
                  ),
                  tooltip: 'Eliminar financiador',
                  onPressed: () async {
                    project.partners.remove(project.partnersObj[index].uuid);
                    project.updateProjectPartners();
                    loadProject(project);
                  },
                )
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
                          DateFormat("yyyy-MM-dd").format(dates.approved), 14),
                      customText(
                          DateFormat("yyyy-MM-dd").format(dates.start), 14),
                      customText(
                          DateFormat("yyyy-MM-dd").format(dates.end), 14),
                      customText(
                          DateFormat("yyyy-MM-dd").format(dates.justification),
                          14),
                      customText(
                          DateFormat("yyyy-MM-dd").format(dates.delivery), 14),
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
                      customText("Pais", 14, bold: FontWeight.bold),
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
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                projectManagerProgramme(context, project),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                customText("Breve descripción del proyecto:", 14,
                    bold: FontWeight.bold),
                space(height: 5),
                customText(project?.description, 14),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                customText("Convocatoria:", 14, bold: FontWeight.bold),
                space(height: 5),
                customText(project?.announcement, 14),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                customText("Ambito del proyecto:", 14, bold: FontWeight.bold),
                space(height: 5),
                customText(project?.ambit, 14),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectAuditEvaluation(context, project),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectFinanciersHeader(context, project),
                projectFinanciers(context, project),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectPartnersHeader(context, project),
                projectPartners(context, project),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectInfoDates(context, project),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectInfoLocation(context, project),
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
    SProject project = args[0];
    project.save();

    Navigator.pop(context);
  }

  void _callProjectEditDialog(context, roject) async {
    List<KeyValue> types = await getProjectTypesHash();
    List<KeyValue> contacts = await getContactsHash();
    List<KeyValue> programmes = await getProgrammesHash();
    editProjectDialog(context, project, types, contacts, programmes);
  }

  Future<void> editProjectDialog(
      context, project, types, contacts, programmes) {
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
                    size: 220,
                    initial: project.name,
                    fieldValue: (String val) {
                      setState(() {
                        project.name = val;
                      });
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Descripción',
                    size: 220,
                    initial: project.description,
                    fieldValue: (String val) {
                      setState(() {
                        project.description = val;
                      });
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Tipo de proyecto',
                    size: 220,
                    selected: project.typeObj.toKeyValue(),
                    options: types,
                    onSelectedOpt: (String val) {
                      setState(() {
                        project.type = val;
                      });
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Presupuesto',
                    size: 220,
                    initial: project.budget,
                    fieldValue: (String val) {
                      setState(() {
                        project.budget = val;
                      });
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
                    selected: project.managerObj.toKeyValue(),
                    options: contacts,
                    onSelectedOpt: (String val) {
                      setState(() {
                        project.manager = val;
                      });
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Programa',
                    size: 220,
                    selected: project.programmeObj.toKeyValue(),
                    options: programmes,
                    onSelectedOpt: (String val) {
                      setState(() {
                        project.programme = val;
                      });
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Convocatoria',
                    size: 220,
                    initial: project.announcement,
                    fieldValue: (String val) {
                      setState(() {
                        project.announcement = val;
                      });
                    },
                  ),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Ámbito',
                    size: 220,
                    initial: project.ambit,
                    fieldValue: (String val) {
                      setState(() {
                        project.ambit = val;
                      });
                    },
                  ),
                ]),
              ]),
              space(height: 20),
              Row(
                children: <Widget>[
                  customText("Auditoría:", 16, textColor: Colors.blue),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: project.audit,
                      onChanged: (bool? value) {
                        setState(() {
                          project.audit = value!;
                          state.didChange(project.audit);
                        });
                      },
                    );
                  }),
                  space(width: 20),
                  customText("Evaluación:", 16, textColor: Colors.blue),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: project.evaluation,
                      onChanged: (bool? value) {
                        setState(() {
                          project.evaluation = value!;
                          state.didChange(project.evaluation);
                        });
                      },
                    );
                  })
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
    SProject project = args[0];
    project.updateProjectFinanciers();
    loadProject(project);
  }

  /*void _removeFinancier(context, project) async {
    project.updateProjectFinanciers();
    loadProject(project);
  }*/

  void callFinancierEditDialog(context, project) async {
    List<KeyValue> financiers = await getFinanciersHash();
    editProjectFinancierDialog(context, project, financiers);
  }

  Future<void> editProjectFinancierDialog(context, project, financiers) {
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
                  setState(() {
                    project?.financiers.add(val);
                  });
                },
              ),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveFinancier, project)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           PARTNERS                                 */
  /*--------------------------------------------------------------------*/
  void savePartner(List args) async {
    SProject project = args[0];
    project.updateProjectPartners();
    loadProject(project);
  }

  /*void _removePartner(context, project) async {
    project.updateProjectPartners();
    loadProject(project);
  }*/

  void callPartnerEditDialog(context, project) async {
    List<KeyValue> contacts = await getContactsHash();
    editProjectPartnerDialog(context, project, contacts);
  }

  Future<void> editProjectPartnerDialog(context, project, contacts) {
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
                options: contacts,
                onSelectedOpt: (String val) {
                  setState(() {
                    project?.partners.add(val);
                  });
                },
              ),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, savePartner, project)],
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
    loadProject(project);
  }

  void callDatesEditDialog(context, project) async {
    await getProjectDatesByProject(project.uuid).then((value) async {
      editProjectDatesDialog(context, value);
    });
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

  Future<void> editProjectDatesDialog(context, dates) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar fechas'),
          content: SingleChildScrollView(
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /*customText("Fecha de aprobación:", 16, textColor: Colors.blue),
                customDateField(context, approvedController),*/
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
                /*customText("Fecha de inicio:", 16, textColor: Colors.blue),
                customDateField(context, startController),*/
                SizedBox(
                    width: 220,
                    child: DateTimePicker(
                      labelText: 'Inicio',
                      selectedDate: dates.start,
                      onSelectedDate: (DateTime date) {
                        setState(() {
                          dates.start = date;
                        });
                      },
                    )),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /*customText("Fecha de fin:", 16, textColor: Colors.blue),
                customDateField(context, endController),*/
                SizedBox(
                    width: 220,
                    child: DateTimePicker(
                      labelText: 'Fin',
                      selectedDate: dates.end,
                      onSelectedDate: (DateTime date) {
                        setState(() {
                          dates.end = date;
                        });
                      },
                    )),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /*customText("Fecha de justificación:", 16,
                    textColor: Colors.blue),
                customDateField(context, justificationController),*/
                SizedBox(
                    width: 220,
                    child: DateTimePicker(
                      labelText: 'Justificación',
                      selectedDate: dates.justification,
                      onSelectedDate: (DateTime date) {
                        setState(() {
                          dates.justification = date;
                        });
                      },
                    )),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /*customText("Fecha de entrega:", 16, textColor: Colors.blue),
                customDateField(context, deliveryController),*/
                SizedBox(
                    width: 220,
                    child: DateTimePicker(
                      labelText: 'Informe de seguimiento',
                      selectedDate: dates.delivery,
                      onSelectedDate: (DateTime date) {
                        setState(() {
                          dates.delivery = date;
                        });
                      },
                    )),
              ]),
              space(width: 20),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveDates, dates)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           LOCATION                                 */
  /*--------------------------------------------------------------------*/
  /*void _saveLocation(context, _loc, _country, _province, _region, _town,
      _project, countries, provinces, regions, towns) async {
    _loc.country = _country;
    _loc.province = _province;
    _loc.region = _region;
    _loc.town = _town;
    _loc.save();
    if (!countries.contains(_country)) {
      Country _c = Country(_country);
      _c.save();
    }
    if (!provinces.contains(_province)) {
      Province _p = Province(_province);
      _p.save();
    }
    if (!regions.contains(_region)) {
      Region _r = Region(_region);
      _r.save();
    }
    if (!towns.contains(_town)) {
      Town _t = Town(_town);
      _t.save();
    }
    loadProject(_project);
    //Navigator.of(context).pop();
  }*/
  void saveLocation(List args) async {
    ProjectLocation loc = args[0];
    loc.save();
    loadProject(project);
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

    /*await getCountries().then((valueCountries) async {
      for (Country item in valueCountries) {
        countries.add(item.toKeyValue());
      }

      await getProvinces().then((valueProvinces) async {
        for (Province item in valueProvinces) {
          provinces.add(item.toKeyValue());
        }

        await getRegions().then((valueRegions) async {
          for (Region item in valueRegions) {
            regions.add(item.toKeyValue());
          }

          await getTowns().then((valueTowns) async {
            for (Town item in valueTowns) {
              towns.add(item.toKeyValue());
            }

            await getProjectLocationByProject(_project.uuid)
                .then((value) async {
              // if (value == null) {
              //   value = ProjectLocation(_project.uuid);
              //   value.save();
              // }

              _editProjectLocationDialog(context, value, _project, countries,
                  provinces, regions, towns);
            });
          });
        });
      });
    });*/
  }

  Future<void> editProjectLocationDialog(
      context, loc, project, countries, provinces, regions, towns) {
    /*TextEditingController countryController = TextEditingController(text: "");
    TextEditingController provinceController = TextEditingController(text: "");
    TextEditingController regionController = TextEditingController(text: "");
    TextEditingController townController = TextEditingController(text: "");
    if (loc != null) {
      countryController = TextEditingController(text: loc.country);
      provinceController = TextEditingController(text: loc.province);
      regionController = TextEditingController(text: loc.region);
      townController = TextEditingController(text: loc.town);
    }*/

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
                /*customText("País:", 16, textColor: Colors.blue),
                customDropdownField(
                  countryController,
                  countries,
                  loc.countryObj.toKeyValue(),
                  "Seleccione país",
                ),*/
                //customAutocompleteField(countryController, countries, "País")
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

                /*customText("Provincia:", 16, textColor: Colors.blue),
                customDropdownField(
                  provinceController,
                  provinces,
                  loc.provinceObj.toKeyValue(),
                  "Seleccione provincia",
                ),*/
                /*customAutocompleteField(
                    provinceController, provinces, "Provincia")*/
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

                /*customText("Comunidad:", 16, textColor: Colors.blue),
                customDropdownField(
                  regionController,
                  regions,
                  loc.regionObj.toKeyValue(),
                  "Seleccione provincia",
                ),*/
                //customAutocompleteField(regionController, regions, "Comunidad")
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

                /*customText("Municipio:", 16, textColor: Colors.blue),
                customDropdownField(
                  townController,
                  towns,
                  loc.townObj.toKeyValue(),
                  "Seleccione provincia",
                ),*/
                //customAutocompleteField(townController, towns, "Municipio")
              ]),
              space(width: 20),
            ]),
          ),
          actions: <Widget>[
            dialogsBtns(context, saveLocation, loc)
            /*TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveLocation(
                    context,
                    loc,
                    countryController.text,
                    provinceController.text,
                    regionController.text,
                    townController.text,
                    project,
                    countries,
                    provinces,
                    regions,
                    towns);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),*/
          ],
        );
      },
    );
  }
}
