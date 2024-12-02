// ignore_for_file: avoid_web_libraries_in_flutter, curly_braces_in_flow_control_structures

// import 'dart:js_interop_unsafe';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:googleapis/keep/v1.dart';
// import 'package:googleapis/photoslibrary/v1.dart';
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:sic4change/services/form_nomina.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';

class NominasPage extends StatefulWidget {
  final Profile? profile;
  final String? codeEmployee;
  const NominasPage({super.key, this.profile, this.codeEmployee});

  @override
  State<NominasPage> createState() => _NominasPageState();
}

class _NominasPageState extends State<NominasPage> {
  GlobalKey<ScaffoldState> mainMenuKey = GlobalKey();
  Profile? profile;
  List<Nomina> nominas = [];
  List<bool> nominasFiltered = [];
  List<Employee> employees = [];
  Widget contentPanel = const Text('Loading...');
  Widget mainMenuPanel = const Text('');
  Widget secondaryMenuPanel = const Row(children: []);
  DateTime fromDateFilter =
      firstDayOfMonth(DateTime.now().subtract(const Duration(days: 180)));
  DateTime toDateFilter = lastDayOfMonth(DateTime.now());
  String employeeFilter = '';
  double minNetSalaryFilter = 0.0;
  double maxNetSalaryFilter = 1e6;
  double minGrossSalaryFilter = 0.0;
  double maxGrossSalaryFilter = 1e6;
  double minTotalSalaryFilter = 0.0;
  double maxTotalSalaryFilter = 1e6;

  int sortAsc = -1; // 1 ascending, -1 descending
  int sortColumnIndex = 3;

  int compareNomina(Nomina a, Nomina b) {
    return a.compareTo(b, sortColumnIndex: sortColumnIndex, sortAsc: sortAsc);
  }

  Future<void> downloadZipNominas(String filename) async {
    List<String> paths = [];

    List<Nomina> nominasToDownload = [];

    for (bool filter in nominasFiltered) {
      if (filter) {
        nominasToDownload.add(nominas[nominasFiltered.indexOf(filter)]);
      }
    }

    for (Nomina nomina in nominasToDownload) {
      paths.add(nomina.noSignedPath);
      if (nomina.signedPath != null) {
        paths.add(nomina.signedPath!);
      }
    }

    await compressAndDownloadFiles(paths, filename);
  }

  Future<void> exportNominasToCsv(String filename) async {
    String csv = 'DNI/NIE/ID,Nombre,Apellidos,Fecha Nómina,Neto,Deducciones,'
        'SSTrab,Bruto,SSEmp,Total\n';
    for (Nomina nomina in nominas) {
      nomina.employee = employees
          .where((element) => element.code == nomina.employeeCode)
          .first;
      csv += '${nomina.employeeCode},'
          '${nomina.employee!.firstName},'
          '${nomina.employee!.lastName1} ${nomina.employee!.lastName2},'
          '${DateFormat('dd/MM/yyyy').format(nomina.date)},'
          '${nomina.netSalary},'
          '${nomina.deductions},'
          '${nomina.employeeSocialSecurity},'
          '${nomina.grossSalary},'
          '${nomina.employerSocialSecurity},'
          '${nomina.grossSalary + nomina.employerSocialSecurity}\n';
    }
    final blob = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '$filename.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  void initState() {
    super.initState();

    if (widget.profile == null) {
      Profile.getProfile(FirebaseAuth.instance.currentUser!.email!)
          .then((value) {
        profile = value;
        secondaryMenuPanel = secondaryMenu(context, NOMINA_ITEM, profile);
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      profile = widget.profile;
      secondaryMenuPanel = secondaryMenu(context, NOMINA_ITEM, profile);
    }

    Employee.getEmployees().then((value) {
      employees = value;
      employees.sort((a, b) => a.compareTo(b));
      if (mounted) {
        setState(() {
          contentPanel = content(context);
        });
      }
    });

    Nomina.getNominas(employeeCode: widget.codeEmployee).then((value) {
      nominas = value;
      nominas.sort(compareNomina);
      nominasFiltered = List.filled(nominas.length, true);
      for (int i = 0; i < nominas.length; i++) {
        if (nominas[i].date.isAfter(toDateFilter)) {
          toDateFilter = nominas[i].date;
        }
      }
      if (mounted) {
        setState(() {
          contentPanel = content(context);
        });
      }
    });
  }

  Widget content(context) {
    return Column(
      children: [
        nominasPanel(context),
      ],
    );
  }

  Widget nominasPanel(context) {
    Widget titleBar = s4cTitleBar(const Padding(
        padding: EdgeInsets.all(5),
        child: Text('Listado de Nóminas',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold))));

    Widget toolsNomina = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        addBtnRow(context, dialogFormNomina, -1),
        gralBtnRow(context, (context) async {
          String? filename = await showDialog(
              context: context, builder: (context) => const FileNameDialog());
          if (filename != null && filename.isNotEmpty)
            exportNominasToCsv(filename);
        }, null, icon: Icons.download, text: 'Exportar'),
        gralBtnRow(context, (context) async {
          String? filename = await showDialog(
              context: context, builder: (context) => const FileNameDialog());
          if (filename != null && filename.isNotEmpty)
            downloadZipNominas(filename);
        }, null, icon: Icons.download, text: 'Zip'),
      ],
    );

    for (int i = 0; i < nominas.length; i++) {
      nominas[i].employee = employees
          .where((element) => element.code == nominas[i].employeeCode)
          .first;
    }
    nominas.sort(compareNomina);

    // a widtget to filter the rows, with a text field by column
    Widget filterPanel = Row(
      children: [
        Expanded(
            child: Row(
          children: [
            Expanded(
                child: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: fromDateFilter,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100))
                          .then((value) {
                        if (value != null) {
                          fromDateFilter = value;
                          if (mounted) {
                            setState(() {
                              contentPanel = content(context);
                            });
                          }
                        }
                      });
                    })),
            Expanded(
                flex: 4,
                child: TextFormField(
                  key: UniqueKey(),
                  initialValue: DateFormat('dd/MM/yyyy').format(fromDateFilter),
                  decoration: InputDecoration(
                    labelText: 'Desde',
                    hintText: DateFormat('dd/MM/yyyy').format(fromDateFilter),
                  ),
                  readOnly: true,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      // if value has format dd/mm/yyyy  (use a regular expression)

                      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                        fromDateFilter = getDate(value, truncate: true);
                      } else {
                        fromDateFilter = firstDayOfMonth(DateTime.now());
                      }
                    }

                    if (mounted) {
                      setState(() {
                        contentPanel = content(context);
                      });
                    }
                  },
                )),
          ],
        )),

        Expanded(
            child: Row(
          children: [
            Expanded(
                child: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: toDateFilter,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100))
                          .then((value) {
                        if (value != null) {
                          toDateFilter = value;
                          if (mounted) {
                            setState(() {
                              contentPanel = content(context);
                            });
                          }
                        }
                      });
                    })),
            Expanded(
                flex: 4,
                child: TextFormField(
                  key: UniqueKey(),
                  initialValue: DateFormat('dd/MM/yyyy').format(toDateFilter),
                  decoration: InputDecoration(
                    labelText: 'Hasta',
                    hintText: DateFormat('dd/MM/yyyy').format(toDateFilter),
                  ),
                  readOnly: true,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      // if value has format dd/mm/yyyy  (use a regular expression)

                      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                        toDateFilter = getDate(value, truncate: true);
                      } else {
                        toDateFilter = lastDayOfMonth(DateTime.now());
                      }
                    }

                    if (mounted) {
                      setState(() {
                        contentPanel = content(context);
                      });
                    }
                  },
                )),
          ],
        )),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
                labelText: 'Filtrar por empleado',
                hintText: 'Nombre, apellidos o DNI/NIE/ID',
                prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              if (value.isNotEmpty) {
                employeeFilter = value;
              } else {
                employeeFilter = '';
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ), //
        // Filter by salary
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Salario neto mínimo',
                hintText: toCurrency(minNetSalaryFilter),
                prefixIcon: const Icon(Icons.search)),
            onChanged: (value) {
              try {
                minNetSalaryFilter = double.parse(value);
              } catch (e) {
                minNetSalaryFilter = 0.0;
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Salario neto máximo',
                hintText: toCurrency(maxNetSalaryFilter),
                prefixIcon: const Icon(Icons.search)),
            onChanged: (value) {
              try {
                maxNetSalaryFilter = double.parse(value);
              } catch (e) {
                maxNetSalaryFilter = 1e6;
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Salario bruto mínimo',
                hintText: toCurrency(minGrossSalaryFilter),
                prefixIcon: const Icon(Icons.search)),
            onChanged: (value) {
              try {
                minGrossSalaryFilter = double.parse(value);
              } catch (e) {
                minGrossSalaryFilter = 0.0;
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Salario bruto máximo',
                hintText: toCurrency(maxGrossSalaryFilter),
                prefixIcon: const Icon(Icons.search)),
            onChanged: (value) {
              try {
                maxGrossSalaryFilter = double.parse(value);
              } catch (e) {
                maxGrossSalaryFilter = 1e6;
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Salario total mínimo',
                hintText: toCurrency(minTotalSalaryFilter),
                prefixIcon: const Icon(Icons.search)),
            onChanged: (value) {
              try {
                minTotalSalaryFilter = double.parse(value);
              } catch (e) {
                minTotalSalaryFilter = 0.0;
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Salario total máximo',
                hintText: toCurrency(maxTotalSalaryFilter),
                prefixIcon: const Icon(Icons.search)),
            onChanged: (value) {
              try {
                maxTotalSalaryFilter = double.parse(value);
              } catch (e) {
                maxTotalSalaryFilter = 1e6;
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
      ],
    );

    // Filtros
    nominasFiltered = List.filled(nominas.length, true);
    for (int i = 0; i < nominas.length; i++) {
      if (employeeFilter.isNotEmpty) {
        if (!employees
            .where((element) => element.code == nominas[i].employeeCode)
            .first
            .getFullName()
            .toLowerCase()
            .contains(employeeFilter.toLowerCase())) {
          nominasFiltered[i] = false;
        }
      }
      if (nominas[i].date.isBefore(fromDateFilter) ||
          nominas[i].date.isAfter(toDateFilter)) {
        nominasFiltered[i] = false;
      }
      if (nominas[i].netSalary < minNetSalaryFilter ||
          nominas[i].netSalary > maxNetSalaryFilter) {
        nominasFiltered[i] = false;
      }
      if (nominas[i].grossSalary < minGrossSalaryFilter ||
          nominas[i].grossSalary > maxGrossSalaryFilter) {
        nominasFiltered[i] = false;
      }
      if (nominas[i].grossSalary + nominas[i].employerSocialSecurity <
              minTotalSalaryFilter ||
          nominas[i].grossSalary + nominas[i].employerSocialSecurity >
              maxTotalSalaryFilter) {
        nominasFiltered[i] = false;
      }
    }

    List filteredNominas = nominas
        .asMap()
        .entries
        .where((element) => nominasFiltered[element.key])
        .map((e) => e.value)
        .toList();

    Widget dataTable = DataTable(
      sortAscending: sortAsc == 1,
      sortColumnIndex: sortColumnIndex,
      showCheckboxColumn: false,
      headingRowColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return headerListBgColor.withOpacity(0.5);
        }
        return headerListBgColor;
      }),
      columns: [
        'DNI/NIE/ID',
        'Nombre',
        'Apellidos',
        // 'Días Cotizados',
        'Fecha Nómina',
        'Neto',
        'Deducciones',
        'SSTrab',
        'Bruto',
        'SSEmp',
        'Total',
        ''
      ]
          .map((e) => DataColumn(
              onSort: (e != '')
                  ? (columnIndex, ascending) {
                      sortColumnIndex = columnIndex;
                      sortAsc = ascending ? 1 : -1;
                      contentPanel = content(context);
                      if (mounted) setState(() {});
                    }
                  : null,
              label: Text(
                e,
                style: headerListStyle,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              )))
          .toList(),
      rows: filteredNominas
          .map((e) => DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08);
                    }
                    if (filteredNominas.indexOf(e).isEven) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.grey[300];
                      }
                      return Colors.grey[200];
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.white.withOpacity(0.5);
                    }
                    return Colors.white;
                  }),
                  cells: [
                    DataCell(Text(e.employeeCode)),
                    DataCell(Text(employees
                        .where((element) => element.code == e.employeeCode)
                        .first
                        .firstName)),
                    DataCell(Text(
                        '${employees.where((element) => element.code == e.employeeCode).first.lastName1} ${employees.where((element) => element.code == e.employeeCode).first.lastName2}')),
                    // (employees
                    //         .where((element) => element.code == e.employeeCode)
                    //         .isNotEmpty)
                    //     ? DataCell(Text(employees
                    //         .where((element) => element.code == e.employeeCode)
                    //         .first
                    //         .altaDays(date: e.date)
                    //         .toString()))
                    //     : const DataCell(Text('0')),
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(e.date))),
                    DataCell(Text(toCurrency(e.netSalary))),
                    DataCell(Text(toCurrency(e.deductions))),
                    DataCell(Text(toCurrency(e.employeeSocialSecurity))),
                    DataCell(Text(toCurrency(e.grossSalary))),
                    DataCell(Text(toCurrency(e.employerSocialSecurity))),
                    DataCell(Text(
                        toCurrency(e.grossSalary + e.employerSocialSecurity))),
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          (e.noSignedPath != null)
                              ? Tooltip(
                                  message: 'Descargar nómina sin firmar',
                                  child: iconBtn(context, (context) {
                                    e.noSignedFileUrl().then((value) {
                                      final Uri toDownload = Uri.parse(value);
                                      html.window.open(
                                          toDownload.toString(), 'Download');
                                    });
                                  }, null, icon: Icons.download))
                              : const Tooltip(
                                  message: 'No hay archivo',
                                  child: Icon(
                                    Icons.not_interested,
                                    color: Colors.red,
                                  )),
                          (e.signedPath != null)
                              ? Tooltip(
                                  message: 'Descargar nómina firmada',
                                  child: iconBtn(context, (context) {
                                    e.signedFileUrl().then((value) {
                                      final Uri toDownload = Uri.parse(value);
                                      html.window.open(
                                          toDownload.toString(), 'Download');
                                    });
                                  }, null, icon: Icons.download))
                              : const Tooltip(
                                  message: 'No se ha firmado',
                                  child: Icon(
                                    Icons.not_interested,
                                    color: Colors.red,
                                  )),
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                dialogFormNomina(context, nominas.indexOf(e));
                              }),
                          iconBtn(context, dialogCopyNomina, e,
                              icon: Icons.copy),
                          removeConfirmBtn(context, () {
                            e.delete().then((value) {
                              nominas.remove(e);
                              if (mounted)
                                setState(() {
                                  nominasFiltered =
                                      List.filled(nominas.length, true);
                                  contentPanel = content(context);
                                });
                            });
                          }, null),
                        ],
                      ),
                    )
                  ]))
          .toList(),
    );

    Widget listNominas = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            child: dataTable));
    return Card(
      child: Column(children: [
        titleBar,
        Padding(padding: const EdgeInsets.all(5), child: toolsNomina),
        (MediaQuery.of(context).size.width < 1300)
            ? Center(
                child: Text('Scroll horizontal para ver más datos',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)))
            : Container(),
        Padding(padding: const EdgeInsets.all(5), child: filterPanel),
        Padding(padding: const EdgeInsets.all(5), child: listNominas),
      ] // ListView.builder
          ),
    );
  }

  void dialogFormNomina(BuildContext context, int index) {
    showDialog<Nomina>(
        context: context,
        builder: (BuildContext context) {
          Nomina? nomina;
          if (index == -1) {
            nomina = Nomina.getEmpty();
            nomina.date = //first day of the month
                DateTime(DateTime.now().year, DateTime.now().month, 1);
            nomina.paymentDate = nomina.date.add(const Duration(days: 10));
          } else {
            nomina = nominas[index];
          }
          return AlertDialog(
            title: s4cTitleBar('Nómina', context, Icons.add_outlined),
            content: NominaForm(
              selectedItem: nomina,
              employees: employees,
            ),
          );
        }).then(
      (value) {
        if (value != null) {
          if (index == -1) {
            nominas.add(value);
          } else {
            nominas[index] = value;
          }
          if (mounted) {
            setState(() {
              contentPanel = content(context);
            });
          }
        }
      },
    );
  }

  void dialogCopyNomina(context, Nomina nomina) {
    showDialog<Nomina>(
        context: context,
        builder: (BuildContext context) {
          Nomina newNomina = Nomina.getEmpty();
          newNomina.date = DateTime(nomina.date.year, nomina.date.month + 1,
              min(nomina.date.day, 28));
          newNomina.paymentDate = newNomina.date;
          newNomina.employeeCode = nomina.employeeCode;
          newNomina.netSalary = nomina.netSalary;
          newNomina.deductions = nomina.deductions;
          newNomina.employeeSocialSecurity = nomina.employeeSocialSecurity;
          newNomina.grossSalary = nomina.grossSalary;
          newNomina.employerSocialSecurity = nomina.employerSocialSecurity;

          return AlertDialog(
            title: s4cTitleBar('Nómina', context, Icons.add_outlined),
            content: NominaForm(
              selectedItem: newNomina,
              employees: employees,
            ),
          );
        }).then(
      (value) {
        if (value != null) {
          nominas.add(value);
          if (value.date.isAfter(toDateFilter)) {
            toDateFilter = value.date;
          }
          if (value.date.isBefore(fromDateFilter)) {
            fromDateFilter = value.date;
          }

          if (mounted) {
            setState(() {
              contentPanel = content(context);
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return to login_page if profile is null
    if (profile == null) {
      return SelectionArea(
          child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuOperator(context, url: "/rrhh", profile: profile),
              const CircularProgressIndicator(),
              const Text(
                'Loading profile...',
              ),
            ],
          ),
        ),
      ));
    } else {
      return SelectionArea(
          child: Scaffold(
              body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuOperator(context, url: "/rrhh", profile: profile),
              Padding(
                  padding: const EdgeInsets.all(30), child: secondaryMenuPanel),
              contentPanel,
              footer(context)
            ],
          ),
        ),
      )));
    }
  }
}
