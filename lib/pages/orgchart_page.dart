import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/profile_form.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Orgchart extends StatefulWidget {
  const Orgchart({Key? key}) : super(key: key);

  @override
  State<Orgchart> createState() => _OrgchartState();
}

class _OrgchartState extends State<Orgchart> {
  //User user = FirebaseAuth.instance.currentUser!;
  Profile? currentProfile;
  List<Profile> profiles = [];
  List<Profile> filteredProfiles = [];
  Profile? myProfile;
  ProfileProvider? profileCache;

  @override
  void initState() {
    super.initState();
    profileCache = context.read<ProfileProvider>();
    myProfile = profileCache!.profile;
    getProfiles();
    currentProfile = null;
  }

  void getProfiles() async {
    // await Profile.getProfile(user.email!).then((value) {
    //   setState(() {
    //     currentProfile = value;
    //   });
    // });
    await Profile.getProfiles(orgid: myProfile!.organization ?? "")
        .then((value) {
      setState(() {
        profiles = value;
        filteredProfiles = value;
      });
    });
  }

  void testAction(context) {}

  void addProfileDialog(Map<String, dynamic> args) {
    BuildContext context = args['context'];
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
          title: s4cTitleBar(
              '${AppLocalizations.of(context)!.add} Perfil', context),
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
      actionButtonVertical(context, AppLocalizations.of(context)!.add,
          addProfileDialog, Icons.add, {'context': context}),
      // space(width: 10),
      // backButton(context),
    ];
    return Padding(
        padding: const EdgeInsets.all(10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons));
  }

  Widget buildProfileList() {
    if (filteredProfiles.isEmpty) {
      return const Center(
        child: Text("No hay perfiles disponibles"),
      );
    } else {
      filteredProfiles.sort((a, b) => a.email.compareTo(b.email));
      return ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        shrinkWrap: true,
        itemCount: filteredProfiles.length,
        itemBuilder: (context, index) {
          Profile item = filteredProfiles[index];
          return Tooltip(
              message: AppLocalizations.of(context)!.click_to_edit,
              child: ListTile(
                title: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(item.email, style: normalText)),
                        Expanded(
                            flex: 1,
                            child: Text(item.mainRole, style: normalText)),
                        // Expanded(
                        //     flex: 2,
                        //     child: Text(item.holidaySupervisor.join(', '),
                        //         style: normalText)),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  currentProfile = item;
                  addProfileDialog({'context': context});
                },
              ));
        },
      );
    }
  }

  Widget buildProfileHeader() {
    return const ListTile(
        title: Column(
      children: [
        Row(
          children: [
            Expanded(flex: 1, child: Text("Usuario", style: headerListStyle)),
            Expanded(flex: 1, child: Text("Rol", style: headerListStyle)),
            // Expanded(
            //     flex: 2,
            //     child: Text("Supervisores vacaciones", style: headerListStyle)),
          ],
        ),
        Divider(),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          mainMenu(context, "/orgchart"),
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
          CardRounded(
              child:
                  Column(children: [buildProfileHeader(), buildProfileList()])),
          // buildProfileHeader(),
          // SizedBox(
          //   height: 400,
          //   child: buildProfileList(),
          // ),
        ],
      )),
    );
  }
}
