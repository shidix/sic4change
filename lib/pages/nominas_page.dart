// ignore_for_file: avoid_web_libraries_in_flutter, curly_braces_in_flow_control_structures

import 'dart:js_interop_unsafe';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/keep/v1.dart';
import 'package:googleapis/photoslibrary/v1.dart';
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
  const NominasPage({Key? key, this.profile, this.codeEmployee})
      : super(key: key);

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
  String dateFilter = '';
  String employeeFilter = '';

  int sortAsc = 1;
  int sortColumnIndex = 0;

  int compareNomina(Nomina a, Nomina b) {
    return a.compareTo(b, sortColumnIndex: sortColumnIndex, sortAsc: sortAsc);
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
      nominas.sort((a, b) => a.compareTo(b));
      nominasFiltered = List.filled(nominas.length, true);
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
      children: [addBtnRow(context, dialogFormNomina, -1)],
    );

    nominas.sort(compareNomina);
    // a widtget to filter the rows, with a text field by column
    Widget filterPanel = Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
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
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Filtrar por fecha',
                hintText: 'dd/mm/yyyy',
                prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // if value has format dd/mm/yyyy  (use a regular expression)

                if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                  dateFilter = value;
                } else {
                  dateFilter = '';
                }
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

    if (employeeFilter.isNotEmpty) {
      nominasFiltered = List.filled(nominas.length, false);
      for (int i = 0; i < nominas.length; i++) {
        if (employees
                .where((element) => element.code == nominas[i].employeeCode)
                .first
                .getFullName()
                .toLowerCase()
                .contains(employeeFilter.toLowerCase()) ||
            nominas[i]
                .employeeCode
                .toLowerCase()
                .startsWith(employeeFilter.toLowerCase())) {
          nominasFiltered[i] = true;
        }
      }
    }

    if (dateFilter.isNotEmpty) {
      nominasFiltered = List.filled(nominas.length, false);
      for (int i = 0; i < nominas.length; i++) {
        if (DateFormat('dd/MM/yyyy').format(nominas[i].date) == dateFilter) {
          nominasFiltered[i] = true;
        }
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
      headingRowColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return headerListBgColor.withOpacity(0.5);
        }
        return headerListBgColor;
      }),
      columns: [
        'DNI/NIE/ID',
        'Nombre',
        'Apellidos',
        'Días Cotizados',
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
                  color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08);
                    }
                    if (filteredNominas.indexOf(e).isEven) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.grey[300];
                      }
                      return Colors.grey[200];
                    }
                    if (states.contains(MaterialState.hovered)) {
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
                    (employees
                            .where((element) => element.code == e.employeeCode)
                            .isNotEmpty)
                        ? DataCell(Text(employees
                            .where((element) => element.code == e.employeeCode)
                            .first
                            .altaDays(date: e.date)
                            .toString()))
                        : const DataCell(Text('0')),
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuOperator(context,
                  url: ModalRoute.of(context)!.settings.name, profile: profile),
              const CircularProgressIndicator(),
              const Text(
                'Loading profile...',
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
          body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuOperator(context,
                  url: ModalRoute.of(context)!.settings.name, profile: profile),
              Padding(
                  padding: const EdgeInsets.all(30), child: secondaryMenuPanel),
              contentPanel,
              footer(context)
            ],
          ),
        ),
      ));
    }
  }
}
