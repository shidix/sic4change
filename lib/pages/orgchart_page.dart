import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/profile_form.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

class Orgchart extends StatefulWidget {
  const Orgchart({Key? key}) : super(key: key);

  @override
  State<Orgchart> createState() => _OrgchartState();
}

class _OrgchartState extends State<Orgchart> {
  User user = FirebaseAuth.instance.currentUser!;
  Profile? currentProfile;
  List<Profile> profiles = [];
  List<Profile> filteredProfiles = [];

  void initState() {
    super.initState();
    getProfiles();
    currentProfile = null;
  }

  void getProfiles() async {
    // await Profile.getProfile(user.email!).then((value) {
    //   setState(() {
    //     currentProfile = value;
    //   });
    // });
    await Profile.getProfiles().then((value) {
      setState(() {
        profiles = value;
        filteredProfiles = value;
      });
    });
  }

  void testAction(context) {
    print("testAction");
  }

  void addProfileDialog(context) {
    _addProfileDialog(context).then((value) {
      currentProfile = null;
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
          title: s4cTitleBar('$addText Perfil'),
          content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ProfileForm(
                key: null,
                currentProfile: currentProfile,
              )),
        );
      },
    );
  }

  void filterProfiles(String value) {
    filteredProfiles = [];
    value = value.toLowerCase();
    for (var profile in profiles) {
      if (profile.email.toLowerCase().contains(value)) {
        filteredProfiles.add(profile);
      } else if (profile.mainRole.toLowerCase().contains(value)) {
        filteredProfiles.add(profile);
      } else if (profile.holidaySupervisor
          .join(', ')
          .toLowerCase()
          .contains(value)) {
        filteredProfiles.add(profile);
      }
    }
    setState(() {});
  }

  Widget topButtons(BuildContext context) {
    List<Widget> buttons = [
      actionButton(
          context, "$addText perfil", addProfileDialog, Icons.add, context),
      space(width: 10),
      backButton(context),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  Widget buildProfileList() {
    if (filteredProfiles.isEmpty) {
      return const Center(
        child: Text("No hay datos"),
      );
    } else {
      filteredProfiles.sort((a, b) => a.email.compareTo(b.email));
      return ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        shrinkWrap: true,
        itemCount: filteredProfiles.length,
        itemBuilder: (context, index) {
          Profile item = filteredProfiles[index];
          return ListTile(
            title: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 1, child: Text(item.email, style: normalText)),
                    Expanded(
                        flex: 1, child: Text(item.mainRole, style: normalText)),
                    Expanded(
                        flex: 2,
                        child: Text(item.holidaySupervisor.join(', '),
                            style: normalText)),
                  ],
                ),
              ],
            ),
            onTap: () {
              currentProfile = item;
              addProfileDialog(context);
            },
          );
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
          Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Expanded(
                    flex: 1,
                    child: Text("Roles",
                        style: titleText.copyWith(color: normalColor))),
                Expanded(
                    flex: 4,
                    child: SearchBar(
                      controller: TextEditingController(),
                      onSubmitted: (value) {
                        filterProfiles(value);
                      },
                      leading: const Icon(Icons.search),
                    )),
                Expanded(flex: 2, child: topButtons(context))
              ])),
          buildProfileHeader(),
          SizedBox(
            height: 400,
            child: buildProfileList(),
          ),
        ],
      )),
    ));
  }
}
