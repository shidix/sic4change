import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const adminProfilesTitle = "Perfiles";
List profiles = [];
bool loadingProfile = false;
Widget? _mainMenu;

class AdminProfilesPage extends StatefulWidget {
  const AdminProfilesPage({super.key});

  @override
  State<AdminProfilesPage> createState() => _AdminProfilesPageState();
}

class _AdminProfilesPageState extends State<AdminProfilesPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingProfile = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingProfile = false;
    });
  }

  void loadProfiles() async {
    setLoading();
    await Profile.getProfiles().then((val) {
      profiles = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        adminProfilesHeader(context),
        loadingProfile
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : adminProfilesList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            CATEGORIES
-------------------------------------------------------------*/
  Widget adminProfilesHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("PERFILES", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, editAdminProfilesDialog,
                {'profile': Profile.getEmpty()}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveAdminProfiles(List args) async {
    Profile profile = args[0];
    profile.save();
    loadProfiles();

    Navigator.pop(context);
  }

  Future<void> editAdminProfilesDialog(context, Map<String, dynamic> args) {
    Profile profile = args["profile"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Perfil"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: profile.name,
                size: 900,
                minLines: 1,
                maxLines: 1,
                fieldValue: (String val) {
                  profile.name = val;
                  //setState(() => profile.name = val);
                },
              )
            ]),
            space(height: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Correo electrónico",
                initial: profile.email,
                size: 900,
                minLines: 1,
                maxLines: 1,
                fieldValue: (String val) {
                  profile.email = val;
                  //setState(() => profile.email = val);
                },
              )
            ]),
            space(height: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Teléfono",
                initial: profile.phone,
                size: 900,
                minLines: 1,
                maxLines: 1,
                fieldValue: (String val) {
                  profile.phone = val;
                  //setState(() => profile.phone = val);
                },
              )
            ]),
            space(height: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Rol",
                initial: profile.mainRole,
                size: 900,
                minLines: 1,
                maxLines: 1,
                fieldValue: (String val) {
                  profile.mainRole = val;
                  //setState(() => profile.mainRole = val);
                },
              )
            ]),
            space(height: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Posición",
                initial: profile.position,
                size: 900,
                minLines: 1,
                maxLines: 1,
                fieldValue: (String val) {
                  profile.position = val;
                  //setState(() => profile.position = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveAdminProfiles, profile),
          ],
        );
      },
    );
  }

  Widget adminProfilesList(context) {
    return Container(
      decoration: tableDecoration,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          sortColumnIndex: 0,
          showCheckboxColumn: false,
          headingRowColor:
              MaterialStateColor.resolveWith((states) => headerListBgColor),
          headingRowHeight: 40,
          columns: [
            DataColumn(
              label: customText("Nombre", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(
              label: customText("Correo electrónico", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(
              label: customText("Teléfono", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(
              label: customText("Rol", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(
              label: customText("Supervisor", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(
              label: customText("Posición", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(label: Container()),
          ],
          rows: profiles
              .map(
                (profile) => DataRow(cells: [
                  DataCell(Text(profile.name)),
                  DataCell(Text(profile.email)),
                  DataCell(Text(profile.phone)),
                  DataCell(Text(profile.mainRole)),
                  DataCell(Text(profile.holidaySupervisor.join(', '))),
                  DataCell(Text(profile.position)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(
                        context, editAdminProfilesDialog, {"profile": profile}),
                    removeBtn(context, removeAdminProfilesDialog,
                        {"profile": profile})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeAdminProfilesDialog(context, args) {
    customRemoveDialog(context, args["profile"], loadProfiles, null);
  }
}
