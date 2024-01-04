import 'package:intl/intl.dart';
import 'package:sic4change/services/models_commons.dart';

const List<String> MONTHS = [
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

Map<String, String> CURRENCIES = {
  'EUR': '€',
  'USD': '\$',
  'SOL': 'S/',
  'GBP': '£',
  'JPY': '¥',
  'CNY': '¥',
  'RUB': '₽',
  'INR': '₹',
  'BRL': 'R\$',
  'CAD': '\$',
  'AUD': '\$',
  'CHF': 'CHF',
  'HKD': 'HK\$',
  'IDR': 'Rp',
  'KRW': '₩',
  'MXN': '\$',
  'MYR': 'RM',
  'NZD': '\$',
  'PHP': '₱',
  'SGD': 'S\$',
  'THB': '฿',
  'ZAR': 'R',
};

List reshape(List list, int m, int n) {
  List result = [];
  for (int i = 0; i < m; i++) {
    List row = [];
    for (int j = 0; j < n; j++) {
      row.add(list[i * n + j]);
    }
    result.add(row);
  }
  return result;
}

DateTime today() {
  return truncDate(DateTime.now());
}

DateTime truncDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String dateToES(DateTime date, {bool withDay = true, bool withTime = false}) {
  List days = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sabado",
    "Domingo",
  ];
  List months = MONTHS;

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

String toCurrency(double value, [String symbol = 'EUR']) {
  return NumberFormat.currency(locale: 'es_ES', symbol: CURRENCIES[symbol])
      .format(value);
}

String showException(dynamic e) {
  try {
    throw e; // Re-lanza la excepción para obtener la traza de la pila
  } catch (error, stackTrace) {
    if (error is Exception) {
      return 'ERROR ===:> [$error in ${stackTrace.toString()}]';
    } else {
      return 'WARNING ===:> $error';
    }
  }
}

double currencyToDouble(String value) {
  value = value.replaceAll(
      RegExp(r'^\D+|(?<=\d),(?=\d)|(?<=\d).(?<=\d),(?=\d)'), '');
  // value = value.replaceAll('€', '');
  // value = value.replaceAll(' ', '');
  value = value.replaceAll('.', '');
  value = value.replaceAll(',', '.');
  try {
    return double.parse(value);
  } catch (e) {
    print("Error al convertir $value a double");
    return 0.0;
  }
}

double fromCurrency(String value) {
  return currencyToDouble(value);
}
