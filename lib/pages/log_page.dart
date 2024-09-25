import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

Widget? _mainMenu;

class LogPage extends StatefulWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List logs = [];
  bool sortAsc = false;
  int sortColumnIndex = 0;
  DateTime currentDate = DateTime.now();
  List selected = [];

  @override
  void initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    getLogList(currentDate);
  }

  void getLogList(DateTime date) async {
    await SLogs.getLogs().then((value) {
      for (SLogs l in value) {
        if (DateUtils.isSameDay(l.date, date)) {
          logs.add(l);
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          _mainMenu!,
          space(height: 10),
          logHeader(context),
          space(height: 20),
          contentTabSized(context, logList, null),
        ],
      )),
    );
  }

  Widget logHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: const Text("Logs", style: headerTitleText),
      ),
      /*SearchBar(
        controller: searchController,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onSubmitted: (value) {
          //loadTasks();
        },
        leading: const Icon(Icons.search),
      ),*/
      SizedBox(
          width: 330,
          child: DateTimePicker(
            labelText: 'Acuerdo',
            selectedDate: DateTime.now(),
            lastDate: DateTime.now(),
            onSelectedDate: (DateTime date) {
              getLogList(date);
              setState(() {
                currentDate = date;
              });
            },
          )),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //addBtn(context, callEditDialog, {"task": null}),
            FilledButton(
                onPressed: () async {
                  for (SLogs l in selected) {
                    logs.remove(l);
                    l.delete();
                  }
                  setState(() {});
                },
                style: btnStyle,
                child: Column(
                  children: [
                    space(height: 5),
                    const Icon(Icons.remove_circle_outline,
                        color: subTitleColor),
                    space(height: 5),
                    customText("Eliminar", 12, textColor: subTitleColor),
                    space(height: 5),
                  ],
                )),
            space(width: 10),
            FilledButton(
                onPressed: () async {
                  exportLogFromFirebase();
                },
                style: btnStyle,
                child: Column(
                  children: [
                    space(height: 5),
                    const Icon(Icons.download, color: subTitleColor),
                    space(height: 5),
                    customText("Descargar", 12, textColor: subTitleColor),
                    space(height: 5),
                  ],
                )),
          ],
        ),
      ),
    ]);
  }

  void onSort(int columnIndex, bool asc) {
    if (columnIndex == 0) {
      logs.sort((t1, t2) => compareDates(asc, t1.date, t2.date));
    } else if (columnIndex == 1) {
      logs.sort((t1, t2) => compareString(asc, t1.user, t2.user));
    } else if (columnIndex == 2) {
      logs.sort((t1, t2) => compareString(asc, t1.msg, t2.msg));
    }

    setState(() {
      sortColumnIndex = columnIndex;
      sortAsc = asc;
    });
  }

  DataColumn customColumn(String text) {
    return DataColumn(
      label: customText(text, 14, bold: FontWeight.bold),
      tooltip: text,
      onSort: onSort,
    );
  }

  Widget logList(context, params) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        sortAscending: sortAsc,
        sortColumnIndex: sortColumnIndex,
        showCheckboxColumn: true,
        headingRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.hovered)) {
            return headerListBgColor.withOpacity(0.5);
          }
          return headerListBgColor;
        }),
        columns: [
          customColumn("Fecha"),
          customColumn("Usuario"),
          customColumn("Log"),
        ],
        rows: logs
            .map(
              (log) => DataRow(
                cells: [
                  DataCell(
                    Text(DateFormat('yyyy-MM-dd').format(log.date)),
                  ),
                  DataCell(Text(log.user)),
                  DataCell(customText(log.msg, 14)),
                ],
                selected: selected.contains(log),
                onSelectChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selected.add(log);
                    } else {
                      selected.remove(log);
                    }
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
