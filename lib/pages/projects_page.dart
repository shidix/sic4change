import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/documents_page.dart';
import 'package:sic4change/pages/finns_page.dart';
import 'package:sic4change/pages/goals_page.dart';
import 'package:sic4change/pages/programme_page.dart';
import 'package:sic4change/pages/project_info_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_quality.dart';
import 'package:sic4change/services/models_risks.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const projectTitle = "Proyectos";
bool loading = false;
Widget? _mainMenu;

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key, this.prList});

  final List? prList;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List prList = [];
  List programList = [];
  Profile? profile;
  String deleteMsg = "";
  final user = FirebaseAuth.instance.currentUser!;

  void setLoading() {
    setState(() {
      loading = true;
    });
  }

  void stopLoading() {
    setState(() {
      loading = false;
    });
  }

  void loadProgrammes() async {
    await getProgrammes().then((val) {
      programList = val;
    });
    setState(() {});
  }

  void loadProjects() async {
    setLoading();
    await getProjects().then((val) {
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
      //prList = val;
    });
    setState(() {});
    stopLoading();
  }

  void getProfile(user) async {
    await Profile.getProfile(user.email!).then((value) {
      profile = value;
      //print(profile?.mainRole);
    });
  }

  @override
  void initState() {
    super.initState();

    _mainMenu = mainMenu(context, "/projects");
    loadProjects();
    /*getProjects().then((val) {
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
    });*/

    getProfile(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //mainMenu(context, "/projects"),
          _mainMenu!,
          projectSearch(),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "PROGRAMAS")),
          programmeList(context),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "INICIATIVAS")),
          loading
              ? const Center(child: CircularProgressIndicator())
              : projectList(context),
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
              /*goPage(context, "Listado", const ProjectListPage(), Icons.info,
                  style: "bigBtn", extraction: () {}),*/
              space(width: 10),
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
                                  InkWell(
                                      child: Image.network(
                                        programme.logo,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    ProgrammePage(
                                                        programme:
                                                            programme))));
                                      }),
                                  /*InkWell(
                                    child: customText(programme.name, 16),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  ProgrammePage(
                                                      programme: programme))));
                                    },
                                  ),*/
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
        child: SizedBox(
            height: 900,
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: prList.length,
                itemBuilder: (_, index) {
                  return projectCard(context, prList[index]);
                })));

    /*return Container(
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
        })));*/
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

  Widget projectCard(context, project) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: projectCardDatas(context, project),
      /*child: SingleChildScrollView(
        child: projectCardDatas(context, _project),
      ),*/
    );
  }

  Widget projectCardDatasHeader(context, project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customText(project.name, 20, bold: FontWeight.bold),
            customText(project.statusObj.name.toUpperCase(), 15,
                textColor: mainColor),
            customText(project.typeObj.name.toUpperCase(), 15,
                textColor: mainColor),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Eliminar proyecto',
              onPressed: () {
                projectRemoveDialog(context, project);
              },
            ),
          ],
        ),
        space(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: customText(project.description, 15)),
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
            .add((getObject(project.financiersObj, uuid) as Organization).name);
      }
    }

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        customText("Financiador/es:", 16, textColor: Colors.grey),
      ]),
      Row(
        children: [Text(financiers.join(', '))],
      )
    ]);
  }

  Widget projectCardDatasPartners(SProject project) {
    List list = project.partners;
    List partners = [];
    if (project.partnersObj.isNotEmpty) {
      for (var uuid in list) {
        partners
            .add((getObject(project.partnersObj, uuid) as Organization).name);
      }
    }

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        customText("Socios del proyecto:", 16, textColor: Colors.grey),
      ]),
      Row(children: [
        Text(
          partners.join(", "),
        )
      ]),
    ]);
  }

  Widget projectCardDatas(context, SProject project) {
    /*double prjBudget = fromCurrency(project.budget);
    double execVsBudget = (prjBudget != 0) ? project.execBudget / prjBudget : 0;
    double execVsAssigned = (project.assignedBudget != 0)
        ? project.execBudget / project.assignedBudget
        : 0;

    execVsBudget = (execVsBudget > 1) ? 1 : execVsBudget;
    execVsAssigned = (execVsAssigned > 1) ? 1 : execVsAssigned;

    execVsBudget = (execVsBudget * 100).round() / 100;
    execVsAssigned = (execVsAssigned * 100).round() / 100;*/

    return SingleChildScrollView(
        child: Column(
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
                  customText(
                      "En ejecución: ${toCurrency(project.assignedBudget)}",
                      16),
                  space(height: 5),
                  /*customLinearPercent(
                      context, 4.5, execVsAssigned, percentBarPrimary),*/
                  customLinearPercent(context, 4.5, project.getExecVsAssigned(),
                      percentBarPrimary),
                ],
              ),
              const VerticalDivider(
                width: 10,
                color: Colors.grey,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Presupuesto total:   ${project.budget} €", 16),
                space(height: 5),
                //customLinearPercent(context, 4.5, execVsBudget, blueColor),
                customLinearPercent(
                    context, 4.5, project.getExecVsBudget(), blueColor),
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
            /*customPushBtn(context, "+ Info", Icons.info, "/project_info",
                {"project": project}),*/
            /*customPushBtn(context, "Marco técnico", Icons.task, "/goals",
                {"project": project}),*/
            goPage(context, "+ Info", ProjectInfoPage(project: project),
                Icons.info,
                style: "bigBtn", extraction: () {}),
            (project.folderObj.uuid != "")
                ? goPage(context, "Documentos",
                    DocumentsPage(currentFolder: project.folderObj), Icons.info,
                    style: "bigBtn", extraction: () {})
                : Container(),
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
    ));
  }

  void callProjectDialog(context, args) {
    projectEditDialog(context, args["project"]);
  }

  void setProjectStatus(project) async {
    ProjectStatus st = await ProjectStatus.byUuid(statusFormulation);
    project.status = st.uuid;
    project.save();
  }

  void saveProject(List args) {
    SProject project = args[0];

    setProjectStatus(project);
    loadProjects();

    Navigator.pop(context);
    /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => ProjectInfoPage(
                  project: project,
                ))));*/
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

  void removeProject(List args) async {
    setLoading();
    Navigator.pop(context);

    SProject project = args[0];

    ProjectDates pd = await getProjectDatesByProject(project.uuid);
    pd.delete();

    ProjectLocation pl = await getProjectLocationByProject(project.uuid);
    pl.delete();

    List refList = await getReformulationsByProject(project.uuid);
    for (Reformulation ref in refList) {
      ref.delete();
    }

    List riskList = await getRisksByProject(project.uuid);
    for (Risk risk in riskList) {
      risk.delete();
    }

    Quality q = await Quality.byProject(project.uuid);
    if (q.id != "") {
      q.delete();
    }

    Transparency t = await Transparency.byProject(project.uuid);
    if (t.id != "") {
      t.delete();
    }

    Gender g = await Gender.byProject(project.uuid);
    if (g.id != "") {
      g.delete();
    }

    Environment e = await Environment.byProject(project.uuid);
    if (e.id != "") {
      e.delete();
    }

    List finList = await SFinn.byProject(project.uuid);
    for (SFinn finn in finList) {
      // List contribList = await FinnContribution.getByFinn(finn.uuid);
      // for (FinnContribution contrib in contribList) {
      //   contrib.delete();
      // }

      List distList = await FinnDistribution.getByFinn(finn.uuid);
      for (FinnDistribution dist in distList) {
        dist.delete();
      }

      List invList = await Invoice.getByFinn(finn.uuid);
      for (Invoice inv in invList) {
        inv.delete();
      }

      finn.delete();
    }

    List btList = await BankTransfer.getByProject(project.uuid);
    for (BankTransfer bt in btList) {
      bt.delete();
    }

    Folder? folder = await getFolderByUuid(project.folder);
    bool haveChildren = await folder!.haveChildren();
    if (!haveChildren) {
      folder.delete();
    } else {
      folder.name = "BORRADO!-${folder.name}";
      folder.save();
    }

    project.delete();

    loadProjects();
  }

  Future<void> projectRemoveDialog(context, project) {
    project ??= SProject("");
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: s4cTitleBar('Borrar proyecto'),
            content: SingleChildScrollView(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            customText(
                                "Se va a borrar el proyecto ${project.name}.",
                                16,
                                bold: FontWeight.bold),
                            space(height: 20),
                            customText("En concreto se borrara:", 16),
                            space(height: 10),
                            customText(
                                "- Información relacionadad con los detalles del proyecto (fechas, ubicación...)",
                                16),
                            space(height: 10),
                            customText(
                                "- El marco lógico (objetivos, resultados...)",
                                16),
                            space(height: 10),
                            customText(
                                "- Los riesgos asociados al proyecto", 16),
                            space(height: 10),
                            customText(
                                "- La información transversal asociada al proyecto (calidad, transparencia...)",
                                16),
                            space(height: 10),
                            customText(
                                "- La información financiera asociada al proyecto (partidas, aportaciones...)",
                                16),
                            space(height: 20),
                            customText(
                                "- La carpeta del proyecto y todo lo que contiene",
                                16),
                            space(height: 20),
                            customText(
                                "Esta información NO será recuperable, ¿está seguro/a de que desea borrarla?",
                                16,
                                bold: FontWeight.bold),
                            //customText(deleteMsg, 16, bold: FontWeight.bold),
                          ])),
            actions: <Widget>[
              Row(children: [
                Expanded(
                  flex: 5,
                  child: actionButton(context, "Borrar", removeProject,
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
        });
  }
}
