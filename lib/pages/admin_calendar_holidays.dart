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

  //Sobreescribir el método onTap

  @override
  String? getNotes(int index) {
    return appointments![index].notes;
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
      headerStyle: CalendarHeaderStyle(
          backgroundColor: Theme.of(context).canvasColor,
          textStyle: TextStyle(
              backgroundColor: Theme.of(context).canvasColor,
              color: Theme.of(context).canvasColor)),
      dataSource: MeetingDataSource(meetings),
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.appointment) {
          print(details.date);
          final Appointment appointment = details.appointments![0];
          final DateTime date = appointment.startTime;
          final String dateString =
              "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
          final String title = "$dateString";
          final String message =
              "¿Seguro que deseas eliminar este día festivo?";
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        holidaysConfig!.gralHolidays.remove(date);
                        holidaysConfig!.save();
                        fillContent();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Eliminar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                );
              });
        }
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
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Añadir día festivo"),
                              content: Column(
                                children: [
                                  const Text("Selecciona la fecha:"),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                      onPressed: () {
                                        showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2021),
                                                lastDate: DateTime(2022))
                                            .then((value) {
                                          if (value != null) {
                                            holidaysConfig!.gralHolidays
                                                .add(value);
                                            holidaysConfig!.save();
                                            fillContent();
                                          }
                                        });
                                      },
                                      child: const Text("Seleccionar fecha")),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                              ],
                            );
                          });
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
