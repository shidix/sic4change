// ignore_for_file: unused_import, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/transcoder/v1.dart';
import 'package:sic4change/pages/tasks_users_page.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/widgets/common_widgets.dart';

// class Event extends Appointment {
//   final int index;
//   Event(
//       {required String subject,
//       required DateTime startTime,
//       required DateTime endTime,
//       String? notes,
//       Color? color,
//       bool isAllDay = false,
//       required this.index})
//       : super(
//             subject: subject,
//             startTime: startTime,
//             endTime: endTime,
//             notes: notes,
//             color: color ?? Colors.blue,
//             isAllDay: isAllDay);

// }

class EventForm extends StatefulWidget {
  final Event? currentEvent;
  final int index;
  final HolidaysConfig? holidaysConfig;

  const EventForm(
      {Key? key, this.currentEvent, this.holidaysConfig, required this.index})
      : super(key: key);

  @override
  createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  late Event event;
  late HolidaysConfig holidaysConfig;
  bool isNewItem = false;

  @override
  void initState() {
    super.initState();
    isNewItem = (widget.currentEvent!.subject == "");
    event = widget.currentEvent!;
    holidaysConfig = widget.holidaysConfig!;
    if (isNewItem) {
      event = Event(
          subject: "",
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 1)),
          isAllDay: false,
          notes: "");
    }
  }

  void saveItem(List args) {
    BuildContext context = args[0];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      if (isNewItem) {
        holidaysConfig.gralHolidays.add(event);
      } else {
        holidaysConfig.gralHolidays[widget.index] = event;
      }
      holidaysConfig.save();
      formKey.currentState!.save();
      Navigator.of(context).pop(event);
    } else {
      print(2);
    }
  }

  void removeItem(List args) {
    holidaysConfig.gralHolidays.removeAt(widget.index);
    holidaysConfig.save();
    Navigator.of(args[0]).pop(null);

    // BuildContext context = args[0];
    // Event event = args[1];
    // GlobalKey<FormState> formKey = args[2];
    // if (formKey.currentState!.validate()) {
    //   formKey.currentState!.save();
    //   Navigator.of(context).pop(event);
    // }
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<Expanded> deleteButton = [];
    int flex = 5;
    if (!isNewItem) {
      flex = 3;
      deleteButton = [
        Expanded(flex: 1, child: Container()),
        Expanded(
            flex: flex,
            child: actionButton(context, "Eliminar", removeItem, Icons.delete,
                [context, event, _formKey]))
      ];
    }
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: event.subject,
                decoration: const InputDecoration(labelText: 'Evento'),
                onChanged: (value) => event.subject = value,
                // onSaved: (val) => setState(() => event.subject = val!),
              ),
              space(),
              TextFormField(
                initialValue: event.notes,
                decoration: const InputDecoration(labelText: 'Notas'),
                onChanged: (val) => setState(() => event.notes = val),
              ),
              space(height: 16),
              Row(
                  children: [
                        Expanded(
                            flex: flex,
                            child: actionButton(
                                context,
                                "Enviar",
                                saveItem,
                                Icons.save_outlined,
                                [context, event, _formKey])),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                            flex: flex,
                            child: actionButton(context, "Cancelar", cancelItem,
                                Icons.cancel, context))
                      ] +
                      deleteButton),
            ],
          ),
        ),
      ),
    );
  }
}

class HolidayRequestForm extends StatefulWidget {
  final HolidayRequest? currentRequest;
  final User? user;

  const HolidayRequestForm({Key? key, this.currentRequest, this.user})
      : super(key: key);

  @override
  createState() => _HolidayRequestFormState();
}

class _HolidayRequestFormState extends State<HolidayRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidayRequest holidayRequest;
  late User user;
  bool isNewItem = false;
  late Profile profile;

  @override
  void initState() {
    super.initState();
    user = widget.user!;
    profile =
        Profile(id: '', email: '', holidaySupervisor: [], mainRole: 'Usuario');
    Profile.getCurrentProfile().then((value) {
      if (mounted) {
        setState(() {
          profile = value;
        });
      } else {
        profile = value;
      }
    });
    isNewItem = (widget.currentRequest!.id == "");
    holidayRequest = widget.currentRequest!;
    if (isNewItem) {
      holidayRequest.userId = user.email!;
      holidayRequest.requestDate = DateTime.now();
      holidayRequest.approvalDate = DateTime(2099, 12, 31);
      holidayRequest.status = "Pendiente";
      holidayRequest.approvedBy = "";
    }
  }

  void saveItem(List args) {
    BuildContext context = args[0];
    HolidayRequest holidayRequest = args[1];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      holidayRequest.save();
      Navigator.of(context).pop(holidayRequest);
    }
  }

  void removeItem(List args) {
    BuildContext context = args[0];
    HolidayRequest holidayRequest = args[1];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      holidayRequest.delete();
      Navigator.of(context).pop(holidayRequest);
    }
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<Expanded> deleteButton = [];
    int flex = 5;
    if (!isNewItem) {
      flex = 3;
      deleteButton = [
        Expanded(flex: 1, child: Container()),
        Expanded(
            flex: flex,
            child: actionButton(context, "Eliminar", removeItem, Icons.delete,
                [context, holidayRequest, _formKey]))
      ];
    }
    Widget statusField;

    if (user.email == holidayRequest.userId) {
      statusField = Row(children: [
        Expanded(
            flex: 1,
            child: ReadOnlyTextField(
                label: 'Estado', textToShow: holidayRequest.status))
      ]);
    } else {
      List<DropdownMenuItem<String>>? statusList = [];

      for (String status in ['Pendiente', 'Aprobado', 'Rechazado']) {
        statusList.add(
            DropdownMenuItem(value: status, child: Text(status.toUpperCase())));
      }

      statusField = DropdownButtonFormField(
          value: holidayRequest.status,
          decoration: const InputDecoration(labelText: 'Estado'),
          items: statusList,
          onChanged: (value) {
            holidayRequest.status = value.toString();
          });
    }

    Widget categorySelectField;
    List<DropdownMenuItem<String>>? categoryList = [];
    for (String category in [
      'Vacaciones',
      'Permiso',
      'Licencia',
      'Ausencia',
      'Asuntos Propios',
      'Enfermedad'
    ]) {
      categoryList.add(DropdownMenuItem(
          value: category, child: Text(category.toUpperCase())));
    }
    categorySelectField = DropdownButtonFormField(
        value: holidayRequest.catetory,
        decoration: const InputDecoration(labelText: 'Categoría'),
        items: categoryList,
        onChanged: (value) {
          holidayRequest.catetory = value.toString();
        });
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ReadOnlyTextField(
                  label: 'Usuario', textToShow: holidayRequest.userId),
              space(),
              ReadOnlyTextField(
                  label: 'Fecha de Solicitud',
                  textToShow: DateFormat('dd-MM-yyyy')
                      .format(holidayRequest.requestDate)),
              space(),
              categorySelectField,
              space(),
              DateTimeRangePicker(
                labelText: 'Período',
                calendarRangeDate: DateTimeRange(
                    start: DateTime.now(),
                    end: DateTime.now().add(Duration(days: 365))),
                selectedDate: DateTimeRange(
                    start: holidayRequest.startDate,
                    end: holidayRequest.endDate),
                onSelectedDate: (DateTimeRange date) {
                  setState(() {
                    holidayRequest.startDate = date.start;
                    holidayRequest.endDate = date.end;
                  });
                },
              ),
              space(),
              statusField,
              space(),
              ReadOnlyTextField(
                  label: "Aprobado por ${profile.holidaySupervisor}",
                  textToShow: (holidayRequest.approvedBy != '')
                      ? holidayRequest.approvedBy
                      : 'Pendiente de aprobación'),
              // TextFormField(
              //   initialValue: holidayRequest.approvedBy,
              //   decoration: const InputDecoration(labelText: 'Aprobado por'),
              //   onSaved: (val) =>
              //       setState(() => holidayRequest.approvedBy = val!),
              // ),
              space(height: 16),
              Row(
                  children: [
                        Expanded(
                            flex: flex,
                            child: actionButton(
                                context,
                                "Enviar",
                                saveItem,
                                Icons.save_outlined,
                                [context, holidayRequest, _formKey])),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                            flex: flex,
                            child: actionButton(context, "Cancelar", cancelItem,
                                Icons.cancel, context))
                      ] +
                      deleteButton),
            ],
          ),
        ),
      ),
    );
  }
}

class HolidayConfigForm extends StatefulWidget {
  final HolidaysConfig? holidaysConfig;
  final Function? afterSave;
  final Function? afterDelete;
  final int index;

  const HolidayConfigForm(
      {Key? key,
      this.holidaysConfig,
      this.afterSave,
      this.afterDelete,
      required this.index})
      : super(key: key);

  @override
  createState() => _HolidayConfigFormState();
}

class _HolidayConfigFormState extends State<HolidayConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidaysConfig holidaysConfig;
  bool isNewItem = false;

  @override
  void initState() {
    super.initState();
    isNewItem = (widget.index == -1);
    holidaysConfig = widget.holidaysConfig!;
  }

  void saveItem(List args) {
    BuildContext context = args[0];
    HolidaysConfig holidaysConfig = args[1];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      holidaysConfig.save();
      if (widget.afterSave != null) {
        widget.afterSave!();
      }
      Navigator.of(context).pop(holidaysConfig);
    }
  }

  void removeItem(List args) {
    BuildContext context = args[0];
    HolidaysConfig holidaysConfig = args[1];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      holidaysConfig.delete();
      if (widget.afterDelete != null) {
        widget.afterDelete!();
      }
      Navigator.of(context).pop();
    }
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<Expanded> deleteButton = [];
    int flex = 5;
    if (!isNewItem) {
      flex = 3;
      deleteButton = [
        Expanded(flex: 1, child: Container()),
        Expanded(
            flex: flex,
            child: actionButton(context, "Eliminar", removeItem, Icons.delete,
                [context, holidaysConfig, _formKey]))
      ];
    }
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        child: SingleChildScrollView(
          child: Column(children: [
            TextFormField(
              initialValue: holidaysConfig.year.toString(),
              decoration: const InputDecoration(labelText: 'Año'),
              onSaved: (val) =>
                  setState(() => holidaysConfig.year = int.parse(val!)),
            ),
            space(),
            TextFormField(
              initialValue: holidaysConfig.name,
              decoration: const InputDecoration(labelText: 'Nombre'),
              onSaved: (val) => setState(() {
                holidaysConfig.name = val!;
              }),
            ),
            space(),
            TextFormField(
              initialValue: holidaysConfig.totalDays.toString(),
              //only numbers
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Días totales'),
              onSaved: (val) => setState(() {
                holidaysConfig.totalDays = int.parse(val!);
              }),
            ),
            space(),
            // Buttons
            Row(
                children: [
                      Expanded(
                          flex: flex,
                          child: actionButton(
                              context,
                              "Enviar",
                              saveItem,
                              Icons.save_outlined,
                              [context, holidaysConfig, _formKey])),
                      Expanded(flex: 1, child: Container()),
                      Expanded(
                          flex: flex,
                          child: actionButton(context, "Cancelar", cancelItem,
                              Icons.cancel, context))
                    ] +
                    deleteButton),
          ]),
        ),
      ),
    );
  }
}

class HolidayConfigUserForm extends StatefulWidget {
  final HolidaysConfig? holidaysConfig;
  final Function? afterSave;
  final Function? afterDelete;

  const HolidayConfigUserForm(
      {Key? key, this.holidaysConfig, this.afterSave, this.afterDelete})
      : super(key: key);

  @override
  createState() => _HolidayConfigUserFormState();
}

class _HolidayConfigUserFormState extends State<HolidayConfigUserForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidaysConfig holidaysConfig;
  bool isNewItem = false;
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    // Initialize the list of employees from the organization
    Employee.getAll().then((value) {
      employees = value;
      if (mounted) {
        setState(() {});
      }
    });

    holidaysConfig = widget.holidaysConfig!;
  }

  // void saveItem(List args) {
  //   BuildContext context = args[0];
  //   HolidaysConfig holidaysConfig = args[1];
  //   GlobalKey<FormState> formKey = args[2];
  //   if (formKey.currentState!.validate()) {
  //     formKey.currentState!.save();
  //     holidaysConfig.save();
  //     if (widget.afterSave != null) {
  //       widget.afterSave!();
  //     }
  //     Navigator.of(context).pop(holidaysConfig);
  //   }
  // }

  // void removeItem(List args) {
  //   BuildContext context = args[0];
  //   HolidaysConfig holidaysConfig = args[1];
  //   GlobalKey<FormState> formKey = args[2];
  //   if (formKey.currentState!.validate()) {
  //     formKey.currentState!.save();
  //     holidaysConfig.save();
  //     if (widget.afterDelete != null) {
  //       widget.afterDelete!();
  //     }
  //     Navigator.of(context).pop();
  //   }
  // }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // My form is a list or buttons with the user names; if the user is already in the list, the button has background color green, if not, it has background color red. Press button to add or remove user from the list.
    List<Widget> userButtons = [];

    userButtons = employees.map((employee) {
      bool isSelected =
          holidaysConfig.employees.any((element) => element.id == employee.id);
      return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            color: (holidaysConfig.employees
                    .any((element) => element.code == employee.code))
                ? Colors.white
                : Colors.grey,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(children: [
            Expanded(
              flex: 3,
              child: Text(employee.getFullName(),
                  style: TextStyle(
                      color: (holidaysConfig.employees
                              .any((element) => element.code == employee.code))
                          ? Colors.black
                          : Colors.white)),
            ),
            Expanded(
              flex: 1,
              child: iconBtn(context, (context) {
                if (isSelected) {
                  holidaysConfig = holidaysConfig.removeEmployee(employee);
                } else {
                  holidaysConfig = holidaysConfig.addEmployee(employee);
                }
                if (mounted) {
                  setState(() {});
                }
              }, null,
                  text: '',
                  icon: (isSelected) ? Icons.remove : Icons.add_outlined,
                  color: (isSelected) ? Colors.red : Colors.white),
            )
          ]),
        ),
      );
    }).toList();

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        child: SingleChildScrollView(
            child: Column(
          children: userButtons,
        )),
      ),
    );
  }
}
