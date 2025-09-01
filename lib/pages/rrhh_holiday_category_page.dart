import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/holiday_form.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';

class HolidayCategoryPage extends StatefulWidget {
  const HolidayCategoryPage({super.key});

  @override
  State<HolidayCategoryPage> createState() => HolidayCategoryPageState();
}

class HolidayCategoryPageState extends State<HolidayCategoryPage> {
  List<HolidaysCategory> holidaysCategories = [];
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
    holidaysCategories =
        await HolidaysCategory.getAll(organization: currentOrganization);
    if (mounted) {
      setState(() {
        contentPanel = content(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    secondaryMenuPanel = secondaryMenu(context, HOLIDAYS_ITEM);
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

  void dialogHolidaysCategoryForm(int index) {
    HolidaysCategory selectedItem;
    if (index == -1) {
      selectedItem = HolidaysCategory.getEmpty();
      selectedItem.organization = currentOrganization;
    } else {
      selectedItem = holidaysCategories[index];
    }

    HolidaysCategoryForm form = HolidaysCategoryForm(
      category: selectedItem,
      afterSave: (item) {
        if (index == -1) {
          holidaysCategories.add(item);
        } else {
          holidaysCategories[index] = item;
        }
        // Navigator.of(context).pop();
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
          title: s4cTitleBar(index == -1 ? "Nuevo Permiso" : "Editar Permiso",
              context, index == -1 ? Icons.add_rounded : Icons.edit_rounded),
          content: SizedBox(
            width: max(600, MediaQuery.of(context).size.width * 0.6),
            child: SingleChildScrollView(child: form),
          ),
        );
      },
    );
  }

  Widget content(BuildContext context) {
    Widget titleBar = s4cTitleBar(const Padding(
        padding: EdgeInsets.all(5),
        child: Text('Permisos',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold))));

    Widget toolsEmployee = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        addBtnRow(context, (args) {
          dialogHolidaysCategoryForm(-1);
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
      columns: [
        'Año',
        'Nombre',
        'Código',
        'Documentos',
        'Días disponibles',
        'Válido hasta',
        'Acciones'
      ].map((e) {
        return DataColumn(
          onSort: (columnIndex, ascending) {
            sortColumnIndex = columnIndex;
            orderDirection = ascending ? 1 : -1;
            if (e == 'Año') {
              // Order by year, then by name
              holidaysCategories.sort((a, b) {
                int res = orderDirection * a.year.compareTo(b.year);
                if (res != 0) return res;
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
              });
            } else if (e == 'Nombre') {
              holidaysCategories.sort((a, b) =>
                  orderDirection *
                  a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            } else if (e == 'Código') {
              holidaysCategories.sort((a, b) =>
                  orderDirection *
                  (a.code).toLowerCase().compareTo((b.code).toLowerCase()));
            } else if (e == 'Válido hasta') {
              holidaysCategories.sort((a, b) =>
                  orderDirection * a.validUntil.compareTo(b.validUntil));
            } else {
              holidaysCategories.sort((a, b) =>
                  orderDirection *
                  a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
      rows: holidaysCategories.map((e) {
        return DataRow(cells: [
          DataCell(Text(e.year.toString())),
          DataCell(Text(e.name)),
          DataCell(Text(e.code)),
          DataCell(Text(e.docRequired.toString())),
          DataCell(Text(e.days.toString())),
          DataCell(Text(
              "${e.validUntil.day.toString().padLeft(2, '0')}/${e.validUntil.month.toString().padLeft(2, '0')}/${e.validUntil.year}")),
          DataCell(
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  dialogHolidaysCategoryForm(holidaysCategories.indexOf(e));
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
                        title: s4cTitleBar(
                            "Eliminar Permiso", context, Icons.delete_rounded),
                        content: const Row(children: [
                          Expanded(
                              child: Text(
                                  "¿Está seguro que desea eliminar este tipo de permiso?",
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
                                holidaysCategories.remove(e);
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

    Widget listHolidaysCategorys = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: (holidaysCategories.isNotEmpty)
            ? dataTable
            : const Text("No hay datos"));

    return Column(children: [
      Card(
        child: Column(children: [
          titleBar,
          Padding(padding: const EdgeInsets.all(5), child: toolsEmployee),
          Padding(padding: const EdgeInsets.all(5), child: filterPanel),
          Padding(
              padding: const EdgeInsets.all(5),
              child: Row(children: [Expanded(child: listHolidaysCategorys)])),
        ] // ListView.builder
            ),
      )
    ]);
  }
}
