import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/keep/v1.dart';
import 'package:sic4change/services/models_rrhh.dart';
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
  String noSignedFileMsg = "";

  @override
  void initState() {
    super.initState();
    nomina = widget.selectedItem;
    notSignedFile = null;
    signedFile = null;
  }

  Future<String> uploadFileToStorage(PlatformFile file) async {
    PlatformFile pickedFile = file;
    Uint8List? pickedFileBytes = file.bytes;
    UploadTask? uploadTask;

    String uniqueFileName =
        "${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}";
    final path = 'files/nominas/$uniqueFileName';
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      uploadTask = ref.putData(pickedFileBytes!);
      await uploadTask.whenComplete(() => null);
    } catch (e) {
      print(e);
    }
    return path;
  }

  void uploadFile() {
    if (notSignedFile != null) {
      uploadFileToStorage(notSignedFile!).then((value) {
        nomina.noSignedDate = DateTime.now();
        setState(() {});
      });
    }
  }

  void saveNomina() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      nomina.noSignedDate = DateTime.now();
      noSignedFileMsg = "";
      if (notSignedFile != null) {
        uploadFileToStorage(notSignedFile!).then((value) {
          nomina.noSignedPath = value;
          nomina.save();
          Navigator.of(context).pop(nomina);
        });
      } else if (nomina.noSignedPath.isNotEmpty) {
        nomina.save();
        Navigator.of(context).pop(nomina);
      } else {
        noSignedFileMsg = "Por favor, seleccione un archivo";
        setState(() {});
      }
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
                        textToShow: (noSignedFileMsg.isEmpty)
                            ? "Sin firmar"
                            : Text(noSignedFileMsg,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12)),
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
