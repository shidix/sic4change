// ignore_for_file: avoid_web_libraries_in_flutter

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
  Widget contentPanel = const Text('Loading...');
  Widget mainMenuPanel = const Text('');
  Widget secondaryMenuPanel = const Row(children: []);

  @override
  void initState() {
    super.initState();
    secondaryMenuPanel = secondaryMenu(context, NOMINA_ITEM, profile);
    if (widget.profile == null) {
      Profile.getProfile(FirebaseAuth.instance.currentUser!.email!)
          .then((value) {
        profile = value;
        mainMenuPanel = mainMenuOperator(context,
            url: ModalRoute.of(context)!.settings.name,
            profile: profile,
            key: mainMenuKey);

        if (mounted) {
          setState(() {});
        }
      });
    } else {
      profile = widget.profile;
      mainMenuPanel = mainMenuOperator(context,
          url: ModalRoute.of(context)!.settings.name,
          profile: profile,
          key: mainMenuKey);
      if (mounted) {
        setState(() {});
      }
    }
    Nomina.collection.get().then((value) {
      nominas = value.docs.map((e) {
        Nomina item = Nomina.fromJson(e.data());
        item.id = e.id;
        return item;
      }).toList();

      if (widget.codeEmployee != null) {
        nominas = nominas
            .where((element) => element.employeeCode == widget.codeEmployee)
            .toList();
      }

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

    Widget listNominas = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
            width: double.infinity,
            child: DataTable(
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
                'SS Empleado',
                'Bruto',
                'SS Empresa',
                'Coste Total',
                'No firmada',
                'Firmada',
                ''
              ]
                  .map((e) => DataColumn(
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
                              Align(
                                  alignment: Alignment.center,
                                  child: (e.noSignedPath != null)
                                      ? iconBtn(context, (context) {
                                          e.noSignedFileUrl().then((value) {
                                            final Uri toDownload =
                                                Uri.parse(value);
                                            html.window.open(
                                                toDownload.toString(),
                                                'Download');
                                          });
                                        }, null, icon: Icons.download)
                                      : const Icon(Icons.not_interested,
                                          color: Colors.red)),
                            ),
                            DataCell(
                              Align(
                                  alignment: Alignment.center,
                                  child: (e.signedPath != null)
                                      ? iconBtn(context, (context) {
                                          e.signedFileUrl().then((value) {
                                            final Uri toDownload =
                                                Uri.parse(value);
                                            html.window.open(
                                                toDownload.toString(),
                                                'Download');
                                          });
                                        }, null, icon: Icons.download)
                                      : const Tooltip(
                                          message: 'No se ha firmado',
                                          child: Icon(
                                            Icons.not_interested,
                                            color: Colors.red,
                                          ))),
                            ),
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        dialogFormNomina(
                                            context, nominas.indexOf(e));
                                      }),
                                  removeConfirmBtn(context, () {
                                    e.delete().then((value) {
                                      nominas.remove(e);
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

    // Widget listNominas = ListView.builder(
    //   shrinkWrap: true,
    //   itemCount: nominas.length + 1,
    //   itemBuilder: (context, index) {
    //     if (index == 0) {
    //       return Container(
    //           color: headerListBgColor,
    //           child: const Padding(
    //               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    //               child: Row(
    //                 children: [
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(
    //                         'Código',
    //                         style: headerListStyle,
    //                       )),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text('Fecha', style: headerListStyle)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text('Neto',
    //                           style: headerListStyle,
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text('Deducciones',
    //                           style: headerListStyle,
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text('SS Empleado',
    //                           style: headerListStyle,
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text('Bruto',
    //                           style: headerListStyle,
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text('SS Empresa',
    //                           style: headerListStyle,
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text('Coste Total',
    //                           style: headerListStyle,
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                     flex: 1,
    //                     child: Text(
    //                       'No firmada',
    //                       style: headerListStyle,
    //                       textAlign: TextAlign.center,
    //                     ),
    //                   ),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text('Firmada',
    //                           style: headerListStyle,
    //                           textAlign: TextAlign.center)),
    //                   Expanded(flex: 1, child: Text('')),
    //                 ],
    //               )));
    //     } else {
    //       return Container(
    //           color: index.isEven ? Colors.grey[200] : Colors.white,
    //           child: Padding(
    //               padding:
    //                   const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
    //               child: Row(
    //                 children: [
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(nominas[index - 1].employeeCode)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(DateFormat('dd/MM/yyyy')
    //                           .format(nominas[index - 1].date))),
    //                   //Show the net amount, deductions, employee social security, gross amount, and company social security
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(toCurrency(nominas[index - 1].netSalary),
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(toCurrency(nominas[index - 1].deductions),
    //                           textAlign: TextAlign.right)),

    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(
    //                           toCurrency(
    //                               nominas[index - 1].employeeSocialSecurity),
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(
    //                           toCurrency(nominas[index - 1].grossSalary),
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(
    //                           toCurrency(
    //                               nominas[index - 1].employerSocialSecurity),
    //                           textAlign: TextAlign.right)),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Text(
    //                           toCurrency(nominas[index - 1].grossSalary +
    //                               nominas[index - 1].employerSocialSecurity),
    //                           textAlign: TextAlign.right)),

    //                   Expanded(
    //                     flex: 1,
    //                     child: Align(
    //                         alignment: Alignment.center,
    //                         child: (nominas[index - 1].noSignedPath != null)
    //                             ? iconBtn(context, (context) {
    //                                 nominas[index - 1]
    //                                     .noSignedFileUrl()
    //                                     .then((value) {
    //                                   final Uri toDownload = Uri.parse(value);
    //                                   html.window.open(
    //                                       toDownload.toString(), 'Download');
    //                                 });
    //                               }, null, icon: Icons.download)
    //                             : const Icon(Icons.not_interested,
    //                                 color: Colors.red)),
    //                   ),

    //                   // iconBtn(context, (context) {
    //                   //   nominas[index - 1].noSignedFileUrl().then((value) {
    //                   //     final Uri toDownload = Uri.parse(value);
    //                   //     html.window.open(toDownload.toString(), 'Download');
    //                   //   });
    //                   // }, null, icon: Icons.download)),
    //                   Expanded(
    //                     flex: 1,
    //                     child: Align(
    //                         alignment: Alignment.center,
    //                         child: (nominas[index - 1].signedPath != null)
    //                             ? iconBtn(context, (context) {
    //                                 nominas[index - 1]
    //                                     .signedFileUrl()
    //                                     .then((value) {
    //                                   final Uri toDownload = Uri.parse(value);
    //                                   html.window.open(
    //                                       toDownload.toString(), 'Download');
    //                                 });
    //                               }, null, icon: Icons.download)
    //                             : const Tooltip(
    //                                 message: 'No se ha firmado',
    //                                 child: Icon(
    //                                   Icons.not_interested,
    //                                   color: Colors.red,
    //                                 ))),
    //                   ),
    //                   Expanded(
    //                       flex: 1,
    //                       child: Row(
    //                         mainAxisAlignment: MainAxisAlignment.end,
    //                         children: [
    //                           IconButton(
    //                               icon: const Icon(Icons.edit),
    //                               onPressed: () {
    //                                 dialogFormNomina(context, index - 1);
    //                               }),
    //                           removeConfirmBtn(context, () {
    //                             nominas[index - 1].delete().then((value) {
    //                               nominas.removeAt(index - 1);
    //                               setState(() {
    //                                 contentPanel = content(context);
    //                               });
    //                             });
    //                           }, null),
    //                         ],
    //                       ))
    //                 ],
    //               )));
    //     }
    //   },
    // );

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
          setState(() {
            contentPanel = content(context);
          });
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
              mainMenuPanel,
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
