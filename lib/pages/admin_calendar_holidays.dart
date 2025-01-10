import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/monitoring/v3.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/holiday_form.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventTile extends StatelessWidget {
  final Event event;

  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(children: [
            Row(children: [
              // Fecha
              Expanded(
                  // Fecha
                  flex: 1,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.purple,
                    child: Text(
                      event.startTime.day.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )),
              Expanded(
                  flex: 2,
                  child: Text(
                    DateFormat('EEE, MMM', 'es')
                        .format(event.startTime)
                        .toUpperCase(),
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  )),
              // Información del evento
              if (event.isAllDay)
                Expanded(
                    flex: 1,
                    child: Icon(Icons.circle, color: Colors.red, size: 10)),

              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.subject,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: event.isAllDay ? Colors.grey : Colors.black,
                      ),
                    ),
                    if (event.notes!.isNotEmpty)
                      Text(
                        event.notes!,
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              // Icono o indicador (opcional)
            ]),
          ])),
      Divider(thickness: 0.5, color: Colors.grey.shade400)
    ]);
  }
}

class EventList extends StatelessWidget {
  final List<Event> events;
  final HolidaysConfig holidaysConfig;
  final Function refresh;

  const EventList(
      {super.key,
      required this.events,
      required this.holidaysConfig,
      required this.refresh});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return InkWell(
            child: EventTile(event: events[index]),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return CustomPopupDialog(
                        context: context,
                        title:
                            "Editar evento ${DateFormat('EEE, d MMM', 'es').format(events[index].startTime)}",
                        icon: Icons.edit,
                        content: EventForm(
                          holidaysConfig: holidaysConfig,
                          index: index,
                          currentEvent: events[index],
                        ),
                        actionBtns: null);
                  }).then(
                (value) {
                  refresh();
                },
              );
            });
      },
    );
  }
}

//
class CalendarHolidaysPage extends StatefulWidget {
  const CalendarHolidaysPage({super.key});

  @override
  _CalendarHolidaysPageState createState() => _CalendarHolidaysPageState();
}

class _CalendarHolidaysPageState extends State<CalendarHolidaysPage> {
  Widget? _mainMenu;
  Profile? profile;
  Contact? contact;
  List<HolidaysConfig>? holidaysList;
  HolidaysConfig? holidaysConfig;
  Widget content = const Center(child: CircularProgressIndicator());
  Widget? listDatesView;

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
              holidaysList = value
                  .where((element) => element.year == DateTime.now().year)
                  .toList();
              if (holidaysList!.isNotEmpty) {
                holidaysConfig = holidaysList!.last;
              } else {
                holidaysConfig = value.last;
                holidaysConfig!.year = DateTime.now().year;
                holidaysConfig!.id = "";
                holidaysConfig!.gralHolidays = [
                  Event(
                      subject: "Año Nuevo",
                      startTime: DateTime(holidaysConfig!.year, 1, 1),
                      endTime: DateTime(holidaysConfig!.year, 1, 1),
                      notes: "",
                      isAllDay: true),
                  Event(
                      subject: "Navidad",
                      startTime: DateTime(holidaysConfig!.year, 12, 25),
                      endTime: DateTime(holidaysConfig!.year, 12, 25),
                      notes: "",
                      isAllDay: true),
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
                Event(
                    subject: "Año Nuevo",
                    startTime: DateTime(holidaysConfig!.year, 1, 1),
                    endTime: DateTime(holidaysConfig!.year, 1, 1),
                    notes: "",
                    isAllDay: true),
                Event(
                    subject: "Navidad",
                    startTime: DateTime(holidaysConfig!.year, 12, 25),
                    endTime: DateTime(holidaysConfig!.year, 12, 25),
                    notes: "",
                    isAllDay: true),
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
            Event(
              subject: "Año Nuevo",
              startTime: DateTime(holidaysConfig!.year, 1, 1),
              endTime: DateTime(holidaysConfig!.year, 1, 1),
              notes: "",
              isAllDay: true,
            ),
            Event(
              subject: "Navidad",
              startTime: DateTime(holidaysConfig!.year, 12, 25),
              endTime: DateTime(holidaysConfig!.year, 12, 25),
              notes: "",
              isAllDay: true,
            ),
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
    if (holidaysList == null) {
      return;
    }
    List<List<HolidaysConfig>> calendarList = resize(holidaysList!, 5);

    if (calendarList.last.length < 5) {
      calendarList.last.addAll(List.generate(
          5 - calendarList.last.length, (index) => HolidaysConfig.getEmpty()));
    }

    content = Column(
        children: calendarList.map((e) {
      return Row(
          children: e.map((f) {
        return Expanded(
            flex: 1,
            child: (f.id != "")
                ? actionButtonVertical(context, f.year.toString(),
                    (HolidaysConfig calendar) {
                    holidaysConfig = calendar;
                    drawCalendart();
                  }, Icons.calendar_month, f)
                : Container());
      }).toList());
    }).toList());
    if (mounted) {
      setState(() {});
    }
  }

  void drawCalendart() {
    List<Event> meetings = holidaysConfig!.gralHolidays;

    meetings.sort((a, b) => a.startTime.compareTo(b.endTime));

    listDatesView = EventList(
        events: meetings,
        holidaysConfig: holidaysConfig!,
        refresh: () {
          drawCalendart();
        });

    Widget contentCalendar = SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: [
            Row(children: [
              headerCell(
                  flex: 1,
                  text: Text(holidaysConfig!.year.toString(),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center)),
            ]),
            Row(
              children: [
                headerCell(
                    text: Text("${holidaysConfig!.name}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              addBtn(context, (context) {
                //open dialog to add new holiday
                showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year),
                        lastDate: DateTime(DateTime.now().year + 10))
                    .then((value) {
                  if (value != null) {
                    Event newEvent = Event(
                        subject: "Día festivo",
                        startTime: value,
                        endTime: value,
                        notes: "",
                        isAllDay: true);
                    holidaysConfig!.gralHolidays.add(newEvent);
                    holidaysConfig!.save();
                    drawCalendart();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CustomPopupDialog(
                              context: context,
                              title:
                                  "Nuevo evento ${DateFormat('EEE, d MMM', 'es').format(newEvent.startTime)}",
                              icon: Icons.edit,
                              content: EventForm(
                                holidaysConfig: holidaysConfig,
                                index: holidaysConfig!.gralHolidays
                                    .indexOf(newEvent),
                                currentEvent: newEvent,
                              ),
                              actionBtns: null);
                        }).then(
                      (value) {
                        drawCalendart();
                      },
                    );
                  }
                });
              }, null),
              space(width: 10),
              actionButtonVertical(context, "Volver", () {
                fillContent();
              }, Icons.arrow_back, null),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: meetings.length * 80,
              //width 50% del tamaño de la pantalla
              child: listDatesView!,
            ),
          ],
        ));

    content = contentCalendar;
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
