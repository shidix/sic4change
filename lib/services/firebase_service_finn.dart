//import 'dart:ffi';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';

class InvoiceDetail extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetail({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                  flex: 1,
                  child: ReadOnlyTextField(
                      label: 'Número', textToShow: invoice.number)),
              Expanded(
                  flex: 1,
                  child: ReadOnlyTextField(
                      label: 'Código', textToShow: invoice.code)),
              Expanded(
                  flex: 1,
                  child: ReadOnlyTextField(
                      label: 'Fecha', textToShow: invoice.date)),
            ]),
            const SizedBox(height: 16.0),
            Row(children: [
              Expanded(
                  flex: 3,
                  child: ReadOnlyTextField(
                      label: 'Concepto', textToShow: invoice.concept)),
            ]),
            const SizedBox(height: 16.0),
            Row(children: [
              Expanded(
                  flex: 3,
                  child: ReadOnlyTextField(
                      label: 'Proveedor', textToShow: invoice.provider)),
            ]),
            const SizedBox(height: 16.0),
            Row(children: [
              Expanded(
                  flex: 3,
                  child: ReadOnlyTextField(
                      label: 'Desglose', textToShow: invoice.desglose)),
            ]),
            const SizedBox(height: 16.0),
            Row(children: [
              Expanded(
                  flex: 1,
                  child: ReadOnlyTextField(
                      label: 'Base', textToShow: invoice.base.toString())),
              Expanded(
                  flex: 1,
                  child: ReadOnlyTextField(
                      label: 'Impuestos',
                      textToShow: invoice.taxes.toString())),
              Expanded(
                  flex: 1,
                  child: ReadOnlyTextField(
                      label: 'Total', textToShow: invoice.total.toString())),
            ]),
          ],
        ));
  }
}

class InvoiceForm extends StatefulWidget {
  final Invoice? existingInvoice;
  final List<Contact>? partners;

  const InvoiceForm({Key? key, this.existingInvoice, this.partners})
      : super(key: key);

  @override
  createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  late Invoice _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.existingInvoice ?? Invoice.getEmpty()
      ..uuid = const Uuid().v4()
      ..date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // Invoice(
    //   '',
    //   const Uuid().v4(),
    //   '',
    //   '',
    //   '',
    //   '',
    //   DateFormat('yyyy-MM-dd').format(DateTime.now()),
    //   0.0,
    //   0.0,
    //   0.0,
    //   '',
    //   '',
    //   '',
    // );
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<Object>>? partnersItems = [];
    partnersItems.add(const DropdownMenuItem(
        value: "", child: Text("--  Selecciona un socio  --")));
    for (Contact partner in widget.partners!) {
      partnersItems.add(
          DropdownMenuItem(value: partner.uuid, child: Text(partner.name)));
    }

    return Form(
      key: _formKey,
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _invoice.number,
                decoration: const InputDecoration(labelText: 'Número'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un valor';
                  }
                  return null;
                },
                onSaved: (value) => _invoice.number = value!,
              ),
              TextFormField(
                initialValue: _invoice.code,
                decoration: const InputDecoration(labelText: 'Código'),
                onSaved: (value) => _invoice.code = value!,
              ),
              DropdownButtonFormField(
                  value: _invoice.partner,
                  decoration: const InputDecoration(labelText: 'Socio'),
                  items: partnersItems,
                  onChanged: (value) {
                    _invoice.partner = value.toString();
                  }),
              TextFormField(
                initialValue: _invoice.concept,
                decoration: const InputDecoration(labelText: 'Concepto'),
                onSaved: (value) => _invoice.concept = value!,
              ),
              TextFormField(
                initialValue: _invoice.provider,
                decoration: const InputDecoration(labelText: 'Proveedor'),
                onSaved: (value) => _invoice.provider = value!,
              ),
              DateTimePicker(
                labelText: 'Fecha',
                selectedDate: DateTime.parse(_invoice.date),
                onSelectedDate: (DateTime value) {
                  setState(() {
                    _invoice.date = DateFormat('yyyy-MM-dd').format(value);
                  });
                },
              ),
              TextFormField(
                initialValue: _invoice.desglose,
                keyboardType: TextInputType.multiline,
                maxLines: null, // Permite un número ilimitado de líneas
                decoration: const InputDecoration(labelText: 'Desglose'),
                onSaved: (value) => _invoice.desglose = value!,
              ),
              TextFormField(
                initialValue: _invoice.base.toString(),
                decoration: const InputDecoration(labelText: 'Base'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la base';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value == "") {
                    value = "0.0";
                  }
                  try {
                    _invoice.base = double.parse(value);
                  } catch (e) {
                    _invoice.base = 0.0;
                  }
                  setState(() {
                    _invoice.total = _invoice.base + _invoice.taxes;
                  });
                },
                onSaved: (value) => _invoice.base = double.parse(value!),
              ),
              TextFormField(
                initialValue: _invoice.taxes.toString(),
                decoration: const InputDecoration(labelText: 'Impuestos'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese los impuestos';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value == "") {
                    value = "0.0";
                  }
                  try {
                    _invoice.taxes = double.parse(value);
                  } catch (e) {
                    _invoice.taxes = 0.0;
                  }
                  setState(() {
                    _invoice.total = _invoice.base + _invoice.taxes;
                  });
                },
                onSaved: (value) => _invoice.taxes = double.parse(value!),
              ),
              ReadOnlyTextField(
                  label: 'Total', textToShow: _invoice.total.toString()),
              TextFormField(
                initialValue: _invoice.document,
                decoration: const InputDecoration(labelText: 'Documento'),
                onSaved: (value) => _invoice.document = value!,
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
                          _invoice.save();
                          Navigator.of(context).pop(_invoice);
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
          )),
    );
  }
}

class BankTransferForm extends StatefulWidget {
  final BankTransfer? existingBankTransfer;
  final SProject? project;

  const BankTransferForm({Key? key, this.existingBankTransfer, this.project})
      : super(key: key);

  @override
  _BankTransferFormState createState() => _BankTransferFormState();
}

class _BankTransferFormState extends State<BankTransferForm> {
  final _formKey = GlobalKey<FormState>();
  late BankTransfer _bankTransfer;

  @override
  void initState() {
    super.initState();
    if (widget.existingBankTransfer == null) {
      _bankTransfer = BankTransfer("", "", "", "", "", "", "", "", "", 0, 0, 0,
          0, 0, 0, 0, 0, "Euro", "Euro", "Euro", "");
      _bankTransfer.uuid = const Uuid().v4();
      _bankTransfer.project = widget.project!.uuid;
      _bankTransfer.concept = "Concepto";
      _bankTransfer.date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _bankTransfer.emissor = widget.project!.financiersObj[0].uuid;
      _bankTransfer.receiver = widget.project!.partnersObj[0].uuid;
    } else {
      _bankTransfer = widget.existingBankTransfer!;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<Object>>? financiers = [];
    for (Financier financier in widget.project!.financiersObj) {
      financiers.add(
          DropdownMenuItem(value: financier.uuid, child: Text(financier.name)));
    }

    List<DropdownMenuItem<Object>>? contacts = [];
    for (Contact contact in widget.project!.partnersObj) {
      contacts.add(
          DropdownMenuItem(value: contact.uuid, child: Text(contact.name)));
    }

    List<Widget> buttons;
    ElevatedButton saveButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          _bankTransfer.save();
          Navigator.of(context).pop(_bankTransfer);
        }
      },
      child: const Text('Enviar'),
    );
    ElevatedButton removeButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          _bankTransfer.delete();
          Navigator.of(context).pop(_bankTransfer);
        }
      },
      child: const Text('Eliminar'),
    );
    ElevatedButton cancelButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
      ),
      onPressed: () {
        Navigator.of(context).pop(null);
      },
      child: const Text('Cancelar'),
    );

    if (widget.existingBankTransfer!.id == "") {
      buttons = [
        Expanded(flex: 5, child: saveButton),
        Expanded(flex: 1, child: Container()),
        Expanded(flex: 5, child: cancelButton)
      ];
    } else {
      buttons = [
        Expanded(flex: 3, child: saveButton),
        Expanded(flex: 1, child: Container()),
        Expanded(flex: 3, child: cancelButton),
        Expanded(flex: 1, child: Container()),
        Expanded(flex: 3, child: removeButton)
      ];
    }

    return Form(
      key: _formKey,
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: _bankTransfer.concept,
                      decoration: const InputDecoration(labelText: 'Concepto'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onSaved: (value) => _bankTransfer.concept = value!,
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: DateTimePicker(
                        labelText: 'Fecha',
                        selectedDate: DateTime.parse(_bankTransfer.date),
                        onSelectedDate: (DateTime value) {
                          setState(() {
                            _bankTransfer.date =
                                DateFormat('yyyy-MM-dd').format(value);
                          });
                        },
                      ))
                ],
              ),
              DropdownButtonFormField(
                  value: _bankTransfer.emissor,
                  decoration: const InputDecoration(labelText: 'Emisor'),
                  items: financiers,
                  onChanged: (value) {
                    _bankTransfer.emissor = value.toString();
                  }),
              DropdownButtonFormField(
                  value: _bankTransfer.receiver,
                  decoration: const InputDecoration(labelText: 'Receptor'),
                  items: contacts,
                  onChanged: (value) {
                    _bankTransfer.receiver = value.toString();
                  }),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _bankTransfer.amountSource.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Importe Enviado'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == "") {
                          value = "0.0";
                        }
                        try {
                          _bankTransfer.amountSource = double.parse(value);
                        } catch (e) {
                          _bankTransfer.amountSource = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) =>
                          _bankTransfer.amountSource = double.parse(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _bankTransfer.commissionSource.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Comisión Origen'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == "") {
                          value = "0.0";
                        }
                        try {
                          _bankTransfer.commissionSource = double.parse(value);
                        } catch (e) {
                          _bankTransfer.commissionSource = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) =>
                          _bankTransfer.commissionSource = double.parse(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _bankTransfer.exchangeSource.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Cambio Origen'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == "") {
                          value = "0.0";
                        }
                        try {
                          _bankTransfer.exchangeSource = double.parse(value);
                        } catch (e) {
                          _bankTransfer.exchangeSource = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) =>
                          _bankTransfer.exchangeSource = double.parse(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _bankTransfer.currencySource,
                      decoration:
                          const InputDecoration(labelText: 'Moneda Origen'),
                      onSaved: (value) => _bankTransfer.currencySource = value!,
                    )),
              ]),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _bankTransfer.amountIntermediary.toString(),
                      decoration: const InputDecoration(
                          labelText: 'Importe Intermediario'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == "") {
                          value = "0.0";
                        }
                        try {
                          _bankTransfer.amountIntermediary =
                              double.parse(value);
                        } catch (e) {
                          _bankTransfer.amountIntermediary = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) => _bankTransfer.amountIntermediary =
                          double.parse(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue:
                          _bankTransfer.commissionIntermediary.toString(),
                      decoration: const InputDecoration(
                          labelText: 'Comisión Intermediario'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == "") {
                          value = "0.0";
                        }
                        try {
                          _bankTransfer.commissionIntermediary =
                              double.parse(value);
                        } catch (e) {
                          _bankTransfer.commissionIntermediary = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) => _bankTransfer.commissionIntermediary =
                          double.parse(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue:
                          _bankTransfer.exchangeIntermediary.toString(),
                      decoration: const InputDecoration(
                          labelText: 'Cambio Intermediario'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == "") {
                          value = "0.0";
                        }
                        try {
                          _bankTransfer.exchangeIntermediary =
                              double.parse(value);
                        } catch (e) {
                          _bankTransfer.exchangeIntermediary = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) => _bankTransfer.exchangeIntermediary =
                          double.parse(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _bankTransfer.currencyIntermediary,
                      decoration: const InputDecoration(
                          labelText: 'Moneda Intermediario'),
                      onSaved: (value) =>
                          _bankTransfer.currencyIntermediary = value!,
                    )),
              ]),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _bankTransfer.amountDestination.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Importe Destino'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == "") {
                          value = "0.0";
                        }
                        try {
                          _bankTransfer.amountDestination = double.parse(value);
                        } catch (e) {
                          _bankTransfer.amountDestination = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) => _bankTransfer.amountDestination =
                          double.parse(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue:
                          _bankTransfer.commissionDestination.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Comisión Destino'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un valor';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == "") {
                          value = "0.0";
                        }
                        try {
                          _bankTransfer.commissionDestination =
                              double.parse(value);
                        } catch (e) {
                          _bankTransfer.commissionDestination = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) => _bankTransfer.commissionDestination =
                          double.parse(value!),
                    )),
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _bankTransfer.currencyDestination,
                      decoration:
                          const InputDecoration(labelText: 'Moneda Destino'),
                      onSaved: (value) =>
                          _bankTransfer.currencyDestination = value!,
                    )),
              ]),
              TextFormField(
                initialValue: _bankTransfer.document,
                decoration: const InputDecoration(labelText: 'Documento'),
                onSaved: (value) => _bankTransfer.document = value!,
              ),
              const SizedBox(height: 16.0),
              Row(children: buttons),
            ],
          )),
    );
  }
}
