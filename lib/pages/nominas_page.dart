// ignore_for_file: avoid_web_libraries_in_flutter, curly_braces_in_flow_control_structures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:sic4change/services/form_nomina.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
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
  List<Employee> employees = [];
  Widget contentPanel = const Text('Loading...');
  Widget mainMenuPanel = const Text('');
  Widget secondaryMenuPanel = const Row(children: []);

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

    Widget listNominas = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
            width: double.infinity,
            child: DataTable(
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
                'Código',
                'Fecha',
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
              rows: nominas
                  .map((e) => DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.08);
                            }
                            if (nominas.indexOf(e).isEven) {
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
                            DataCell(
                                Text(DateFormat('dd/MM/yyyy').format(e.date))),
                            DataCell(Text(toCurrency(e.netSalary))),
                            DataCell(Text(toCurrency(e.deductions))),
                            DataCell(
                                Text(toCurrency(e.employeeSocialSecurity))),
                            DataCell(Text(toCurrency(e.grossSalary))),
                            DataCell(
                                Text(toCurrency(e.employerSocialSecurity))),
                            DataCell(Text(toCurrency(
                                e.grossSalary + e.employerSocialSecurity))),
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  (e.noSignedPath != null)
                                      ? Tooltip(
                                          message:
                                              'Descarcar nómina sin firmar',
                                          child: iconBtn(context, (context) {
                                            e.noSignedFileUrl().then((value) {
                                              final Uri toDownload =
                                                  Uri.parse(value);
                                              html.window.open(
                                                  toDownload.toString(),
                                                  'Download');
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
                                              final Uri toDownload =
                                                  Uri.parse(value);
                                              html.window.open(
                                                  toDownload.toString(),
                                                  'Download');
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
                                        dialogFormNomina(
                                            context, nominas.indexOf(e));
                                      }),
                                  removeConfirmBtn(context, () {
                                    e.delete().then((value) {
                                      nominas.remove(e);
                                      if (mounted)
                                        setState(() {
                                          contentPanel = content(context);
                                        });
                                    });
                                  }, null),
                                ],
                              ),
                            )
                          ]))
                  .toList(),
            )));

    return Card(
      child: Column(children: [
        titleBar,
        Padding(padding: const EdgeInsets.all(5), child: toolsNomina),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuOperator(context,
                  url: ModalRoute.of(context)!.settings.name, profile: profile),
              Padding(
                  padding: const EdgeInsets.all(30), child: secondaryMenuPanel),
              contentPanel,
            ],
          ),
        ),
      );
    }
  }
}
