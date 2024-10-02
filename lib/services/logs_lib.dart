//import 'package:export_firebase_csv/export_firebase_csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sic4change/services/models_commons.dart';
//import 'package:to_csv/to_csv.dart' as exportCSV;

void createLog(String msg) {
  final user = FirebaseAuth.instance.currentUser!;
  SLogs log = SLogs(user.email!);
  log.msg = msg;
  log.save();
}

/*void exportLogFromFirebase() async {
  String collectionName = 's4c_logs';
  List<String> rowTitles = ['Date', 'User', 'Msg'];
  List<String> fieldNames = ['date', 'user', 'msg'];
  DateTime startDate = DateTime(2024, 1, 1);
  DateTime endDate = DateTime(2024, 12, 31);
  String dateFieldName = 'date';

  //await exportWithTitles(collectionName, rowTitles, fieldNames, startDate,
  //    endDate, dateFieldName, "-", "report");
}*/

/*void exportLogFromFirebase() async {
  DateTime startDate = DateTime(2024, 10, 1);
  DateTime endDate = DateTime(2024, 12, 31);

  List<String> header = [];
  header.add('Fecha');
  header.add('Usuario');
  header.add('IP');
  header.add('Log');

  List<List<String>> listOfLists =
      []; //Outter List which contains the data List

  List logList = await SLogs.getLogs();
  for (SLogs l in logList) {
    if (l.date.isAfter(startDate) && l.date.isBefore(endDate)) {
      List<String> data1 = [l.date.toString(), l.user, l.ip, l.msg];
      listOfLists.add(data1);
    }
  }

  exportCSV.myCSV(
    header,
    listOfLists,
    setHeadersInFirstRow: true,
  );
}*/

void exportLogFromFirebase(List logList) async {
  List<String> header = [];
  header.add('Fecha');
  header.add('Usuario');
  header.add('IP');
  header.add('Log');

  List<List<String>> listOfLists =
      []; //Outter List which contains the data List

  for (SLogs l in logList) {
    List<String> data1 = [l.date.toString(), l.user, l.ip, l.msg];
    listOfLists.add(data1);
  }

  /*exportCSV.myCSV(
    header,
    listOfLists,
    setHeadersInFirstRow: true,
  );*/
}
