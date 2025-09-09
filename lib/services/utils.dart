import 'dart:math';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:archive/archive.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/main.dart';
import 'package:sic4change/services/cache_rrhh.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'dart:math' as math;

import 'package:sic4change/services/models_profile.dart';

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

const List<String> MonthsNamesES = [
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

const List<String> DaysNamesES = [
  "Lunes",
  "Martes",
  "Miércoles",
  "Jueves",
  "Viernes",
  "Sábado",
  "Domingo"
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

bool isValidEmail(String email) {
  // Expresión regular para validar el formato del correo electrónico
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(email);
}

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
  List months = MonthsNamesES;

  final dateFormatted =
      "${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} de ${date.year}";
  if (withTime) {
    return "$dateFormatted ${date.hour}:${date.minute}";
  }
  return dateFormatted;
}

int getWorkingDaysBetween(
    DateTime date1, DateTime date2, HolidaysConfig? calendar) {
  int workingDays = 0;
  DateTime currentDate = date1;
  while (currentDate.isBefore(date2.add(const Duration(days: 1)))) {
    if (currentDate.weekday == DateTime.saturday ||
        currentDate.weekday == DateTime.sunday) {
      currentDate = currentDate.add(const Duration(days: 1));
      continue;
    }
    if (calendar != null) {
      if (calendar.isHoliday(currentDate)) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }
    }

    workingDays++;
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

DateTime getDate(dynamic date, {truncate = false, DateTime? defaultValue}) {
  if (date == null) {
    return defaultValue ?? DateTime(2099, 12, 31);
  }
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
    return '';
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

Future<String> getDownloadUrl(String? path) async {
  if (path == null) {
    return '';
  }
  final ref = FirebaseStorage.instance.ref().child(path);
  // check if the file exists
  try {
    await ref.getMetadata();
    return await ref.getDownloadURL();
  } catch (e) {
    return '';
  }
}

Future<FullMetadata?> getMetadataFileUrl(String? path) async {
  if (path == null) {
    return FullMetadata({'updated': DateTime(2099, 12, 31)});
  }
  final ref = FirebaseStorage.instance.ref().child(path);
  // check if the file exists
  try {
    return await ref.getMetadata();
  } catch (e) {
    return FullMetadata({'updated': DateTime(2099, 12, 31)});
  }
}

Future<Map<String, dynamic>> openFileUrl(context, String path) async {
  final ref = FirebaseStorage.instance.ref().child(path);
  // check if the file exists
  try {
    Uint8List? data = await ref.getData();
    if (data == null) {
      return {'success': false, 'message': 'File not found'};
    }

    String path_ext = path.split('.').last.toLowerCase();
    String mime = 'application/octet-stream';

    if (path_ext == 'pdf') {
      mime = 'application/pdf';
    }
    if (path_ext == 'doc' || path_ext == 'docx') {
      mime = 'application/msword';
    }
    if (path_ext == 'xls' || path_ext == 'xlsx') {
      mime = 'application/vnd.ms-excel';
    }
    if (path_ext == 'ppt' || path_ext == 'pptx') {
      mime = 'application/vnd.ms-powerpoint';
    }
    if (path_ext == 'jpg' || path_ext == 'jpeg') {
      mime = 'image/jpeg';
    }
    if (path_ext == 'png') {
      mime = 'image/png';
    }
    if (path_ext == 'gif') {
      mime = 'image/gif';
    }
    if (path_ext == 'zip') {
      mime = 'application/zip';
    }
    if (path_ext == 'txt') {
      mime = 'text/plain';
    }

    final blob = html.Blob([data], mime);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      // ..setAttribute('view', path.split('/').last)
      ..setAttribute('target', '_blank')
      ..click();

    return {
      'success': true,
      'message': 'File opened successfully',
      'url': url,
      'mime': mime,
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Error opening file: ${e.toString()}',
      'url': null,
      'mime': null,
    };
  }
}

Future<Map<String, dynamic>> fileExistsInStorage(String? path) async {
  if (path == null) {
    return {'exists': false, 'message': 'File path is null'};
  }
  final ref = FirebaseStorage.instance.ref().child(path);
  // check if the file exists
  try {
    await ref.getMetadata();
    return {'exists': true, 'message': 'File exists'};
  } catch (e) {
    return {'exists': false, 'message': 'File does not exist. $e'};
  }
}

int compareString(bool asc, String val1, String val2) =>
    asc ? val1.compareTo(val2) : val2.compareTo(val1);

int compareDates(bool asc, DateTime val1, DateTime val2) =>
    asc ? val1.compareTo(val2) : val2.compareTo(val1);

Uint8List createZip(List<Uint8List> filesData, List<String> fileNames) {
  final archive = Archive();

  for (int i = 0; i < filesData.length; i++) {
    final file = ArchiveFile.noCompress(
      fileNames[i],
      filesData[i].length,
      filesData[i],
    );
    archive.addFile(file);
  }

  try {
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    if (zipData == null) {
      return Uint8List(0);
    }
    return (Uint8List.fromList(zipData));
  } catch (e) {
    return Uint8List(0);
  } finally {
    archive.clear();
  }
}

Future<void> compressAndDownloadFiles(
    List<String> filePaths, String filename) async {
  // 1. Obtener las URLs de los archivos
  List<Uint8List> filesData = [];
  for (String path in filePaths) {
    try {
      /*final Uint8List? fileData = await ref.getData();
      if (fileData != null) {
        filesData.add(fileData);
      }*/
      final ref = FirebaseStorage.instance.ref().child(path);
      final data = await ref.getData();
      filesData.add(Uint8List.fromList(data!));
    } catch (e) {}
  }

  // 2. Crear el archivo ZIP
  List<String> fileNames =
      filePaths.map((path) => path.split('/').last).toList();
  Uint8List zipData = createZip(filesData, fileNames);
  // 3. Descargar el archivo ZIP
  final blob = html.Blob([zipData]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', '$filename.zip')
    ..click();
}

Color randomColor() {
  return Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
      .withOpacity(1.0);
}

List<List<T>> resize<T>(List<T> list, int ncols) {
  List<List<T>> rows = [];
  for (var i = 0; i < list.length; i += ncols) {
    rows.add(
        list.sublist(i, i + ncols > list.length ? list.length : i + ncols));
  }

  return rows;
}

void checkPermissions(
    BuildContext context, Profile profile, List<String> allowedRole,
    {String? message}) {
  if (!allowedRole.contains(profile.mainRole)) {
    String msg = message ?? "No tienes permisos para acceder a esta sección.";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context);
    Navigator.pushNamed(context, '/');
  }
}

void signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  RestartApp.restart(context);
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
}

String toDuration(double hours, {String format = 'dhm'}) {
  if (hours.isNaN || hours.isInfinite) {
    hours = 0.0;
  }
  if (hours == 0.0) {
    return '0 h';
  }
  hours = hours.abs();
  int totalSeconds = (hours * 3600).round();
  int daysPart = 0;

  if (format.contains('d')) {
    daysPart = totalSeconds ~/ 86400; // 86400 seconds in a day
    totalSeconds %= 86400; // Remaining seconds after extracting days
  }

  int hoursPart = totalSeconds ~/ 3600;
  int minutesPart = (totalSeconds % 3600) ~/ 60;
  int secondsPart = totalSeconds % 60;

  String daysStr = daysPart > 0 ? '$daysPart d ' : '';
  String hoursStr = hoursPart > 0 ? '$hoursPart h ' : '';
  String minutesStr = minutesPart > 0 ? '$minutesPart m ' : '';

  String secondsStr = '';
  if (format.contains('s')) {
    secondsStr = secondsPart > 0 ? '$secondsPart s' : '';
  }

  return '$daysStr$hoursStr$minutesStr$secondsStr'.trim();
}

bool dateInRange(DateTime date, DateTime start, DateTime end) {
  return (date.isAtSameMomentAs(start) ||
      date.isAtSameMomentAs(end) ||
      (date.isAfter(start) && date.isBefore(end)));
}

bool isEmail(String value) {
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(value);
}
