// ignore_for_file: library_private_types_in_public_api

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_commons.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Employee employee;
  List<KeyValue> promotions = [];
  int contentIndex = 0;
  String employmentPromotion = '';
  double employeeSalary = 0;

  @override
  void initState() {
    super.initState();

    employee = widget.selectedItem;
    if (employee.altas.isNotEmpty) {
      employee.altas.sort((a, b) => a.date.compareTo(b.date));
      employmentPromotion = employee.altas.last.employmentPromotion;
      employeeSalary = employee.altas.last.salary;
    }
    EmploymentPromotion.getActive().then((value) {
      promotions = value.map((e) => KeyValue(e.name, e.name)).toList();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (contentIndex == 0) {
      return Form(
          key: _formKey,
          child: SizedBox(
              child: SingleChildScrollView(
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
                decoration:
                    const InputDecoration(labelText: 'Segundo Apellido'),
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
                        employee.altas.add(Alta(date: truncDate(date)));
                      } else {
                        employee.altas[employee.altas.length - 1] =
                            Alta(date: truncDate(date), salary: employeeSalary);
                      }
                    }
                    setState(() {});
                  }),
              Row(children: [
                Expanded(
                    flex: 4,
                    child: CustomSelectFormField(
                        key: UniqueKey(),
                        labelText: 'Promoción de empleo',
                        initial: employee.isActive()
                            ? employee.altas.last.employmentPromotion
                            : '',
                        options: promotions,
                        onSelectedOpt: (value) {
                          employmentPromotion = value;
                        })),
                Expanded(
                    flex: 1,
                    child: addBtnRow(context, (context) {
                      contentIndex = 1;
                      setState(() {});
                    }, null, text: 'Añadir'))
              ]),
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
                initialValue: toCurrency(employee.getSalary()),
                decoration: const InputDecoration(labelText: 'Salario'),
                onSaved: (String? value) {
                  employeeSalary = fromCurrency(value!);
                },
              ),
              TextFormField(
                initialValue: employee.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
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
                        if (employee.altas.isNotEmpty) {
                          employee.altas.last.employmentPromotion =
                              employmentPromotion;
                          employee.altas.last.salary = employeeSalary;
                        }
                        employee.save();
                        Navigator.of(context).pop(employee);
                      } else {
                        setState(() {});
                      }
                    }, null)),
                Expanded(flex: 1, child: Container()),
              ]),
            ],
          ))));
    } else {
      EmploymentPromotion newItem = EmploymentPromotion.getEmpty();

      return Form(
          child: SizedBox(
              child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              s4cSubTitleBar('Nueva situación de promoción de empleo', null),
              TextFormField(
                initialValue: '',
                decoration: const InputDecoration(labelText: 'Nombre'),
                enabled: true,
                onChanged: (String value) {
                  newItem.name = value;
                },
              ),
              TextFormField(
                initialValue: '',
                decoration: const InputDecoration(labelText: 'Descripción'),
                enabled: true,
                onChanged: (String value) {
                  newItem.description = value;
                },
              ),
              space(height: 30),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: saveBtnForm(context, () {
                      newItem.save();
                      setState(() {
                        promotions.add(KeyValue(newItem.name, newItem.name));
                        contentIndex = 0;
                      });
                    }, null)),
                Expanded(
                    flex: 1,
                    child: actionButton(context, cancelText, () {
                      contentIndex = 0;
                      setState(() {});
                    }, Icons.cancel, null)),
              ]),
            ],
          ),
        ),
      )));
    }
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Employee employee;
  DateTime? selectedDate;
  String selectedReason = '';
  int contentIndex = 0;
  List<KeyValue> reasonsOptions = [];

  @override
  void initState() {
    super.initState();
    employee = widget.selectedItem;
    BajaReason.getAll().then((value) {
      reasonsOptions = value.map((e) => KeyValue(e.name, e.name)).toList();
      if (mounted) {
        setState(() {});
      }
    });
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

    if (contentIndex == 0) {
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
              Row(children: [
                Expanded(
                    flex: 4,
                    child: CustomSelectFormField(
                        key: UniqueKey(),
                        labelText: 'Motivo Baja',
                        initial: '',
                        options: reasonsOptions,
                        onSelectedOpt: (value) {
                          selectedReason = value;
                        })),
                Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: iconBtn(context, (context) {
                          contentIndex = 1;
                          setState(() {});
                        }, null, icon: Icons.add))),
              ]),
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
                            employee.bajas.add(Baja(
                                date: selectedDate!, reason: selectedReason));
                          } else {
                            Baja item = employee.bajas.last;
                            item.date = selectedDate!;
                            item.reason = selectedReason;
                            employee.bajas[employee.bajas.length - 1] = item;
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
    } else {
      BajaReason newItem = BajaReason.getEmpty();
      return Form(
          key: UniqueKey(),
          child: SizedBox(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  s4cSubTitleBar('Nuevo motivo de baja', null),
                  TextFormField(
                    initialValue: '',
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    enabled: true,
                    onChanged: (String value) {
                      newItem.name = value;
                    },
                  ),
                  space(height: 30),
                  Row(children: [
                    Expanded(
                        flex: 1,
                        child: saveBtnForm(context, () {
                          contentIndex = 0;
                          newItem.save();
                          reasonsOptions
                              .add(KeyValue(newItem.name, newItem.name));

                          setState(() {});
                        }, null)),
                    Expanded(
                        flex: 1,
                        child: actionButton(context, cancelText, () {
                          contentIndex = 0;
                          setState(() {});
                        }, Icons.cancel, null)),
                  ]),
                ],
              ),
            ),
          )));
    }
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Employee employee;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    employee = widget.selectedItem;
    if (!employee.isActive()) {
      selectedDate = DateTime.now();
    } else {
      selectedDate = employee.altas.last.date;
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
            DateTimePicker(
                labelText: 'Fecha Alta',
                selectedDate: (employee.isActive())
                    ? employee.altas.last.date
                    : DateTime.now(),
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
                        if (!employee.isActive()) {
                          employee.altas.add(Alta(date: selectedDate));
                        } else {
                          employee.altas[employee.altas.length - 1] =
                              Alta(date: selectedDate);
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

class EmployeeDocumentsForm extends StatefulWidget {
  final Employee selectedItem;
  const EmployeeDocumentsForm({Key? key, required this.selectedItem})
      : super(key: key);

  @override
  _EmployeeDocumentsFormState createState() => _EmployeeDocumentsFormState();
}

class _EmployeeDocumentsFormState extends State<EmployeeDocumentsForm> {
  late Employee selectedItem;
  String genericDocDesc = '';

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    genericDocDesc = '';
    List listDocuments = [];
    for (Alta alta in selectedItem.altas) {
      listDocuments.add({
        'type': 'Alta',
        'desc': 'Contrato',
        'date': alta.date,
        'path': alta.pathContract
      });
      listDocuments.add({
        'type': 'Alta',
        'desc': 'Anexo',
        'date': alta.date,
        'path': alta.pathAnnex
      });
      listDocuments.add({
        'type': 'Alta',
        'desc': 'NIF',
        'date': alta.date,
        'path': alta.pathNIF
      });
      listDocuments.add({
        'type': 'Alta',
        'desc': 'NDA',
        'date': alta.date,
        'path': alta.pathNDA
      });
      listDocuments.add({
        'type': 'Alta',
        'desc': 'LOPD',
        'date': alta.date,
        'path': alta.pathLOPD
      });

      if (alta.pathOthers != null) {
        alta.pathOthers!.forEach((key, value) {
          listDocuments.add(
              {'type': 'Alta', 'desc': key, 'date': alta.date, 'path': value});
        });
      }

      if (selectedItem.extraDocs.isNotEmpty) {
        selectedItem.extraDocs.forEach((key, value) {
          listDocuments.add({
            'type': 'Otros',
            'desc': key,
            'date': selectedItem.getAltaDate(),
            'path': value
          });
        });
      }

      // Add pathNIE
    }
    return SingleChildScrollView(
        child: SizedBox(
            width: double.infinity,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Expanded(
                    flex: 4,
                    child: // TextField for a descriotion
                        TextFormField(
                      key: UniqueKey(),
                      initialValue: genericDocDesc,
                      decoration: const InputDecoration(
                          labelText: 'Descripción Documento Genérico'),
                      onChanged: (String value) {
                        genericDocDesc = value;
                      },
                    )),
                Expanded(
                  flex: 1,
                  child: addBtnRow(context, (context) {
                    if (genericDocDesc != '') {
                      selectedItem.extraDocs[genericDocDesc] = null;
                      genericDocDesc = '';
                      selectedItem.save();
                      setState(() {
                        genericDocDesc = '';
                      });
                    }
                  }, null, text: 'Añadir'),
                ),
              ]),
              DataTable(
                dataRowMinHeight: 70,
                dataRowMaxHeight: 70,
                columns: ['Satus', 'Trámite', 'Fecha', 'Descripción', '']
                    .map((item) {
                  return DataColumn(
                    label: Text(
                      item,
                      style: headerListStyle,
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
                rows: listDocuments.map((e) {
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08);
                      }
                      if (selectedItem.altas.indexOf(e).isEven) {
                        return Colors.grey[200];
                      } else {
                        return Colors.white;
                      }
                    }),
                    cells: [
                      DataCell(
                        e['path'] != null
                            ? const Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                      ),
                      DataCell(Text(e['type'])),
                      DataCell(
                          Text(DateFormat('dd/MM/yyyy').format(e['date']))),
                      DataCell(Text(e['desc'])),
                      DataCell(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            e['path'] == null
                                ? UploadFileField(
                                    padding: const EdgeInsets.all(5),
                                    textToShow: Container(),
                                    onSelectedFile: (PlatformFile? pickedFile) {
                                      if (pickedFile != null) {
                                        String extention =
                                            pickedFile.name.split('.').last;
                                        uploadFileToStorage(pickedFile,
                                                rootPath:
                                                    'files/employees/${selectedItem.code}/documents/${e['type']}/',
                                                fileName:
                                                    '${DateFormat('yyyyMMdd').format(e['date'])}_${e['desc'].replaceAll(' ', '_')}.$extention')
                                            .then((value) {
                                          selectedItem.extraDocs[e['desc']] =
                                              value;
                                          selectedItem.save();
                                          setState(() {});
                                        });
                                      }
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(
                                        Icons.remove_red_eye_outlined),
                                    onPressed: () async {
                                      if (e['path'] != null) {
                                        downloadFileUrl(e['path'])
                                            .then((value) {
                                          if (value) {
                                            //Use toast to show a message

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Descargando archivo...')));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Error al descargar archivo')));
                                          }
                                        });
                                      }
                                    }),
                            (e['path'] != null) || (e['type'] == 'Otros')
                                ? removeConfirmBtn(context, (context) async {
                                    removeFileFromStorage(e['path'])
                                        .then((value) {
                                      if (value) {
                                        if (e['type'] != 'Otros') {
                                          selectedItem.updateDocument(e, null);
                                          e['path'] = null;
                                          selectedItem.save();
                                        } else {
                                          selectedItem.extraDocs
                                              .remove(e['desc']);
                                          selectedItem.save();
                                        }
                                        setState(() {});
                                      }
                                    });
                                  }, null)
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              )
            ])));
  }
}
