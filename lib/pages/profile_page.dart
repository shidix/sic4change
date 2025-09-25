// ignore_for_file: non_constant_identifier_names

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/projects_page.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/profile_menu_widget.dart';

const profileTitle = "Detalles del Perfil";
bool projLoading = true;

class ProfilePage extends StatefulWidget {
  //final SProject? project;
  //const ProfilePage({super.key, this.project});
  final int HOLIDAY_DAYS = 30;

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileProvider? profileProvider;
  HolidaysConfig? myCalendar;
  Profile? profile;
  Organization? organization;
  Contact? contact;
  Employee? employee;
  List<HolidayRequest>? myHolidays = [];
  List<HolidaysCategory> holCat = [];
  int holidayDays = 0;

  void initializeData() async {
    organization ??= profileProvider!.organization;
    profile ??= profileProvider!.profile;
    if (organization != null) {
      holCat = await HolidaysCategory.byOrganization(organization!);
      if (holCat.isEmpty) {
        holCat = await HolidaysCategory.byOrganization(organization!);
      }
      employee = await Employee.byEmail(profile!.email);
      if (employee != null) {
        myHolidays = await HolidayRequest.byUser(profile!.email);
        myCalendar = await HolidaysConfig.byEmployee(employee!);
        for (HolidayRequest holiday in myHolidays!) {
          if (holiday.status != "Rechazado") {
            holidayDays -= getWorkingDaysBetween(
                holiday.startDate, holiday.endDate, myCalendar!);
          }
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  initState() {
    super.initState();
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider!.addListener(() {
      profile = profileProvider!.profile;
      organization = profileProvider!.organization;
      if ((organization == null) || (profile == null)) {
        profileProvider!.loadProfile();
      } else {
        initializeData();
      }
    });
    //project = widget.project;
    // try {
    //   final user = FirebaseAuth.instance.currentUser!;
    //   Profile.getProfile(user.email!).then((value) {
    //     profile = value;

    //     Contact.byEmail(user.email!).then((value) {
    //       contact = value;

    //       HolidayRequest.byUser(user.email!).then((value) {
    //         myHolidays = value;
    //         holidayDays = widget.HOLIDAY_DAYS;

    //         for (HolidayRequest holiday in myHolidays!) {
    //           holidayDays -=
    //               getWorkingDaysBetween(holiday.startDate, holiday.endDate, myCalendar!);
    //         }
    //         setState(() {
    //           loading = false;
    //         });
    //       });
    //     });
    //   });
    // } catch (e) {
    //   setState(() {
    //     loading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          loading
              ? const Center(child: CircularProgressIndicator())
              : profileHeader(context),
          space(height: 30),
          profileDetailsMenu(context, "holidays"),
          loading
              ? const Center(child: CircularProgressIndicator())
              : contentTab(context, holidayPanel, {}),
        ],
      ),
    );
  }

  Widget profileHeader(context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Image(
              image: AssetImage('assets/images/logo.jpg'),
              width: 100,
            ),
            space(width: 30),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText(profile!.name, 24,
                  bold: FontWeight.bold, textColor: cardHeaderColor),
              customText(profile!.position, 16, textColor: smallColor),
            ]),
          ])
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          customText(profile!.email, 16, textColor: smallColor),
          customText(profile!.phone, 16, textColor: smallColor),
        ]),
        addBtn(context, editProfileDialog, {'profile': profile},
            text: "Editar"),
        /*Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              addBtn(context, _callProjectEditDialog, project,
                  icon: Icons.edit, text: "Editar"),
              space(width: 10),
              goPage(context, "Volver", const ProjectsPage(),
                  Icons.arrow_circle_left_outlined),
            ])*/
      ]),
    );
  }

/*--------------------------------------------------------------------*/
/*                           EDIT PROFILE                             */
/*--------------------------------------------------------------------*/
  void saveProfile(List args) async {
    Profile profile = args[0];
    profile.save();
    //loadGoals();

    Navigator.pop(context);
  }

  Future<void> editProfileDialog(context, Map<String, dynamic> args) {
    Profile profile = args["profile"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Perfil"),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: profile.name,
                size: 220,
                fieldValue: (String val) {
                  setState(() => profile.name = val);
                },
              )
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Cargo",
                initial: profile.position,
                size: 220,
                fieldValue: (String val) {
                  setState(() => profile.position = val);
                },
              )
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Teléfono",
                initial: profile.phone,
                size: 220,
                fieldValue: (String val) {
                  setState(() => profile.phone = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveProfile, profile),
          ],
        );
      },
    );
  }

/*--------------------------------------------------------------------*/
/*                           HOLIDAYS                                 */
/*--------------------------------------------------------------------*/
  Widget holidayRows(BuildContext context) {
    return Container(
        height: 150,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        color: Colors.white,
        child: contact != null
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: myHolidays!.length,
                itemBuilder: (BuildContext context, int index) {
                  HolidayRequest holiday = myHolidays!.elementAt(index);
                  HolidaysCategory category = holCat.firstWhere(
                      (cat) => cat.id == holiday.category,
                      orElse: () => HolidaysCategory.getEmpty());
                  return ListTile(
                      subtitle: Column(children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        category.name,
                                        style: normalText,
                                      )),
                                )),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(holiday.startDate),
                                    style: normalText,
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(holiday.endDate),
                                    style: normalText,
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    getWorkingDaysBetween(holiday.startDate,
                                            holiday.endDate, myCalendar!)
                                        .toString(),
                                    style: normalText,
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Card(
                                      color: warningColor,
                                      child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            holiday.status,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          )))),
                            ),
                          ],
                        )
                      ]),
                      onTap: () {
                        //currentHoliday = holiday;
                        //addHolidayRequestDialog(context);
                      });
                })
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  Widget holidayPanel(BuildContext context, Map<dynamic, dynamic> args) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Container(
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.beach_access, color: mainColor),
                        space(width: 20),
                        Row(
                          children: [
                            const Text("Me quedan ", style: subTitleText),
                            Text(holidayDays.toString(), style: mainText),
                            const Text(" días libres", style: subTitleText),
                          ],
                        )

                        /*Expanded(
                            flex: 3,
                            child: actionButton(
                                context,
                                "Solicitar días",
                                addHolidayRequestDialog,
                                Icons.play_circle_outline_sharp,
                                context)),*/
                      ],
                    )),
                Container(
                    color: Colors.white,
                    child: const ListTile(
                      title: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Concepto",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Desde",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Hasta",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Días",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Estado",
                                style: subTitleText,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    )),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                holidayRows(context),
              ],
            )));
  }
}
