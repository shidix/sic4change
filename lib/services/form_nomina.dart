import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/keep/v1.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class NominaForm extends StatefulWidget {
  final Nomina selectedItem;
  final List<Employee> employees;
  const NominaForm(
      {Key? key, required this.selectedItem, required this.employees})
      : super(key: key);

  @override
  _NominaFormState createState() => _NominaFormState();
}

class _NominaFormState extends State<NominaForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Nomina nomina;
  late List<KeyValue> employees;
  late PlatformFile? notSignedFile;
  late PlatformFile? signedFile;
  String noSignedFileMsg = "";
  late Nomina oldNominas;

  @override
  void initState() {
    super.initState();
    employees = widget.employees
        .map((Employee e) =>
            KeyValue(e.code, "${e.firstName} ${e.lastName1} ${e.lastName2}"))
        .toList();
    nomina = widget.selectedItem;
    oldNominas = Nomina(
        employeeCode: nomina.employeeCode,
        date: nomina.date,
        grossSalary: nomina.grossSalary,
        netSalary: nomina.netSalary,
        deductions: nomina.deductions,
        employeeSocialSecurity: nomina.employeeSocialSecurity,
        employerSocialSecurity: nomina.employerSocialSecurity,
        noSignedPath: nomina.noSignedPath,
        noSignedDate: nomina.noSignedDate,
        signedPath: nomina.signedPath,
        signedDate: nomina.signedDate);
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
    bool totalIsRight = (nomina.grossSalary -
            nomina.netSalary -
            nomina.deductions -
            nomina.employeeSocialSecurity) ==
        0;
    if (!totalIsRight) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text(
                  "La suma de los campos no coincide con el salario bruto"),
              actions: [
                TextButton(
                    onPressed: () {
                      // nomina.deductions = oldNomina.deductions;
                      // nomina.netSalary = oldNomina.netSalary;
                      // nomina.employeeSocialSecurity =
                      //     oldNomina.employeeSocialSecurity;
                      // nomina.employerSocialSecurity =
                      //     oldNomina.employerSocialSecurity;
                      // nomina.grossSalary = oldNomina.grossSalary;
                      Navigator.of(context).pop();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: const Text("OK"))
              ],
            );
          });
      return;
    } else {
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
                    child: CustomSelectFormField(
                      labelText: "Empleado",
                      initial: nomina.employeeCode,
                      options: employees,
                      onSelectedOpt: (value) {
                        nomina.employeeCode = value;
                        setState(() {});
                      },
                    ),

                    // Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: TextFormField(
                    //       decoration: const InputDecoration(
                    //           labelText: "Códido Empleado"),
                    //       initialValue: nomina.employeeCode,
                    //       validator: (value) {
                    //         if (value == null || value.isEmpty) {
                    //           return 'Por favor, ingrese el código del empleado';
                    //         }
                    //         return null;
                    //       },
                    //       onChanged: (value) {
                    //         nomina.employeeCode = value;
                    //       },
                    //     )),
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
              // Fields for netSalary, deductions, employeeSocialSecurity, employerSocialSecurity
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Salario Neto"),
                          initialValue: nomina.netSalary.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese el salario neto';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            nomina.netSalary = double.parse(value);
                          },
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Deducciones"),
                          initialValue: nomina.deductions.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese las deducciones';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            nomina.deductions = double.parse(value);
                          },
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Seguro Social Empleado"),
                          initialValue:
                              nomina.employeeSocialSecurity.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese el seguro social del empleado';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            nomina.employeeSocialSecurity = double.parse(value);
                          },
                        )),
                  ),
                  //field for grossSalary
                  Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Salario Bruto"),
                          initialValue: nomina.grossSalary.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese el salario bruto';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            nomina.grossSalary = double.parse(value);
                          },
                        )),
                  ),

                  Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Seguro Social Empleador"),
                          initialValue:
                              nomina.employerSocialSecurity.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese el seguro social del empleador';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            nomina.employerSocialSecurity = double.parse(value);
                          },
                        )),
                  ),
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
