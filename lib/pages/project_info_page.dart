import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/firebase_service_location.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/services/firebase_service.dart';

const PROJECT_INFO_TITLE = "Detalles del Proyecto";
SProject? _project;

class ProjectInfoPage extends StatefulWidget {
  const ProjectInfoPage({super.key});

  @override
  State<ProjectInfoPage> createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
  void loadProject(id) async {
    await getProjectById(id).then((val) {
      Navigator.popAndPushNamed(context, "/project_info",
          arguments: {"project": val});
      /*setState(() {
        _project = val;
        print(_project?.announcement);
      });*/
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    child: projectInfoDetails(context),
                    //child: projectInfoDetails(context, _project),
                  ))),
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

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget projectManagerProgramme(context, _project) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width / 2.2,
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
          Container(
              width: MediaQuery.of(context).size.width / 2.2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Programa:", 16, textColor: Colors.grey),
                    space(height: 5),
                    customText(_project.programme, 16),
                  ])),
          VerticalDivider(
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
          )
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
          Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Necesita auditoría:", 16, textColor: Colors.grey),
                  space(height: 5),
                  customText(audit, 16),
                ],
              )),
          VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Necesita evaluación:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(evaluation, 16),
          ]),
        ],
      ),
    );
  }

  Widget projectFinanciersHeader(context, _project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Financiador/es:", 16, textColor: Colors.grey),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir financiador',
        onPressed: () {
          _callFinancierEditDialog(context, _project);
        },
      )
    ]);
  }

  Widget projectFinanciers(context, _project) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: NeverScrollableScrollPhysics(),
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
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar financiador',
                      onPressed: () async {
                        _project.financiers.remove(_project.financiers[index]);
                        _removeFinancier(context, _project);
                      },
                    )
                  ]));
        });
  }

  Widget projectPartnersHeader(context, _project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Socios:", 16, textColor: Colors.grey),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir socio',
        onPressed: () {
          _callPartnerEditDialog(context, _project);
        },
      )
    ]);
  }

  Widget projectPartners(context, _project) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _project.partners.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_project.partners[index]}'),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar financiador',
                      onPressed: () async {
                        _project.partners.remove(_project.partners[index]);
                        _removePartner(context, _project);
                      },
                    )
                  ]));
        });
  }

  Widget projectInfoDates(context, _project) {
    return FutureBuilder(
        future: getProjectDatesByProject(_project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            var _dates = snapshot.data!;
            return Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                customText("Fechas", 16, textColor: Colors.grey),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar fechas',
                  onPressed: () {
                    _callDatesEditDialog(context, _project);
                  },
                )
              ]),
              Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      customText("Fecha de aprobación", 16,
                          textColor: Colors.grey),
                      customText("Fecha de inicio", 16, textColor: Colors.grey),
                      customText("Fecha de finalización", 16,
                          textColor: Colors.grey),
                      customText("Fecha de Justificación", 16,
                          textColor: Colors.grey),
                      customText(
                          "Fecha de entrega de informes y seguimiento", 16,
                          textColor: Colors.grey),
                    ]),
                    TableRow(children: [
                      customText(_dates.approved, 16),
                      customText(_dates.start, 16),
                      customText(_dates.end, 16),
                      customText(_dates.justification, 16),
                      customText(_dates.delivery, 16),
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

  Widget projectInfoLocation(context, _project) {
    return FutureBuilder(
        future: getProjectLocationByProject(_project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            var _loc = snapshot.data!;
            return Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                customText("Fechas", 16, textColor: Colors.grey),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar ubicación',
                  onPressed: () {
                    _callLocationEditDialog(context, _project);
                  },
                )
              ]),
              Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      customText("Pais", 16, textColor: Colors.grey),
                      customText("Provincia", 16, textColor: Colors.grey),
                      customText("Comunidad", 16, textColor: Colors.grey),
                      customText("Municipio", 16, textColor: Colors.grey),
                    ]),
                    TableRow(children: [
                      customText(_loc.country, 16),
                      customText(_loc.province, 16),
                      customText(_loc.region, 16),
                      customText(_loc.town, 16),
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

  Widget projectInfoDetails(context) {
    return SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                projectManagerProgramme(context, _project),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                customText("Breve descripción del proyecto:", 16,
                    textColor: Colors.grey),
                space(height: 5),
                customText(_project?.description, 16),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                customText("Convocatoria:", 16, textColor: Colors.grey),
                space(height: 5),
                customText(_project?.announcement, 16),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                customText("Ambito del proyecto:", 16, textColor: Colors.grey),
                space(height: 5),
                customText(_project?.ambit, 16),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                projectAuditEvaluation(context, _project),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                projectFinanciersHeader(context, _project),
                projectFinanciers(context, _project),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                projectPartnersHeader(context, _project),
                projectPartners(context, _project),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                projectInfoDates(context, _project),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                projectInfoLocation(context, _project),
              ],
            )));
  }

/*--------------------------------------------------------------------*/
/*                           EDIT PROJECT                             */
/*--------------------------------------------------------------------*/
  void _saveProject(
      context,
      _project,
      _types,
      _contacts,
      _programmes,
      _name,
      _desc,
      _type,
      _budget,
      _manager,
      _programme,
      _announcement,
      _ambit,
      _audit,
      _evaluation) async {
    if (_project != null) {
      await updateProject(
              _project.id,
              _project.uuid,
              _name,
              _desc,
              _type,
              _budget,
              _manager,
              _programme,
              _announcement,
              _ambit,
              _audit,
              _evaluation,
              _project.financiers,
              _project.partners)
          .then((value) async {
        loadProject(_project.id);
      });
    } else {
      await addProject(_name, _desc, _type, _budget, _manager, _programme,
              _announcement, _ambit, false, false)
          .then((value) async {
        loadProject(_project.id);
      });
    }
    if (!_types.contains(_type)) await addProjectType(_type);
    if (!_contacts.contains(_manager)) {
      Contact _contact = Contact(_manager, "", "", "", "");
      _contact.save();
    }
    if (!_programmes.contains(_programme)) await addProgramme(_programme);
    Navigator.of(context).pop();
  }

  void _callProjectEditDialog(context, _project) async {
    List<String> types = [];
    List<String> contacts = [];
    List<String> programmes = [];
    await getProjectTypes().then((value) async {
      for (ProjectType item in value) {
        types.add(item.name);
      }
      await getContacts().then((value) async {
        for (Contact item2 in value) {
          contacts.add(item2.name);
        }
        await getProgrammes().then((value) async {
          for (Programme item3 in value) {
            programmes.add(item3.name);
          }
          _editProjectDialog(context, _project, types, contacts, programmes);
        });
      });
    });
  }

  Future<void> _editProjectDialog(
      context, _project, _types, _contacts, _programmes) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    TextEditingController typeController = TextEditingController(text: "");
    TextEditingController budgetController = TextEditingController(text: "");
    TextEditingController managerController = TextEditingController(text: "");
    TextEditingController programmeController = TextEditingController(text: "");
    TextEditingController announcementController =
        TextEditingController(text: "");
    TextEditingController ambitController = TextEditingController(text: "");
    bool _audit = false;
    bool _evaluation = false;

    if (_project != null) {
      nameController = TextEditingController(text: _project.name);
      descController = TextEditingController(text: _project.description);
      typeController = TextEditingController(text: _project.type);
      budgetController = TextEditingController(text: _project.budget);
      managerController = TextEditingController(text: _project.manager);
      programmeController = TextEditingController(text: _project.programme);
      announcementController =
          TextEditingController(text: _project.announcement);
      ambitController = TextEditingController(text: _project.ambit);
      _audit = _project.audit;
      _evaluation = _project.evaluation;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Project edit'),
          content: SingleChildScrollView(
            child: Column(children: [
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Nombre:", 16, textColor: Colors.blue),
                  customTextField(nameController, "Enter name"),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Descripción:", 16, textColor: Colors.blue),
                  customTextField(descController, "Enter description"),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Tipo de proyecto:", 16, textColor: Colors.blue),
                  customAutocompleteField(typeController, _types,
                      "Write or select project type..."),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Presupuesto:", 16, textColor: Colors.blue),
                  customTextField(budgetController, "Enter budget"),
                ]),
              ]),
              space(height: 20),
              Row(children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Responsable:", 16, textColor: Colors.blue),
                  customAutocompleteField(managerController, _contacts,
                      "Write or select manager..."),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Programa:", 16, textColor: Colors.blue),
                  customAutocompleteField(programmeController, _programmes,
                      "Write or select programme..."),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Convocatoria:", 16, textColor: Colors.blue),
                  customTextField(announcementController, "Enter country"),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Ámbito:", 16, textColor: Colors.blue),
                  customTextField(ambitController, "Enter ambit"),
                ]),
              ]),
              space(height: 20),
              Row(
                children: <Widget>[
                  customText("Auditoría:", 16, textColor: Colors.blue),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: _audit,
                      onChanged: (bool? value) {
                        setState(() {
                          _audit = value!;
                          state.didChange(_audit);
                        });
                      },
                    );
                  }),
                  space(width: 20),
                  customText("Evaluación:", 16, textColor: Colors.blue),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: _evaluation,
                      onChanged: (bool? value) {
                        setState(() {
                          _evaluation = value!;
                          state.didChange(_evaluation);
                        });
                      },
                    );
                  })
                ],
              )
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveProject(
                    context,
                    _project,
                    _types,
                    _contacts,
                    _programmes,
                    nameController.text,
                    descController.text,
                    typeController.text,
                    budgetController.text,
                    managerController.text,
                    programmeController.text,
                    announcementController.text,
                    ambitController.text,
                    _audit,
                    _evaluation);
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

  /*--------------------------------------------------------------------*/
  /*                           FINACIERS                                */
  /*--------------------------------------------------------------------*/
  void _saveFinancier(context, _project, _name, _financiers) async {
    _project.financiers.add(_name);
    await updateProjectFinanciers(_project.id, _project.financiers)
        .then((value) async {
      if (!_financiers.contains(_name)) await addFinancier(_name);
      loadProject(_project.id);
    });
    Navigator.of(context).pop();
  }

  void _removeFinancier(context, _project) async {
    await updateProjectFinanciers(_project.id, _project.financiers)
        .then((value) async {
      loadProject(_project.id);
    });
  }

  void _callFinancierEditDialog(context, _project) async {
    List<String> financiers = [];
    await getFinanciers().then((value) async {
      for (Financier item in value) {
        financiers.add(item.name);
      }

      _editProjectFinancierDialog(context, _project, financiers);
    });
  }

  Future<void> _editProjectFinancierDialog(context, _project, _financiers) {
    TextEditingController nameController = TextEditingController(text: "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Add financier'),
          content: SingleChildScrollView(
            child: Column(children: [
              customAutocompleteField(
                  nameController, _financiers, "Write or select financier..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveFinancier(
                    context, _project, nameController.text, _financiers);
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

  /*--------------------------------------------------------------------*/
  /*                           PARTNERS                                 */
  /*--------------------------------------------------------------------*/
  void _savePartner(context, _project, _name, _contacts) async {
    _project.partners.add(_name);
    await updateProjectPartners(_project.id, _project.partners)
        .then((value) async {
      if (!_contacts.contains(_name)) {
        Contact _contact = Contact(_name, "", "", "", "");
        _contact.save();
      }
      loadProject(_project.id);
    });
    Navigator.of(context).pop();
  }

  void _removePartner(context, _project) async {
    await updateProjectPartners(_project.id, _project.partners)
        .then((value) async {
      loadProject(_project.id);
    });
  }

  void _callPartnerEditDialog(context, _project) async {
    List<String> contacts = [];
    await getContacts().then((value) async {
      for (Contact item in value) {
        contacts.add(item.name);
      }

      _editProjectPartnerDialog(context, _project, contacts);
    });
  }

  Future<void> _editProjectPartnerDialog(context, _project, _contacts) {
    TextEditingController nameController = TextEditingController(text: "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Add partner'),
          content: SingleChildScrollView(
            child: Column(children: [
              customAutocompleteField(
                  nameController, _contacts, "Write or select contact..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _savePartner(context, _project, nameController.text, _contacts);
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

  /*--------------------------------------------------------------------*/
  /*                           DATES                                    */
  /*--------------------------------------------------------------------*/
  void _saveDates(context, _dates, _approved, _start, _end, _justification,
      _delivery, _project) async {
    await updateProjectDates(_dates.id, _dates.uuid, _approved, _start, _end,
            _justification, _delivery, _project.uuid)
        .then((value) async {
      loadProject(_project.id);
    });
    Navigator.of(context).pop();
  }

  void _callDatesEditDialog(context, _project) async {
    await getProjectDatesByProject(_project.uuid).then((value) async {
      if (value != null)
        _editProjectDatesDialog(context, value, _project);
      else {
        await addProjectDates("", "", "", "", "", _project.uuid)
            .then((valueAdd) async {
          await getProjectDatesByProject(_project.uuid)
              .then((valueDates) async {
            _editProjectDatesDialog(context, valueDates, _project);
          });
        });
      }
    });
  }

  Widget customDateField(context, dateController) {
    return SizedBox(
        width: 220,
        child: TextField(
          controller: dateController, //editing controller of this TextField
          decoration: InputDecoration(
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
            } else {
              print("Date is not selected");
            }
          },
        ));
  }

  Future<void> _editProjectDatesDialog(context, _dates, _project) {
    TextEditingController approvedController = TextEditingController(text: "");
    TextEditingController startController = TextEditingController(text: "");
    TextEditingController endController = TextEditingController(text: "");
    TextEditingController justificationController =
        TextEditingController(text: "");
    TextEditingController deliveryController = TextEditingController(text: "");
    if (_dates != null) {
      approvedController = TextEditingController(text: _dates.approved);
      startController = TextEditingController(text: _dates.start);
      endController = TextEditingController(text: _dates.end);
      justificationController =
          TextEditingController(text: _dates.justification);
      deliveryController = TextEditingController(text: _dates.delivery);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Add partner'),
          content: SingleChildScrollView(
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Fecha de aprobación:", 16, textColor: Colors.blue),
                customDateField(context, approvedController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Fecha de inicio:", 16, textColor: Colors.blue),
                customDateField(context, startController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Fecha de fin:", 16, textColor: Colors.blue),
                customDateField(context, endController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Fecha de justificación:", 16,
                    textColor: Colors.blue),
                customDateField(context, justificationController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Fecha de entrega:", 16, textColor: Colors.blue),
                customDateField(context, deliveryController),
              ]),
              space(width: 20),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveDates(
                    context,
                    _dates,
                    approvedController.text,
                    startController.text,
                    endController.text,
                    justificationController.text,
                    deliveryController.text,
                    _project);
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

  /*--------------------------------------------------------------------*/
  /*                           LOCATION                                 */
  /*--------------------------------------------------------------------*/
  void _saveLocation(context, _loc, _country, _province, _region, _town,
      _project, countries, provinces, regions, towns) async {
    await updateProjectLocation(_loc.id, _loc.uuid, _country, _province,
            _region, _town, _project.uuid)
        .then((value) async {
      loadProject(_project.id);
    });
    if (!countries.contains(_country)) await addCountry(_country);
    if (!provinces.contains(_province)) await addProvince(_province);
    if (!regions.contains(_region)) await addRegion(_region);
    if (!towns.contains(_town)) await addTown(_town);
    Navigator.of(context).pop();
  }

  void _callLocationEditDialog(context, _project) async {
    List<String> countries = [];
    List<String> provinces = [];
    List<String> regions = [];
    List<String> towns = [];

    await getCountries().then((valueCountries) async {
      for (Country item in valueCountries) {
        countries.add(item.name);
      }

      await getProvinces().then((valueProvinces) async {
        for (Province item in valueProvinces) {
          provinces.add(item.name);
        }

        await getRegions().then((valueRegions) async {
          for (Region item in valueRegions) {
            regions.add(item.name);
          }

          await getTowns().then((valueTowns) async {
            for (Town item in valueTowns) {
              towns.add(item.name);
            }

            await getProjectLocationByProject(_project.uuid)
                .then((value) async {
              if (value != null)
                _editProjectLocationDialog(context, value, _project, countries,
                    provinces, regions, towns);
              else {
                await addProjectLocation("", "", "", "", _project.uuid)
                    .then((valueAdd) async {
                  await getProjectLocationByProject(_project.uuid)
                      .then((valueLocation) async {
                    _editProjectLocationDialog(context, valueLocation, _project,
                        countries, provinces, regions, towns);
                  });
                });
              }
            });
          });
        });
      });
    });
  }

  Future<void> _editProjectLocationDialog(
      context, _loc, _project, countries, provinces, regions, towns) {
    TextEditingController countryController = TextEditingController(text: "");
    TextEditingController provinceController = TextEditingController(text: "");
    TextEditingController regionController = TextEditingController(text: "");
    TextEditingController townController = TextEditingController(text: "");
    if (_loc != null) {
      countryController = TextEditingController(text: _loc.country);
      provinceController = TextEditingController(text: _loc.province);
      regionController = TextEditingController(text: _loc.region);
      townController = TextEditingController(text: _loc.town);
    }

    print(countries);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Add location'),
          content: SingleChildScrollView(
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("País:", 16, textColor: Colors.blue),
                customAutocompleteField(countryController, countries, "País")
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Provincia:", 16, textColor: Colors.blue),
                customAutocompleteField(
                    provinceController, provinces, "Provincia")
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Comunidad:", 16, textColor: Colors.blue),
                customAutocompleteField(regionController, regions, "Comunidad")
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Municipio:", 16, textColor: Colors.blue),
                customAutocompleteField(townController, towns, "Municipio")
              ]),
              space(width: 20),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveLocation(
                    context,
                    _loc,
                    countryController.text,
                    provinceController.text,
                    regionController.text,
                    townController.text,
                    _project,
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
            ),
          ],
        );
      },
    );
  }
}
