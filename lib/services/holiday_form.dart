import 'package:flutter/material.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/widgets/common_widgets.dart';


class HolidayRequestForm extends StatefulWidget {
  final HolidayRequest? currentRequest;

  const HolidayRequestForm({Key? key, this.currentRequest}) : super(key: key);

  @override
  _HolidayRequestFormState createState() => _HolidayRequestFormState();
}

class _HolidayRequestFormState extends State<HolidayRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late HolidayRequest holidayRequest;

  @override
  void initState() {
    super.initState();
    if (widget.currentRequest != null) {
      holidayRequest = widget.currentRequest!;
    }
    else {
      holidayRequest = HolidayRequest(
        id: '',
        uuid: '',
        userId: '',
        catetory: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        requestDate: DateTime.now(),
        approvalDate: DateTime(2099,1,1),
        status: 'Pendiente',
        approvedBy: '',
      );}
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: holidayRequest.userId,
                  decoration: InputDecoration(labelText: 'Usuario'),
                  onSaved: (val) => setState(() => holidayRequest.userId = val!),
                ),

                TextFormField(
                  initialValue: holidayRequest.catetory,
                  decoration: InputDecoration(labelText: 'Categoría'),
                  onSaved: (val) => setState(() => holidayRequest.catetory = val!),
                ),

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

                TextFormField(
                  initialValue: holidayRequest.status,
                  decoration: InputDecoration(labelText: 'Estado'),
                  onSaved: (val) => setState(() => holidayRequest.status = val!),
                ),

                TextFormField(
                  initialValue: holidayRequest.approvedBy,
                  decoration: InputDecoration(labelText: 'Aprobado por'),
                  onSaved: (val) => setState(() => holidayRequest.approvedBy = val!),
                ),

                DateTimePicker(
                  labelText: 'Fecha de solicitud',
                  selectedDate: holidayRequest.requestDate,
                  onSelectedDate: (DateTime date) {
                    setState(() {
                      holidayRequest.requestDate = date;
                    });
                  },
                ),


                const SizedBox(height: 16.0),
                          Row(children: [
            Expanded(
                flex: 5,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueGrey),
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
                flex: 5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text('Cancelar'),
                ))
          ]),

              ],
            ),
          ),
        ),
      );
  }
}
