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

class EmployeeForm extends StatefulWidget {
  final Employee selectedItem;
  EmployeeForm({Key? key, required this.selectedItem}) : super(key: key);

  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Employee employee;
  late PlatformFile? notSignedFile;
  late PlatformFile? signedFile;
  String noSignedFileMsg = "";

  @override
  void initState() {
    super.initState();
    employee = widget.selectedItem;
    notSignedFile = null;
    signedFile = null;
  }

  Future<String> uploadFileToStorage(PlatformFile file) async {
    PlatformFile pickedFile = file;
    Uint8List? pickedFileBytes = file.bytes;
    UploadTask? uploadTask;

    String uniqueFileName =
        "${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}";
    final path = 'files/employees/$uniqueFileName';
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
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SizedBox(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              initialValue: employee.code,
              decoration: const InputDecoration(labelText: 'Número Empleado'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (String? value) {
                employee.code = value!;
              },
            ),
            TextFormField(
              initialValue: employee.firstName,
              decoration: const InputDecoration(labelText: 'Nombre(s)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (String? value) {
                employee.firstName = value!;
              },
            ),
            TextFormField(
              initialValue: employee.lastName1,
              decoration: const InputDecoration(labelText: 'Primer Apellido'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (String? value) {
                employee.lastName1 = value!;
              },
            ),
            TextFormField(
              initialValue: employee.lastName2,
              decoration: const InputDecoration(labelText: 'Segundo Apellido'),
              onSaved: (String? value) {
                employee.lastName2 = value!;
              },
            ),
            TextFormField(
              initialValue: employee.email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (String? value) {
                employee.email = value!;
              },
            ),
            TextFormField(
              initialValue: employee.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (String? value) {
                employee.phone = value!;
              },
            ),
            space(height: 30),
            Row(children: [
              Expanded(flex: 1, child: Container()),
              Expanded(
                  flex: 2,
                  child: saveBtnForm(
                    context,
                    () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        noSignedFileMsg = "";
                        if (notSignedFile != null) {
                          uploadFileToStorage(notSignedFile!).then((value) {
                            employee.photoPath = value;
                            employee.save();
                            Navigator.of(context).pop(employee);
                          });
                        } else {
                          employee.save();
                          Navigator.of(context).pop(employee);
                        }
                      } else {
                        noSignedFileMsg = "Please select a file";
                        print(noSignedFileMsg);
                        setState(() {});
                      }
                    },
                  )),
              Expanded(flex: 1, child: Container()),
            ]),
          ],
        )));
  }
}
