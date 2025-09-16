import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class AmbitForm extends StatefulWidget {
  final Ambit? ambit;
  final Function(Ambit) onSave;

  AmbitForm({this.ambit, required this.onSave});

  @override
  AmbitFormState createState() => AmbitFormState();
}

class AmbitFormState extends State<AmbitForm> {
  final _formKey = GlobalKey<FormState>();
  late Ambit _ambit;

  @override
  void initState() {
    super.initState();
    _ambit = widget.ambit ?? Ambit('');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: _ambit.name,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _ambit.name = value!;
                },
              ),
              space(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: saveBtnForm(
                            null,
                            () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _ambit.save();
                                widget.onSave(_ambit);
                              }
                            },
                          ))),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: cancelBtnForm(context),
                      )),
                ],
              ),
            ],
          ),
        ));
  }
}
