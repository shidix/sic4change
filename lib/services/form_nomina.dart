import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
  late PlatformFile? reciptFile;
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
    if (nomina.noSignedPath.isNotEmpty) {
      noSignedFileMsg = nomina.noSignedPath.split("/").last;
    }
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
    reciptFile = null;
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
        if (signedFile != null) {
          uploadFileToStorage(signedFile!).then((value) {
            nomina.signedPath = value;
          });
        }
        if (reciptFile != null) {
          uploadFileToStorage(reciptFile!).then((value) {
            nomina.reciptPath = value;
          });
        }
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

          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 8,
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
                        ),
                        Expanded(
                            flex: 2,
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
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomDateField(
                                labelText: "Fecha Pago",
                                selectedDate: getDate(nomina.paymentDate),
                                onSelectedDate: (value) {
                                  nomina.paymentDate = value;
                                  setState(() {});
                                },
                              ),
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
                                decoration: const InputDecoration(
                                    labelText: "Salario Neto"),
                                initialValue: nomina.netSalary.toString(),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
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
                                decoration: const InputDecoration(
                                    labelText: "Deducciones"),
                                initialValue: nomina.deductions.toString(),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
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
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingrese el seguro social del empleado';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  nomina.employeeSocialSecurity =
                                      double.parse(value);
                                },
                              )),
                        ),
                        //field for grossSalary
                        Expanded(
                          flex: 1,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    labelText: "Salario Bruto"),
                                initialValue: nomina.grossSalary.toString(),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
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
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingrese el seguro social del empleador';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  nomina.employerSocialSecurity =
                                      double.parse(value);
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
                )),
            Expanded(
                flex: 2,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      nomina.noSignedPath.isNotEmpty
                          ? Card(
                              child: Column(
                              children: [
                                const Text("Nómina no firmada",
                                    style: subTitleText),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      iconBtn(context, (context) {
                                        downloadFileUrl(nomina.noSignedPath);
                                      }, null, icon: Icons.download),
                                      const SizedBox(width: 10),
                                      removeConfirmBtn(context, () {
                                        removeFileFromStorage(
                                                nomina.noSignedPath)
                                            .then((value) {
                                          notSignedFile = null;
                                          noSignedFileMsg = "";
                                          nomina.noSignedPath = "";
                                          nomina.noSignedDate = DateTime.now();
                                          nomina.save();
                                          setState(() {});
                                        });
                                      }, null),
                                    ])
                              ],
                            ))
                          : UploadFileField(
                              textToShow: (noSignedFileMsg.isEmpty)
                                  ? "Nómina sin firmar"
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
                            ),
                      const SizedBox(height: 10),
                      (nomina.signedPath != null &&
                              nomina.signedPath!.isNotEmpty)
                          ? Card(
                              child: Column(
                              children: [
                                const Text("Nómina firmada",
                                    style: subTitleText),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      iconBtn(context, (context) {
                                        downloadFileUrl(nomina.signedPath!);
                                      }, null, icon: Icons.download),
                                      const SizedBox(width: 10),
                                      removeConfirmBtn(context, () {
                                        removeFileFromStorage(nomina.signedPath)
                                            .then((value) {
                                          signedFile = null;
                                          nomina.signedPath = "";
                                          nomina.signedDate = DateTime.now();
                                          nomina.save();
                                          setState(() {});
                                        });
                                      }, null),
                                    ])
                              ],
                            ))
                          : UploadFileField(
                              textToShow: (signedFile == null)
                                  ? "Nómina firmada"
                                  : Text(signedFile!.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12)),
                              pickedFile: signedFile,
                              onSelectedFile: (PlatformFile? file) {
                                if (file != null) {
                                  signedFile = file;
                                  nomina.signedDate = DateTime.now();
                                  setState(() {});
                                }
                              },
                            ),
                      space(height: 10),
                      (nomina.reciptPath != null &&
                              nomina.reciptPath!.isNotEmpty)
                          ? Card(
                              child: Column(
                              children: [
                                const Text("Recibo de nómina",
                                    style: subTitleText),
                                const SizedBox(height: 10),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      iconBtn(context, (context) {
                                        downloadFileUrl(nomina.reciptPath!);
                                      }, null, icon: Icons.download),
                                      const SizedBox(width: 10),
                                      removeConfirmBtn(context, () {
                                        removeFileFromStorage(nomina.reciptPath)
                                            .then((value) {
                                          reciptFile = null;
                                          nomina.reciptPath = "";
                                          nomina.save();
                                          setState(() {});
                                        });
                                      }, null),
                                    ])
                              ],
                            ))
                          : UploadFileField(
                              textToShow: (reciptFile == null)
                                  ? "Recibo de nómina"
                                  : Text(signedFile!.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12)),
                              pickedFile: reciptFile,
                              onSelectedFile: (PlatformFile? file) {
                                if (file != null) {
                                  reciptFile = file;
                                  setState(() {});
                                }
                              },
                            ),
                    ]))
          ]),
        ));
  }
}
