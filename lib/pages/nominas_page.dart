// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:sic4change/services/form_nomina.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/models_profile.dart';
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
            url: "/home_operator", profile: profile, key: mainMenuKey);

        if (mounted) {
          setState(() {});
        }
      });
    } else {
      profile = widget.profile;
      mainMenuPanel = mainMenuOperator(context,
          url: "/home_operator", profile: profile, key: mainMenuKey);
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

    Widget listNominas = ListView.builder(
      shrinkWrap: true,
      itemCount: nominas.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
              color: headerListBgColor,
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(
                            'Código',
                            style: headerListStyle,
                          )),
                      Expanded(
                          flex: 1,
                          child: Text('Fecha', style: headerListStyle)),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'No firmada',
                          style: headerListStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Text('Firmada',
                              style: headerListStyle,
                              textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text('')),
                    ],
                  )));
        } else {
          return Container(
              color: index.isEven ? Colors.grey[200] : Colors.white,
              child: Row(
                children: [
                  Expanded(
                      flex: 1, child: Text(nominas[index - 1].employeeCode)),
                  Expanded(
                      flex: 1,
                      child: Text(DateFormat('dd/MM/yyyy')
                          .format(nominas[index - 1].date))),
                  Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.center,
                        child: (nominas[index - 1].noSignedPath != null)
                            ? iconBtn(context, (context) {
                                nominas[index - 1]
                                    .noSignedFileUrl()
                                    .then((value) {
                                  final Uri toDownload = Uri.parse(value);
                                  html.window
                                      .open(toDownload.toString(), 'Download');
                                });
                              }, null, icon: Icons.download)
                            : Text(
                                'No se ha firmado',
                                textAlign: TextAlign.center,
                              )),
                  ),

                  // iconBtn(context, (context) {
                  //   nominas[index - 1].noSignedFileUrl().then((value) {
                  //     final Uri toDownload = Uri.parse(value);
                  //     html.window.open(toDownload.toString(), 'Download');
                  //   });
                  // }, null, icon: Icons.download)),
                  Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.center,
                        child: (nominas[index - 1].signedPath != null)
                            ? iconBtn(context, (context) {
                                nominas[index - 1]
                                    .signedFileUrl()
                                    .then((value) {
                                  final Uri toDownload = Uri.parse(value);
                                  html.window
                                      .open(toDownload.toString(), 'Download');
                                });
                              }, null, icon: Icons.download)
                            : Text(
                                'No se ha firmado',
                                textAlign: TextAlign.center,
                              )),
                  ),
                  Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                dialogFormNomina(context, index - 1);
                              }),
                          removeConfirmBtn(context, () {
                            nominas[index - 1].delete().then((value) {
                              nominas.removeAt(index - 1);
                              setState(() {
                                contentPanel = content(context);
                              });
                            });
                          }, null),
                        ],
                      ))
                ],
              ));
        }
      },
    );

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
            nomina = Nomina(
                employeeCode: '',
                date: DateTime.now(),
                noSignedPath: '',
                noSignedDate: DateTime.now());
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
                  url: "/home_operator", profile: profile),
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
