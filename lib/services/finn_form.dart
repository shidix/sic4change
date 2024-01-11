import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    _invoice = widget.existingInvoice ?? Invoice.getEmpty();
  }

  @override
  Widget build(BuildContext context) {
    void saveInvoice() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _invoice.save();
        Navigator.of(context).pop(_invoice);
      }
    }

    Invoice? removeInvoice() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _invoice.delete();
        Navigator.of(context).pop(_invoice);
        return (_invoice);
      }
      return null;
    }

    return Form(
      key: _formKey,
      child: SizedBox(
          //width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue: _invoice.number,
                  decoration: const InputDecoration(labelText: 'Número'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un valor';
                    }
                    return null;
                  },
                  onSaved: (value) => _invoice.number = value!,
                )),
            Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue: _invoice.code,
                  decoration: const InputDecoration(labelText: 'Código'),
                  onSaved: (value) => _invoice.code = value!,
                )),
            Expanded(
                flex: 1,
                child: CustomSelectFormField(
                  labelText: 'Socio',
                  initial: _invoice.partner,
                  options: widget.partners!
                      .map((partner) => KeyValue(partner.uuid, partner.name))
                      .toList(),
                  onSelectedOpt: (value) {
                    _invoice.partner = value.toString();
                  },
                  required: true,
                ))
          ]),
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
          Row(children: [
            Expanded(
                flex: 1,
                child: CustomSelectFormField(
                  labelText: AppLocalizations.of(context)!.currency,
                  initial: _invoice.currency,
                  options: CURRENCIES.keys
                      .map((currency) => KeyValue(currency, currency))
                      .toList(),
                  onSelectedOpt: (value) {
                    _invoice.currency = value.toString();
                    if (mounted) setState(() {});
                  },
                  required: true,
                )),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: DateTimePicker(
                      labelText: 'Fecha',
                      selectedDate: _invoice.date,
                      onSelectedDate: (DateTime value) {
                        setState(() {
                          _invoice.date = value;
                        });
                      },
                    ))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: DateTimePicker(
                      labelText: 'Fecha Pago',
                      selectedDate: _invoice.paidDate,
                      onSelectedDate: (DateTime value) {
                        setState(() {
                          _invoice.paidDate = value;
                        });
                      },
                    ))),
          ]),
          TextFormField(
            initialValue: _invoice.desglose,
            keyboardType: TextInputType.multiline,
            maxLines: null, // Permite un número ilimitado de líneas
            decoration: const InputDecoration(labelText: 'Desglose'),
            onSaved: (value) => _invoice.desglose = value!,
          ),
          Row(children: [
            Expanded(
                flex: 1,
                child: TextFormField(
                  textAlign: TextAlign.right,
                  initialValue: _invoice.base.toString(),
                  decoration: InputDecoration(
                      labelText:
                          'Base ${CURRENCIES[_invoice.currency]!.value}'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la base';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _invoice.base = currencyToDouble(value);
                    setState(() {
                      _invoice.total = _invoice.base + _invoice.taxes;
                    });
                  },
                  onSaved: (value) => _invoice.base = currencyToDouble(value!),
                )),
            Expanded(
                flex: 1,
                child: TextFormField(
                  textAlign: TextAlign.right,
                  initialValue: _invoice.taxes.toString(),
                  decoration: InputDecoration(
                      labelText:
                          'Impuestos ${CURRENCIES[_invoice.currency]!.value}'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese los impuestos';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _invoice.taxes = currencyToDouble(value);
                    setState(() {
                      _invoice.total = _invoice.base + _invoice.taxes;
                    });
                  },
                  onSaved: (value) => _invoice.taxes = currencyToDouble(value!),
                )),
            Expanded(
              flex: 1,
              child: ReadOnlyTextField(
                label: 'Total ${CURRENCIES[_invoice.currency]!.value}',
                textToShow: toCurrency(_invoice.total, _invoice.currency),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
                flex: 1,
                child: TextFormField(
                  textAlign: TextAlign.right,
                  initialValue: _invoice.imputation.toStringAsFixed(2),
                  decoration: const InputDecoration(labelText: 'Imputado (%)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el % imputado';
                    }
                    if (double.parse(value) > 100) {
                      return 'El % imputado no puede ser mayor que 100';
                    }
                    if (double.parse(value) < 1) {
                      return 'El % imputado no puede ser menor que 1';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _invoice.imputation = double.parse(value);
                  },
                  onSaved: (value) =>
                      _invoice.imputation = double.parse(value!),
                )),
          ]),
          TextFormField(
            initialValue: _invoice.document,
            decoration:
                const InputDecoration(labelText: 'Documento (localizador)'),
            onSaved: (value) => _invoice.document = value!,
          ),
          const SizedBox(height: 16.0),
          Row(children: [
            Expanded(flex: _invoice.id == "" ? 3 : 2, child: Container()),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: saveBtnForm(context, saveInvoice))),
            _invoice.id == ""
                ? Container(width: 0)
                : Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: removeBtnForm(context, removeInvoice))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: cancelBtnForm(context))),
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
  createState() => _BankTransferFormState();
}

class _BankTransferFormState extends State<BankTransferForm> {
  final _formKey = GlobalKey<FormState>();
  late BankTransfer _bankTransfer;

  @override
  void initState() {
    super.initState();
    if (widget.existingBankTransfer == null) {
      _bankTransfer = BankTransfer.getEmpty();
      _bankTransfer.uuid = const Uuid().v4();
      _bankTransfer.project = widget.project!.uuid;
      _bankTransfer.concept = "Concepto";
      _bankTransfer.date = DateTime.now();
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
          _bankTransfer.id = "";
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
                        selectedDate: _bankTransfer.date,
                        onSelectedDate: (DateTime value) {
                          setState(() {
                            _bankTransfer.date = value;
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
                    child: CustomSelectFormField(
                      labelText: AppLocalizations.of(context)!.currency,
                      initial: _bankTransfer.currencySource,
                      options: CURRENCIES.keys
                          .map((currency) => KeyValue(currency, currency))
                          .toList(),
                      onSelectedOpt: (value) {
                        _bankTransfer.currencySource = value.toString();
                        if (mounted) setState(() {});
                      },
                      required: true,
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
                    child: CustomSelectFormField(
                      labelText: AppLocalizations.of(context)!.currency,
                      initial: _bankTransfer.currencyIntermediary,
                      options: CURRENCIES.keys
                          .map((currency) => KeyValue(currency, currency))
                          .toList(),
                      onSelectedOpt: (value) {
                        _bankTransfer.currencyIntermediary = value.toString();
                        if (mounted) setState(() {});
                      },
                      required: true,
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
                    child: CustomSelectFormField(
                      labelText: AppLocalizations.of(context)!.currency,
                      initial: _bankTransfer.currencyDestination,
                      options: CURRENCIES.keys
                          .map((currency) => KeyValue(currency, currency))
                          .toList(),
                      onSelectedOpt: (value) {
                        _bankTransfer.currencyDestination = value.toString();
                        if (mounted) setState(() {});
                      },
                      required: true,
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
