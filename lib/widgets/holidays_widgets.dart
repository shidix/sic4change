import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget buildHolidayListItem(
  BuildContext context,
  HolidayRequest holiday, {
  required Function? onTap,
}) {
  // Define the colors for each holiday status
  Map<String, Color> holidayStatusColors = {
    "pendiente": warningColor,
    "aprobado": successColor,
    "rechazado": dangerColor,
  };
  return ListTile(
      subtitle: Column(children: [
        Row(
          children: [
            Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        (holiday.category != null)
                            ? holiday.category!.code
                            : 'Cargando...',
                        style: normalText,
                      )),
                )),
            Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(holiday.startDate),
                    style: normalText,
                    textAlign: TextAlign.center,
                  )),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(holiday.endDate),
                    style: normalText,
                    textAlign: TextAlign.center,
                  )),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    getWorkingDaysBetween(holiday.startDate, holiday.endDate)
                        .toString(),
                    style: normalText,
                    textAlign: TextAlign.center,
                  )),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                      color: holidayStatusColors[holiday.status.toLowerCase()]!,
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            holiday.status.substring(0, 3).toUpperCase(),
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          )))),
            ),
          ],
        )
      ]),
      onTap: (onTap != null)
          ? (onTap())
          : (() {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return infoDialog(
                      context,
                      Icon(Icons.info),
                      "Solicitud de ${holiday.category?.name ?? 'días libres'}",
                      "Esta solicitud ya ha sido aprobada o denegada. No se puede editar.",
                    );
                  });
            }));
}
