import 'dart:math';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const String statusFormulation = "1"; //En formulación
const String statusSended = "2"; //Presentado
const String statusReject = "3"; //Denegado
const String statusRefuse = "4"; //Rechazado
const String statusApproved = "5"; // Aprobado
const String statusStart = "6"; //En ejecución
const String statusEnds = "7"; //Finalización
const String statusJustification = "8"; //En evaluación de justificación
const String statusClose = "9"; //Cerrado
const String statusDelivery = "10"; //En seguimiento

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

final currencyFormat = NumberFormat("#,##0.00", "es_ES");

Map<String, KeyValue> CURRENCIES = {
  'EUR': KeyValue('EUR', '€'),
  'USD': KeyValue('USD', '\$'),
  'PEN': KeyValue('PEN', 'S/'),
  'GBP': KeyValue('GBP', '£'),
  'MAD': KeyValue('MAD', 'MAD'),
  'MRU': KeyValue('MRU', 'UM'),

  // 'USD': '\$',
  // 'SOL': 'S/',
  // 'GBP': '£',
  // 'JPY': '¥',
  // 'CNY': '¥',
  // 'RUB': '₽',
  // 'INR': '₹',
  // 'BRL': 'R\$',
  // 'CAD': '\$',
  // 'AUD': '\$',
  // 'CHF': 'CHF',
  // 'HKD': 'HK\$',
  // 'IDR': 'Rp',
  // 'KRW': '₩',
  // 'MXN': '\$',
  // 'MYR': 'RM',
  // 'NZD': '\$',
  // 'PHP': '₱',
  // 'SGD': 'S\$',
  // 'THB': '฿',
  // 'ZAR': 'R',
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

Object getObject(List items, String value, {String key = 'uuid'}) {
  try {
    if (key == "uuid") {
      return items.firstWhere((item) => item.uuid == value);
    } else {
      // get the first item that has the value in the key key
      return items.firstWhere((item) => item.toJson()[key] == value);
    }
  } catch (e) {
    return Null;
  }
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
  try {
    return NumberFormat.currency(
            locale: 'es_ES', symbol: CURRENCIES[symbol]!.value)
        .format(value);
  } catch (e) {
    return NumberFormat.currency(
            locale: 'es_ES', symbol: CURRENCIES['EUR']!.value)
        .format(value);
  }
}

String showException(dynamic e) {
  try {
    throw e; // Re-lanza la excepción para obtener la traza de la pila
  } catch (error, stackTrace) {
    return (error.toString() + stackTrace.toString());
    // var trace = Trace.from(stackTrace);
    // var frame = trace.frames.first;
    // return ('${error.toString()} at ${frame.uri}:${frame.line}');
    // print('Exception details: $error');
    // print('File: ${frame.uri}');
    // print('Line: ${frame.line}');
  }
}

Icon getIcon(bool value, {double size = 24.0}) {
  if (value) {
    return Icon(Icons.check_circle_outline, color: Colors.green, size: size);
  } else {
    return Icon(Icons.remove_circle_outline, color: Colors.red, size: size);
  }
}

DateTime getDate(dynamic date, {truncate = false}) {
  DateTime convert = DateTime(2099, 12, 31);
  DateTime result = convert;

  if (date is DateTime) {
    result = date;
  }
  if (date is Timestamp) {
    result = date.toDate();
  }
  if (date is String) {
    try {
      result = DateTime.parse(date);
    } catch (e) {
      result = convert;
    }
  }
  if (date is int) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(date);
    } catch (e) {
      result = convert;
    }
  }
  return truncate ? truncDate(result) : result;
}

int getDaysInMonth(int year, int month) {
  if (month == DateTime.february) {
    final bool isLeapYear =
        (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
    return isLeapYear ? 29 : 28;
  }
  const List<int> daysInMonth = <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];
  return daysInMonth[month - 1];
}

DateTime firstDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime lastDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month, getDaysInMonth(date.year, date.month),
      23, 59, 59, 999);
}

DateTime addMonth(DateTime date) {
  int year = date.year;
  int month = date.month;
  int day = date.day;
  int daysInMonth = getDaysInMonth(year, month);
  if (day > daysInMonth) {
    day = daysInMonth;
  }
  if (month == 12) {
    month = 1;
    year++;
  } else {
    month++;
  }
  return DateTime(year, month, day);
}

double currencyToDouble(String value) {
  if (value == '') {
    return 0.0;
  }
  List<String> new_value = [];
  String allowed = '0123456789.,';
  for (int i = 0; i < value.length; i++) {
    if (allowed.contains(value[i])) {
      new_value.add(value[i]);
    }
  }
  value = new_value.join();
  try {
    return double.parse(value);
  } catch (e) {
    // value = value.replaceAll('€', '');
    // value = value.replaceAll(' ', '');
    if ((value.contains(".")) && (value.contains(","))) {
      value = value.replaceAll('.', '');
      value = value.replaceAll(',', '.');
    } else if (value.contains(",")) {
      value = value.replaceAll(',', '.');
    }
    try {
      return double.parse(value);
    } catch (e) {
      print("Error al convertir $value a double");
      return 0.0;
    }
  }
}

double fromCurrency(String value) {
  return currencyToDouble(value);
}

String getTracker({int length = 5}) {
  String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();
  String code = '';
  for (int i = 0; i < length; i++) {
    code += chars[random.nextInt(chars.length)];
  }
  return code;
}

Future<String> uploadFileToStorage(PlatformFile file,
    {String rootPath = "files/", String fileName = ''}) async {
  PlatformFile pickedFile = file;
  Uint8List? pickedFileBytes = file.bytes;
  UploadTask? uploadTask;

  String uniqueFileName = fileName.isNotEmpty
      ? fileName
      : "${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}";
  final path = '$rootPath$uniqueFileName';
  final ref = FirebaseStorage.instance.ref().child(path);

  try {
    uploadTask = ref.putData(pickedFileBytes!);
    await uploadTask.whenComplete(() => null);
  } catch (e) {
    print(e);
  }
  return path;
}

Future<bool> removeFileFromStorage(String? path) async {
  if (path == null) {
    return true;
  }
  final ref = FirebaseStorage.instance.ref().child(path);

  // check if the file exists
  try {
    await ref.getMetadata();
    return ref.delete().then((value) => true).catchError((e) => false);
  } catch (e) {
    return true;
  }
}

Future<bool> downloadFileUrl(String path) async {
  final ref = FirebaseStorage.instance.ref().child(path);
  // check if the file exists
  try {
    await ref.getMetadata();
    return ref.getDownloadURL().then(
      (value) {
        final Uri toDownload = Uri.parse(value);
        html.window.open(toDownload.toString(), 'Download');
        return true;
      },
    );
  } catch (e) {
    return false;
  }
}

int compareString(bool asc, String val1, String val2) =>
    asc ? val1.compareTo(val2) : val2.compareTo(val1);

int compareDates(bool asc, DateTime val1, DateTime val2) =>
    asc ? val1.compareTo(val2) : val2.compareTo(val1);
