import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

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
  SfCalendar? calendar;

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenuAdmin(context);

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

        if (contact!.organization != "") {
          HolidaysConfig.byOrganization(contact!.organization).then((value) {
            if (value.isNotEmpty) {
              value.sort((a, b) => a.year.compareTo(b.year));
              if (value.last.year == DateTime.now().year) {
                holidaysConfig = value.last;
              } else {
                holidaysConfig = value.last;
                holidaysConfig!.year = DateTime.now().year;
                holidaysConfig!.id = "";
                holidaysConfig!.gralHolidays = [
                  DateTime(holidaysConfig!.year, 1, 1),
                  DateTime(holidaysConfig!.year, 12, 25),
                ];
                holidaysConfig!.save();
              }
              fillContent();
              if (mounted) {
                setState(() {});
              }
            } else {
              holidaysConfig = HolidaysConfig.getEmpty();
              holidaysConfig!.year = DateTime.now().year;
              holidaysConfig!.totalDays = 30;
              holidaysConfig!.gralHolidays = [
                DateTime(holidaysConfig!.year, 1, 1),
                DateTime(holidaysConfig!.year, 12, 25),
              ];
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
        } else {
          holidaysConfig = HolidaysConfig.getEmpty();
          holidaysConfig!.year = DateTime.now().year;
          holidaysConfig!.totalDays = 30;
          holidaysConfig!.organization = Organization.getEmpty();
          holidaysConfig!.gralHolidays = [
            DateTime(holidaysConfig!.year, 1, 1),
            DateTime(holidaysConfig!.year, 12, 25),
          ];
          fillContent();
          if (mounted) {
            setState(() {});
          }
        }
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
    List<Appointment> meetings = holidaysConfig!.gralHolidays
        .map((e) => Appointment(
            subject: "Día festivo",
            startTime: e,
            endTime: e,
            color: Colors.red,
            isAllDay: true))
        .toList();
    calendar = SfCalendar(
      view: CalendarView.schedule,
      dataSource: MeetingDataSource(meetings),
      monthCellBuilder: (BuildContext context, MonthCellDetails details) {
        // Lista de días personalizados
        final List<DateTime> customDays = holidaysConfig!.gralHolidays;

        // Verifica si la celda actual está en la lista
        final bool isCustomDay = customDays.any((customDay) =>
            customDay.year == details.date.year &&
            customDay.month == details.date.month &&
            customDay.day == details.date.day);

        // Devuelve el widget con fondo personalizado
        return Container(
          color: isCustomDay ? Colors.red : Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            details.date.day.toString(),
            style: TextStyle(
              color: isCustomDay ? Colors.white : Colors.black,
            ),
          ),
        );
      },
    );
    content = Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [
            Expanded(
                flex: 1,
                child: Text("Año: ${holidaysConfig!.year}",
                    style: const TextStyle(fontSize: 20))),
            Expanded(
                flex: 1,
                child: ElevatedButton(
                    onPressed: () {
                      //open dialog to add new holiday
                    },
                    child: const Text("Añadir"))),
          ]),
          const SizedBox(height: 10),
          calendar!,
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
