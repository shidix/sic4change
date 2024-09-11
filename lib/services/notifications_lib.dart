import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/widgets/common_widgets.dart';

void createNotification(String sender, List receivers, String msg) {
  for (String r in receivers) {
    SNotification n = SNotification(sender);
    n.receiver = r;
    n.msg = msg;
    n.save();
  }
}

Widget notificationsBadge(context, user, notif, notifColor, url) {
  return badges.Badge(
    position: badges.BadgePosition.topEnd(top: 5, end: 0),
    badgeContent: customText(notif, 10),
    badgeStyle: badges.BadgeStyle(
      shape: badges.BadgeShape.square,
      badgeColor: notifColor,
      padding: const EdgeInsets.all(3),
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: notifColor, width: 2),
      elevation: 0,
    ),
    child: IconButton(
      icon: const Icon(Icons.notifications, color: Colors.white54),
      onPressed: () {
        notificationsDialog(context, user, url);
      },
    ),
  );
}

badges.BadgeStyle badgeStyle = badges.BadgeStyle(
  shape: badges.BadgeShape.square,
  badgeColor: Colors.red,
  padding: const EdgeInsets.all(3),
  borderRadius: BorderRadius.circular(4),
  borderSide: const BorderSide(color: Colors.red, width: 2),
  elevation: 0,
);

Future<void> notificationsDialog(context, user, url) async {
  List notificationList = await SNotification.getNotificationsByReceiver(user);
  for (SNotification n in notificationList) {
    n.readed = true;
    n.save();
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(0),
        title: s4cTitleBar('Notificaciones'),
        content: DataTable(
          headingRowHeight: 0,
          columns: [DataColumn(label: Container())],
          rows: notificationList
              .map(
                (n) => DataRow(cells: [
                  DataCell(Text(n.msg)),
                ]),
              )
              .toList(),
        ),
        actions: <Widget>[
          /*actionButton(context, "Cerrar", cancelItem, Icons.cancel, context),*/
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, url, arguments: []);
            },
            child: customText("Marcar como leídos", 16,
                textColor: cardHeaderColor),
          ),
        ],
      );
    },
  );
}
