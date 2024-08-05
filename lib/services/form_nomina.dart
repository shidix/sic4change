import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/keep/v1.dart';
import 'package:sic4change/services/model_nominas.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class NominaForm extends StatefulWidget {
  final Nomina selectedItem;
  NominaForm({Key? key, required this.selectedItem}) : super(key: key);

  @override
  _NominaFormState createState() => _NominaFormState();
}

class _NominaFormState extends State<NominaForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Nomina nomina;
  late PlatformFile? notSignedFile;
  late PlatformFile? signedFile;

  @override
  void initState() {
    super.initState();
    nomina = widget.selectedItem;
    notSignedFile = null;
    signedFile = null;
  }

  void saveNomina() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      nomina.noSignedDate = DateTime.now();
      nomina.save();
      Navigator.of(context).pop(nomina);
    }
  }

  @override
  Widget build(BuildContext context) {
    nomina = widget.selectedItem;
    return Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          // height: MediaQuery.of(context).size.height * 0.75,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Códido Empleado"),
                          initialValue: nomina.employeeCode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese el código del empleado';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            nomina.employeeCode = value;
                          },
                        )),
                  ),
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomDateField(
                          labelText: "Fecha Nómina",
                          selectedDate: getDate(nomina.date),
                          onSelectedDate: (value) {
                            nomina.date = value;
                            setState(() {});
                          },
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: UploadFileField(
                        textToShow: "Sin Firmar",
                        pickedFile: notSignedFile,
                        onSelectedFile: (PlatformFile? file) {
                          if (file != null) {
                            notSignedFile = file;
                            nomina.noSignedDate = DateTime.now();
                            setState(() {});
                          }
                        },
                      )),
                ],
              ),
              //Row with 2 Widgets
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: saveBtnForm(context, saveNomina, null))),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: cancelBtnForm(context),
                      )),
                ],
              ),
            ],
          ),
        ));
  }
}
