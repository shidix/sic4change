// import 'package:export_firebase_csv/export_firebase_csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sic4change/services/models_commons.dart';

void createLog(String msg) {
  final user = FirebaseAuth.instance.currentUser!;
  SLogs log = SLogs(user.email!);
  log.msg = msg;
  log.save();
}

void exportLogFromFirebase() async {
  String collectionName = 's4c_logs';
  List<String> rowTitles = ['Date', 'User', 'Msg'];
  List<String> fieldNames = ['date', 'user', 'msg'];
  DateTime startDate = DateTime(2024, 1, 1);
  DateTime endDate = DateTime(2024, 12, 31);
  String dateFieldName = 'date';

  // await exportWithTitles(collectionName, rowTitles, fieldNames, startDate,
  //     endDate, dateFieldName, "-", "report");
}
