import 'package:firebase_auth/firebase_auth.dart';
import 'package:sic4change/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_workday.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class WorkdayForm extends StatefulWidget {
  final Workday? currentWorkday;
  final User? user;

  const WorkdayForm({Key? key, this.currentWorkday, this.user})
      : super(key: key);

  @override
  createState() => WorkdayFormState();
}

class WorkdayFormState extends State<WorkdayForm> {
  final formKey = GlobalKey<FormState>();
  late Workday workday;
  late User user;
  bool isNewItem = false;

  @override
  void initState() {
    super.initState();

    user = widget.user!;
    workday = widget.currentWorkday!;
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
                            : const Text(""))),
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
                      leading: const Icon(Icons.date_range),
                      title: const Text("Fecha"),
                      subtitle: Text(
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
                    ))
              ]),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.date_range),
                      title: const Text("Inicio de jornada"),
                      subtitle:
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
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: const Text(
                                          "La fecha de inicio de jornada no puede ser posterior a la de fin"),
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
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.date_range),
                      title: const Text("Fin de jornada"),
                      subtitle:
                          Text(DateFormat('HH:mm').format(workday.endDate)),
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
                Expanded(
                    flex: 1,
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text("Horas"),
                      subtitle: Text(workday.hours().toStringAsFixed(2)),
                    ))
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
