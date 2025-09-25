import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/form_rrhh_workplace.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';

class WorkplacePage extends StatefulWidget {
  const WorkplacePage({super.key});

  @override
  State<WorkplacePage> createState() => WorkplacePageState();
}

class WorkplacePageState extends State<WorkplacePage> {
  List<Workplace> workplaces = [];
  late ProfileProvider _profileProvider;
  late VoidCallback _listener;
  Profile? profile;
  Organization? currentOrganization;
  late Widget secondaryMenuPanel;
  late Widget mainMenuPanel;
  late Widget contentPanel;

  int sortColumnIndex = 0;
  int orderDirection = 1; // 1 asc, -1 desc

  void initializeData() async {
    if ((currentOrganization == null) || (profile == null)) return;
    workplaces = await Workplace.getAll(organization: currentOrganization);
    if (mounted) {
      setState(() {
        contentPanel = content(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    secondaryMenuPanel = secondaryMenu(context, WORKPLACE_ITEM);
    mainMenuPanel = mainMenu(context, "/rrhh");
    contentPanel = content(context); // Initialize contentPanel
    _profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _listener = () {
      if (!mounted) return;
      currentOrganization = _profileProvider.organization;

      profile = _profileProvider.profile;
      mainMenuPanel = mainMenu(context, "/rrhh");
      if ((profile != null) && (currentOrganization != null)) {
        initializeData();
      } else {
        // If profile or organization is null, load profile again
        _profileProvider.loadProfile();
      }

      if (mounted) setState(() {});
    };
    _profileProvider.addListener(_listener);

    currentOrganization = _profileProvider.organization;
    profile = _profileProvider.profile;
    if ((profile == null) || (currentOrganization == null)) {
      _profileProvider.loadProfile();
    } else {
      initializeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // return to login_page if profile is null
    return SelectionArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            mainMenuPanel,
            Padding(
                padding: const EdgeInsets.all(30), child: secondaryMenuPanel),
            contentPanel,
            footer(context),
          ],
        ),
      ),
    ));
  }

  @override
  void dispose() {
    _profileProvider.removeListener(_listener);
    super.dispose();
  }

  void dialogWorkcenterForm(int index) {
    Workplace selectedItem;
    if (index == -1) {
      selectedItem = Workplace.getEmpty();
      selectedItem.organization = currentOrganization;
    } else {
      selectedItem = workplaces[index];
    }

    WorkplaceForm form = WorkplaceForm(
      selectedItem: selectedItem,
      existingWorkplaces: workplaces,
      onSaved: (item) {
        if (index == -1) {
          workplaces.add(item);
        } else {
          workplaces[index] = item;
        }
        setState(() {
          contentPanel = content(context);
        });
        return item;
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: s4cTitleBar(
              index == -1
                  ? "Nuevo Centro de Trabajo"
                  : "Editar Centro de Trabajo",
              context,
              index == -1 ? Icons.add_rounded : Icons.edit_rounded),
          content: SingleChildScrollView(child: form),
        );
      },
    );
  }

  Widget content(BuildContext context) {
    Widget titleBar = s4cTitleBar(const Padding(
        padding: EdgeInsets.all(5),
        child: Text('Centros de Trabajo',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold))));

    Widget toolsEmployee = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        addBtnRow(context, (args) {
          dialogWorkcenterForm(-1);
        }, null),
      ],
    );

    Widget filterPanel = Container();

    DataTable dataTable = DataTable(
      headingRowColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        return headerListBgColor;
      }),
      sortAscending: orderDirection == 1,
      sortColumnIndex: sortColumnIndex,
      columns: ['Nombre', 'Dirección', 'Teléfono', 'Acciones'].map((e) {
        return DataColumn(
          onSort: (columnIndex, ascending) {
            sortColumnIndex = columnIndex;
            orderDirection = ascending ? 1 : -1;
            if (e == 'Nombre') {
              workplaces.sort((a, b) =>
                  orderDirection *
                  a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            } else if (e == 'Dirección') {
              workplaces.sort((a, b) =>
                  orderDirection *
                  (a.address ?? "")
                      .toLowerCase()
                      .compareTo((b.address ?? "").toLowerCase()));
            } else if (e == 'Teléfono') {
              workplaces.sort((a, b) =>
                  orderDirection *
                  (a.phone ?? "")
                      .toLowerCase()
                      .compareTo((b.phone ?? "").toLowerCase()));
            }
            if (mounted) {
              setState(() {
                contentPanel = content(context);
              });
            }
          },
          label: Text(
            e,
            style: headerListStyle,
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
      rows: workplaces.map((e) {
        return DataRow(cells: [
          DataCell(Text(e.name)),
          DataCell(Text(e.address ?? "")),
          DataCell(Text(e.phone ?? "")),
          DataCell(
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  dialogWorkcenterForm(workplaces.indexOf(e));
                  // Edit employee
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Delete employee
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: s4cTitleBar("Eliminar Centro de Trabajo",
                            context, Icons.delete_rounded),
                        content: const Row(children: [
                          Expanded(
                              child: Text(
                                  "¿Está seguro que desea eliminar este centro de trabajo?",
                                  textAlign: TextAlign.center)),
                        ]),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Cancelar"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Eliminar"),
                            onPressed: () {
                              setState(() {
                                workplaces.remove(e);
                                e.delete();
                                contentPanel = content(context);
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ]),
          ),
        ]);
      }).toList(),
    );

    Widget listWorkplaces = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:
            (workplaces.isNotEmpty) ? dataTable : const Text("No hay datos"));

    return Column(children: [
      Card(
        child: Column(children: [
          titleBar,
          Padding(padding: const EdgeInsets.all(5), child: toolsEmployee),
          Padding(padding: const EdgeInsets.all(5), child: filterPanel),
          Padding(
              padding: const EdgeInsets.all(5),
              child: Row(children: [Expanded(child: listWorkplaces)])),
        ] // ListView.builder
            ),
      )
    ]);
  }
}
