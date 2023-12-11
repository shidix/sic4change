import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class HolidayRequestForm extends StatefulWidget {
  final HolidayRequest? currentRequest;
  final User? user;

  const HolidayRequestForm({Key? key, this.currentRequest, this.user})
      : super(key: key);

  @override
  _HolidayRequestFormState createState() => _HolidayRequestFormState();
}

class _HolidayRequestFormState extends State<HolidayRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidayRequest holidayRequest;
  late User user;
  bool isNewItem = false;

  @override
  void initState() {
    super.initState();
    user = widget.user!;
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ReadOnlyTextField(
                  label: 'Usuario', textToShow: holidayRequest.userId),
              ReadOnlyTextField(
                  label: 'Fecha de Solicitud',
                  textToShow: DateFormat('dd-MM-yyyy')
                      .format(holidayRequest.requestDate)),

              categorySelectField,
              DateTimePicker(
                labelText: 'Fecha de inicio',
                selectedDate: holidayRequest.startDate,
                onSelectedDate: (DateTime date) {
                  setState(() {
                    holidayRequest.startDate = date;
                  });
                },
              ),
              DateTimePicker(
                labelText: 'Fecha de fin',
                selectedDate: holidayRequest.endDate,
                onSelectedDate: (DateTime date) {
                  setState(() {
                    holidayRequest.endDate = date;
                  });
                },
              ),
              statusField,
              ReadOnlyTextField(
                  label: "Aprobado por", textToShow: holidayRequest.approvedBy),
              // TextFormField(
              //   initialValue: holidayRequest.approvedBy,
              //   decoration: const InputDecoration(labelText: 'Aprobado por'),
              //   onSaved: (val) =>
              //       setState(() => holidayRequest.approvedBy = val!),
              // ),

              const SizedBox(height: 16.0),
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
