import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class EmployeeForm extends StatefulWidget {
  final Employee selectedItem;
  const EmployeeForm({Key? key, required this.selectedItem}) : super(key: key);

  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Employee employee;
  // DateTime? altaDate;
  // late PlatformFile? notSignedFile;
  // late PlatformFile? signedFile;
  // String noSignedFileMsg = "";

  @override
  void initState() {
    super.initState();
    employee = widget.selectedItem;
    // notSignedFile = null;
    // signedFile = null;
  }

  // Future<String> uploadFileToStorage(PlatformFile file) async {
  //   PlatformFile pickedFile = file;
  //   Uint8List? pickedFileBytes = file.bytes;
  //   UploadTask? uploadTask;

  //   String uniqueFileName =
  //       "${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}";
  //   final path = 'files/employees/$uniqueFileName';
  //   final ref = FirebaseStorage.instance.ref().child(path);

  //   try {
  //     uploadTask = ref.putData(pickedFileBytes!);
  //     await uploadTask.whenComplete(() => null);
  //   } catch (e) {
  //     print(e);
  //   }
  //   return path;
  // }

  // void uploadFile() {
  //   if (notSignedFile != null) {
  //     uploadFileToStorage(notSignedFile!).then((value) {
  //       setState(() {});
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // if (altaDate == null) {
    //   if (employee.isActive()) {
    //     altaDate = employee.altas.last;
    //   } else {
    //     altaDate = DateTime.now();
    //   }
    // }
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
                  return 'El campo no puede estar vacío';
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
                  return 'El campo no puede estar vacío';
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
                  return 'El campo no puede estar vacío';
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
                  return 'El campo no puede estar vacío';
                }
                return null;
              },
              onSaved: (String? value) {
                employee.email = value!;
              },
            ),
            TextFormField(
              initialValue: employee.position,
              decoration: const InputDecoration(labelText: 'Puesto'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El campo no puede estar vacío';
                }
                return null;
              },
              onSaved: (String? value) {
                employee.position = value!;
              },
            ),
            TextFormField(
              initialValue: employee.category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              onSaved: (String? value) {
                employee.category = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El campo no puede estar vacío';
                }
                return null;
              },
            ),
            DateTimePicker(
                labelText: 'Fecha Alta',
                selectedDate: employee.getAltaDate(),
                onSelectedDate: (DateTime? date) {
                  if (date != null) {
                    if (employee.altas.isEmpty) {
                      employee.altas.add(truncDate(date));
                    } else {
                      employee.altas[employee.altas.length - 1] =
                          truncDate(date);
                    }
                  }
                  setState(() {});
                }),
            DateTimePicker(
                labelText: 'Fecha Baja',
                selectedDate: employee.getBajaDate(),
                onSelectedDate: (DateTime? date) {
                  if (date != null) {
                    if (employee.bajas.isEmpty) {
                      employee.bajas.add(truncDate(date));
                    } else {
                      employee.bajas[employee.bajas.length - 1] =
                          truncDate(date);
                    }
                  }
                  setState(() {});
                }),
            TextFormField(
              initialValue: employee.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              onSaved: (String? value) {
                employee.phone = value!;
              },
            ),
            space(height: 30),
            Row(children: [
              Expanded(flex: 1, child: Container()),
              Expanded(
                  flex: 2,
                  child: saveBtnForm(context, () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      employee.save();
                      Navigator.of(context).pop(employee);
                    } else {
                      setState(() {});
                    }
                  }, null)),
              Expanded(flex: 1, child: Container()),
            ]),
          ],
        )));
  }
}

class EmployeeBajaForm extends StatefulWidget {
  final Employee selectedItem;
  const EmployeeBajaForm({Key? key, required this.selectedItem})
      : super(key: key);

  @override
  _EmployeeBajaFormState createState() => _EmployeeBajaFormState();
}

class _EmployeeBajaFormState extends State<EmployeeBajaForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Employee employee;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    employee = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDate == null) {
      if (employee.isActive()) {
        selectedDate = DateTime.now();
      } else {
        selectedDate = employee.bajas.last;
      }
    }

    return Form(
        key: _formKey,
        child: SizedBox(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            DateTimePicker(
                labelText: 'Fecha Baja',
                selectedDate: selectedDate!,
                onSelectedDate: (DateTime? date) {
                  if (date != null) {
                    selectedDate = date;
                  }
                  setState(() {});
                }),
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
                        if (employee.isActive()) {
                          employee.bajas.add(selectedDate);
                        } else {
                          employee.bajas[employee.bajas.length - 1] =
                              selectedDate;
                        }
                        employee.save();
                        Navigator.of(context).pop(employee);
                      } else {
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

class EmployeeAltaForm extends StatefulWidget {
  final Employee selectedItem;
  const EmployeeAltaForm({Key? key, required this.selectedItem})
      : super(key: key);

  @override
  _EmployeeAltaFormState createState() => _EmployeeAltaFormState();
}

class _EmployeeAltaFormState extends State<EmployeeAltaForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Employee employee;

  @override
  void initState() {
    super.initState();
    employee = widget.selectedItem;
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
            DateTimePicker(
                labelText: 'Fecha Alta',
                selectedDate: (employee.isActive())
                    ? employee.altas.last
                    : DateTime.now(),
                onSelectedDate: (DateTime? date) {
                  if (date != null) {
                    if (!employee.isActive()) {
                      employee.altas.add(date);
                    } else {
                      employee.altas[employee.altas.length - 1] = date;
                    }
                  }
                  setState(() {});
                }),
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
                        employee.save();
                        Navigator.of(context).pop(employee);
                      } else {
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
