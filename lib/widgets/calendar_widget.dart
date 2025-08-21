import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/admin_calendar_holidays.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_rrhh.dart';
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
  DateTime selectedDate = DateTime.now();
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime(DateTime.now().year, 12, 31);
  double height = double.infinity;
  double width = 400;

  CalendarWidget({
    super.key,
    required this.holidays,
    required this.categories,
    required this.onDateSelected,
    required this.employees,
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
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
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
    return EventTile(event: event);
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
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'Solicitudes de permisos para ${date.day} ${MONTHS[date.month - 1]}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: holidaysInDate.map((holiday) {
                Employee employee = widget.employees.firstWhere(
                    (emp) => emp.email == holiday.userId,
                    orElse: () => Employee.getEmpty(name: 'Desconocido'));
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Expanded(
                            flex: 7,
                            child: ListTile(
                              title: Text(
                                  '${employee.getFullName()} - ${holiday.getCategory(widget.categories).autoCode()}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: holiday.isAproved()
                                          ? Colors.green
                                          : (holiday.isPending()
                                              ? Colors.orange
                                              : Colors.red))),
                              subtitle: Text(
                                  '${holiday.startDate.day} ${MONTHS[holiday.startDate.month - 1]} - ${holiday.endDate.day} ${MONTHS[holiday.endDate.month - 1]}'),
                            )),
                        if ((!holiday.isAproved()) &&
                            (holiday.userId != user.email!) &&
                            (holiday.startDate.isAfter(DateTime.now()) ||
                                (holiday
                                    .getCategory(widget.categories)
                                    .retroactive)))
                          actionButton(context, "", (args) {
                            HolidayRequest holiday = args[0];
                            // Approve the holiday request
                            holiday.status = 'Aprobado';
                            holiday.approvalDate = DateTime.now();
                            holiday.approvedBy = user.email!;
                            holiday.save();
                            // Search holiday in the holidays list and update it
                            int index = listHolidays
                                .indexWhere((h) => h.id == holiday.id);
                            if (index != -1) {
                              listHolidays[index] = holiday;
                            }
                            if (mounted) {
                              setState(() {});
                              // Update this dialog
                              Navigator.of(context).pop();
                              showHolidaysDialog(date);
                            }
                          }, Icons.check, [holiday, null],
                              iconColor: Colors.green,
                              tooltip: 'Aprobar solicitud'),
                        space(width: 10),
                        if (!holiday.isRejected() &&
                            holiday.userId != user.email!)
                          actionButton(context, "", (args) {
                            HolidayRequest holiday = args[0];
                            // Reject the holiday request
                            holiday.status = 'Rechazado';
                            holiday.approvalDate = DateTime.now();
                            holiday.approvedBy = user.email!;
                            holiday.save();
                            // Search holiday in the holidays list and update it
                            int index = listHolidays
                                .indexWhere((h) => h.id == holiday.id);
                            if (index != -1) {
                              listHolidays[index] = holiday;
                            }
                            if (mounted) {
                              // Update this dialog
                              setState(() {});
                              Navigator.of(context).pop();
                              showHolidaysDialog(date);
                            }
                          }, Icons.close, [holiday, null],
                              iconColor: Colors.red,
                              tooltip: 'Rechazar solicitud'),
                        space(width: 10),
                        if (!holiday.isPending() &&
                            holiday.userId != user.email! &&
                            (holiday.startDate.isAfter(DateTime.now()) ||
                                (holiday
                                    .getCategory(widget.categories)
                                    .retroactive)))
                          actionButton(context, "", (args) {
                            HolidayRequest holiday = args[0];
                            // Reject the holiday request
                            holiday.status = 'Pendiente';
                            holiday.approvalDate = DateTime.now();
                            holiday.approvedBy = user.email!;
                            holiday.save();
                            // Search holiday in the holidays list and update it
                            int index = listHolidays
                                .indexWhere((h) => h.id == holiday.id);
                            if (index != -1) {
                              listHolidays[index] = holiday;
                            }
                            if (mounted) {
                              setState(() {});
                              // Update this dialog
                              Navigator.of(context).pop();
                              showHolidaysDialog(date);
                            }
                          }, Icons.question_mark, [holiday, null],
                              iconColor: Colors.orange,
                              tooltip: 'Cambiar solicitud a pendiente'),
                      ])),
                );
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
    }

    return Expanded(
        flex: 1,
        child: GestureDetector(
          onDoubleTap: () {
            showHolidaysDialog(date).then((_) {
              // Scrool to the week of the selected date
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
                        '${date.day} ${MONTHS[date.month - 1].substring(0, 3)}',
                        style: TextStyle(
                          color: isHoliday ? Colors.black : Colors.grey,
                          fontWeight:
                              isHoliday ? FontWeight.bold : FontWeight.normal,
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
        ));
  }

  @override
  Widget build(BuildContext context) {
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
