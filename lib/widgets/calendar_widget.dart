import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/rrhh_calendars_page.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/notifications_lib.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class CalendarFormat {
  static const month = 'month';
  static const week = 'week';
  static const twoWeeks = 'twoWeeks';
}

class CalendarWidget extends StatefulWidget {
  final List<HolidayRequest> holidays;
  final List<HolidaysCategory> categories;
  final Function(DateTime) onDateSelected;
  final List<Employee> employees;
  final Profile currentProfile;
  DateTime selectedDate = DateTime.now();
  DateTime startDate =
      DateTime(DateTime.now().year, 1, 1).subtract(const Duration(days: 60));
  DateTime endDate =
      DateTime(DateTime.now().year, 12, 31).add(const Duration(days: 60));
  double height = double.infinity;
  double width = 400;

  CalendarWidget({
    super.key,
    required this.holidays,
    required this.categories,
    required this.onDateSelected,
    required this.employees,
    required this.currentProfile,
    DateTime? selectedDate,
    DateTime? startDate,
    DateTime? endDate,
    this.height = double.infinity,
    this.width = 400,
  }) {
    if (selectedDate != null) {
      this.selectedDate = selectedDate;
    }
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (endDate != null) {
      this.endDate = endDate;
    }
  }

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final user = FirebaseAuth.instance.currentUser!;
  List<Event> events = [];
  late DateTime selectedDate;
  late DateTime startDate;
  late DateTime endDate;
  final ScrollController _scrollController = ScrollController();
  late List<HolidayRequest> listHolidays = [];

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget eventLoader(Event event) {
    return EventTile(
        event: event, inSameYear: true, timeZone: STimeZone.getEmpty());
  }

  // Dialog to show the list of holidays for the selected date
  Future<void> showHolidaysDialog(DateTime date) async {
    List<HolidayRequest> holidaysInDate = listHolidays
        .where((holiday) =>
            date.isAfter(truncDate(holiday.startDate)
                .subtract(const Duration(seconds: 1))) &&
            date.isBefore(
                truncDate(holiday.endDate).add(const Duration(days: 1))))
        .toList();
    if (holidaysInDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay solicitudes de permisos para este día.'),
        ),
      );
      return;
    }

    Map<String, int> availableDays = {};

    for (HolidayRequest holiday in holidaysInDate) {
      HolidaysCategory category = holiday.getCategory(widget.categories);
      String key = "${holiday.category}-${holiday.userId}";
      availableDays[key] = await category.getAvailableDays(holiday.userId);
    }

    // Open previous loading dialog, when showDialog is called inside another showDialog

    await showDialog(
        context: context,
        barrierColor: Colors.black54,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                    'Solicitudes de permisos para ${date.day} ${MonthsNamesES[date.month - 1]}'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: holidaysInDate.map((holiday) {
                      Employee employee = widget.employees.firstWhere(
                          (emp) => emp.email == holiday.userId,
                          orElse: () => Employee.getEmpty(name: 'Desconocido'));

                      bool canModify = (holiday.startDate
                                  .isAfter(DateTime.now()) ||
                              (holiday
                                  .getCategory(widget.categories)
                                  .retroactive)) &&
                          (holiday.userId != user.email!) &&
                          (!holiday.getCategory(widget.categories).onlyRRHH ||
                              ([Profile.RRHH]
                                  .contains(widget.currentProfile.mainRole)));

                      String scale = 'sm';
                      HolidaysCategory currentCategory =
                          holiday.getCategory(widget.categories);

                      Widget statusMsg = Container();
                      for (var doc in holiday.documents) {
                        if (doc.isEmpty) {
                          holiday.documents.remove(doc);
                        }
                      }

                      if (currentCategory.docRequired !=
                          holiday.documents.length) {
                        statusMsg = Container(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            'Faltan documentos adjuntos: ${currentCategory.docMessage}',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else {
                        statusMsg = Container(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            (currentCategory.docRequired > 0)
                                ? 'Documentos adjuntos completos.'
                                : 'No se requieren documentos adjuntos.',
                            style: const TextStyle(color: Colors.green),
                          ),
                        );
                      }

                      return Card(
                          key: UniqueKey(),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(children: [
                                  Expanded(
                                      flex: 7,
                                      child: ListTile(
                                        title: Text(
                                            '${employee.getFullName()} - ${holiday.getCategory(widget.categories).autoCode()} (quedan ${availableDays["${holiday.category}-${holiday.userId}"]} días)',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: holiday.isAproved()
                                                    ? Colors.green
                                                    : (holiday.isPending()
                                                        ? Colors.orange
                                                        : Colors.red))),
                                        subtitle: Text(
                                            '${holiday.startDate.day} ${MonthsNamesES[holiday.startDate.month - 1]} - ${holiday.endDate.day} ${MonthsNamesES[holiday.endDate.month - 1]}'),
                                      )),
                                  if ((!holiday.isAproved()) &&
                                      (holiday.userId != user.email!) &&
                                      (holiday.startDate
                                              .isAfter(DateTime.now()) ||
                                          (holiday
                                              .getCategory(widget.categories)
                                              .retroactive)) &&
                                      canModify)
                                    actionButton(context, "", (args) {
                                      HolidayRequest holiday = args[0];
                                      // Approve the holiday request
                                      holiday.status = 'Aprobado';
                                      holiday.approvalDate = DateTime.now();
                                      holiday.approvedBy = user.email!;
                                      holiday.save();
                                      // Add notification to the user
                                      String msg =
                                          "La solicitud de ${holiday.getCategory(widget.categories).autoCode()} entre los días ${holiday.startDate.day} ${MonthsNamesES[holiday.startDate.month - 1]} - ${holiday.endDate.day} ${MonthsNamesES[holiday.endDate.month - 1]} ha sido aprobada.";
                                      createNotification(
                                          user.email!, [holiday.userId], msg,
                                          objId: holiday.id,
                                          objType: 'holiday');

                                      // Search holiday in the holidays list and update it
                                      int index = listHolidays.indexWhere(
                                          (h) => h.id == holiday.id);
                                      if (index != -1) {
                                        listHolidays[index] = holiday;
                                      }
                                      if (mounted) {
                                        setState(() {});

                                        // Update this dialog
                                        // Navigator.of(context).pop();
                                        // showHolidaysDialog(date);
                                      }
                                    }, Icons.check, [holiday, null],
                                        iconColor: Colors.green,
                                        tooltip: 'Aprobar solicitud',
                                        scale: scale),
                                  space(width: 10),
                                  if (!holiday.isRejected() &&
                                      holiday.userId != user.email! &&
                                      canModify)
                                    actionButton(context, "", (args) {
                                      HolidayRequest holiday = args[0];
                                      // Reject the holiday request
                                      holiday.status = 'Rechazado';
                                      holiday.approvalDate = DateTime.now();
                                      holiday.approvedBy = user.email!;
                                      holiday.save();
                                      String msg =
                                          "La solicitud de ${holiday.getCategory(widget.categories).autoCode()} entre los días ${holiday.startDate.day} ${MonthsNamesES[holiday.startDate.month - 1]} - ${holiday.endDate.day} ${MonthsNamesES[holiday.endDate.month - 1]} ha sido rechazada.";
                                      createNotification(
                                          user.email!, [holiday.userId], msg,
                                          objId: holiday.id,
                                          objType: 'holiday');
                                      // Search holiday in the holidays list and update it
                                      int index = listHolidays.indexWhere(
                                          (h) => h.id == holiday.id);
                                      if (index != -1) {
                                        listHolidays[index] = holiday;
                                      }
                                      if (mounted) {
                                        // Update this dialog
                                        setState(() {});
                                        // Navigator.of(context).pop();
                                        // showHolidaysDialog(date);
                                      }
                                    }, Icons.close, [holiday, null],
                                        iconColor: Colors.red,
                                        tooltip: 'Rechazar solicitud',
                                        scale: scale),
                                  space(width: 10),
                                  if (!holiday.isPending() &&
                                      holiday.userId != user.email! &&
                                      (holiday.startDate
                                              .isAfter(DateTime.now()) ||
                                          (holiday
                                              .getCategory(widget.categories)
                                              .retroactive)) &&
                                      canModify)
                                    actionButton(context, "", (args) {
                                      HolidayRequest holiday = args[0];
                                      // Reject the holiday request
                                      holiday.status = 'Pendiente';
                                      holiday.approvalDate = DateTime.now();
                                      holiday.approvedBy = user.email!;
                                      holiday.save();
                                      // Search holiday in the holidays list and update it
                                      int index = listHolidays.indexWhere(
                                          (h) => h.id == holiday.id);
                                      if (index != -1) {
                                        listHolidays[index] = holiday;
                                      }
                                      if (mounted) {
                                        setState(() {});
                                        // Update this dialog
                                        // Navigator.of(context).pop();
                                        // showHolidaysDialog(date);
                                      }
                                    }, Icons.question_mark, [holiday, null],
                                        iconColor: Colors.orange,
                                        tooltip:
                                            'Cambiar solicitud a pendiente',
                                        scale: scale),
                                  space(width: 10),
                                  if (currentCategory.docRequired > 0)
                                    actionButton(context, "", (args) {
                                      HolidayRequest holiday = args[0];
                                      // Open the document URL in a web browser
                                      if (holiday.documents.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'No hay documentos adjuntos para esta solicitud.'),
                                          ),
                                        );
                                        return;
                                      }
                                      for (var docPath in holiday.documents) {
                                        openFileUrl(context, docPath);
                                      }
                                    }, Icons.find_in_page_outlined,
                                        [holiday, null],
                                        iconColor: Colors.blue,
                                        tooltip: 'Ver documentos adjunto',
                                        scale: scale),
                                  space(width: 10),
                                ]),
                                statusMsg
                              ],
                            ),
                          ));
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();

    listHolidays = [];
    selectedDate = widget.selectedDate;
    startDate = widget.startDate;
    endDate = widget.endDate;
    //Remove holydays duplicates in listHolidays

    for (HolidayRequest holiday in widget.holidays) {
      if (listHolidays.indexWhere((h) => h.id == holiday.id) == -1) {
        listHolidays.add(holiday);
      }
    }

    int weekForSelectedDate =
        ((selectedDate.difference(startDate).inDays) / 7).floor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(weekForSelectedDate * 100.0);
    });
  }

  Widget dayCell(DateTime date) {
    bool isHoliday = listHolidays.any((holiday) =>
        date.isAfter(truncDate(holiday.startDate)
            .subtract(const Duration(seconds: 1))) &&
        date.isBefore(
            truncDate(holiday.endDate).add(const Duration(days: 1))) &&
        !holiday.isRejected());

    // Extract holidays in this date
    List<HolidayRequest> holidaysInDate = listHolidays
        .where((holiday) =>
            date.isAfter(truncDate(holiday.startDate)
                .subtract(const Duration(seconds: 1))) &&
            date.isBefore(
                truncDate(holiday.endDate).add(const Duration(days: 1))))
        .toList();
    holidaysInDate = holidaysInDate.toSet().toList(); // Remove duplicates

    String textCell = '';
    String textPending = '';
    String textRejected = '';
    //Get the aka from employees where email is in holidaysInDate
    if (holidaysInDate.isNotEmpty) {
      List<HolidayRequest> holidaysInDateAproved =
          holidaysInDate.where((holiday) => holiday.isAproved()).toList();
      List<HolidayRequest> holidaysInDatePending =
          holidaysInDate.where((holiday) => holiday.isPending()).toList();
      List<HolidayRequest> holidaysInDateRejected =
          holidaysInDate.where((holiday) => holiday.isRejected()).toList();

      // Limit to 3 names per status

      textCell = holidaysInDateAproved.map((holiday) {
        if (widget.employees
                .indexWhere((test) => test.email == holiday.userId) !=
            -1) {
          Employee employee =
              widget.employees.firstWhere((emp) => emp.email == holiday.userId);
          return employee.aka();
        } else {
          return '';
        }
      }).join(', ');
      // Check if there are more than 3 names, then add +n more at the end
      (textCell.split(', ').length > 3)
          ? textCell =
              '${textCell.split(', ').sublist(0, 2).join(', ')} +${textCell.split(', ').length - 2} más'
          : textCell = textCell;

      textPending = holidaysInDatePending.map((holiday) {
        if (widget.employees
                .indexWhere((test) => test.email == holiday.userId) !=
            -1) {
          Employee employee =
              widget.employees.firstWhere((emp) => emp.email == holiday.userId);
          return employee.aka();
        } else {
          return '';
        }
      }).join(', ');
      textPending = (textPending.split(', ').length > 3)
          ? '${textPending.split(', ').sublist(0, 2).join(', ')} +${textPending.split(', ').length - 2} más'
          : textPending = textPending;

      textRejected = holidaysInDateRejected.map((holiday) {
        if (widget.employees
                .indexWhere((test) => test.email == holiday.userId) !=
            -1) {
          Employee employee =
              widget.employees.firstWhere((emp) => emp.email == holiday.userId);
          return employee.aka();
        } else {
          return '';
        }
      }).join(', ');
      textRejected = (textRejected.split(', ').length > 3)
          ? '${textRejected.split(', ').sublist(0, 2).join(', ')} +${textRejected.split(', ').length - 2} más'
          : textRejected = textRejected;
    }

    return Expanded(
        flex: 1,
        child: GestureDetector(
            onDoubleTap: () {
              // Launch a loading dialog and then lauch showHolidaysDialog, with a background in order to avoid clicks during loading

              // Show backgound barrier
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: Colors.black54,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: SizedBox(
                        height: 100,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Cargando solicitudes...'),
                              SizedBox(height: 20),
                              CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
                    );
                  });

              showHolidaysDialog(date).then((_) {
                // Scrool to the week of the selected date
                // Close the loading dialog
                Navigator.of(context).pop();
                int weekForSelectedDate =
                    ((date.difference(startDate).inDays) / 7).floor();
                _scrollController.jumpTo(weekForSelectedDate * 100.0);
                setState(() {
                  selectedDate = date;
                });
              });
            },
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color: isSameDay(date, selectedDate)
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.white,
                  ),
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '${date.day} ${MonthsNamesES[date.month - 1].substring(0, 3)}',
                            style: TextStyle(
                              color: isHoliday ? Colors.black : Colors.grey,
                              fontWeight: isHoliday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isHoliday)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              textCell,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        if (textPending.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              textPending,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        if (textRejected.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              textRejected,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        // if (isHoliday)
                        //   ...holidaysInDate.map((holiday) => Padding(
                        //         padding: const EdgeInsets.all(4.0),
                        //         child: Text(
                        //           holiday.userId.split('@')[0],
                        //           style: const TextStyle(
                        //             color: Colors.red,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       )),
                      ],
                    ),
                  )),
            )));
  }

  @override
  Widget build(BuildContext context) {
    for (HolidayRequest holiday in widget.holidays) {
      if (listHolidays.indexWhere((h) => h.id == holiday.id) == -1) {
        listHolidays.add(holiday);
      }
    }
    List<DateTime> daysInCalendar = [];
    DateTime current = startDate;
    while (current.isBefore(endDate) || isSameDay(current, endDate)) {
      daysInCalendar.add(current);
      current = current.add(const Duration(days: 1));
    }

    // If first day is not monday, then add previous days to the start of the list
    while (daysInCalendar.first.weekday != DateTime.monday) {
      daysInCalendar.insert(
          0, daysInCalendar.first.subtract(const Duration(days: 1)));
    }
    // If last day is not sunday, then add next days to the end of the list
    while (daysInCalendar.last.weekday != DateTime.sunday) {
      daysInCalendar.add(daysInCalendar.last.add(const Duration(days: 1)));
    }

    List<List<DateTime>> weeks = resize(
      daysInCalendar,
      7,
    );

    Widget item = SizedBox(
      height: widget.height,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            for (var week in weeks)
              Row(
                children: [
                  for (var day in week) dayCell(day),
                ],
              )
          ],
        ),
      ),
    );
    return item;
  }
}
