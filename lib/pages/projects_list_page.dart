import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/project_info_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/project_list_menu_widget.dart';

const projectTitle = "Proyectos";

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
    if (widget.prType != null) {
      prType = widget.prType;
    } else {
      prType = "Proyecto";
    }
    //getProjects().then((val) {
    getProjectsByType(prType!).then((val) {
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
    String currentTab = (prType == "Proyecto") ? "proyectos" : "consultorias";
    return Scaffold(
      //body: SingleChildScrollView(
      //child: Column(
      body: Column(
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
          projectListMenu(context, currentTab),
          contentTab(context, projectList, null)
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
  Widget projectList(context, param) {
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Builder(builder: ((context) {
          if (prList.isNotEmpty) {
            return DataTable(
                sortColumnIndex: 0,
                showCheckboxColumn: false,
                columns: [
                  /*DataColumn(
                      label: customText("Nº", 14, bold: FontWeight.bold),
                      tooltip: "Nº"),*/
                  DataColumn(
                    label: customText("Código", 14, bold: FontWeight.bold),
                    tooltip: "Código",
                  ),
                  DataColumn(
                      label: customText("Título", 14, bold: FontWeight.bold),
                      tooltip: "Título"),
                  DataColumn(
                      label: customText("Estado", 14, bold: FontWeight.bold),
                      tooltip: "Estado"),
                  DataColumn(
                      label:
                          customText("Responsable", 14, bold: FontWeight.bold),
                      tooltip: "Responsable"),
                  /*DataColumn(
                      label: customText("Sector", 14, bold: FontWeight.bold),
                      tooltip: "Sector"),*/
                  DataColumn(
                      label:
                          customText("Presupuesto", 14, bold: FontWeight.bold),
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
                        //DataCell(customText(proj.id, 14)),
                        DataCell(customText(proj.getCode(), 14)),
                        DataCell(customText(proj.name, 14)),
                        DataCell(customText(proj.statusObj.name, 14,
                            textColor: proj.getStatusColor())),
                        DataCell(customText(proj.managerObj.name, 14)),
                        //DataCell(customText(proj.ambitObj.name, 14)),
                        DataCell(customText(proj.budget, 14)),
                        DataCell(
                            customText(proj.locationObj.countryObj.name, 14)),
                        DataCell(customText(proj.getFinanciersStr(), 14)),
                        DataCell(customText(
                            DateFormat('yyyy').format(proj.datesObj.approved),
                            14)),
                        DataCell(Row(children: [
                          goPageIcon(context, "Ver", Icons.info_outline,
                              ProjectInfoPage(project: proj)),
                          //removeBtn(context, removeTaskDialog, {"task": task})
                        ]))
                      ]),
                    )
                    .toList());
            /*return SizedBox(
                //height: 900,
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
                      SProject pr = prList[index];
                      return customText(pr.name, 16);
                      //return projectCard(context, prList[index]);
                    }));*/
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        })));
  }
}
