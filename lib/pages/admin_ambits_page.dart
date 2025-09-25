import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/form_admin_ambit.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

class AdminAmbitsPage extends StatefulWidget {
  const AdminAmbitsPage({super.key});

  @override
  State<AdminAmbitsPage> createState() => AdminAmbitsPageState();
}

class AdminAmbitsPageState extends State<AdminAmbitsPage> {
  Widget? _mainMenu;
  Widget? _toolsBar;
  Widget? _listAmbitsPanel;
  Widget? _footer;
  ProfileProvider? profileProvider;
  Profile? profile;

  List ambits = [];

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider?>();
    profileProvider ??= ProfileProvider();
    profileProvider!.addListener(() {
      setState(() {
        profile = profileProvider!.profile;
      });
    });
    profile = profileProvider!.profile;
    Ambit.getAmbits().then((val) {
      setState(() {
        ambits = val;
        _listAmbitsPanel = loadAmbits();
      });
    });
  }

  Widget toolsBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: addBtn(null, (_) {
              // Open new ambit dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: s4cTitleBar("Nuevo Ámbito"),
                      titlePadding: const EdgeInsets.all(0),
                      content: AmbitForm(
                        onSave: (newAmbit) {
                          // Add new ambit to the list and refresh UI
                          setState(() {
                            ambits.add(newAmbit);
                            _listAmbitsPanel = loadAmbits();
                          });
                          Navigator.of(context).pop();
                        },
                      ));
                },
              );
            }, null)),
        space(width: 10),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: backButton(
              context,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _mainMenu ??= mainMenu(context, null, profile);
    _toolsBar ??= toolsBar();
    _listAmbitsPanel ??= loadAmbits();
    _footer ??= footer(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          _mainMenu!,
          const TitlePageS4C(title: "Gestión de Ámbitos"),
          _toolsBar!,
          _listAmbitsPanel!,
          _footer!,
        ]),
      ),
    );
  }

  Widget loadAmbits() {
    // DataTable with ambits
    ambits.sort((a, b) => a.name.compareTo(b.name));
    return Row(children: [
      Expanded(
          flex: 1,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('')),
            ],
            sortAscending: true,
            sortColumnIndex: 0,
            headingTextStyle: headerListStyle,
            headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              return Colors.grey[200]; // Header background color
            }),
            rows: ambits
                .map(
                  (ambit) => DataRow(
                    cells: [
                      DataCell(Text(ambit.name ?? '')),
                      DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Open edit ambit dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: s4cTitleBar("Editar Ámbito"),
                                          titlePadding: const EdgeInsets.all(0),
                                          content: AmbitForm(
                                            ambit: ambit,
                                            onSave: (updatedAmbit) {
                                              // Update ambit in the list and refresh UI
                                              setState(() {
                                                int index =
                                                    ambits.indexOf(ambit);
                                                ambits[index] = updatedAmbit;
                                                _listAmbitsPanel = loadAmbits();
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ));
                                    },
                                  );
                                },
                              ),
                              // Add delete button
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Show confirmation dialog before deleting
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text("Confirmar eliminación"),
                                        content: const Text(
                                            "¿Estás seguro de que deseas eliminar este ámbito?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Remove ambit from the list and refresh UI
                                              setState(() {
                                                ambits.remove(ambit);
                                                ambit.delete();
                                                _listAmbitsPanel = loadAmbits();
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Eliminar"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          )))
                      // ]))),
                    ],
                  ),
                )
                .toList(),
          ))
    ]);
  }
}
