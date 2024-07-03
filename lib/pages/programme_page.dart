import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/projects_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const programmeTitle = "Programas";
bool loading = false;
Widget? _mainMenu;

class ProgrammePage extends StatefulWidget {
  final Programme? programme;
  const ProgrammePage({super.key, this.programme});

  @override
  State<ProgrammePage> createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> {
  Programme? programme;
  Profile? profile;
  List projects = [];
  //List financiers = [];
  double totalBudget = 0.0;
  Map<String, double> financiers = {};
  Map<String, int> projStatus = {};

  Future<Map<String, double>> getProgrammeFinanciers() async {
    /*List financiers = [];
    for (SProject project in projects) {
      //List finList = await project.getFinanciers();
      List finList = await project.getFinns();
      for (SFinn financier in finList) {
        if (!financiers.contains(financier)) {
          financiers.add(financier);
        }
      }
    }*/

    Map<String, double> finMap = {};
    Map<String, String> finUUID = {};
    Map<String, dynamic> finnInfo = {};

    for (SProject project in projects) {
      List<Organization> finList = await project.getFinanciers();
      project.financiersObj = finList;
      for (Organization financier in finList) {
        finMap[financier.name] = 0;
        finUUID[financier.name] = financier.uuid;
      }
    }

    print("DBG 000");
    for (SProject project in projects) {
      print("DBG: ${project.uuid}");
      finnInfo[project.uuid] = await SFinnInfo.byProject(project.uuid);
    }

    finMap.forEach((key, value) async {
      double amount = 0;
      for (SProject project in projects) {
        try {
          amount += finnInfo[project.uuid].getContribByFinancier(finUUID[key]!);
        } catch (e) {}
      }
      finMap[key] = amount;
    });
    return finMap;
  }

  void loadProgrammeProjects() async {
    setState(() {
      loading = true;
    });
    await getProjectsByProgramme(programme!.uuid).then((val) async {
      projects = val;
      financiers = await getProgrammeFinanciers();
      projStatus["formulation"] =
          await programme!.getProjectsByStatus(statusFormulation);
      projStatus["sended"] = await programme!.getProjectsByStatus(statusSended);
      projStatus["reject"] = await programme!.getProjectsByStatus(statusReject);
      projStatus["refuse"] = await programme!.getProjectsByStatus(statusRefuse);
      projStatus["approved"] =
          await programme!.getProjectsByStatus(statusApproved);
      projStatus["start"] = await programme!.getProjectsByStatus(statusStart);
      projStatus["end"] = await programme!.getProjectsByStatus(statusEnds);
      projStatus["justification"] =
          await programme!.getProjectsByStatus(statusJustification);
      projStatus["close"] = await programme!.getProjectsByStatus(statusClose);
      projStatus["delivery"] =
          await programme!.getProjectsByStatus(statusDelivery);
    });
    setState(() {
      loading = false;
    });
    /*for (SProject p in projects) {
      await p.totalBudget();
      totalBudget = totalBudget + p.dblbudget;
    }*/

    for (SProject p in projects) {
      totalBudget = totalBudget + fromCurrency(p.budget);
    }
    setState(() {});
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
    programme = widget.programme;
    _mainMenu = mainMenu(context, "/projects");
    loadProgrammeProjects();

    final user = FirebaseAuth.instance.currentUser!;
    getProfile(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          _mainMenu!,
          programmeHeader(),
          loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    programmeSummary(),
                    programmeImpact(),
                    programmeProjects(context),
                  ],
                )
          //programmeList(context),
        ],
      ),
    ));
  }

  Widget programmeHeader() {
    return Container(
        padding: const EdgeInsets.only(left: 20, top: 20),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(programme!.logo),
            Container(
              padding: const EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(programme!.title, 16,
                      bold: FontWeight.bold, textColor: headerListTitleColor),
                  space(height: 10),
                  customText(programme!.description, 14),
                ],
              ),
            ),
            goPage(context, "Volver", const ProjectsPage(),
                Icons.arrow_circle_left_outlined),
            /*Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              addBtn(context, callDialog, {"programme": null},
                  text: "Añadir Programa"),
            ])*/
          ],
        ));
  }

  Widget programmeSummary() {
    return Container(
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Color(0xffdfdfdf), width: 1))),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            customText("Nº Proyectos", 16,
                bold: FontWeight.bold, textColor: headerListTitleColor),
            customText(projects.length.toString(), 16,
                bold: FontWeight.bold, textColor: headerListTitleColor),
          ]),
        ),
        projectByStatus(context),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: programmeProjectList(context)),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: programmeFinancierList(context)),
          ],
        ),
      ]),
    );
  }

  Widget programmeProjectList(context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            /*customText("Nº Proyectos", 16,
                bold: FontWeight.bold, textColor: headerListTitleColor),
            customText(projects.length.toString(), 16,
                bold: FontWeight.bold, textColor: headerListTitleColor),*/
            customText("Inversión total", 16,
                bold: FontWeight.bold, textColor: headerListTitleColor),
            customText("${currencyFormat.format(totalBudget)} €", 16,
                bold: FontWeight.bold, textColor: headerListTitleColor),
          ]),
        ),
        ListView.builder(
            //padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: projects.length,
            itemBuilder: (BuildContext context, int index) {
              SProject proj = projects[index];
              return Container(
                height: 50,
                padding: const EdgeInsets.only(top: 20, left: 20),
                //padding: const EdgeInsets.all(15),
                /*decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xffdfdfdf), width: 1)),
                ),*/
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText(proj.name, 14),
                      customLinearPercent(context, 4.5, 0.5, percentBarPrimary),
                      customText(proj.budget, 14)
                    ]),
              );
            })
      ],
    );
  }

  Widget programmeFinancierList(context) {
    return Container(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Financiadores", 16,
                      bold: FontWeight.bold, textColor: headerListTitleColor),
                  customText("", 16,
                      bold: FontWeight.bold, textColor: headerListTitleColor),
                ]),
          ),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: financiers.length,
              itemBuilder: (BuildContext context, int index) {
                //SFinn financier = financiers[index];
                //final contrib = financier.getTotalContrib();
                String key = financiers.keys.elementAt(index);
                return SizedBox(
                  height: 30,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(key, 14),
                        customText(financiers[key].toString(), 14)
                      ]),
                );
              })
        ],
      ),
    );
  }

  Widget projectByStatus(context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
          width: double.infinity,
          child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(children: [
                  customText("En formulación: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['formulation']}", 14,
                      bold: FontWeight.bold),
                  customText("Presentados: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['sended']}", 14,
                      bold: FontWeight.bold),
                  customText("Denegados: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['reject']}", 14,
                      bold: FontWeight.bold),
                  customText("Rechazados: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['refuse']}", 14,
                      bold: FontWeight.bold),
                  customText("Aprobados: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['approved']}", 14,
                      bold: FontWeight.bold),
                ]),
                TableRow(children: [
                  space(height: 10),
                  space(height: 10),
                  space(height: 10),
                  space(height: 10),
                  space(height: 10),
                  space(height: 10),
                  space(height: 10),
                  space(height: 10),
                  space(height: 10),
                  space(height: 10),
                ]),
                TableRow(children: [
                  customText("En ejecución: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['start']}", 14,
                      bold: FontWeight.bold),
                  customText("Finalizados: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['end']}", 14, bold: FontWeight.bold),
                  customText("En evalución: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['justification']}", 14,
                      bold: FontWeight.bold),
                  customText("Cerrados: ", 14, textColor: headerListTitleColor),
                  customText("${projStatus['close']}", 14,
                      bold: FontWeight.bold),
                  customText("En seguimiento: ", 14,
                      textColor: headerListTitleColor),
                  customText("${projStatus['delivery']}", 14,
                      bold: FontWeight.bold),
                ]),
              ])),
    );
  }

  Widget programmeImpact() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Color(0xffdfdfdf), width: 1))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText("Impacto (Objetivo Cero)", 16,
                bold: FontWeight.bold, textColor: headerListTitleColor),
            customText(programme!.impact, 14),
          ],
        ));
  }

  Widget programmeProjects(context) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: projects.length,
            itemBuilder: (BuildContext context, int index) {
              SProject project = projects[index];
              return customCollapse(
                  context, project.name, programmeProjectDetails, project,
                  expanded: true);
            }));
  }

/*-------------------------------------------------------------
                     PROJECTS
-------------------------------------------------------------*/
  Future<SProject> loadProjectObjects(project) async {
    project.datesObj = await project.getDates();
    project.locationObj = await project.getLocation();
    return project;
  }

  Widget programmeProjectDetails(context, project) {
    return Column(
      children: [
        programmeProjectDetails1(context, project),
        programmeProjectDetails2(context),
        programmeProjectDetails3(context, project),
        space(height: 20),
      ],
    );
  }

  Widget programmeProjectDetails1(context, project) {
    return FutureBuilder(
        future: loadProjectObjects(project),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            SProject proj = snapshot.data!;
            return Column(children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: customText(proj.description, 14),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(children: [
                      Row(children: [
                        customText(proj.locationObj.regionObj.name, 14),
                        customText(", ", 14),
                        customText(proj.locationObj.countryObj.name, 14)
                      ]),
                      Row(children: [
                        customText(
                            DateFormat("dd-MM-yyyy")
                                .format(proj.datesObj.start),
                            14),
                        customText(" - ", 14),
                        customText(
                            DateFormat("dd-MM-yyyy").format(proj.datesObj.end),
                            14)
                      ]),
                    ]),
                  )
                ],
              )
            ]);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget programmeProjectDetails2(context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText("Principales impactos", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
              space(height: 10),
              customText("Principales...", 14),
            ]),
      ),
    ]);
  }

  Widget programmeProjectDetails3(context, project) {
    List finList = project.financiersObj;

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          //child: customText("_text", 16),
          child: DataTable(
            sortColumnIndex: 0,
            columns: [
              DataColumn(
                  label: customText("Financiadores", 14,
                      bold: FontWeight.bold, textColor: headerListTitleColor),
                  tooltip: "Financiadores"),
              DataColumn(
                label: customText("Inversión", 14,
                    bold: FontWeight.bold, textColor: headerListTitleColor),
                tooltip: "Inversión",
              ),
              DataColumn(
                  label: customText("Importe", 14,
                      bold: FontWeight.bold, textColor: headerListTitleColor),
                  tooltip: "Importe"),
            ],
            rows: finList
                .map(
                  (finn) => DataRow(cells: [
                    DataCell(customText(finn.name, 14)),
                    DataCell(customText(finn.name, 14)),
                    DataCell(customText(financiers[finn.name].toString(), 14)),
                  ]),
                )
                .toList(),
          ),
        ));
  }
}
