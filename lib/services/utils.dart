import 'package:intl/intl.dart';

String dateToES(DateTime date, {bool withTime = false}) {
  List days = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sabado",
    "Domingo",
  ];
  List months = [
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio ",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre "
  ];

  final dateFormatted =
      "${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} de ${date.year}";
  if (withTime) {
    return "$dateFormatted ${date.hour}:${date.minute}";
  }
  return dateFormatted;
}

int getWorkingDaysBetween(DateTime date1, DateTime date2) {
  int workingDays = 0;
  DateTime currentDate = date1;
  while (currentDate.isBefore(date2.add(const Duration(days: 1)))) {
    if (currentDate.weekday != DateTime.saturday &&
        currentDate.weekday != DateTime.sunday) {
      workingDays++;
    }
    currentDate = currentDate.add(const Duration(days: 1));
  }
  return workingDays;
}

String toCurrency(double value) {
  return NumberFormat.currency(locale: 'es_ES', symbol: '€').format(value);
}

String showException(dynamic e) {
  try {
    throw e; // Re-lanza la excepción para obtener la traza de la pila
  } catch (error, stackTrace) {
    if (error is Exception) {
      return 'ERROR ===:> [$error in ${stackTrace.toString()}]';
    } else {
      return 'ERROR ===:> $error';
    }
  }
}
