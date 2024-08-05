// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:sic4change/services/form_nomina.dart';
import 'package:sic4change/services/model_nominas.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

class HomeOperatorPage extends StatefulWidget {
  final Profile? profile;
  const HomeOperatorPage({Key? key, this.profile}) : super(key: key);

  @override
  State<HomeOperatorPage> createState() => _HomeOperatorPageState();
}

class _HomeOperatorPageState extends State<HomeOperatorPage> {
  GlobalKey<ScaffoldState> mainMenuKey = GlobalKey();
  Profile? profile;
  List<Nomina> nominas = [];
  Widget contentPanel = const Text('Loading...');
  Widget mainMenuPanel = const Text('');
  Widget secondaryMenuPanel = const Row(children: []);

  @override
  void initState() {
    super.initState();
    secondaryMenuPanel = secondaryMenu(context);
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

      nominas.sort((a, b) => a.compareTo(b));
      if (mounted) {
        setState(() {
          contentPanel = content(context);
        });
      }
    });
  }

  Widget secondaryMenu(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        goPage(context, "Nóminas", null, Icons.euro_symbol),
      ],
    );
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
                        child: Text('No firmada', style: headerListStyle),
                      ),
                      Expanded(
                          flex: 1,
                          child: Text('Firmada', style: headerListStyle)),
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
                        alignment: Alignment.centerLeft,
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
                            : Text('No se ha firmado')),
                  ),

                  // iconBtn(context, (context) {
                  //   nominas[index - 1].noSignedFileUrl().then((value) {
                  //     final Uri toDownload = Uri.parse(value);
                  //     html.window.open(toDownload.toString(), 'Download');
                  //   });
                  // }, null, icon: Icons.download)),
                  Expanded(
                      flex: 1,
                      child: (nominas[index - 1].signedPath != null)
                          ? iconBtn(context, (context) {
                              nominas[index - 1].signedFileUrl().then((value) {
                                final Uri toDownload = Uri.parse(value);
                                html.window
                                    .open(toDownload.toString(), 'Download');
                              });
                            }, null, icon: Icons.download)
                          : Text('No se ha firmado')),
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
