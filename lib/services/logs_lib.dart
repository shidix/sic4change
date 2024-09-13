import 'package:sic4change/services/models_commons.dart';

void createLog(String user, String msg) {
  SLogs log = SLogs(user);
  log.msg = msg;
  log.save();
}
