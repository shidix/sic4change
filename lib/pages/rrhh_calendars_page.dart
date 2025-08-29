import 'package:flutter/material.dart';
// import 'package:googleapis/monitoring/v3.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/holiday_form.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
// import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';
import 'package:uuid/uuid.dart';
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
                      style: const TextStyle(
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
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  )),
              // Información del evento
              if (event.isAllDay)
                const Expanded(
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
                        style: const TextStyle(color: Colors.grey),
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
                            "Editar evento ${DateFormat('EEE, d MMM', 'es').format(events[index].startTime).toUpperCase()}",
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
  CalendarHolidaysPageState createState() => CalendarHolidaysPageState();
}

class CalendarHolidaysPageState extends State<CalendarHolidaysPage> {
  Widget? _mainMenu;
  Widget? _secondaryMenu;
  Widget? _toolsMenu;
  Profile? profile;
  Contact? contact;
  List<HolidaysConfig>? holidaysList;
  // late List<Employee> employeesList;
  Organization? currentOrganization;
  HolidaysConfig? holidaysConfig;
  Widget content = const Center(child: CircularProgressIndicator());
  Widget? listDatesView;
  late ProfileProvider _profileProvider;
  late VoidCallback _listener;

  // List<Employee>? employees;

  Widget holidayHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("Calendarios", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(context, newYearDialog, null),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void initializeData() async {
    if (!(mounted)) return;

    if (currentOrganization == null) {
      content = const Center(
          child: Text("No hay organización asignada a este usuario"));
      return;
    }
    if (profile == null) {
      content = const Center(child: Text("No hay perfil de usuario"));
      return;
    }
    if (profile!.mainRole == Profile.RRHH) {
      _mainMenu = mainMenu(context, "/rrhh");
      _secondaryMenu = secondaryMenu(context, CALENDAR_ITEM);
      _toolsMenu = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [addBtn(context, newYearDialog, null)],
        ),
      );
    } else {
      _mainMenu = mainMenu(context, "/home");
      _secondaryMenu = holidayHeader(context);
      _toolsMenu = Container();
    }
    // Check if the user has permissions
    checkPermissions(
        context, profile!, [Profile.ADMINISTRATIVE, Profile.ADMIN]);
    // If the user has permissions, load the holidays configuration

    // Load holidays configuration for the current organization
    final results = await Future.wait([
      HolidaysConfig.byOrganization(currentOrganization!.id),
      // Employee.getEmployees(organization: currentOrganization!)
    ]);

    holidaysList = results[0];
    // employeesList = results[1] as List<Employee>;
    // Filter holidays for the current year
    holidaysList = holidaysList!
        .where((element) => element.year >= DateTime.now().year)
        .toList();
    if (holidaysList!.isNotEmpty) {
      holidaysConfig = holidaysList!.last;
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
            id: "",
            isAllDay: true),
        Event(
            subject: "Navidad",
            startTime: DateTime(holidaysConfig!.year, 12, 25),
            endTime: DateTime(holidaysConfig!.year, 12, 25),
            id: "",
            notes: "",
            isAllDay: true),
      ];
      holidaysConfig!.organization = currentOrganization!.id;
      // holidaysConfig!.save();
    } // Initialize the content with the holidays configuration
    fillContent();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  initState() {
    super.initState();
    _profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    _listener = () {
      if (!mounted) return;
      currentOrganization = _profileProvider.organization;

      profile = _profileProvider.profile;
      _mainMenu = mainMenu(context, "/home");
      _secondaryMenu = holidayHeader(context);
      if ((profile != null) && (currentOrganization != null)) {
        initializeData();
      } else {
        // If profile or organization is null, load profile again
        _profileProvider.loadProfile();
      }

      if (mounted) setState(() {});
    };
    _profileProvider.addListener(_listener);

    currentOrganization = _profileProvider.organization;
    profile = _profileProvider.profile;
    if ((profile == null) || (currentOrganization == null)) {
      _profileProvider.loadProfile();
    } else {
      initializeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((profile != null) && (profile?.mainRole == Profile.RRHH)) {
      _mainMenu = mainMenu(
        context,
        "/rrhh",
      );
    }
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        Padding(padding: const EdgeInsets.all(30), child: _secondaryMenu),
        content,
        footer(context),
      ]),
    ));
  }

  Future<void> duplicateCalendar(HolidaysConfig calendar) async {
    //Show confirm Dialog
    bool confirmed = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirmar copia"),
            content: const Text(
                "¿Estás seguro de que deseas duplicar este calendario? Los usuarios asignados no se copiarán."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  HolidaysConfig newCalendar =
                      HolidaysConfig.fromJson(calendar.toJson());
                  newCalendar.id = "";
                  newCalendar.name = "${calendar.name} (Copia)";
                  newCalendar.employees = [];
                  await newCalendar.save();
                  holidaysList!.add(newCalendar);
                  fillContent();
                  if (mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text("Duplicar"),
              ),
            ],
          );
        });
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calendario duplicado')),
      );
      setState(() {
        holidaysList = holidaysList;
      });
    }
  }

  void deleteCalendar(HolidaysConfig calendar) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirmar eliminación"),
            content: const Text(
                "¿Estás seguro de que deseas eliminar este calendario?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  holidaysList!.remove(calendar);
                  calendar.delete();
                  fillContent();
                  Navigator.of(context).pop();
                },
                child: const Text("Eliminar"),
              ),
            ],
          );
        });
  }

  void fillContent() {
    if (holidaysList == null) {
      content = const Center(child: Text("No hay calendarios"));
      return;
    }

    // Sort holidaysList by year and then by name
    holidaysList!.sort((a, b) {
      int yearComparison = b.year.compareTo(a.year);
      if (yearComparison != 0) return yearComparison;
      return a.name.compareTo(b.name);
    });

    // fill calendarList to 5 columns
    int nCols = 6;
    if (MediaQuery.of(context).size.width < 1200) nCols = 4;
    if (MediaQuery.of(context).size.width < 800) nCols = 2;

    List<List<HolidaysConfig>> calendarList = resize(holidaysList!, nCols);

    // Check last row from calendarList and complete to 8
    if (calendarList.isNotEmpty) {
      while (calendarList.last.length < nCols) {
        calendarList.last.add(HolidaysConfig.getEmpty());
      }
    }

    content = Column(children: [
      _toolsMenu ?? Container(),
      ...calendarList.map((row) {
        return Row(
            children: row.map((cell) {
          return Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: (cell.id != '')
                      ? Card(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 0),
                              child: Column(children: [
                                const Icon(Icons.calendar_month,
                                    size: 50, color: mainColor),
                                Text(
                                  cell.year.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  cell.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                space(height: 10),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          actionButton(context, '',
                                              (HolidaysConfig calendar) {
                                            holidaysConfig = calendar;
                                            drawCalendar();
                                          }, Icons.calendar_month, cell,
                                              scale: 'sm', tooltip: 'Editar'),
                                          actionButton(context, '', (calendar) {
                                            duplicateCalendar(calendar);
                                          }, Icons.copy, cell,
                                              scale: 'sm', tooltip: "Duplicar"),
                                          actionButton(context, '', (calendar) {
                                            deleteCalendar(calendar);
                                          }, Icons.delete, cell,
                                              scale: 'sm', tooltip: "Eliminar")
                                        ]))
                              ])))
                      : Container()));
        }).toList());
      }).toList(),
    ]);

    if (mounted) {
      setState(() {});
    }
    return;
  }

  void editYearDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return CustomPopupDialog(
              context: context,
              title: "Editar calendario",
              icon: Icons.edit,
              content: HolidayConfigForm(
                holidaysConfig: holidaysConfig,
                afterSave: () {
                  drawCalendar();
                },
                afterDelete: () {
                  holidaysList!.remove(holidaysConfig);
                  fillContent();
                },
                index: holidaysList!.indexOf(holidaysConfig!),
              ),
              actionBtns: null);
        });
  }

  void newYearDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          HolidaysConfig newItem = HolidaysConfig.getEmpty();
          if (currentOrganization != null) {
            newItem.organization = currentOrganization!.id;
            return CustomPopupDialog(
                context: context,
                title: "Nuevo calendario",
                icon: Icons.edit,
                content: HolidayConfigForm(
                  holidaysConfig: newItem,
                  afterSave: () {
                    holidaysList ??= [];
                    holidaysList!.add(newItem);
                    holidaysConfig = newItem;
                    drawCalendar();
                  },
                  index: -1,
                ),
                actionBtns: null);
          } else {
            return CustomPopupDialog(
                context: context,
                title: "¡¡¡¡AVISO!!!!",
                icon: Icons.warning,
                content: Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    height: 100,
                    child: const Text(
                        "No se puede crear un calendario porque tu usuario no tiene una organización asignada. Verifica que el perfil esté registrado en los contactos.",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
                actionBtns: null);
          }
        });
  }

  void drawCalendar() {
    List<Event> meetings = holidaysConfig!.gralHolidays;
    List<String> employeesInCalendars = [];
    for (HolidaysConfig calendar in holidaysList!) {
      if (calendar.id == holidaysConfig!.id) continue;
      for (Employee emp in calendar.employees) {
        if (emp.id != null) {
          employeesInCalendars.add(emp.id!);
        }
      }
    }

    // Check it every day is in this year
    for (var event in meetings) {
      if (event.startTime.year != holidaysConfig!.year) {
        event.startTime = DateTime(
            holidaysConfig!.year, event.startTime.month, event.startTime.day);
        event.endTime = DateTime(
            holidaysConfig!.year, event.endTime.month, event.endTime.day);
      }
    }

    meetings.sort((a, b) => a.startTime.compareTo(b.endTime));

    listDatesView = EventList(
        events: meetings,
        holidaysConfig: holidaysConfig!,
        refresh: () {
          drawCalendar();
        });

    Widget contentCalendar = Container(
        decoration: tableDecoration,
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: [
                Container(
                    decoration: const BoxDecoration(
                      color: mainColor,
                    ),
                    child: Row(children: [
                      headerCell(
                          flex: 5,
                          text: Text(
                            holidaysConfig!.year.toString(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                      headerCell(
                        flex: 5,
                        text: Text(
                            (holidaysConfig!.name != "")
                                ? holidaysConfig!.name
                                : 'Sin Nombre',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      headerCell(
                        flex: 5,
                        text: Text("${holidaysConfig!.totalDays} días",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      headerCell(
                          flex: 1,
                          text: IconButton(
                              onPressed: () {
                                fillContent();
                              },
                              icon:
                                  const Icon(Icons.close, color: Colors.white)))
                    ])),
                space(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  actionButtonVertical(
                      context, "Editar", editYearDialog, Icons.edit, null),
                  space(width: 10),
                  actionButtonVertical(context, "Festivo", (context) {
                    //open dialog to add new holiday
                    showDatePicker(
                            context: context,
                            initialDate: DateTime(holidaysConfig!.year, 1, 1),
                            firstDate: DateTime(holidaysConfig!.year, 1, 1),
                            lastDate: DateTime(holidaysConfig!.year, 12, 31))
                        .then((value) {
                      if (value != null) {
                        Event newEvent = Event(
                            id: const Uuid().v4().toString(),
                            subject: "Día festivo",
                            startTime: value,
                            endTime: value,
                            notes: "",
                            isAllDay: true);
                        holidaysConfig!.gralHolidays.add(newEvent);
                        holidaysConfig!.save();
                        drawCalendar();
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
                            drawCalendar();
                          },
                        );
                      }
                    });
                  }, Icons.add_rounded, context),
                  space(width: 10),
                  actionButtonVertical(context, "Usuarios", (context) {
                    // open dialog to add new employee
                    employeesInCalendars = [];
                    for (HolidaysConfig calendar in holidaysList!) {
                      if (calendar.id == holidaysConfig!.id) continue;
                      if (calendar.year != holidaysConfig!.year) continue;
                      for (Employee emp in calendar.employees) {
                        if (emp.id != null) {
                          employeesInCalendars.add(emp.id!);
                        }
                      }
                    }
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CustomPopupDialog(
                              context: context,
                              title: "Usuarios",
                              icon: Icons.people,
                              content: HolidayConfigUserForm(
                                  holidaysConfig: holidaysConfig!,
                                  employeesInCalendars: employeesInCalendars,
                                  afterSave: () {
                                    drawCalendar();
                                  }),
                              actionBtns: null);
                        });
                  }, Icons.people, context),
                  space(width: 10),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                    height: meetings.length * 80,
                    //width 50% del tamaño de la pantalla
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: listDatesView!,
                    )),
              ],
            )));

    content = contentCalendar;
    if (mounted) {
      setState(() {});
    }
  }
}
