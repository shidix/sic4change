import 'package:firebase_auth/firebase_auth.dart';
// import 'package:googleapis/driveactivity/v2.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_workday.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class WorkdayForm extends StatefulWidget {
  final Workday? currentWorkday;
  final User? user;

  const WorkdayForm({super.key, this.currentWorkday, this.user});

  @override
  createState() => WorkdayFormState();
}

class WorkdayFormState extends State<WorkdayForm> {
  final formKey = GlobalKey<FormState>();
  late Workday workday;
  late User user;
  late Contact contact;
  bool isNewItem = false;

  @override
  void initState() {
    super.initState();

    user = widget.user!;
    workday = widget.currentWorkday!;
    contact = Contact.getEmpty();
    contact.name = "Loading...";
    contact.email = user.email!;

    Contact.byEmail(user.email!).then((Contact contact) {
      this.contact = contact;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Workday saveItem() {
    workday.save();
    Navigator.of(context).pop(workday);
    return workday;
  }

  Workday removeItem() {
    workday.delete();
    workday.id = "";
    Navigator.of(context).pop(workday);
    return workday;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(children: [
                Expanded(
                    flex: 1,
                    child: ListTile(
                        leading: const Icon(Icons.person),
                        title: (user.displayName != null)
                            ? Text(user.displayName!)
                            : (contact.name != '')
                                ? Text(contact.name)
                                : Text(
                                    "Nombre no indicado en perfil <${user.email!}>"))),
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(
                        user.email!,
                      ),
                    )),

                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text("Horas"),
                      subtitle: Text(workday.hours().toStringAsFixed(2)),
                    )),

                // Add checkbox for open workday
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.work),
                      title: const Text("Jornada Abierta"),
                      trailing: Checkbox(
                        value: workday.open,
                        onChanged: (bool? value) {
                          setState(() {
                            workday.open = value ?? false;
                          });
                        },
                      ),
                    )),
              ]),
              Divider(thickness: 1, color: Colors.grey[400]),
              const Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        "Inicio de Jornada",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        "Fin de Jornada",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.date_range),
                      title: Text(
                          DateFormat('dd/MM/yyyy').format(workday.startDate)),
                      onTap: (workday.id == "")
                          ? () async {
                              final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: workday.startDate,
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101));
                              if (picked != null &&
                                  picked != workday.startDate &&
                                  mounted) {
                                setState(() {
                                  workday.startDate = truncDate(picked)
                                      .add(const Duration(hours: 8));
                                  workday.endDate = truncDate(picked)
                                      .add(const Duration(hours: 16));
                                });
                              }
                            }
                          : null,
                    )),
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title:
                          Text(DateFormat('HH:mm').format(workday.startDate)),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(workday.startDate),
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            });
                        if (picked != null && mounted) {
                          setState(() {
                            DateTime newStartDate = DateTime(
                                workday.startDate.year,
                                workday.startDate.month,
                                workday.startDate.day,
                                picked.hour,
                                picked.minute);
                            if (newStartDate.isBefore(workday.endDate)) {
                              workday.startDate = newStartDate;
                            } else {
                              double elapsedTime = workday.endDate
                                  .difference(workday.startDate)
                                  .inMinutes
                                  .toDouble();

                              newStartDate = newStartDate
                                  .subtract(const Duration(hours: 24));
                              workday.startDate = newStartDate;
                              workday.endDate = newStartDate
                                  .add(Duration(minutes: elapsedTime.toInt()));
                            }
                          });
                        }
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.date_range),
                      // title: const Text("Fecha Fin"),
                      title: Text(
                          DateFormat('dd/MM/yyyy').format(workday.endDate)),
                      onTap: (workday.id == "")
                          ? () async {
                              final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: workday.endDate,
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101));
                              if (picked != null &&
                                  picked != workday.endDate &&
                                  mounted) {
                                setState(() {
                                  workday.endDate = truncDate(picked)
                                      .add(const Duration(hours: 8));
                                  workday.endDate = truncDate(picked)
                                      .add(const Duration(hours: 16));
                                });
                              }
                            }
                          : null,
                    )),
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(DateFormat('HH:mm').format(workday.endDate)),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(workday.endDate),
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            });

                        if (picked != null &&
                            picked != TimeOfDay.fromDateTime(workday.endDate) &&
                            (mounted)) {
                          setState(() {
                            DateTime newEndDate = DateTime(
                                workday.startDate.year,
                                workday.startDate.month,
                                workday.startDate.day,
                                picked.hour,
                                picked.minute);
                            if (newEndDate.isAfter(workday.startDate)) {
                              workday.endDate = newEndDate;
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: const Text(
                                          "La fecha de fin de jornada no puede ser anterior a la de inicio"),
                                      actions: [
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                            }
                          });
                        }
                      },
                    )),
              ]),
              const SizedBox(height: 16.0),
              const Divider(),
              Row(children: [
                Expanded(flex: workday.id == "" ? 3 : 2, child: Container()),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: saveBtnForm(context, saveItem))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: removeBtnForm(context, removeItem))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: cancelBtnForm(context))),
              ])
            ],
          ),
        ));
  }
}

class WorkdayUploadForm extends StatefulWidget {
  final WorkdayUpload? currentWorkdayUpload;
  final Employee? employee;

  const WorkdayUploadForm(
      {super.key, this.currentWorkdayUpload, this.employee});

  @override
  createState() => WorkdayUploadFormState();
}

class WorkdayUploadFormState extends State<WorkdayUploadForm> {
  late WorkdayUpload workdayUpload;

  @override
  void initState() {
    super.initState();
    workdayUpload = widget.currentWorkdayUpload ?? WorkdayUpload.getEmpty();
  }

  // Form with Card with DatePicker and UploadFormFile for workdayUpload
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
