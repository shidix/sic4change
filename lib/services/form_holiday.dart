// ignore_for_file: unused_import, prefer_const_constructors

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/transcoder/v1.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/admin_holidays_categories_page.dart';
import 'package:sic4change/pages/tasks_users_page.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/notifications_lib.dart';
import 'package:sic4change/services/utils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;

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
          id: Uuid().v4().toString(),
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
    } else {}
  }

  void removeItem(List args) {
    holidaysConfig.gralHolidays.removeAt(widget.index);
    print("Users in calendar after remove: ${holidaysConfig.employees}");
    //holidaysConfig.save();
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
  final Profile profile;
  final List<Employee> superiors;
  final HolidaysConfig calendar;
  final List<HolidaysCategory> categories;
  final List<HolidayRequest> granted;
  final Map<String, int> remainingHolidays;

  const HolidayRequestForm(
      {super.key,
      this.currentRequest,
      this.user,
      required this.superiors,
      required this.profile,
      required this.categories,
      required this.granted,
      required this.calendar,
      required this.remainingHolidays});

  @override
  createState() => _HolidayRequestFormState();
}

class _HolidayRequestFormState extends State<HolidayRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidayRequest holidayRequest;
  late List<HolidayRequest> granted;
  late List<HolidaysCategory> categories;
  late Map<String, int> remainingHolidays;
  late User user;
  bool isNewItem = false;
  late Profile profile;
  late List<Employee> superiors;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    user = widget.user!;
    categories = widget.categories;
    granted = widget.granted;
    remainingHolidays = widget.remainingHolidays;
    profile = widget.profile;
    superiors = widget.superiors;

    // profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    isNewItem = (widget.currentRequest!.id == "");
    holidayRequest = widget.currentRequest!;
    if (isNewItem) {
      holidayRequest.userId = user.email!;
      holidayRequest.requestDate = DateTime.now();
      holidayRequest.approvalDate = DateTime(2099, 12, 31);
      holidayRequest.status = "Pendiente";
      holidayRequest.approvedBy = "";
    } else {
      // Add the current days to the remaining holidays
      HolidaysCategory cat = holidayRequest.getCategory(categories);
      if (cat.id != '') {
        remainingHolidays[cat.autoCode()] =
            (remainingHolidays[cat.autoCode()] ?? 0) +
                getWorkingDaysBetween(holidayRequest.startDate,
                    holidayRequest.endDate, [widget.calendar]);
      }
    }
  }

  void saveItem(List args) {
    BuildContext context = args[0];
    HolidayRequest holidayRequest = args[1];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      List<String> superiorsEmails =
          superiors.map((e) => e.email).toList().cast<String>();
      print("Superiores: $superiorsEmails");
      if (superiorsEmails.isNotEmpty) {
        createNotification(user.email!, superiorsEmails,
            "Solicitud de permiso: Del ${DateFormat('dd-MM-yyyy').format(holidayRequest.startDate)} al ${DateFormat('dd-MM-yyyy').format(holidayRequest.endDate)}, categoría: ${holidayRequest.getCategory(categories).name}, Estado: ${holidayRequest.status}",
            objId: holidayRequest.id,
            objType: HolidayRequest.tbName.toUpperCase());
      }
      formKey.currentState!.save();
      holidayRequest.save().then((value) {
        if (mounted) {
          Navigator.of(context).pop(value);
        }
      });
    }
  }

  void removeItem(List args) {
    BuildContext context = args[0];
    HolidayRequest holidayRequest = args[1];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      holidayRequest.delete();
      HolidayRequest item = HolidayRequest.getEmpty();
      item.id = "--remove--";
      Navigator.of(context).pop(item);
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
      List<String> statuses = ['Pendiente', 'Aprobado', 'Rechazado'];

      if (!statuses.contains(holidayRequest.status)) {
        statusList.add(DropdownMenuItem(
            value: holidayRequest.status,
            child: Text(holidayRequest.status + ' (actual)')));
      }

      for (String status in statuses) {
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
    for (HolidaysCategory category in categories) {
      if (category.id == '') {
        continue; // Skip empty categories
      }

      categoryList.add(DropdownMenuItem(
          value: category.id,
          child: Text(
              "${category.name.toUpperCase()} (${remainingHolidays[category.autoCode()] ?? 0})")));
    }

    if ((holidayRequest.category == '') ||
        (!categoryList.any((item) => item.value == holidayRequest.category))) {
      // If category is empty, set it to the first category in the list
      if (categoryList.isNotEmpty) {
        holidayRequest.category = categoryList.first.value!;
      } else {
        HolidaysCategory emptyCategory = HolidaysCategory.getEmpty();
        emptyCategory.name = 'Sin categoría';
        emptyCategory.id = '--empty--';
        categories.add(emptyCategory);
        categoryList.add(
            DropdownMenuItem(value: '--empty--', child: Text('Sin categoría')));
        // If no categories are available, set category to empty

        holidayRequest.category = '--empty--';
      }
    }

    categorySelectField = DropdownButtonFormField(
        value: holidayRequest.category,
        decoration: const InputDecoration(labelText: 'Categoría'),
        items: categoryList,
        onChanged: (value) {
          holidayRequest.category = value ?? '';
          if (mounted) {
            setState(() {});
          }
        });

    bool isRetroactive = holidayRequest.getCategory(categories).retroactive;

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
                errorMessage: errorMessage,
                calendarRangeDate: DateTimeRange(
                    start: (isRetroactive)
                        ? DateTime.now().subtract(Duration(days: 365))
                        : DateTime.now(),
                    end: DateTime.now().add(Duration(days: 365))),
                selectedDate: DateTimeRange(
                    start: holidayRequest.startDate,
                    end: holidayRequest.endDate),
                onSelectedDate: (DateTimeRange date) {
                  errorMessage = null; // Reset error message
                  setState(() {
                    int workingDays = getWorkingDaysBetween(
                        date.start, date.end, [widget.calendar]);
                    if (workingDays >
                        remainingHolidays[holidayRequest
                            .getCategory(categories)
                            .autoCode()]!) {
                      errorMessage = "No hay suficientes días disponibles";
                    } else {
                      holidayRequest.startDate = date.start;
                      holidayRequest.endDate = date.end;
                    }
                  });
                },
              ),
              space(),
              statusField,
              // space(),
              // ReadOnlyTextField(
              //     label: "Aprobado por ",
              //     textToShow: (holidayRequest.approvedBy != '')
              //         ? holidayRequest.approvedBy
              //         : 'Pendiente de aprobación'),
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
            // TextFormField(
            //   initialValue: holidaysConfig.totalDays.toString(),
            //   //only numbers
            //   keyboardType: TextInputType.number,
            //   decoration: const InputDecoration(labelText: 'Días totales'),
            //   onSaved: (val) => setState(() {
            //     holidaysConfig.totalDays = int.parse(val!);
            //   }),
            // ),
            // space(),
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
  final List<String>? employeesInCalendars;
  final Function? afterSave;
  final Function? afterDelete;

  const HolidayConfigUserForm(
      {Key? key,
      this.holidaysConfig,
      this.employeesInCalendars,
      this.afterSave,
      this.afterDelete})
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
      // Remove employees that are already in the calendar
      if (widget.employeesInCalendars != null) {
        employees.removeWhere(
            (employee) => widget.employeesInCalendars!.contains(employee.id));
      }

      if (mounted) {
        setState(() {});
      }
    });

    holidaysConfig = widget.holidaysConfig!;
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> userButtons = [];
    List<Employee> employeesInCalendar = employees
        .where((emp) =>
            holidaysConfig.employees.any((element) => element == emp.id))
        .toList();

    userButtons = employees.map((employee) {
      bool isSelected =
          holidaysConfig.employees.any((element) => element == employee.id);

      return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            color: (employeesInCalendar
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
                      color: (employeesInCalendar
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

class HolidaysCategoryForm extends StatefulWidget {
  final HolidaysCategory? category;
  final Function? afterSave;
  final Function? afterDelete;

  const HolidaysCategoryForm(
      {Key? key, this.category, this.afterSave, this.afterDelete})
      : super(key: key);

  @override
  createState() => _HolidaysCategoryFormState();
}

class _HolidaysCategoryFormState extends State<HolidaysCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidaysCategory category;
  late final HolidaysCategory? originalCategory;
  bool isNewItem = false;

  @override
  void initState() {
    super.initState();
    isNewItem = (widget.category!.id == "");
    category = widget.category!;
    originalCategory = HolidaysCategory.fromJson(widget.category!.toJson());
  }

  void saveItem(List args) {
    BuildContext context = args[0];
    HolidaysCategory category = args[1];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      category.save();
      if (widget.afterSave != null) {
        widget.afterSave!(category);
      }
      try {
        if (!mounted) return;
        Navigator.of(context).pop(category);
      } catch (e) {}
    }
  }

  void removeItem(List args) {
    BuildContext context = args[0];
    HolidaysCategory category = args[1];
    GlobalKey<FormState> formKey = args[2];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      category.delete();
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
                [context, category, _formKey]))
      ];
    }
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        child: SingleChildScrollView(
          child: Column(children: [
            //Row with name and code
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    initialValue: category.name,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onSaved: (val) => setState(() => category.name = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: category.code,
                    decoration: const InputDecoration(labelText: 'Código'),
                    onSaved: (val) => setState(() => category.code = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: category.year.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Año'),
                    onSaved: (val) =>
                        setState(() => category.year = int.parse(val!)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DateTimePicker(
                      labelText: 'Válido hasta',
                      selectedDate: getDate(category.validUntil),
                      onSelectedDate: (date) {
                        setState(() {
                          category.validUntil = date;
                        });
                      }),
                ),
              ],
            ),
            space(),
            // Row with days, obligation, and retroactive
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: category.days.toString(),
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Número de días'),
                    onSaved: (val) => setState(() {
                      category.days = int.parse(val!);
                    }),
                  ),
                ),
                space(width: 16),
                Expanded(
                  flex: 2,
                  child: CheckboxFormField(
                      title: const Text('Obligatorios'),
                      initialValue: category.obligation,
                      onSaved: (val) => setState(() {
                            category.obligation = val!;
                          })),
                ),
                space(width: 16),
                Expanded(
                  flex: 2,
                  child: CheckboxFormField(
                      title: const Text('Retroactivo'),
                      initialValue: category.retroactive,
                      onSaved: (val) => setState(() {
                            category.retroactive = val!;
                          })),
                ),
                space(width: 16),
                Expanded(
                  flex: 2,
                  child: CheckboxFormField(
                      title: const Text('Solo RRHH'),
                      initialValue: category.onlyRRHH,
                      onSaved: (val) => setState(() {
                            category.onlyRRHH = val!;
                          })),
                ),
              ],
            ),
            space(height: 16),
            // Row with document requirements
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: category.docRequired.toString(),
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Número Documentos'),
                    onSaved: (val) =>
                        setState(() => category.docRequired = int.parse(val!)),
                  ),
                ),
                space(width: 16),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    initialValue: category.docMessage.isNotEmpty
                        ? category.docMessage
                        : " ",
                    decoration: const InputDecoration(
                        labelText: 'Descripción de los documentos requeridos'),
                    onSaved: (val) =>
                        setState(() => category.docMessage = val!),
                  ),
                ),
              ],
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
                              [context, category, _formKey])),
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

class HolidayDocumentsForm extends StatefulWidget {
  final HolidayRequest? holidayRequest;
  final Function? afterSave;
  final List<HolidaysCategory> categories;

  const HolidayDocumentsForm(
      {Key? key, this.holidayRequest, this.afterSave, required this.categories})
      : super(key: key);

  @override
  createState() => _HolidayDocumentsFormState();
}

class _HolidayDocumentsFormState extends State<HolidayDocumentsForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidayRequest holidayRequest;
  late List<HolidaysCategory> categories;
  // List<PlatformFile?> uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    holidayRequest = widget.holidayRequest!;
    categories = widget.categories;

    for (int i = 0; i < holidayRequest.documents.length; i++) {
      if (holidayRequest.documents[i].isNotEmpty) {
        fileExistsInStorage(holidayRequest.documents[i]).then((result) {
          if (!result['exists']) {
            holidayRequest.documents[i] = '';
          }
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  void uploadFile(PlatformFile? file, int index) {
    if (file != null) {
      String extention = file.name.split('.').last;
      HolidaysCategory catReq = categories.firstWhere(
          (cat) => cat.id == holidayRequest.category,
          orElse: () => HolidaysCategory.getEmpty());
      if (catReq.id == '') {
        catReq.name = 'NOCAT';
      }
      uploadFileToStorage(file,
              rootPath:
                  'files/holidays/${holidayRequest.userId}/${holidayRequest.id}/documents/${catReq.name.replaceAll(" ", "_")}/',
              fileName:
                  '${DateFormat('yyyyMMdd').format(DateTime.now())}_${catReq.autoCode()}_$index.$extention')
          .then((fname) {
        if (holidayRequest.documents.length <= index) {
          holidayRequest.documents.add(fname);
        } else {
          String fremove = holidayRequest.documents[index];
          if ((fremove.isNotEmpty) && fremove != fname) {
            removeFileFromStorage(fremove);
          }
          holidayRequest.documents[index] = fname;
        }
        holidayRequest.save();
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    HolidaysCategory catReq = categories.firstWhere(
        (cat) => cat.id == holidayRequest.category,
        orElse: () => HolidaysCategory.getEmpty());
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        child: SingleChildScrollView(
          child: Column(children: [
            // Add your document fields here
            // For example, a TextFormField for document name
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text('Documentos requeridos para ${catReq.name}:',
                      style: subTitleText, textAlign: TextAlign.center),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(catReq.docMessage,
                      style: subTitleText, textAlign: TextAlign.center),
                )
              ],
            ),
            space(height: 16),
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < catReq.docRequired; i++)
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: UploadFileField(
                              textToShow: (holidayRequest.documents.length >
                                          i &&
                                      holidayRequest.documents[i].isNotEmpty)
                                  ? "Documento ya cargado"
                                  : "Subir documento",
                              onSelectedFile: (file) {
                                // Handle file selection
                                if (file != null) {
                                  uploadFile(file, i);
                                }
                              },
                            )))
                ]),
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0;
                      i < holidayRequest.getCategory(categories).docRequired;
                      i++)
                    Expanded(
                        flex: 1,
                        child: ((i < holidayRequest.documents.length) &&
                                (holidayRequest.documents[i].isNotEmpty))
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: actionButtonVertical(
                                          context, "Abrir", (context) {
                                        openFileUrl(context,
                                                holidayRequest.documents[i])
                                            .then((value) {});
                                      }, Icons.open_in_browser, context)),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: actionButtonVertical(
                                          context, "Eliminar", (context) {
                                        if (holidayRequest.documents.length >
                                            i) {
                                          String fremove =
                                              holidayRequest.documents[i];
                                          if (fremove.isNotEmpty) {
                                            removeFileFromStorage(fremove)
                                                .then((value) {
                                              if (value) {
                                                holidayRequest.documents[i] =
                                                    '';
                                                holidayRequest.save();

                                                if (mounted) {
                                                  setState(() {});
                                                }
                                              }
                                            });
                                          }
                                        }
                                      }, Icons.delete, context)),
                                ],
                              )
                            : Container())
                ]),
            space(height: 16),
            Row(children: [
              // Expanded(
              //     flex: 5,
              //     child: actionButton(
              //         context,
              //         "Enviar",
              //         saveItem,
              //         Icons.save_outlined,
              //         [context, holidayRequest, _formKey])),
              // Expanded(flex: 1, child: Container()),
              Expanded(flex: 1, child: Container()),
              Expanded(
                  flex: 1,
                  child: actionButton(context, "Cerrar", (context) {
                    Navigator.of(context).pop(null);
                  }, Icons.cancel, context)),
              Expanded(flex: 1, child: Container()),
            ]),
          ]),
        ),
      ),
    );
  }
}
