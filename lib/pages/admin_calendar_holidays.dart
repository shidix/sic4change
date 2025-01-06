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
  Widget content = const Center(child: CircularProgressIndicator());

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
        HolidaysConfig.byOrganization(contact!.organization).then((value) {
          if (value != []) {
            // ordenar value por el campo year
            value.sort((a, b) => a.year.compareTo(b.year));
            if (value.last.year == DateTime.now().year) {
              holidaysConfig = value.last;
            } else {
              //copy last value and change year to current year
              holidaysConfig = value.last;
              holidaysConfig!.year = DateTime.now().year;
              holidaysConfig!.id = "";
              holidaysConfig!.save();
            }
            if (mounted) {
              setState(() {});
            }
          }
          else {
            holidaysConfig = HolidaysConfig.getEmpty();
            holidaysConfig!.year = DateTime.now().year;
            holidaysConfig!.totalDays = 30;
            Organization.byUuid(contact!.organization).then((value) {
              holidaysConfig!.organization = value;
              holidaysConfig!.save();
              fillContent();
              if (mounted) {
                setState(() {});
              }
            });
            if (mounted) {
              setState(() {});
            }
          }
        });
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
        content,
        footer(context),
      ]),
    ));
  }

  void fillContent() {
    content = Container(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Row(children: [
            Expanded(
              flex: 1,
              child: Text("Año: ${holidaysConfig!.year}",
                  style: const TextStyle(fontSize: 20))),
            Expanded(
              flex:1, 
              child:
              ElevatedButton(
                  onPressed: () {
                    //open dialog to add new holiday
                  },
                  child: const Text("Añadir"))),
          ]),
          const SizedBox(height: 10),
          ],
        ),
      );
      if (mounted) {
        setState(() {});
      }
  
  }

  Widget holidayHeader(context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: customTitle(context, "DÍAS FESTIVOS"));
  }
}
