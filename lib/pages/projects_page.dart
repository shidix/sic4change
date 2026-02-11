import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:googleapis/cloudresourcemanager/v3.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/documents_page.dart';
import 'package:sic4change/pages/finns_page.dart';
import 'package:sic4change/pages/goals_page.dart';
import 'package:sic4change/pages/programme_page.dart';
import 'package:sic4change/pages/project_info_page.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/cache_projects.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_quality.dart';
import 'package:sic4change/services/models_risks.dart';
import 'package:sic4change/services/programme_form.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/services/check_permissions.dart';

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
  // List prList = [];
  List programList = [];
  Profile? profile;
  Organization? currentOrg;
  String deleteMsg = "";
  late ProfileProvider? _profileProvider;
  late ProjectsProvider? _projectsProvider;
  get projectsCache => _projectsProvider;
  late VoidCallback _listener;
  final user = FirebaseAuth.instance.currentUser!;

  Widget contentTopButtons = Container();
  Widget programmeListPanel = Container();
  Widget projectListPanel = Container();
  Widget projectFilter = Container();

  String searchText = "";
  String searchStatus = "";
  String searchType = "";

  void setLoading() {
    loading = true;
    if (!mounted) return;
    setState(() {
      loading = true;
    });
  }

  void stopLoading() {
    loading = false;
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  void loadProgrammes() async {
    programList = _projectsProvider!.programmes;
    if ((programList.isEmpty)) {
      programList = await Programme.getProgrammes();
    }
    programmeListPanel = programmeList();
    if (!mounted) return;
    setState(() {});
  }

  void loadProjects() async {
    setLoading();
    if ((projectsCache!.projects.isEmpty)) {
      await projectsCache!.initialize();
    }

    List<KeyValue> statusOptions = [];
    for (ProjectStatus st in projectsCache!.status) {
      statusOptions.add(KeyValue(st.uuid, st.name));
    }
    statusOptions.sort((a, b) => a.value.compareTo(b.value));
    statusOptions.insert(0, KeyValue("all", "Todos"));

    List<KeyValue> typeOptions = [];
    for (ProjectType pt in projectsCache!.types) {
      typeOptions.add(KeyValue(pt.uuid, pt.name));
    }
    typeOptions.sort((a, b) => a.value.compareTo(b.value));
    typeOptions.insert(0, KeyValue("all", "Todos"));

    projectFilter = Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: CustomDropdown(
                      labelText: "Filtrar por tipo",
                      size: 0.3,
                      options: typeOptions,
                      selected: typeOptions.first,
                      onSelectedOpt: (uuid) {
                        searchType = uuid;
                        if (!mounted) return;
                        setState(() {
                          projectListPanel = projectList();
                        });
                      }))),
          Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: CustomDropdown(
                    labelText: "Filtrar por estado",
                    size: 0.3,
                    options: statusOptions,
                    selected: statusOptions.first,
                    onSelectedOpt: (uuid) {
                      searchStatus = uuid;
                      if (!mounted) return;
                      setState(() {
                        projectListPanel = projectList();
                      });
                    })),
          ),
          Expanded(
            flex: 2,
            child: Container(
              // width: 500,
              child: SearchBar(
                hintText: 'Buscar proyecto por nombre (mínimo 3 caracteres)...',
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 10.0)),
                onTap: () {},
                onChanged: (searchValue) {
                  searchText = searchValue;
                  if (!mounted) return;
                  setState(() {
                    searchText = searchValue;
                    projectListPanel = projectList();
                  });
                },
                leading: const Icon(Icons.search),
              ),
            ),
          ),
        ]));
    projectListPanel = projectList();

    if (mounted) {
      setState(() {});
    }
    stopLoading();
  }

  void getProfile(user) {
    // profile = _profileProvider!.profile;
    // currentOrg = _profileProvider!.organization;
    profile ??= Provider.of<ProfileProvider>(context, listen: false).profile;
    currentOrg ??=
        Provider.of<ProfileProvider>(context, listen: false).organization;

    // await Profile.getProfile(user.email!).then((value) {
    //   profile = value;
    //   //print(profile?.mainRole);
    // });
  }

  void initializeData() async {
    // // loadProjects();
    // _projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
    // _projectsProvider = context.read<ProjectsProvider?>();
    // _projectsProvider ??= ProjectsProvider();
    // // _projectsProvider.profile = profile;
    // // _projectsProvider.organization = currentOrg;
    // if (prList.isEmpty) {
    //   loadProjects();
    // }
    // _projectsProvider!.addListener(() {
    //   // prList = _projectsProvider.projects;
    //   loadProjects();
    //   if (!mounted) return;
    //   setState(() {});
    // });
    // if (_projectsProvider!.projects.isEmpty) {
    //   _projectsProvider!.initialize();
    // }
    loadProgrammes();
    loadProjects();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // _projectsProvider!.removeListener(_listener);
    // _projectsProvider!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _mainMenu = mainMenu(context, "/projects");
    _projectsProvider = context.read<ProjectsProvider?>();
    _projectsProvider ??= ProjectsProvider();

    try {
      _profileProvider = context.read<ProfileProvider?>();
    } catch (e) {
      _profileProvider = ProfileProvider();
    }

    _listener = () {
      if (!mounted) return;
      getProfile(user);
      _mainMenu = mainMenu(context, "/projects");
      profile = _profileProvider!.profile;
      currentOrg = _profileProvider!.organization;
      if (!((profile != null) && (currentOrg != null))) {
        _profileProvider!.loadProfile();
      }
      if (mounted) setState(() {});
    };
    _profileProvider!.addListener(_listener);

    if ((profile == null) || (currentOrg == null)) {
      _profileProvider!.loadProfile();
      getProfile(user);
    }

    try {
      _projectsProvider = context.read<ProjectsProvider?>();
    } catch (e) {
      _projectsProvider = ProjectsProvider();
    }

    _projectsProvider ??= context.read<ProjectsProvider?>();
    if (projectsCache!.projects.isEmpty) {
      loadProjects();
    }
    _projectsProvider!.addListener(() {
      // prList = _projectsProvider.projects;
      loadProjects();
      if (!mounted) return;
      setState(() {});
    });

    contentTopButtons = projectTopButtons();
    programmeListPanel = programmeList();
    projectListPanel = projectList();

    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mainMenu!,
          contentTopButtons,
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              child: customTitle(context, "PROGRAMAS")),
                          programmeListPanel,
                        ])),
                Expanded(
                    flex: 5,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              child: customTitle(context, "INICIATIVAS")),
                          projectFilter,
                          space(height: 10),
                          loading
                              ? const Center(child: CircularProgressIndicator())
                              : projectListPanel,
                        ])),
              ]),
        ],
      ),
    ));
  }

  Widget projectTopButtons() {
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
              if (canAddProgramme(profile))
                addBtn(context, callDialog,
                    {"programme": Programme('Nuevo programa')},
                    text: "Añadir Programa"),
              space(width: 10),
              if (canAddProject(profile))
                addBtn(context, callProjectDialog, {"programme": null},
                    text: "Añadir Iniciativa"),
            ]),
          ],
        ));
  }

/*-------------------------------------------------------------
                     PROGRAMMES
-------------------------------------------------------------*/

  Widget programmeList() {
    return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            for (var programme in programList)
              Tooltip(
                  message: "${programme.name}",
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                          child: Column(
                            children: [
                              (programme.logo != '')
                                  ? Image.network(programme.logo, height: 50)
                                  : const SizedBox(height: 50, width: 50),
                              space(width: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  customText(
                                      programme.name.length < 16
                                          ? programme.name
                                          : programme.name.substring(0, 15) +
                                              "...",
                                      16,
                                      bold: FontWeight.bold,
                                      textColor: mainColor),
                                  if (canAddProgramme(profile))
                                    editBtn(context, callDialog,
                                        {'programme': programme}),
                                ],
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) =>
                                        ProgrammePage(programme: programme))));
                          }),
                      const Divider(color: Colors.grey),
                      space(height: 10),
                    ],
                  )),
          ],
        ));
  }

  void callDialog(context, args) {
    programmeEditDialog(args["programme"]);
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  void saveProgramme(List args) async {
    Programme programme = args[0];

    String tmpPath = "files/programmes/${programme.id}/logoTemp.png";
    String logoPath = "files/programmes/${programme.id}/logo.png";
    logoPath = await moveFileInStorage(tmpPath, logoPath);
    programme.logo = await getDownloadUrl(logoPath);
    programme.save();
    _projectsProvider!.addProgramme(programme);
    loadProgrammes();
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<String> uploadLogoProgramme(PlatformFile? file, int index) async {
    if (file != null) {
      String extention = file.name.split('.').last;
      String idPrograme = _projectsProvider!.programmes[index].id;

      String uploadFile = await uploadFileToStorage(file,
          rootPath: 'files/programmes/$idPrograme',
          fileName: 'logo.$extention');
      // await _projectsProvider!.programmes[index].save();
      _projectsProvider!.programmes[index].logo =
          await getDownloadUrl(uploadFile);
      await _projectsProvider!.programmes[index].save();
      if (mounted) {
        setState(() {});
      }
      return _projectsProvider!.programmes[index].logo;
    }
    return "";
  }

  Future<void> programmeEditDialog(programme) {
    // Check permission
    ProfileProvider profileProvider = context.read<ProfileProvider>();
    Profile? profile = profileProvider.profile;
    if ((profile == null) || (!profile.isAdmin())) {
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

/*-------------------------------------------------------------
                     PROJECTS
-------------------------------------------------------------*/
  Widget projectList({bool inline = true}) {
    List<SProject> filteredProjects = [];
    filteredProjects = List<SProject>.from(_projectsProvider!.projects);
    if (searchStatus != "" && searchStatus != "all") {
      filteredProjects.removeWhere((p) => p.status != searchStatus);
    }

    if (searchType != "" && searchType != "all") {
      filteredProjects.removeWhere((p) => p.type != searchType);
    }

    if (searchText.length >= 3) {
      filteredProjects.removeWhere(
          (p) => !p.name.toLowerCase().contains(searchText.toLowerCase()));
    }

    if (inline) {
      return Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
              height: 900,
              child: ListView.builder(
                  itemCount: filteredProjects.length,
                  itemBuilder: (_, index) {
                    return Column(children: [
                      projectCard(context, filteredProjects[index],
                          inline: true),
                      const Divider(color: Colors.grey),
                    ]);
                  })));
    } else {
      return Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
              height: 900,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 12,
                  ),
                  itemCount: filteredProjects.length,
                  itemBuilder: (_, index) {
                    return projectCard(context, filteredProjects[index]);
                  })));
    }
  }

  Widget projectCard(context, project, {bool inline = true}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: (inline
          ? projectInLineData(context, project)
          : projectCardDatas(context, project)),
      /*child: SingleChildScrollView(
        child: projectCardDatas(context, _project),
      ),*/
    );
  }

  Widget projectInLineData(context, SProject project) {
    // Code, status, type, budget, assigned budget, executed budget
    Programme programme = _projectsProvider!.programmes.firstWhere(
        (prog) => prog.uuid == project.programme,
        orElse: () => Programme('NON EXISTENT'));

    // Extracte acronym from programme name => Trhee first letter for each word in uppercase
    String progAcronym =
        (programme.code != "" ? programme.code : programme.name)
            .split(' ')
            .map((word) => ((word.isNotEmpty) && (word.length >= 3))
                ? word.substring(0, 3).toUpperCase()
                : '')
            .join();

    String projectAcronym = (project.code != "")
        ? project.code
        : project.name
            .split(' ')
            .map((word) =>
                ((word.length > 3) || (RegExp(r'^[0-9]+$').hasMatch(word)))
                    ? word.substring(0, min(3, word.length)).toUpperCase()
                    : '')
            .join();
    if (projectAcronym.isEmpty) {
      projectAcronym =
          project.name.toUpperCase().replaceAll(RegExp(r'[^(A-Z0-9)]'), '');
    }
    if (projectAcronym.length > 9) {
      projectAcronym = projectAcronym.substring(0, 9);
    }
    projectAcronym = projectAcronym.replaceAll('\r', '').replaceAll('\n', '');

    String annAcronym = (project.announcementCode != "")
        ? project.announcementCode
        : project.announcement
            .split(' ')
            .map((word) =>
                ((word.length > 3) || (RegExp(r'^[0-9]+$').hasMatch(word)))
                    ? word.substring(0, min(3, word.length)).toUpperCase()
                    : '')
            .join();

    List<Organization> financiers = [];
    for (var uuid in project.financiers) {
      try {
        financiers.add(projectsCache!.organizations
            .firstWhere((org) => ((org.uuid == uuid) && (org != currentOrg))));
      } catch (e) {
        continue; // Ignore errors if the object is not found
      }
    }

    List<Organization> partners = [];
    for (var uuid in project.partners) {
      try {
        partners.add(projectsCache!.organizations
            .firstWhere((org) => ((org.uuid == uuid) && (org != currentOrg))));
      } catch (e) {
        continue; // Ignore errors if the object is not found
      }
    }

    List<Country> countries = [];
    for (var locations in project.locations) {
      try {
        Country country = projectsCache!.countries
            .firstWhere((ctry) => (ctry.uuid == locations['country']));
        if (!countries.contains(country)) {
          countries.add(country);
        }
      } catch (e) {
        continue; // Ignore errors if the object is not found
      }
    }

    String finnAcronym = (financiers.isNotEmpty)
        ? financiers.map((finn) => finn.acronym()).join('-')
        : "NDF"; // No definido financiador
    String partAcronym = (partners.isNotEmpty)
        ? partners.map((part) => part.acronym()).join('-')
        : "NDP"; // No definido partner
    String countryAcronym = "NDC";
    if (countries.isNotEmpty) {
      countryAcronym = countries.map((country) => country.code).join('-');
    }

    // Acronym format: YYYY-FINN-CONV-PARTN-COUNTRY-PROG-PROY

    String acronym = (project.announcementYear.isNotEmpty)
        ? "${project.announcementYear}-$finnAcronym-$annAcronym-$partAcronym-$countryAcronym-$progAcronym-$projectAcronym"
        : "0000-$progAcronym-$annAcronym-$projectAcronym";

    acronym =
        getAcronym(projectsCache!, project, currentOrg ?? Organization(''));

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              flex: 4,
              child: InkWell(
                child: Text(acronym, style: mainText),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) =>
                              ProjectInfoPage(project: project))));
                },
              )),
          Expanded(
              flex: 1,
              child: Text(project.statusObj.name,
                  style: normalText, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(project.typeObj.name,
                  style: normalText, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text("${project.budget} €",
                  style: normalText, textAlign: TextAlign.center)),
          // Expanded(
          //     flex: 1,
          //     child: Text("${toCurrency(project.assignedBudget)} €",
          //         style: normalText, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text("${toCurrency(project.execBudget)} €",
                  style: normalText, textAlign: TextAlign.center)),
          Expanded(
              flex: 2,
              child: projectCardButtons(context, project, inline: true)),
        ],
      ),
      // space(height: 10),
      // projectCardButtons(context, project, inline: true),
    ]);
  }

  Widget projectCardDatasHeader(context, project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 1,
                child: customText(project.statusObj.name.toUpperCase(), 15,
                    textColor: mainColor)),
            Expanded(
                flex: 1,
                child: customText(project.typeObj.name.toUpperCase(), 15,
                    textColor: mainColor, align: TextAlign.center)),
            Expanded(
                flex: 1,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Eliminar proyecto',
                      onPressed: () {
                        projectRemoveDialog(context, project);
                      },
                    ))),
          ],
        ),
        space(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 6,
              child: customText(project.name, 20, bold: FontWeight.bold),
            )
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
        try {
          financiers.add(
              (getObject(project.financiersObj, uuid) as Organization).name);
        } catch (e) {
          continue; // Ignore errors if the object is not found
        }
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
        Object? obj = getObject(project.partnersObj, uuid);
        if (obj != Null) {
          partners.add((obj as Organization).name);
        } else {
          project.partners.remove(uuid);
          project.save();
        }
        // partners
        //     .add((getObject(project.partnersObj, uuid) as Organization).name);
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

  Widget projectCardButtons(context, SProject project, {bool inline = false}) {
    if (!inline) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          goPage(
              context, "+ Info", ProjectInfoPage(project: project), Icons.info,
              style: "bigBtn", extraction: () {}),
          (project.folderObj.uuid != "")
              ? goPage(context, "Documentos",
                  DocumentsPage(currentFolder: project.folderObj), Icons.info,
                  style: "bigBtn", extraction: () {})
              : Container(),
          goPage(
              context, "Marco técnico", GoalsPage(project: project), Icons.task,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(
              context, "Presupuesto", FinnsPage(project: project), Icons.euro,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          customBtn(context, "Personal", Icons.people, "/projects", {}),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          goPageIcon(
            context,
            "+ Info",
            Icons.info,
            ProjectInfoPage(project: project),
          ),
          (project.folderObj.uuid != "")
              ? goPageIcon(
                  context,
                  "Documentos",
                  Icons.folder,
                  DocumentsPage(currentFolder: project.folderObj),
                )
              : Container(),
          goPageIcon(
            context,
            "Marco técnico",
            Icons.task,
            GoalsPage(project: project),
          ),
          goPageIcon(
            context,
            "Presupuesto",
            Icons.euro,
            FinnsPage(project: project),
          ),
        ],
      );
    }
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
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText(
                          "En ejecución: ${toCurrency(project.assignedBudget)}",
                          16),
                      space(height: 5),
                      /*customLinearPercent(
                      context, 4.5, execVsAssigned, percentBarPrimary),*/
                      customLinearPercent(context, 4.5,
                          project.getExecVsAssigned(), percentBarPrimary),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                            "Presupuesto total:   ${project.budget} €", 16),
                        space(height: 5),
                        //customLinearPercent(context, 4.5, execVsBudget, blueColor),
                        customLinearPercent(
                            context, 4.5, project.getExecVsBudget(), blueColor),
                      ])),
            ],
          ),
        ),
        space(height: 5),
        const Divider(color: Colors.grey),
        space(height: 5),
        customText("Responsable del proyecto:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(project.managerObj.getFullName(), 16),
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
    _projectsProvider!.addProject(project, notify: true);
  }

  void saveProject(List args) async {
    SProject project = args[0];
    if (project.folder == "") {
      Folder folder = await project.createFolder();
      _projectsProvider!.addFolder(folder, notify: true);
    }

    setProjectStatus(project);
    if (!mounted) return;
    Navigator.pop(context);
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

    List<ProjectDates> pdList = _projectsProvider!.projectDates
        .where((pd) => pd.project == project.uuid)
        .toList();
    for (ProjectDates pd in pdList) {
      _projectsProvider!.removeProjectDates(pd);
      pd.delete();
    }

    List<ProjectLocation> plList = _projectsProvider!.locations
        .where((pl) => pl.project == project.uuid)
        .toList();
    for (ProjectLocation pl in plList) {
      _projectsProvider!.removeLocation(pl);
      pl.delete();
    }

    List refList = await Reformulation.getReformulationsByProject(project.uuid);
    for (Reformulation ref in refList) {
      ref.delete();
    }

    List riskList = await Risk.getRisksByProject(project.uuid);
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

    Folder? folder;

    if (_projectsProvider!.folders.any((f) => f.uuid == project.folder)) {
      folder = _projectsProvider!.folders
          .firstWhere((f) => f.uuid == project.folder);
      _projectsProvider!.removeFolder(folder);
    } else {
      folder = await Folder.getFolderByUuid(project.folder);
    }

    bool haveChildren = await folder?.haveChildren() ?? false;
    if (!haveChildren) {
      folder?.delete();
    } else if (folder != null) {
      folder.name = "BORRADO!-${folder.name}";
      folder.save();
    }

    // await Folder.getFolderByUuid(project.folder);
    // bool haveChildren = await folder!.haveChildren();
    // if (!haveChildren) {
    //   folder.delete();
    // } else {
    //   folder.name = "BORRADO!-${folder.name}";
    //   folder.save();
    // }

    project.delete();
    _projectsProvider!.removeProject(project);

    // loadProjects();
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
