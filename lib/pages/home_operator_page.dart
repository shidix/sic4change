import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      nominas = value.docs.map((e) => Nomina.fromJson(e.data())).toList();
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
      itemCount: nominas.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(nominas[index].employeeCode),
          subtitle: Text(nominas[index].date.toString()),
        );
      },
    );

    return Card(
      child:
          // list with 5 rows and 3 columns using ListView
          Column(children: [
        titleBar,
        space(height: 10),
        toolsNomina,
        listNominas
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
