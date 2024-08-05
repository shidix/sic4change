import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/model_nominas.dart';
import 'package:sic4change/services/models_profile.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.profile == null) {
      Profile.getProfile(FirebaseAuth.instance.currentUser!.email!)
          .then((value) {
        profile = value;
      });
    } else {
      profile = widget.profile;
    }

    Nomina.collection
        .where('employeeCode', isEqualTo: profile!.email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        nominas.add(Nomina.fromJson(element.data()));
      });
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
    Widget titleBar = Container(
      padding: const EdgeInsets.all(10),
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Nóminas'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Ver todo'),
          )
        ],
      ),
    );

    Widget listNominas = ListView.builder(
      shrinkWrap: true,
      itemCount: nominas.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(nominas[index].date.toString()),
          subtitle: Text(nominas[index].signedDate.toString()),
        );
      },
    );

    return Card(
      child:
          // list with 5 rows and 3 columns using ListView
          Column(children: [titleBar, listNominas] // ListView.builder
              ),
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
              mainMenuOperator(context,
                  url: "/home_operator", profile: profile, key: mainMenuKey),
              Text("Bienvenido ${profile!.name}"),
            ],
          ),
        ),
      );
    }
  }
}
