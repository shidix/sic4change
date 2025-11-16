// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:googleapis/dfareporting/v4.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/projects_list_page.dart';
import 'package:sic4change/pages/projects_page.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/cache_projects.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/project_info_menu_widget.dart';

// import 'dart:developer' as dev;

String s4cUuid = "b1b0c5a8-d0f0-4b43-a50b-33aef2249d00";
const projectInfoTitle = "Detalles del Proyecto";
//SProject? project;
bool projLoading = true;
Widget? _mainMenu;

class ProjectInfoPage extends StatefulWidget {
  final SProject? project;
  final bool? returnToList;
  const ProjectInfoPage({super.key, this.project, this.returnToList});

  @override
  State<ProjectInfoPage> createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
  SProject? project;
  Profile? profile;
  bool _canEdit = false;
  bool returnToList = false;
  ProjectsProvider? projectsProvider;
  bool _update = false;
  bool get update => _update;
  set update(bool val) {
    _update = val;
    if (_update) {
      if (!mounted) return;
      setState(() {
        loadProject();
        _update = false;
      });
    }
  }

  Widget? projectInfoHeaderPanel;
  Widget? profileMenuPanel;
  Widget? projectInfoDetailsPanel;
  Widget? projectInfoLocationPanel;
  void loadProject() async {
    setState(() {
      projLoading = false;
    });

    project!.typeObj = projectsProvider!.types.firstWhere(
        (element) => element.uuid == project!.type,
        orElse: () => ProjectType("Unknown"));

    project!.statusObj = projectsProvider!.status.firstWhere(
        (element) => element.uuid == project!.status,
        orElse: () => ProjectStatus("Unknown"));

    project!.managerObj = projectsProvider!.contacts.firstWhere(
        (element) => element.uuid == project!.manager,
        orElse: () => Contact("Unknown"));
    project!.programmeObj = projectsProvider!.programmes.firstWhere(
        (element) => element.uuid == project!.programme,
        orElse: () => Programme("Unknown"));
    project!.ambitObj = projectsProvider!.ambits.firstWhere(
        (element) => element.uuid == project!.ambit,
        orElse: () => Ambit("Unknown"));
    project!.financiersObj = projectsProvider!.organizations
        .where((element) => project!.financiers.contains(element.uuid))
        .toList();
    project!.partnersObj = projectsProvider!.organizations
        .where((element) => project!.partners.contains(element.uuid))
        .toList();
    project!.locationObj = projectsProvider!.locations.firstWhere(
        (element) => element.project == project!.uuid,
        orElse: () => ProjectLocation("Unknown"));
    project!.locationObj.countryObj = projectsProvider!.countries.firstWhere(
        (element) => element.uuid == project!.locationObj.country,
        orElse: () => Country("Unknown"));
    project!.locationObj.regionObj = projectsProvider!.regions.firstWhere(
        (element) => element.uuid == project!.locationObj.region,
        orElse: () => Region("Unknown"));
    project!.locationObj.provinceObj = projectsProvider!.provinces.firstWhere(
        (element) => element.uuid == project!.locationObj.province,
        orElse: () => Province("Unknown"));
    project!.locationObj.townObj = projectsProvider!.towns.firstWhere(
        (element) => element.uuid == project!.locationObj.town,
        orElse: () => Town("Unknown"));
    project!.locationObj = projectsProvider!.locations.firstWhere(
        (element) => element.project == project!.uuid,
        orElse: () => ProjectLocation("Unknown"));
    project!.datesObj = projectsProvider!.projectDates.firstWhere(
        (element) => element.project == project!.uuid,
        orElse: () => ProjectDates("Unknown"));
    project!.folderObj = projectsProvider!.folders.firstWhere(
        (element) => element.uuid == project!.folder,
        orElse: () => Folder("Unknown", ""));
    setState(() {
      project = project;
      projLoading = true;
    });

    // await project!.reload().then((val) {
    //   /*Navigator.popAndPushNamed(context, "/project_info",
    //       arguments: {"project": val});*/
    //   setState(() {
    //     project = val;
    //     projLoading = true;
    //   });
    // });
  }

  void getProfile(user) async {
    profile = projectsProvider!.profile;
    profile ??= await Profile.getProfile(user.email!);
    _canEdit = canEdit();
    if (!mounted) return;
    _mainMenu = mainMenu(context, null, profile);
    setState(() {});
    // await Profile.getProfile(user.email!).then((value) {
    //   profile = value;

    //   setState(() {
    //     _canEdit = canEdit();
    //   });
    // });
  }

  bool canEdit() {
    return profile!.mainRole == "Admin" ||
        (project!.status != statusReject && project!.status != statusClose);
  }

  Future<void> loadProjectFromCache() async {
    project = projectsProvider!.projects.firstWhere(
        (element) => element.uuid == project!.uuid,
        orElse: () => project!);
    projectInfoHeaderPanel = projectInfoHeader(context);
    profileMenuPanel = profileMenu(context, project, "info");
    projectInfoDetailsPanel = projectInfoDetails(context);
    setState(() {
      projLoading = false;
    });
  }

  void updateProject(SProject project) {
    // dev.log("Updating project in ProjectInfoPageState",
    //     name: "ProjectInfoPage");
    // setState(() {
    //   this.project = project;
    // });
  }

  @override
  initState() {
    super.initState();
    // Create a listener to update the project when update chante to true
    // update = false;
    project = widget.project;
    projectsProvider = context.read<ProjectsProvider?>();
    projectsProvider ??= ProjectsProvider();
    try {
      projectsProvider = context.read<ProjectsProvider?>();
    } catch (e) {
      projectsProvider = ProjectsProvider();
    }
    projectsProvider ??= context.read<ProjectsProvider?>();

    projectsProvider!.addListener(() {
      loadProjectFromCache().then((value) {
        if (!mounted) return;

        projectInfoHeaderPanel = projectInfoHeader(context);
        profileMenuPanel = profileMenu(context, project, "info");
        projectInfoDetailsPanel = projectInfoDetails(context);
        setState(() {});
      });
    });

    try {
      returnToList = widget.returnToList!;
    } catch (e) {
      returnToList = false;
    }
    // _mainMenu = mainMenu(context);

    final user = FirebaseAuth.instance.currentUser!;
    getProfile(user);
    projectInfoLocationPanel = projectInfoLocation(context, project);
    projectInfoHeaderPanel = projectInfoHeader(context); //, widget.project);
    profileMenuPanel = profileMenu(context, project, "info");
    projectInfoDetailsPanel = projectInfoDetails(context);

    createLog("Acceso a al detalle de la iniciativa: ${project!.name}");
  }

  @override
  Widget build(BuildContext context) {
    projectInfoLocationPanel = projectInfoLocation(context, project);
    projectInfoHeaderPanel = projectInfoHeader(context); //, widget.project);
    profileMenuPanel = profileMenu(context, project, "info");
    projectInfoDetailsPanel = projectInfoDetails(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //mainMenu(context),
          _mainMenu!,
          projectInfoHeaderPanel == null
              ? const Center(child: CircularProgressIndicator())
              : projectInfoHeaderPanel!,
          // projectInfoHeader(context),
          profileMenuPanel == null
              ? const Center(child: CircularProgressIndicator())
              : profileMenuPanel!,
          // profileMenu(context, project, "info"),
          projectInfoDetailsPanel != null
              ? contentTab(
                  context, projectInfoDetailsPanel, {"project": project})
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  //Widget projectInfoHeader(context, project) {
  Widget projectInfoHeader(context) {
    if (!mounted) return Container();
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Expanded(
                flex: 1,
                child: customText(project!.statusObj.name, 18,
                    textColor: mainColor)),
            Expanded(
                flex: 3,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _canEdit
                      ? addBtn(context, _callProjectEditDialog, project,
                          icon: Icons.edit, text: "Editar")
                      : addBtn(context, () {}, null,
                          icon: Icons.gpp_bad_outlined,
                          text: "Denegado",
                          style: btnStyle.copyWith(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.grey)),
                          color: Colors.white),
                  space(width: 10),
                  //returnBtn(context),
                  (returnToList)
                      ? goPage(context, "Volver", const ProjectListPage(),
                          Icons.arrow_circle_left_outlined)
                      : goPage(context, "Volver", const ProjectsPage(),
                          Icons.arrow_circle_left_outlined),
                ]))
          ]),
          Row(children: [
            Expanded(flex: 1, child: customText(project!.name, 20)),
          ]),
          space(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText("En ejecución:", 16),
                        space(height: 5),
                        customLinearPercent(context, null,
                            project!.getExecVsAssigned(), percentBarPrimary),
                      ],
                    )),
                Expanded(
                    flex: 1,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customText(
                              "Presupuesto total:   ${project!.budget} €", 16),
                          space(height: 5),
                          customLinearPercent(context, null,
                              project!.getExecVsBudget(), blueColor),
                        ])),
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
          Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Responsable del proyecto", 14,
                      bold: FontWeight.bold),
                  space(height: 5),
                  customText(_project.managerObj.name, 14),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          Expanded(
              flex: 2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("Programa", 14, bold: FontWeight.bold),
                    space(height: 5),
                    customText(_project.programmeObj.name, 14),
                  ])),
          /*const VerticalDivider(
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
                  ])),*/
        ],
      ),
    );
  }

  Widget projectDatesAuditHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Fechas de auditorías", 15, bold: FontWeight.bold),
      addBtnRow(context, callDatesAuditEditDialog, {"project": project},
          text: "Añadir auditoría", icon: Icons.add_circle_outline),
    ]);
  }

  Widget projectDatesAudit(context, project) {
    return FutureBuilder(
        future: (project.datesAudit.isNotEmpty)
            ? Future.value(project.datesAudit)
            : ProjectDatesAudit.getProjectDatesAuditByProject(project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List<ProjectDatesAudit> dates =
                snapshot.data! as List<ProjectDatesAudit>;
            return SizedBox(
              width: double.infinity,
              child: DataTable(
                sortColumnIndex: 0,
                showCheckboxColumn: false,
                headingRowHeight: 0,
                columns: [
                  DataColumn(label: customText("", 14)),
                  DataColumn(
                    label: customText("", 14),
                  ),
                ],
                rows: (dates.isNotEmpty)
                    ? dates
                        .map(
                          (date) => DataRow(cells: [
                            DataCell(
                              customText(
                                  DateFormat("dd-MM-yyyy").format(date.date),
                                  14),
                            ),
                            DataCell(Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  removeBtn(context, removeDateAuditDialog,
                                      {"dateAudit": date}),
                                ]))
                          ]),
                        )
                        .toList()
                    : [],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget projectDatesEvalHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Fechas de evaluación", 15, bold: FontWeight.bold),
      addBtnRow(context, callDatesEvalEditDialog, {"project": project},
          text: "Añadir evaluación", icon: Icons.add_circle_outline),
    ]);
  }

  Widget projectDatesEval(context, project) {
    return FutureBuilder(
        future: ProjectDatesEval.getProjectDatesEvalByProject(project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List dates = snapshot.data!;
            return SizedBox(
              width: double.infinity,
              child: DataTable(
                sortColumnIndex: 0,
                showCheckboxColumn: false,
                headingRowHeight: 0,
                columns: [
                  DataColumn(label: customText("", 14)),
                  DataColumn(
                    label: customText("", 14),
                  ),
                ],
                rows: dates
                    .map(
                      (date) => DataRow(cells: [
                        DataCell(
                          customText(
                              DateFormat("dd-MM-yyyy").format(date.date), 14),
                        ),
                        DataCell(Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              removeBtn(context, removeDateEvalDialog,
                                  {"dateEval": date}),
                            ]))
                      ]),
                    )
                    .toList(),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget projectTracingHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Fechas de informes", 15, bold: FontWeight.bold),
      addBtnRow(context, callDatesTracingEditDialog, {"project": project},
          text: "Añadir informe de seguimiento",
          icon: Icons.add_circle_outline),
    ]);
  }

  Widget projectTracing(context, project) {
    return FutureBuilder(
        future:
            ProjectDatesTracing.getProjectDatesTracingByProject(project.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List dates = snapshot.data!;
            return SizedBox(
              width: double.infinity,
              child: DataTable(
                sortColumnIndex: 0,
                showCheckboxColumn: false,
                headingRowHeight: 0,
                columns: [
                  DataColumn(label: customText("", 14)),
                  DataColumn(
                    label: customText("", 14),
                  ),
                ],
                rows: dates
                    .map(
                      (date) => DataRow(cells: [
                        DataCell(
                          customText(
                              DateFormat("dd-MM-yyyy").format(date.date), 14),
                        ),
                        DataCell(Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              removeBtn(context, removeDateEvalDialog,
                                  {"dateEval": date}),
                            ]))
                      ]),
                    )
                    .toList(),
              ),
            );

            /*return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: dates.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        customText(
                            DateFormat("dd-MM-yyyy").format(dates[index].date),
                            14),
                        removeBtn(context, removeDateTracingDialog,
                            {"dateTracing": dates[index]}),
                      ]);
                });*/
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget projectAuditEvaluation(context, project) {
    var audit = project.audit == true ? "Sí" : "No";
    var evaluation = project.evaluation == true ? "Sí" : "No";
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        customText("Auditoría: ", 14, bold: FontWeight.bold),
                        space(width: 10),
                        customText(audit, 14),
                      ]),
                      space(height: 5),
                      project.audit
                          ? projectDatesAuditHeader(context, project)
                          : Container(),
                      project.audit
                          ? projectDatesAudit(context, project)
                          : Container(),
                      const VerticalDivider(
                        width: 10,
                        color: Colors.grey,
                      ),
                    ],
                  ))),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        customText("Evaluación: ", 14, bold: FontWeight.bold),
                        space(width: 10),
                        customText(evaluation, 14),
                      ]),
                      space(height: 5),
                      project.evaluation
                          ? projectDatesEvalHeader(context, project)
                          : Container(),
                      project.evaluation
                          ? projectDatesEval(context, project)
                          : Container(),
                      const VerticalDivider(
                        width: 10,
                        color: Colors.grey,
                      ),
                    ]),
              )),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText("Informes de seguimiento", 14,
                          bold: FontWeight.bold),
                      space(height: 5),
                      projectTracingHeader(context, project),
                      projectTracing(context, project),
                    ]),
              )),
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
        itemCount: project!.financiers.length,
        itemBuilder: (BuildContext context, int index) {
          Organization financier = projectsProvider!.organizations.firstWhere(
              (element) => element.uuid == project!.financiers[index],
              orElse: () => Organization("Unknown"));

          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customText('${financier.name}', 14),
                    removeBtn(
                      context,
                      removeFinancierDialog,
                      {"financier": financier},
                      callback: (bool? update) {
                        if (update != null && update) {
                          setState(() {});
                        }
                      },
                    ),
                  ]));
        });
  }

  Widget projectPartnersHeader(context, project) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Socios", 15, bold: FontWeight.bold),
      addBtnRow(context, callPartnerEditDialog, {"project": project},
          text: "Añadir socio", icon: Icons.add_circle_outline),
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
              ]);
        });
  }

  Future<ProjectLocation> getProjectLocation(project) async {
    // Check if locationObj exists in provider
    int index = projectsProvider!.locations
        .indexWhere((element) => element.project == project.uuid);
    if (index != -1) {
      project.locationObj = projectsProvider!.locations[index];
    } else {
      // If not, fetch from database
      project.locationObj =
          await ProjectLocation.getProjectLocationByProject(project.uuid);
    }
    project.locationObj.countryObj = projectsProvider!.countries.firstWhere(
        (element) => element.uuid == project.locationObj.country,
        orElse: () => Country("Unknown"));
    project.locationObj.regionObj = projectsProvider!.regions.firstWhere(
        (element) => element.uuid == project.locationObj.region,
        orElse: () => Region("Unknown"));
    project.locationObj.provinceObj = projectsProvider!.provinces.firstWhere(
        (element) => element.uuid == project.locationObj.province,
        orElse: () => Province("Unknown"));
    project.locationObj.townObj = projectsProvider!.towns.firstWhere(
        (element) => element.uuid == project.locationObj.town,
        orElse: () => Town("Unknown"));
    return project.locationObj;
  }

  Widget projectInfoLocation(context, project) {
    return FutureBuilder(future: () async {
      project!.locationObj = await getProjectLocation(project);
      return project!.locationObj;
    }(), builder: ((context, snapshot) {
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
                  customText("Comunidad", 14, bold: FontWeight.bold),
                  customText("Provincia", 14, bold: FontWeight.bold),
                  customText("Municipio", 14, bold: FontWeight.bold),
                ]),
                TableRow(children: [
                  customText(loc.countryObj.name, 14),
                  customText(loc.regionObj.name, 14),
                  customText(loc.provinceObj.name, 14),
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

  Widget projectInfoDetails(context) {
    SProject proj = project!;
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                projectStatusChange(context, proj),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
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
                customText(proj.ambitObj.name, 14),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectAuditEvaluation(context, proj),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    projectFinanciersHeader(context, proj),
                                    projectFinanciers(context)
                                  ])))),
                  Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          projectPartnersHeader(context, proj),
                          projectPartners(context, proj)
                        ],
                      ))
                ]),
                //projectFinanciers(context, proj),
                // space(height: 5),
                // customRowDivider(),
                // space(height: 5),
                // projectPartnersHeader(context, proj),
                // projectPartners(context, proj),
                /*space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectInfoDates(context, proj),
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectTracingHeader(context, proj),
                projectTracing(context, proj),*/
                space(height: 5),
                customRowDivider(),
                space(height: 5),
                projectInfoLocationPanel ?? projectInfoLocation(context, proj),
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
    // loadProject();
    projectsProvider!.addProject(proj, notify: false);
    project = proj;
    projectInfoLocationPanel = projectInfoLocation(context, project);
    projectInfoDetailsPanel = projectInfoDetails(context);
    projectInfoHeaderPanel = projectInfoHeader(context);
    profileMenuPanel = profileMenu(context, project, "info");

    if (!mounted) return;
    setState(() {});

    Navigator.pop(context);
  }

  void _callProjectEditDialog(context, project) async {
    List<Profile> supervisorProfiles = projectsProvider!.profiles
        .where((profile) => profile.mainRole == Profile.SUPERVISOR)
        .toList();
    List<Contact> supervisors = projectsProvider!.contacts
        .where((contact) =>
            supervisorProfiles.any((profile) => profile.email == contact.email))
        .toList();

    List<KeyValue> ambits = await Ambit.getAmbitsHash();
    List<KeyValue> types = await ProjectType.getProjectTypesHash();
    List<KeyValue> status = await ProjectStatus.getProjectStatusHash();
    List<KeyValue> contacts = supervisors.map((e) => e.toKeyValue()).toList();
    // Check if current manager is in the contacts list
    if (!contacts.any((kv) => kv.key == project.manager)) {
      project.manager = contacts.isNotEmpty ? contacts[0].key : "";
      await project.save();
    }

    List<KeyValue> programmes = await Programme.getProgrammesHash();
    editProjectDialog(
        context, project, ambits, types, status, contacts, programmes);
  }

  Future<void> editProjectDialog(
      context, proj, ambits, types, status, contacts, programmes) async {
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
              profile!.mainRole == "Admin"
                  ? Row(children: <Widget>[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdown(
                              labelText: 'Estado',
                              size: 440,
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
                    ])
                  : customText("", 14),
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
              space(height: 20),
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
              space(height: 20),
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
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: CustomTextField(
                          labelText: 'Nombre Convocatoria',
                          size: 220,
                          initial: proj.announcement,
                          fieldValue: (String val) {
                            proj.announcement = val;
                            /*setState(() {
                        proj.announcement = val;
                      });*/
                          },
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Código Convocatoria',
                            ),
                            initialValue: proj.announcementCode,
                            onChanged: (String val) {
                              proj.announcementCode = val;
                            }))),
                // announcementYear
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Año Convocatoria',
                            ),
                            initialValue: proj.announcementYear,
                            onChanged: (String val) {
                              proj.announcementYear = val;
                            }))),
              ]),
              space(height: 20),
              Row(
                children: <Widget>[
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
    String? uuid = args[0];
    if (uuid != null) {
      if (!project!.financiers.contains(uuid)) {
        project?.financiers.add(uuid);
        projectsProvider!.addProject(project!);
        project!.save();
      }
    }
    Navigator.pop(context);
  }

  // void removeFinancierDialog(context, Map<String, dynamic> args) {
  //   Organization financier = args["financier"];
  //   Future<bool> showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         titlePadding: const EdgeInsets.all(0),
  //         title: s4cTitleBar('Eliminar financiador'),
  //         content: SingleChildScrollView(
  //           child: Column(children: [
  //             Text(
  //                 '¿Está seguro de que desea eliminar el financiador "${financier.name}" del proyecto?'),
  //           ]),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancelar'),
  //             onPressed: () {
  //               Navigator.of(context).pop(false);
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Eliminar'),
  //             onPressed: () {
  //               Navigator.of(context).pop(true);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   ).then((value) {
  //     if (value == true) {
  //       removeFinancier(financier);
  //       setState(() {});
  //     }
  //   });
// }
  Future<bool> removeFinancierDialog(
      BuildContext context, Map<String, dynamic> args) async {
    final Organization financier = args['financier'] as Organization;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Eliminar financiador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Está seguro de que desea eliminar el financiador "${financier.name}" del proyecto?',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      removeFinancier(financier);
    }
    return confirmed ?? false;
  }

  void removeFinancier(financier) async {
    project!.financiers.remove(financier.uuid);
    // project!.financiersObj.remove(financier);
    project!.save();
    // setState(() {});
    //loadProject();

    //project.updateProjectFinanciers();
    //loadProject(project);
  }

  void callFinancierEditDialog(context, Map<String, dynamic> args) async {
    SProject project = args["project"];
    List<Organization> existingFinanciers = projectsProvider!.organizations
        .where((org) => (org.financier))
        .toList();

    List<KeyValue> financiers =
        existingFinanciers.map((e) => KeyValue(e.uuid, e.name)).toList();

    editProjectFinancierDialog(context, project, financiers).then((_) {
      updateProject(project);
    });
  }

  Future<void> editProjectFinancierDialog(context, project, financiers) {
    List<KeyValue> availableFinanciers = financiers
        .where((financier) => !project.financiers.contains(financier.key))
        .toList();

    String? uuidSelected;
    if (availableFinanciers.isEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: s4cTitleBar('Añadir financiador'),
            content: const SingleChildScrollView(
              child: Column(children: [
                Text("No hay más financiadores disponibles para añadir."),
              ]),
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
    } else {
      uuidSelected = availableFinanciers.first.key;
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
                  selected: availableFinanciers.first,
                  options: availableFinanciers,
                  onSelectedOpt: (String val) {
                    uuidSelected = val;
                  },
                ),
              ]),
            ),
            actions: <Widget>[
              dialogsBtns(context, saveFinancier, uuidSelected)
            ],
          );
        },
      );
    }
  }

  /*--------------------------------------------------------------------*/
  /*                           PARTNERS                                 */
  /*--------------------------------------------------------------------*/
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
    List<KeyValue> orgs = await Organization.getPartnersHash();
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
    project!.changeStatus(dates);
    loadProject();

    Navigator.pop(context);
  }

  void callDatesEditDialog(context, project) async {
    //ProjectDates dates = await getProjectDatesByProject(project.uuid);
    //editProjectDatesDialog(context, dates, project);
    editProjectDatesDialog(context, project);
  }

  //Future<void> editProjectDatesDialog(context, dates, project) {
  Future<void> editProjectDatesDialog(context, project) {
    ProjectDates dates = project.datesObj;
    dates.sended = dates.getSended();
    if (project.statusInt() == 2 || project.statusInt() >= 5) {
      dates.approved = dates.getApproved();
    }
    if (project.statusInt() == 2 || project.statusInt() == 3) {
      dates.reject = dates.getReject();
    }
    if (project.statusInt() == 2 || project.statusInt() == 4) {
      dates.refuse = dates.getRefuse();
    }
    if (project.statusInt() >= 5) {
      dates.start = dates.getStart();
      dates.end = dates.getEnd();
      dates.justification = dates.getJustification();
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar plazos'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(children: [
                Row(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 220,
                            child: DateTimePicker(
                              labelText: 'Presentación',
                              selectedDate: dates.getSended(),
                              onSelectedDate: (DateTime date) {
                                setState(() {
                                  dates.sended = date;
                                });
                              },
                            )),
                      ]),
                ]),
                space(height: 10),
                Row(children: [
                  (project.statusInt() == 2 || project.statusInt() >= 5)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              SizedBox(
                                  width: 220,
                                  child: DateTimePicker(
                                    labelText: 'Aprobación',
                                    selectedDate: dates.getApproved(),
                                    onSelectedDate: (DateTime date) {
                                      setState(() {
                                        dates.approved = date;
                                      });
                                    },
                                  )),
                            ])
                      : Container(),
                  (project.statusInt() == 2 || project.statusInt() == 3)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              SizedBox(
                                  width: 220,
                                  child: DateTimePicker(
                                    labelText: 'Denegación',
                                    selectedDate: dates.getReject(),
                                    onSelectedDate: (DateTime date) {
                                      setState(() {
                                        dates.reject = date;
                                      });
                                    },
                                  )),
                            ])
                      : Container(),
                  (project.statusInt() == 2 || project.statusInt() == 4)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              SizedBox(
                                  width: 220,
                                  child: DateTimePicker(
                                    labelText: 'Rechazo',
                                    selectedDate: dates.getRefuse(),
                                    onSelectedDate: (DateTime date) {
                                      setState(() {
                                        dates.refuse = date;
                                      });
                                    },
                                  )),
                            ])
                      : Container(),
                ]),
                space(height: 10),
                (project.statusInt() >= 5)
                    ? Row(children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 220,
                                  child: DateTimePicker(
                                    labelText: 'Inicio',
                                    selectedDate: dates.getStart(),
                                    onSelectedDate: (DateTime date) {
                                      setState(() {
                                        dates.start = date;
                                      });
                                    },
                                  )),
                            ]),
                        space(width: 20),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 220,
                                  child: DateTimePicker(
                                    labelText: 'Fin',
                                    selectedDate: dates.getEnd(),
                                    onSelectedDate: (DateTime date) {
                                      setState(() {
                                        dates.end = date;
                                      });
                                    },
                                  )),
                            ]),
                        space(width: 20),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 220,
                                  child: DateTimePicker(
                                    labelText: 'Justificación',
                                    selectedDate: dates.getJustification(),
                                    onSelectedDate: (DateTime date) {
                                      setState(() {
                                        dates.justification = date;
                                      });
                                    },
                                  )),
                            ]),
                        /*space(width: 20),
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
                space(width: 20),*/
                      ])
                    : Container(),
              ]),
            );
          }),
          actions: <Widget>[dialogsBtns(context, saveDates, dates)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           DATES AUDIT                              */
  /*--------------------------------------------------------------------*/
  void saveDateAudit(List args) async {
    ProjectDatesAudit datesAudit = args[0];
    datesAudit.save();
    loadProject();

    Navigator.pop(context);
  }

  void removeDateAuditDialog(context, Map<String, dynamic> args) {
    customRemoveDialog(context, args["dateAudit"], loadProject, null);
  }

  void callDatesAuditEditDialog(context, args) async {
    SProject project = args["project"];
    ProjectDatesAudit pdt = ProjectDatesAudit(project.uuid);
    editProjectDatesAuditDialog(context, pdt);
  }

  Future<void> editProjectDatesAuditDialog(context, dateAudit) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Nueva fecha'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Fecha de auditoría',
                        selectedDate: dateAudit.date,
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            dateAudit.date = date;
                          });
                        },
                      )),
                ]),
              ]),
            );
          }),
          actions: <Widget>[dialogsBtns(context, saveDateAudit, dateAudit)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           DATES EVALUATION                         */
  /*--------------------------------------------------------------------*/
  void saveDateEval(List args) async {
    ProjectDatesEval datesEval = args[0];
    datesEval.save();
    loadProject();

    Navigator.pop(context);
  }

  void removeDateEvalDialog(context, Map<String, dynamic> args) {
    customRemoveDialog(context, args["dateEval"], loadProject, null);
  }

  void callDatesEvalEditDialog(context, args) async {
    SProject project = args["project"];
    ProjectDatesEval pdt = ProjectDatesEval(project.uuid);
    editProjectDatesEvalDialog(context, pdt);
  }

  Future<void> editProjectDatesEvalDialog(context, dateEval) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Nueva fecha'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Fecha de evaluación',
                        selectedDate: dateEval.date,
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            dateEval.date = date;
                          });
                        },
                      )),
                ]),
              ]),
            );
          }),
          actions: <Widget>[dialogsBtns(context, saveDateEval, dateEval)],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           DATES TRACING                            */
  /*--------------------------------------------------------------------*/
  void saveDateTracing(List args) async {
    ProjectDatesTracing datesTracing = args[0];
    datesTracing.save();
    loadProject();

    Navigator.pop(context);
  }

  void removeDateTracingDialog(context, Map<String, dynamic> args) {
    customRemoveDialog(context, args["dateTracing"], loadProject, null);
  }

  void callDatesTracingEditDialog(context, args) async {
    SProject project = args["project"];
    ProjectDatesTracing pdt = ProjectDatesTracing(project.uuid);
    editProjectDatesTracingDialog(context, pdt);
  }

  Future<void> editProjectDatesTracingDialog(context, dateTracing) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Nueva fecha'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Informe de seguimiento',
                        selectedDate: dateTracing.date,
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            dateTracing.date = date;
                          });
                        },
                      )),
                ]),
              ]),
            );
          }),
          actions: <Widget>[dialogsBtns(context, saveDateTracing, dateTracing)],
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
    projectsProvider!.addLocation(loc, notify: false);
    loadProject();
    projectInfoLocationPanel = projectInfoLocation(context, project);
    projectInfoDetailsPanel = projectInfoDetails(context);
    if (!mounted) return;
    setState(() {});
    Navigator.pop(context);
  }

  void _callLocationEditDialog(context, project) async {
    List<KeyValue> countries =
        await Country.getCountriesHash(projectsProvider!.countries);
    List<KeyValue> provinces =
        await Province.getProvincesHash(projectsProvider!.provinces);
    List<KeyValue> regions =
        await Region.getRegionsHash(projectsProvider!.regions);
    List<KeyValue> towns = await Town.getTownsHash(projectsProvider!.towns);
    ProjectLocation currentLoc = projectsProvider!.locations.firstWhere(
        (loc) => loc.project == project.uuid,
        orElse: () => ProjectLocation(project.uuid));
    // await ProjectLocation.getProjectLocationByProject(project.uuid)
    //     .then((value) async {
    //   editProjectLocationDialog(
    //       context, value, project, countries, provinces, regions, towns);
    // });
    editProjectLocationDialog(
        context, currentLoc, project, countries, provinces, regions, towns);
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

  /*--------------------------------------------------------------------*/
  /*                           STATUS                                   */
  /*--------------------------------------------------------------------*/
  void saveCustomDate(List args) async {
    ProjectDates dates = args[0];
    dates.save();
    project!.status = args[1];
    project!.save();
    //project!.changeStatus(dates);
    loadProject();

    Navigator.pop(context);
  }

  void saveCustomStatus(st) {
    project!.status = st;
    project!.save();
    loadProject();
  }

  void callCustomDatesEditDialog(context, args) async {
    editCustomDateDialog(context, args["project"], args["st"]);
  }

  Future<void> editCustomDateDialog(context, project, st) {
    ProjectDates dates = project.datesObj;
    switch (st) {
      case statusReject:
        dates.reject = dates.getReject();
      case statusApproved:
        dates.approved = dates.getApproved();
      case statusRefuse:
        dates.refuse = dates.getRefuse();
      case statusStart:
        dates.start = dates.getStart();
      case statusEnds:
        dates.end = dates.getEnd();
      case statusJustification:
        dates.justification = dates.getJustification();
      case statusDelivery:
        dates.delivery = dates.getDelivery();
      default:
        dates.sended = dates.getSended();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar plazos'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                child: Column(children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //customDateField(context, dates, st),
                  (st == statusReject)
                      ? SizedBox(
                          width: 220,
                          child: DateTimePicker(
                            labelText: 'Denegación',
                            selectedDate: dates.reject,
                            onSelectedDate: (DateTime date) {
                              setState(() {
                                dates.reject = date;
                              });
                            },
                          ))
                      : Container(),
                  (st == statusApproved)
                      ? SizedBox(
                          width: 220,
                          child: DateTimePicker(
                            labelText: 'Aprobación',
                            selectedDate: dates.approved,
                            onSelectedDate: (DateTime date) {
                              setState(() {
                                dates.approved = date;
                              });
                            },
                          ))
                      : Container(),
                  (st == statusRefuse)
                      ? SizedBox(
                          width: 220,
                          child: DateTimePicker(
                            labelText: 'Rechazo',
                            selectedDate: dates.refuse,
                            onSelectedDate: (DateTime date) {
                              setState(() {
                                dates.refuse = date;
                              });
                            },
                          ))
                      : Container(),
                  (st == statusStart)
                      ? SizedBox(
                          width: 220,
                          child: DateTimePicker(
                            labelText: 'Inicio',
                            selectedDate: dates.start,
                            onSelectedDate: (DateTime date) {
                              setState(() {
                                dates.start = date;
                              });
                            },
                          ))
                      : Container(),
                  (st == statusEnds)
                      ? SizedBox(
                          width: 220,
                          child: DateTimePicker(
                            labelText: 'Inicio',
                            selectedDate: dates.end,
                            onSelectedDate: (DateTime date) {
                              setState(() {
                                dates.end = date;
                              });
                            },
                          ))
                      : Container(),
                  (st == statusJustification)
                      ? SizedBox(
                          width: 220,
                          child: DateTimePicker(
                            labelText: 'Justificación',
                            selectedDate: dates.justification,
                            onSelectedDate: (DateTime date) {
                              setState(() {
                                dates.justification = date;
                              });
                            },
                          ))
                      : Container(),
                  (st == statusDelivery)
                      ? SizedBox(
                          width: 220,
                          child: DateTimePicker(
                            labelText: 'Seguimiento',
                            selectedDate: dates.delivery,
                            onSelectedDate: (DateTime date) {
                              setState(() {
                                dates.delivery = date;
                              });
                            },
                          ))
                      : Container(),
                  (st == statusSended)
                      ? SizedBox(
                          width: 220,
                          child: DateTimePicker(
                            labelText: 'Presentación',
                            //selectedDate: dates.getSended(),
                            selectedDate: dates.sended,
                            onSelectedDate: (DateTime date) {
                              setState(() {
                                dates.sended = date;
                              });
                            },
                          ))
                      : Container(),
                ])
              ])
            ]));
          }),
          actions: <Widget>[
            dialogsBtns2(context, saveCustomDate, [dates, st])
          ],
        );
      },
    );
  }

  Widget projectStatusChange(context, project) {
    return Row(
      children: [
        (project.statusInt() < 2)
            ? /*addBtn(context, callDatesEditDialog, project,
                icon: Icons.edit, text: "Presentar")*/
            addBtnRow(context, callCustomDatesEditDialog,
                {'project': project, 'st': statusSended},
                text: "Presentar", icon: Icons.slideshow_outlined)
            : Column(children: [
                customText("Presentado", 16),
                Row(
                  children: [
                    customText(project.datesObj.getSendedStr(), 16),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        saveCustomStatus(statusFormulation);
                      },
                    )
                  ],
                )
              ]),
        space(width: 20),
        (project.statusInt() > 1) ? const Icon(Icons.arrow_right) : Container(),
        space(width: 20),
        (project.statusInt() == 2)
            ? Row(children: [
                addBtnRow(context, callCustomDatesEditDialog,
                    {'project': project, 'st': statusApproved},
                    text: "Aprobar", icon: Icons.thumb_up_outlined),
                addBtnRow(context, callCustomDatesEditDialog,
                    {'project': project, 'st': statusReject},
                    text: "Denegar", icon: Icons.thumb_down_outlined),
              ])
            : (project.statusInt() == 3)
                ? Column(children: [
                    customText("Denegado", 16),
                    Row(
                      children: [
                        customText(project.datesObj.getRejectStr(), 16),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            saveCustomStatus(statusSended);
                          },
                        )
                      ],
                    )
                  ])
                : (project.statusInt() >= 5)
                    ? Column(children: [
                        customText("Aprobado", 16),
                        Row(
                          children: [
                            customText(project.datesObj.getApprovedStr(), 16),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                saveCustomStatus(statusSended);
                              },
                            )
                          ],
                        )
                      ])
                    : Container(),
        space(width: 20),
        (project.statusInt() > 4) ? const Icon(Icons.arrow_right) : Container(),
        space(width: 20),
        (project.statusInt() == 5)
            ? Row(children: [
                addBtnRow(context, callCustomDatesEditDialog,
                    {'project': project, 'st': statusStart},
                    text: "Iniciar", icon: Icons.play_circle_outline),
                addBtnRow(context, callCustomDatesEditDialog,
                    {'project': project, 'st': statusRefuse},
                    text: "Rechazar", icon: Icons.cancel_outlined),
              ])
            : (project.statusInt() >= 6)
                ? Column(children: [
                    customText("Iniciado", 16),
                    Row(
                      children: [
                        customText(project.datesObj.getStartStr(), 16),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            saveCustomStatus(statusApproved);
                          },
                        )
                      ],
                    )
                  ])
                : (project.statusInt() == 4)
                    ? Column(children: [
                        customText("Rechazado", 16),
                        Row(
                          children: [
                            customText(project.datesObj.getRefuseStr(), 16),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                saveCustomStatus(statusApproved);
                              },
                            )
                          ],
                        )
                      ])
                    : Container(),
        space(width: 20),
        (project.statusInt() > 5) ? const Icon(Icons.arrow_right) : Container(),
        space(width: 20),
        (project.statusInt() == 6)
            ? Row(children: [
                addBtnRow(context, callCustomDatesEditDialog,
                    {'project': project, 'st': statusEnds},
                    text: "Finalizar", icon: Icons.sports_score_outlined),
              ])
            : (project.statusInt() >= 6)
                ? Column(children: [
                    customText("Finalizado", 16),
                    Row(
                      children: [
                        customText(project.datesObj.getEndStr(), 16),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            saveCustomStatus(statusStart);
                          },
                        )
                      ],
                    )
                  ])
                : Container(),
        space(width: 20),
        (project.statusInt() > 6) ? const Icon(Icons.arrow_right) : Container(),
        space(width: 20),
        (project.statusInt() == 7)
            ? Row(children: [
                addBtnRow(context, callCustomDatesEditDialog,
                    {'project': project, 'st': statusJustification},
                    text: "Justificar", icon: Icons.history_edu_outlined),
              ])
            : (project.statusInt() >= 7)
                ? Column(children: [
                    customText("Justificado", 16),
                    Row(
                      children: [
                        customText(project.datesObj.getJustificationStr(), 16),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            saveCustomStatus(statusEnds);
                          },
                        )
                      ],
                    )
                  ])
                : Container(),
        space(width: 20),
        (project.statusInt() > 7) ? const Icon(Icons.arrow_right) : Container(),
        space(width: 20),
        (project.statusInt() == 8)
            ? Row(children: [
                addBtnRow(context, callCustomDatesEditDialog,
                    {'project': project, 'st': statusDelivery},
                    text: "Evaluar", icon: Icons.manage_search_outlined),
              ])
            : (project.statusInt() >= 8)
                ? Column(children: [
                    customText("Evaluado", 16),
                    Row(
                      children: [
                        customText(project.datesObj.getDeliveryStr(), 16),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            saveCustomStatus(statusJustification);
                          },
                        )
                      ],
                    )
                  ])
                : Container(),
      ],
    );
  }
}
