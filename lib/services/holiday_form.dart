import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class HolidayRequestForm extends StatefulWidget {
  final HolidayRequest? currentRequest;
  final Contact? contact;

  const HolidayRequestForm({Key? key, this.currentRequest, this.contact})
      : super(key: key);

  @override
  _HolidayRequestFormState createState() => _HolidayRequestFormState();
}

class _HolidayRequestFormState extends State<HolidayRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidayRequest holidayRequest;
  late Contact contact;

  @override
  void initState() {
    super.initState();
    contact = widget.contact!;
    if (widget.currentRequest != null) {
      holidayRequest = widget.currentRequest!;
    } else {
      holidayRequest = HolidayRequest.getEmpty();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Expanded> deleteButton = [];
    int flex = 5;
    if (widget.currentRequest != null) {
      flex = 3;
      deleteButton = [
        Expanded(flex: 1, child: Container()),
        Expanded(
            flex: flex,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  holidayRequest.delete();
                  Navigator.of(context).pop(holidayRequest);
                }
              },
              child: const Text('Eliminar'),
            ))
      ];
    }
    Widget statusField;

    if (contact.uuid == holidayRequest.userId) {
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
    for (String category in ['Vacaciones', 'Permiso', 'Licencia', 'Ausencia', 'Asustos Propios', 'Enfermedad']) {
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
              ReadOnlyTextField(label: 'Usuario', textToShow: contact.name),
              ReadOnlyTextField(
                  label: 'Fecha de Solicitud',
                  textToShow: DateFormat('yyyy-MM-dd')
                      .format(holidayRequest.requestDate)),
              // TextFormField(
              //   initialValue: holidayRequest.catetory,
              //   decoration: const InputDecoration(labelText: 'Categoría'),
              //   onSaved: (val) =>
              //       setState(() => holidayRequest.catetory = val!),
              // ),
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
              TextFormField(
                initialValue: holidayRequest.approvedBy,
                decoration: const InputDecoration(labelText: 'Aprobado por'),
                onSaved: (val) =>
                    setState(() => holidayRequest.approvedBy = val!),
              ),

              // DateTimePicker(
              //   labelText: 'Fecha de solicitud',
              //   selectedDate: holidayRequest.requestDate,
              //   onSelectedDate: (DateTime date) {
              //     setState(() {
              //       holidayRequest.requestDate = date;
              //     });
              //   },
              // ),
              const SizedBox(height: 16.0),
              Row(
                  children: [
                        Expanded(
                            flex: flex,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blueGrey),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  holidayRequest.save();
                                  Navigator.of(context).pop(holidayRequest);
                                }
                              },
                              child: const Text('Enviar'),
                            )),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                            flex: flex,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(null);
                              },
                              child: const Text('Cancelar'),
                            ))
                      ] +
                      deleteButton),
            ],
          ),
        ),
      ),
    );
  }
}
