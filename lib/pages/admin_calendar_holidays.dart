import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

class CalendarHolidaysPage extends StatefulWidget {
  @override
  _CalendarHolidaysPageState createState() => _CalendarHolidaysPageState();
}

class _CalendarHolidaysPageState extends State<CalendarHolidaysPage> {
  Widget? _mainMenu;
  Profile? profile;
  Contact? contact;
  HolidaysConfig? holidaysConfig;

  @override
  initState() {
    super.initState();
    _mainMenu = mainEmptyMenu(context);

    if (profile == null) {
      final user = FirebaseAuth.instance.currentUser!;
      Profile.getProfile(user.email!).then((value) {
        profile = value;
        if (mounted) {
          setState(() {});
        }
      });

      Contact.byEmail(user.email!).then((value) {
        contact = value;

        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        holidayHeader(context),
        footer(context),
      ]),
    ));
  }

  Widget holidayHeader(context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: customTitle(context, "DÍAS FESTIVOS"));
  }
}
