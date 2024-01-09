import 'package:flutter/material.dart';
import 'package:sic4change/pages/finns_page.dart';
import 'package:sic4change/pages/goals_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const projectTitle = "Proyectos";

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key, this.prList});

  final List? prList;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List prList = [];
  List programList = [];

  void loadProgrammes() async {
    await getProgrammes().then((val) {
      programList = val;
    });
    setState(() {});
  }

  void loadProjects() async {
    await getProjects().then((val) {
      prList = val;
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getProjects().then((val) {
      if (mounted) {
        setState(() {
          prList = val;
        });
        for (SProject item in prList) {
          item.loadObjs().then((value) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context, null, "/projects"),
          projectSearch(),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "PROGRAMAS")),
          programmeList(context),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "INICIATIVAS")),
          projectList(context),
        ],
      ),
    ));
  }

  Widget projectSearch() {
    return Container(
        padding: const EdgeInsets.only(left: 20, top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(projectTitle, style: headerTitleText),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              addBtn(context, callDialog, {"programme": null},
                  text: "Añadir Programa"),
              space(width: 10),
              addBtn(context, callProjectDialog, {"programme": null},
                  text: "Añadir Iniciativa"),
            ])
            /*Container(
          width: 500,
          child: SearchBar(
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 10.0)),
            onTap: () {},
            onChanged: (_) {},
            leading: const Icon(Icons.search),
          ),
        ),*/
          ],
        ));
  }

/*-------------------------------------------------------------
                     PROGRAMMES
-------------------------------------------------------------*/
  Widget programmeList(context) {
    return Container(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: FutureBuilder(
            future: getProgrammes(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                programList = snapshot.data!;
                return SizedBox(
                    height: 150,
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          //crossAxisSpacing: 20,
                          //mainAxisSpacing: 20,
                          childAspectRatio: 2,
                        ),
                        itemCount: programList.length,
                        itemBuilder: (_, index) {
                          Programme programme = programList[index];
                          if (programme.logo != "") {
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.network(programme.logo),
                                  editBtn(context, callDialog,
                                      {'programme': programme}),
                                ]);
                          } else {
                            return Column(children: [
                              Row(
                                children: [
                                  customText(programme.name, 15,
                                      bold: FontWeight.bold),
                                  customText(
                                      " ('${programme.projects}' proyectos)",
                                      15),
                                  editBtn(context, callDialog,
                                      {'programme': programme})
                                ],
                              )
                            ]);
                          }
                        }));
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            })));
  }

  void callDialog(context, args) {
    programmeEditDialog(context, args["programme"]);
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  void saveProgramme(List args) async {
    Programme programme = args[0];
    programme.save();
    loadProgrammes();
    Navigator.pop(context);
  }

  Future<void> programmeEditDialog(context, programme) {
    programme ??= Programme("");

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Modificar programa'),
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar programa'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 600,
                  child: TextFormField(
                    initialValue: (programme.name != "") ? programme.name : "",
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (val) => setState(() => programme.name = val),
                  ),
                ),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                //customText("Logo:", 16, textColor: titleColor),
                //customTextField(logoController, "Logo", size: 600),
                SizedBox(
                  width: 600,
                  child: TextFormField(
                    initialValue: (programme.logo != "") ? programme.logo : "",
                    decoration: const InputDecoration(labelText: 'Logo'),
                    onChanged: (val) => setState(() => programme.logo = val),
                  ),
                ),
              ]),
            ]),
          ])),
          actions: <Widget>[
            Row(children: [
              Expanded(
                flex: 5,
                child: actionButton(context, "Enviar", saveProgramme,
                    Icons.save_outlined, [programme]),
              ),
              space(width: 10),
              Expanded(
                  flex: 5,
                  child: actionButton(
                      context, "Cancelar", cancelItem, Icons.cancel, context))
            ]),
          ],
        );
      },
    );
  }

/*-------------------------------------------------------------
                     PROJECTS
-------------------------------------------------------------*/
  Widget projectList(context) {
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Builder(builder: ((context) {
          if (prList.isNotEmpty) {
            return SizedBox(
                height: 900,
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: prList.length,
                    itemBuilder: (_, index) {
                      return projectCard(context, prList[index]);
                    }));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        })));
  }

  // Widget projectList2(context) {
  //   return Container(
  //       padding: const EdgeInsets.only(left: 20, right: 20),
  //       child: FutureBuilder(
  //           future: getProjects(),
  //           builder: ((context, snapshot) {
  //             if (snapshot.hasData) {
  //               prList = snapshot.data!;
  //               return SizedBox(
  //                   height: 900,
  //                   child: GridView.builder(
  //                       gridDelegate:
  //                           const SliverGridDelegateWithFixedCrossAxisCount(
  //                         crossAxisCount: 2,
  //                         crossAxisSpacing: 10,
  //                         mainAxisSpacing: 10,
  //                         childAspectRatio: .9,
  //                       ),
  //                       itemCount: prList.length,
  //                       itemBuilder: (_, index) {
  //                         return projectCard(context, prList[index]);
  //                       }));
  //             } else {
  //               return const Center(
  //                 child: CircularProgressIndicator(),
  //               );
  //             }
  //           })));
  // }

  Widget projectCard(context, _project) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: projectCardDatas(context, _project),
      /*child: SingleChildScrollView(
        child: projectCardDatas(context, _project),
      ),*/
    );
  }

  Widget projectCardDatasHeader(context, _project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _project.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              _project.typeObj.name.toUpperCase(),
              style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
            ),

            /*IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar proyecto',
              onPressed: () {
                _callProjectEditDialog(context, _project);
              },
            ),*/
          ],
        ),
        space(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            _project.description,
            style: const TextStyle(fontSize: 15),
          ),
        ]),
      ],
    );
  }

  Widget projectCardDatasFinancier(SProject project) {
    List list = project.financiers;
    List financiers = [];
    if (project.financiersObj.isNotEmpty) {
      for (var uuid in list) {
        financiers
            .add((getObject(project.financiersObj, uuid) as Financier).name);
      }
    }

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        customText("Financiador/es:", 16, textColor: Colors.grey),
        /*IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Añadir financiador',
          onPressed: () {
            _callFinancierEditDialog(context, _project);
          },
        )*/
      ]),
      Row(
        children: [Text(financiers.join(', '))],
      )
      // ListView.builder(
      //     //padding: const EdgeInsets.all(8),
      //     scrollDirection: Axis.vertical,
      //     shrinkWrap: true,
      //     itemCount: _list.length,
      //     itemBuilder: (BuildContext context, int index) {
      //       return Container(
      //           padding: const EdgeInsets.all(5),
      //           child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text((getObject(_project.financiersObj, _list[index])
      //                         as Financier)
      //                     .name),
      //                 /*IconButton(
      //                   icon: const Icon(
      //                     Icons.remove,
      //                     size: 12,
      //                   ),
      //                   tooltip: 'Eliminar financiador',
      //                   onPressed: () async {
      //                     _project.financiers.remove(_list[index]);
      //                     _removeFinancier(context, _project);
      //                   },
      //                 )*/
      //               ]));
      //     })
    ]);
  }

  Widget projectCardDatasPartners(SProject _project) {
    List list = _project.partners;
    List partners = [];
    if (_project.partnersObj.isNotEmpty) {
      for (var uuid in list) {
        partners.add((getObject(_project.partnersObj, uuid) as Contact).name);
      }
    }

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        customText("Socios del proyecto/programa:", 16, textColor: Colors.grey),
        /*IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Añadir socio',
          onPressed: () {
            _callPartnerEditDialog(context, _project);
          },
        )*/
      ]),
      Row(children: [
        Text(
          partners.join(", "),
        )
      ]),
      // ListView.builder(
      //     //padding: const EdgeInsets.all(8),
      //     scrollDirection: Axis.vertical,
      //     shrinkWrap: true,
      //     itemCount: _list.length,
      //     itemBuilder: (BuildContext context, int index) {
      //       return Container(
      //           padding: EdgeInsets.all(5),
      //           child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Text((getObject(_project.partnersObj, _list[index])
      //                         as Contact)
      //                     .name),
      //                 /*IconButton(
      //                   icon: const Icon(
      //                     Icons.remove,
      //                     size: 12,
      //                   ),
      //                   tooltip: 'Eliminar socio',
      //                   onPressed: () async {
      //                     _project.partners.remove(_list[index]);
      //                     _removePartner(context, _project);
      //                   },
      //                 )*/
      //               ]));
      //     })
    ]);
  }

  Widget projectCardDatas(context, project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        projectCardDatasHeader(context, project),
        space(height: 5),
        const Divider(color: Colors.grey),
        space(height: 5),
        IntrinsicHeight(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("En ejecución:", 16),
                  space(height: 5),
                  customLinearPercent(context, 4.5, 0.8, mainColor),
                ],
              ),
              const VerticalDivider(
                width: 10,
                color: Colors.grey,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Presupuesto total:   ${project.budget} €", 16),
                space(height: 5),
                customLinearPercent(context, 4.5, 0.8, blueColor),
              ]),
            ],
          ),
        ),
        space(height: 5),
        const Divider(color: Colors.grey),
        space(height: 5),
        customText("Responsable del proyecto:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(project.managerObj.name, 16),
        space(height: 5),
        const Divider(color: Colors.grey),
        space(height: 5),
        projectCardDatasFinancier(project),
        space(height: 5),
        const Divider(color: Colors.grey),
        space(height: 5),
        customText("Programa:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(project.programmeObj.name, 16),
        space(height: 5),
        const Divider(color: Colors.grey),
        space(height: 5),
        projectCardDatasPartners(project),
        space(height: 5),
        const Divider(color: Colors.grey),
        space(height: 5),
        customText("País de ejecución:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(project.locationObj.countryObj.name, 16),
        space(height: 5),
        const Divider(color: Colors.grey),
        space(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            customPushBtn(context, "+ Info", Icons.info, "/project_info",
                {"project": project}),
            /*customPushBtn(context, "Marco técnico", Icons.task, "/goals",
                {"project": project}),*/
            goPage(context, "Marco técnico", GoalsPage(project: project),
                Icons.task,
                style: "bigBtn", extraction: () {
              setState(() {});
            }),
            goPage(
                context, "Presupuesto", FinnsPage(project: project), Icons.euro,
                style: "bigBtn", extraction: () {
              setState(() {});
            }),
            customBtn(context, "Personal", Icons.people, "/projects", {}),
            /*customBtn(context, "Editar", Icons.edit, "/projects", {}),
            customBtn(
                context, "Eliminar", Icons.remove_circle, "/projects", {}),*/
          ],
        ),
        space(height: 5),
        const Divider(color: Colors.grey),
      ],
    );
  }

  void callProjectDialog(context, args) {
    projectEditDialog(context, args["project"]);
  }

  void saveProject(List args) async {
    SProject project = args[0];
    project.save();

    Navigator.pop(context);
    Navigator.pushNamed(context, "/project_info",
        arguments: {'project': project});
  }

  Future<void> projectEditDialog(context, project) {
    project ??= SProject("");
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Nuevo proyecto'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 600,
                  child: TextFormField(
                    initialValue: (project.name != "") ? project.name : "",
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (val) => setState(() => project.name = val),
                  ),
                ),
              ]),
            ]),
            space(height: 20),
          ])),
          actions: <Widget>[
            Row(children: [
              Expanded(
                flex: 5,
                child: actionButton(context, "Enviar", saveProject,
                    Icons.save_outlined, [project]),
              ),
              space(width: 10),
              Expanded(
                  flex: 5,
                  child: actionButton(
                      context, "Cancelar", cancelItem, Icons.cancel, context))
            ]),
          ],
        );
      },
    );
  }
  /*void _saveProject(
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
      _country,
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
              _country,
              _announcement,
              _ambit,
              _audit,
              _evaluation,
              _project.financiers,
              _project.partners)
          .then((value) async {
        loadProjects();
      });
    } else {
      await addProject(_name, _desc, _type, _budget, _manager, _programme,
              _country, "", "", false, false)
          .then((value) async {
        loadProjects();
      });
    }
    if (!_types.contains(_type)) await addProjectType(_type);
    if (!_contacts.contains(_manager))
      await addContact(_manager, "", [], "", "", "");
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
    TextEditingController countryController = TextEditingController(text: "");

    if (_project != null) {
      nameController = TextEditingController(text: _project.name);
      descController = TextEditingController(text: _project.description);
      typeController = TextEditingController(text: _project.type);
      budgetController = TextEditingController(text: _project.budget);
      managerController = TextEditingController(text: _project.manager);
      programmeController = TextEditingController(text: _project.programme);
      countryController = TextEditingController(text: _project.country);
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
                customTextField(nameController, "Enter name"),
                space(width: 20),
                customTextField(descController, "Enter description"),
                space(width: 20),
                customAutocompleteField(
                    typeController, _types, "Write or select project type..."),
                space(width: 20),
                customTextField(budgetController, "Enter budget"),
              ]),
              Row(children: <Widget>[
                customAutocompleteField(
                    managerController, _contacts, "Write or select manager..."),
                space(width: 20),
                customAutocompleteField(programmeController, _programmes,
                    "Write or select programme..."),
                space(width: 20),
                customTextField(countryController, "Enter country"),
              ]),
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
                    countryController.text,
                    "",
                    "",
                    false,
                    false);
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
  }*/

  /*--------------------------------------------------------------------*/
  /*                           FINACIERS                                */
  /*--------------------------------------------------------------------*/
  /*void _saveFinancier(context, _project, _name, _financiers) async {
    _project.financiers.add(_name);
    await updateProjectFinanciers(_project.id, _project.financiers)
        .then((value) async {
      if (!_financiers.contains(_name)) await addFinancier(_name);
      loadProjects();
    });
    Navigator.of(context).pop();
  }

  void _removeFinancier(context, _project) async {
    await updateProjectFinanciers(_project.id, _project.financiers)
        .then((value) async {
      loadProjects();
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
  }*/

  /*--------------------------------------------------------------------*/
  /*                           PARTNERS                                 */
  /*--------------------------------------------------------------------*/
  /*void _savePartner(context, _project, _name, _contacts) async {
    _project.partners.add(_name);
    await updateProjectPartners(_project.id, _project.partners)
        .then((value) async {
      if (!_contacts.contains(_name))
        await addContact(_name, "", [], "", "", "");
      loadProjects();
    });
    Navigator.of(context).pop();
  }

  void _removePartner(context, _project) async {
    await updateProjectPartners(_project.id, _project.partners)
        .then((value) async {
      loadProjects();
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
  }*/
}
