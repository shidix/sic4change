import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/profile_form.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

class Orgchart extends StatefulWidget {
  final url = "/orgchart";
  const Orgchart({Key? key}) : super(key: key);

  @override
  State<Orgchart> createState() => _OrgchartState();
}

class _OrgchartState extends State<Orgchart> {
  User user = FirebaseAuth.instance.currentUser!;
  Profile? currentProfile;
  List<Profile> profiles = [];

  void initState() {
    super.initState();
    getProfiles();
    currentProfile = null;
  }

  void getProfiles() async {
    await Profile.getProfile(user.email!).then((value) {
      setState(() {
        currentProfile = value;
      });
    });
    await Profile.getProfiles().then((value) {
      setState(() {
        profiles = value;
      });
    });
  }

  void testAction(context) {
    print("testAction");
  }

  void addProfileDialog(context) {
    _addProfileDialog(context).then((value) {
      getProfiles();
    });
  }

  Future<void> _addProfileDialog(context) {
    currentProfile ??= Profile.getEmpty();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir transferencia'),
          content: ProfileForm(
            key: null,
            currentProfile: currentProfile,
          ),
        );
      },
    );
  }

  Widget topButtons(BuildContext context) {
    List<Widget> buttons = [
      actionButton(
          context, "Nuevo perfil", addProfileDialog, Icons.add, context),
      space(width: 10),
      backButton(context),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  Widget buildProfileList() {
    if (profiles.isEmpty) {
      return const Center(
        child: Text("No hay datos"),
      );
    } else {
      return ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          Profile item = profiles[index];
          return ListTile(
              title: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 1, child: Text(item.email, style: normalText)),
                  Expanded(
                      flex: 1, child: Text(item.mainRole, style: normalText)),
                  Expanded(
                      flex: 2,
                      child: Text(item.holidaySupervisor.join(', '),
                          style: normalText)),
                ],
              ),
              const Divider(),
            ],
          ));
        },
      );
    }
  }

  Widget buildProfileHeader() {
    return Container(
        child: const ListTile(
            title: Column(
      children: [
        Row(
          children: [
            Expanded(flex: 1, child: Text("Usuario", style: subTitleText)),
            Expanded(flex: 1, child: Text("Rol", style: subTitleText)),
            Expanded(
                flex: 2,
                child: Text("Supervisores vacaciones", style: subTitleText)),
          ],
        ),
        Divider(),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
          child: Column(
        children: [
          mainMenu(context, user, "/orgchart"),
          topButtons(context),
          buildProfileHeader(),
          Container(
            height: 400,
            child: buildProfileList(),
          ),
        ],
      )),
    ));
  }
}
