import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/finns_page.dart';
import 'package:sic4change/pages/goals_page.dart';
import 'package:sic4change/pages/programme_page.dart';
import 'package:sic4change/pages/project_info_page.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/cache_projects.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/programme_form.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
// import 'dart:developer' as dev;

const projectTitle = "Proyectos";
bool loading = false;

enum SampleItem { itemOne, itemTwo, itemThree }

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key, this.prList, this.prType});

  final List? prList;
  final String? prType;

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  List prList = [];
  List programList = [];
  String? prType = "Proyecto";
  ProjectsProvider? cacheProjects;
  Widget contentProgrammList = Container();
  Widget contentProjectList = Container();
  Widget? _mainMenu;

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
    programList = await Programme.getProgrammes();
    contentProgrammList = programmeList();
    setState(() {});
  }

  Future<void> loadProjects() async {
    prList = cacheProjects!.projects;
    for (SProject item in prList) {
      if (item.programmeObj.uuid == "") {
        item.programmeObj = cacheProjects!.programmes.firstWhere(
            (prog) => prog.uuid == item.programme || prog.id == item.programme,
            orElse: () => Programme(""));
      }
      if (item.statusObj.uuid == "") {
        item.statusObj = cacheProjects!.status.firstWhere(
            (stat) => stat.uuid == item.status || stat.id == item.status,
            orElse: () => ProjectStatus(""));
      }
      if (item.typeObj.uuid == "") {
        item.typeObj = cacheProjects!.types.firstWhere(
            (type) => type.uuid == item.type || type.id == item.type,
            orElse: () => ProjectType(""));
      }
    }
    contentProjectList = projectList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    cacheProjects = context.read<ProjectsProvider>();
    cacheProjects!.addListener(() {
      _mainMenu = mainMenu(context, "/projects", cacheProjects!.profile);
      contentProgrammList = programmeList();
      contentProjectList = projectList(null, null);
      setState(() {});
    });

    setLoading();

    _mainMenu = mainMenu(context, "/projects", cacheProjects!.profile);

    if (widget.prType != null) {
      prType = widget.prType;
    } else {
      prType = "Proyecto";
    }
    loadProjects().then((value) => stopLoading());

    // //getProjects().then((val) {
    // SProject.getProjectsByType(prType!).then((val) {
    //   if (mounted) {
    //     setState(() {
    //       prList = val;
    //     });
    //     stopLoading();
    //     // for (SProject item in prList) {
    //     //   item.loadObjs().then((value) {
    //     //     if (mounted) {
    //     //       setState(() {});
    //     //     }
    //     //   });
    //     // }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    String currentTab = (prType == "Proyecto") ? "proyectos" : "consultorias";
    return Scaffold(
      //body: SingleChildScrollView(
      //child: Column(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mainMenu!,
          //mainMenu(context, "/projects"),
          projectSearch(),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "PROGRAMAS")),
          contentProgrammList,
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "INICIATIVAS")),
          // projectListMenu(context, currentTab, extraction: () {

          //   setState(() {});
          // }),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                menuTab2(context, "Cuadro de proyectos", null,
                    selected: (currentTab == "proyectos"), extraction: () {
                  setState(() {
                    prType = "Proyecto";
                    contentProjectList = projectList(null, null);
                  });
                }),
                menuTab2(context, "Cuadro de consultorías", null,
                    // const ProjectListPage(prType: "Consultoria"),
                    selected: (currentTab == "consultorias"), extraction: () {
                  setState(() {
                    prType = "Consultoría";
                    contentProjectList = projectList(null, null);
                  });
                }),
              ],
            ),
          ),
          contentProjectList
          // contentTab(context, projectList, null)
          //projectList(context),
        ],
      ),
    );
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
              /*addBtn(context, callProjectDialog, {"programme": null},
                  text: "Añadir Iniciativa"),*/
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
  Widget programmeList() {
    programList = cacheProjects!.programmes;
    return Container(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: SizedBox(
            height: 150,
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  //crossAxisSpacing: 20,
                  //mainAxisSpacing: 20,
                  childAspectRatio: 2,
                ),
                itemCount: programList.length,
                itemBuilder: (_, index) {
                  Programme programme = programList[index];
                  bool hasProjects = prList
                      .where((pr) =>
                          pr.programme == programme.uuid ||
                          pr.programme == programme.id)
                      .isNotEmpty;
                  if (programme.logo != "") {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(programme.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          InkWell(
                            child: SizedBox(
                                height: 80,
                                child: Image.network(
                                  programme.logo,
                                  height: 80,
                                )),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => ProgrammePage(
                                          programme: programme,
                                          returnToList: true))));
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              editBtn(context, callDialog,
                                  {'programme': programme}),
                              hasProjects
                                  ? removeBtn(null, (ctx, args) {
                                      // Show alert dialog with warning
                                      showDialog<void>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            titlePadding:
                                                const EdgeInsets.all(0),
                                            title: s4cTitleBar(
                                              'No se puede eliminar el programa',
                                              null,
                                              null,
                                            ),
                                            content:
                                                const SingleChildScrollView(
                                              child: Text(
                                                  'No se puede eliminar este programa porque tiene iniciativas vinculadas.'),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cerrar'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                      null) /*extraction: () { setState(() {}); }*/

                                  : removeConfirmBtn(context, (ctx, args) {
                                      // Check if any project is linked to this programme

                                      cacheProjects!.removeProgramme(programme);
                                      programme.delete();

                                      setState(() {
                                        contentProgrammList = programmeList();
                                      });
                                    }, {'programme': programme}),
                            ],
                          ),
                        ]);
                  } else {
                    return Column(children: [
                      Row(
                        children: [
                          customText(programme.name, 15, bold: FontWeight.bold),
                          customText(
                              " ('${programme.projects}' proyectos)", 15),
                          editBtn(context, callDialog, {'programme': programme})
                        ],
                      )
                    ]);
                  }
                })));
  }

  void callDialog(context, args) {
    programmeEditDialog(args["programme"]);
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  void saveProgramme2(List args) async {
    Programme programme = args[0];
    programme.save();
    cacheProjects!.addProgramme(programme);
    setState(() {});
    // loadProgrammes();
    Navigator.pop(context);
  }

  void saveProgramme(List args) async {
    Programme programme = args[0];

    String tmpPath = "files/programmes/${programme.id}/logoTemp.png";
    String logoPath = "files/programmes/${programme.id}/logo.png";
    logoPath = await moveFileInStorage(tmpPath, logoPath);
    programme.logo = await getDownloadUrl(logoPath);
    programme.save();
    cacheProjects!.addProgramme(programme);
    loadProgrammes();
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> programmeEditDialog(programme) {
    // Check permission
    ProfileProvider profileProvider = context.read<ProfileProvider>();
    Profile? profile = profileProvider.profile;
    if ((profile == null) || (!profile!.isAdmin())) {
      // Show alert dialog with warning
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permiso denegado'),
            content: const SingleChildScrollView(
              child: Text(
                  'No tienes permiso para modificar programas. Pointe en contacto con el administrador.'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              titlePadding: const EdgeInsets.all(0),
              title: s4cTitleBar('Modificar programa'),
              content: ProgrammeForm(
                currentProgramme: (programme != null) ? programme : null,
                onSaved: (args) {
                  saveProgramme(args);
                },
              ));
        });
  }

  Future<void> programmeEditDialog2(programme) async {
    // Check permission
    ProfileProvider profileProvider = context.read<ProfileProvider>();
    Profile? profile = profileProvider.profile;
    if ((profile == null) || (!profile!.isAdmin())) {
      // Show alert dialog with warning
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permiso denegado'),
            content: const SingleChildScrollView(
              child: Text(
                  'No tienes permiso para modificar programas. Ponte en contacto con el administrador.'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

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

  /*void callActionsDialog(context, args) {
    actionsDialog(context, args["project"]);
  }

  Future<void> actionsDialog(context, project) {
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
                goPage(context, "+ Info", ProjectInfoPage(project: project),
                    Icons.info,
                    style: "bigBtn", extraction: () {}),
                /*(project.folderObj.uuid != "")
                ? goPage(context, "Documentos",
                    DocumentsPage(currentFolder: project.folderObj), Icons.info,
                    style: "bigBtn", extraction: () {})
                : Container(),*/
                goPage(context, "Marco técnico", GoalsPage(project: project),
                    Icons.task,
                    style: "bigBtn", extraction: () {
                  setState(() {});
                }),
                goPage(context, "Presupuesto", FinnsPage(project: project),
                    Icons.euro,
                    style: "bigBtn", extraction: () {
                  setState(() {});
                }),
              ])
            ])
          ])),
          actions: <Widget>[
            Row(children: [
              Expanded(
                  flex: 5,
                  child: actionButton(
                      context, "Cerrar", cancelItem, Icons.cancel, context))
            ]),
          ],
        );
      },
    );
  }*/

  Widget actionsPopUpBtn(context, project) {
    SampleItem? selectedMenu;
    return PopupMenuButton<SampleItem>(
      initialValue: selectedMenu,
      // Callback that sets the selected popup menu item.
      onSelected: (SampleItem item) async {
        selectedMenu = item;
        if (selectedMenu == SampleItem.itemOne) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => ProjectInfoPage(
                        project: project,
                        returnToList: true,
                      ))));
        }
        if (selectedMenu == SampleItem.itemTwo) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => GoalsPage(
                        project: project,
                        returnToList: true,
                      ))));
        }
        if (selectedMenu == SampleItem.itemThree) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => FinnsPage(
                        project: project,
                        returnToList: true,
                      ))));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        const PopupMenuItem<SampleItem>(
            value: SampleItem.itemOne,
            child: Row(children: [
              Icon(Icons.info_outline),
              Text(' Mas Info'),
            ])),
        const PopupMenuItem<SampleItem>(
            value: SampleItem.itemTwo,
            child: Row(children: [
              Icon(Icons.task),
              Text(' Marco Técnico'),
            ])),
        const PopupMenuItem<SampleItem>(
          value: SampleItem.itemThree,
          child: Row(
            children: [
              Icon(Icons.euro),
              Text(' Presupuesto'),
            ],
          ),
        ),
      ],
    );
  }

  Widget projectList([args1, args2]) {
    prList = cacheProjects!.projects;
    if (prType != null) {
      ProjectType? objPrType = cacheProjects!.types.firstWhere(
          (type) => type.name == prType,
          orElse: () => ProjectType(""));
      prList = cacheProjects!.projects
          .where((pr) => pr.type == objPrType!.uuid)
          .toList();
    }
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Builder(builder: ((context) {
          //if (prList.isNotEmpty) {
          return DataTable(
              sortColumnIndex: 0,
              showCheckboxColumn: false,
              columns: [
                DataColumn(
                  label: customText("Código", 14, bold: FontWeight.bold),
                  tooltip: "Código",
                ),
                DataColumn(
                    label: customText("Título", 14, bold: FontWeight.bold),
                    tooltip: "Título"),
                DataColumn(
                    label: customText("Programa", 14, bold: FontWeight.bold),
                    tooltip: "Programa"),
                DataColumn(
                    label: customText("Estado", 14, bold: FontWeight.bold),
                    tooltip: "Estado"),
                DataColumn(
                    label: customText("Responsable", 14, bold: FontWeight.bold),
                    tooltip: "Responsable"),
                DataColumn(
                    label: customText("Presupuesto", 14, bold: FontWeight.bold),
                    tooltip: "Presupuesto"),
                DataColumn(
                    label: customText("País", 14, bold: FontWeight.bold),
                    tooltip: "País"),
                DataColumn(
                    label: customText("Donante", 14, bold: FontWeight.bold),
                    tooltip: "Donante"),
                DataColumn(
                    label: customText("Año", 14, bold: FontWeight.bold),
                    tooltip: "Año"),
                DataColumn(
                    label: customText("Acciones", 14, bold: FontWeight.bold),
                    tooltip: "Acciones"),
              ],
              rows: prList
                  .map(
                    (proj) => DataRow(cells: [
                      DataCell(customText(proj.getCode(), 14)),
                      DataCell(customText(proj.name, 14)),
                      DataCell(customText(proj.programmeObj.name, 14)),
                      DataCell(customText(proj.statusObj.name, 14,
                          textColor: proj.getStatusColor())),
                      DataCell(customText(proj.managerObj.name, 14)),
                      DataCell(customText(proj.budget, 14)),
                      DataCell(
                          customText(proj.locationObj.countryObj.name, 14)),
                      DataCell(customText(proj.getFinanciersStr(), 14)),
                      (proj.datesObj.approved == null)
                          ? DataCell(Container())
                          : DataCell(customText(
                              DateFormat('yyyy').format(proj.datesObj.approved),
                              14)),
                      DataCell(Column(children: [
                        actionsPopUpBtn(context, proj),
                      ]))
                    ]),
                  )
                  .toList());
        })));
  }
}
