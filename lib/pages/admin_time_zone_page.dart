import 'dart:async';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/monitoring/v3.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';


const timeZoneTitle = "Zonas Horarias";
List<TimeZone> timeZones = [];
bool loadingTimeZones = false;
Widget? _mainMenu;

class TimeZonePage extends StatefulWidget {
  const TimeZonePage({super.key});

  @override
  State<TimeZonePage> createState() => _TimeZonePageState();
}

class _TimeZonePageState extends State<TimeZonePage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingTimeZones = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingTimeZones = false;
    });
  }

  void loadTimeZones() async {
    setLoading();
    timeZones = await TimeZone.getAll(fromServer: true);
    if (timeZones.isEmpty) {
      await TimeZone.initialize();
      timeZones = await TimeZone.getAll();
      if (mounted) {
        setState(() {});
      }
    }
    stopLoading();
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        timeZoneHeader(context),
        timeZones.isEmpty
            ? loadingWidget()
            : timeZoneListWidget(context, timeZones),
      ]),
    ));
  }

  Widget timeZoneHeader(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText(timeZoneTitle, 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(
                context, editTimeZoneDialog, {'timeZone': TimeZone.getEmpty()},
                text: "Agregar Zona Horaria"),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  Widget timeZoneListWidget(BuildContext context, List timeZones) {
    DataTable dataTable = DataTable(
      columns: const [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Código')),
        DataColumn(label: Text('UTC Offset (minutos)')),
      ],
      rows: timeZones
          .map<DataRow>((timeZone) => DataRow(cells: [
                DataCell(Text(timeZone.name)),
                DataCell(Text(timeZone.code)),
                DataCell(Text(timeZone.offset.toString())),
              ]))
          .toList(),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        child: dataTable,
      ),
    );
  }

  Widget loadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void editTimeZoneDialog(List args) {
    TimeZone timeZone = args[0];
    // Implement the dialog to edit or add a TimeZone
    print("Editing TimeZone: ${timeZone.id}");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(timeZone.id.isEmpty
              ? 'Agregar Zona Horaria'
              : 'Editar Zona Horaria'),
          content: TimeZoneForm(timeZone: timeZone),
        );
      },
    ).then((_) {
      loadTimeZones();
    });
  }
}

class TimeZoneForm extends StatefulWidget {
  final TimeZone timeZone;

  const TimeZoneForm({super.key, required this.timeZone});

  @override
  State<TimeZoneForm> createState() => _TimeZoneFormState();
}

class _TimeZoneFormState extends State<TimeZoneForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _offsetController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.timeZone.name);
    _offsetController =
        TextEditingController(text: widget.timeZone.offset.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _offsetController,
            decoration: const InputDecoration(labelText: 'UTC Offset'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a UTC offset';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Save the TimeZone
                widget.timeZone.name = _nameController.text;
                widget.timeZone.offset = int.parse(_offsetController.text);
                widget.timeZone.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
