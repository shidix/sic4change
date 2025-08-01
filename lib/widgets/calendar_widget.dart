import 'package:flutter/material.dart';
import 'package:sic4change/pages/admin_calendar_holidays.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';

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
  List<Event> events = [];
  late DateTime selectedDate;
  late DateTime startDate;
  late DateTime endDate;
  final ScrollController _scrollController = ScrollController();

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget eventLoader(Event event) {
    return EventTile(event: event);
  }

  @override
  void initState() {
    super.initState();

    selectedDate = widget.selectedDate;
    startDate = widget.startDate;
    endDate = widget.endDate;
    for (HolidayRequest holiday in widget.holidays) {
      if (!holiday.isRejected()) {
        //Check if idUser is in the list of employees
        if (widget.employees.any((emp) => emp.email == holiday.userId)) {
          Employee employee =
              widget.employees.firstWhere((emp) => emp.email == holiday.userId);

          events.add(Event(
            subject:
                '${employee.aka()} - ${holiday.getCategory(widget.categories).autoCode()}',
            startTime: holiday.startDate,
            endTime: holiday.endDate,
            notes: '',
            isAllDay: true,
          ));
        }
      }
    }

    int weekForSelectedDate =
        ((selectedDate.difference(startDate).inDays) / 7).floor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(weekForSelectedDate * 100.0);
    });
  }

  Widget dayCell(DateTime date) {
    bool isHoliday = widget.holidays.any((holiday) =>
        date.isAfter(holiday.startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(holiday.endDate.add(const Duration(days: 1))) &&
        !holiday.isRejected());

    // Extract holidays in this date
    List<HolidayRequest> holidaysInDate = widget.holidays
        .where((holiday) =>
            date.isAfter(holiday.startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(holiday.endDate.add(const Duration(days: 1))) &&
            !holiday.isRejected())
        .toList();

    return Expanded(
        flex: 1,
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
              print(date);
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
                          color: isHoliday ? Colors.red : Colors.black,
                          fontWeight:
                              isHoliday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isHoliday)
                      ...holidaysInDate.map((holiday) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              holiday.userId.split('@')[0],
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
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
