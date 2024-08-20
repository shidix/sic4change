import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InvoiceForm extends StatefulWidget {
  final Invoice? existingInvoice;
  //final List<Contact>? partners;
  final Organization? partner;
  final String? tracker;
  final List<TaxKind>? taxes;

  const InvoiceForm({
    Key? key,
    this.existingInvoice,
    this.partner,
    this.tracker,
    this.taxes,
  }) : super(key: key);

  @override
  createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Invoice _invoice;
  // TaxesOptions
  late List<TaxKind>? taxes;
  List<KeyValue> taxesOptions = [];

  @override
  void initState() {
    super.initState();
    taxes = widget.taxes;

    if (widget.existingInvoice == null) {
      _invoice = Invoice.getEmpty();
      _invoice.uuid = const Uuid().v4();
      _invoice.currency = 'EUR';
      _invoice.date = DateTime.now();
      _invoice.paidDate = DateTime.now();
      _invoice.tracker = widget.tracker!;
      _invoice.taxKind = taxes![0].name;
    } else {
      _invoice = widget.existingInvoice!;
    }
    taxesOptions.addAll(taxes!
        .map((e) => KeyValue(e.name, "${e.name} ${e.percentaje}%"))
        .toList()); // Se añaden las opciones de impuestos

    if (!taxesOptions.any((element) => element.key == _invoice.taxKind)) {
      taxesOptions.insert(0, KeyValue(_invoice.taxKind!, '--'));
    }
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

    return Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: _invoice.tracker,
                      decoration: const InputDecoration(
                          labelText:
                              'Tracker (si existe, carga automáticamente los datos)'),
                      onChanged: (value) {
                        if (value.length == 5) {
                          Invoice.byTracker(value).then((value) {
                            if (value != null) {
                              _invoice = value;
                              _formKey = GlobalKey<FormState>();
                              if (mounted) {
                                setState(() {
                                  _invoice = value;
                                });
                              }
                            } else {
                              if (mounted) {
                                setState(() {});
                              }
                            }
                          });
                        }
                      },
                    ))
              ]),
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
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, top: 5, bottom: 13),
                        child: DateTimePicker(
                          labelText: 'Fecha',
                          selectedDate: _invoice.date,
                          onSelectedDate: (DateTime value) {
                            if (mounted) {
                              setState(() {
                                _invoice.date = value;
                              });
                            }
                          },
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, top: 5, bottom: 13),
                        child: DateTimePicker(
                          labelText: 'Fecha Pago',
                          selectedDate: _invoice.paidDate,
                          onSelectedDate: (DateTime value) {
                            if (mounted) {
                              setState(() {
                                _invoice.paidDate = value;
                              });
                            }
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
                      onSaved: (value) =>
                          _invoice.base = currencyToDouble(value!),
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
                      onSaved: (value) =>
                          _invoice.taxes = currencyToDouble(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: CustomSelectFormField(
                          labelText: "Tipo Impuesto",
                          initial: _invoice.taxKind!,
                          options: taxesOptions,
                          onSelectedOpt: (value) {
                            _invoice.taxKind = value;
                          },
                        ))),
                Expanded(
                  flex: 1,
                  child: ReadOnlyTextField(
                    label: 'Total ${CURRENCIES[_invoice.currency]!.value}',
                    textToShow: toCurrency(_invoice.total, _invoice.currency),
                    textAlign: TextAlign.right,
                  ),
                ),
              ]),
              TextFormField(
                initialValue: _invoice.document,
                decoration:
                    const InputDecoration(labelText: 'Documento (localizador)'),
                onSaved: (value) => _invoice.document = value!,
              ),
              const SizedBox(height: 16.0),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: saveBtnForm(context, saveInvoice))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: cancelBtnForm(context))),
              ]),
            ],
          )),
        ));
  }
}

class DistributionForm extends StatefulWidget {
  final SFinnInfo info;
  final SProject project;
  final SFinn finn;
  final List<Organization> partners;
  final int index;

  const DistributionForm(
      {Key? key,
      required this.info,
      required this.project,
      required this.finn,
      required this.partners,
      required this.index})
      : super(key: key);

  @override
  createState() => _DistributionFormState();
}

class _DistributionFormState extends State<DistributionForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SFinnInfo info;
  late SProject project;
  late SFinn finn;
  late List<Organization> partners = widget.partners;
  late int index;
  late Distribution item;
  Map<String, Organization> mapPartners = {};
  double maxAllowed = 0;

  @override
  void initState() {
    maxAllowed = widget.finn.getAmountContrib() -
        widget.info.getDistribByFinn(widget.finn);
    super.initState();
    info = widget.info;
    finn = widget.finn;
    project = widget.project;
    partners = widget.partners;
    index = widget.index;
    mapPartners = {for (var e in partners) e.uuid: e};

    if (index >= 0) {
      item = info.distributions[index];
    } else {
      item = Distribution.getEmpty();
      item.partner = partners[0];
      item.finn = finn;
    }
  }

  @override
  Widget build(BuildContext context) {
    void saveDistribution() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        item.save();
        if (index >= 0) {
          info.distributions[index] = item;
        } else {
          info.distributions.add(item);
        }
        info.save();
        Navigator.of(context).pop(info);
      }
    }

    Distribution? removeDistribution() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        item.delete();
        if (index >= 0) {
          info.distributions.removeAt(index);
        }
        info.save();
        Navigator.of(context).pop(info);
        return (item);
      }
      return null;
    }

    List<Organization> partners = widget.partners;

    return Form(
      key: _formKey,
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(
                    flex: 1,
                    child: CustomSelectFormField(
                      labelText: 'Socio',
                      initial: item.partner.uuid,
                      options: partners
                          .map(
                              (partner) => KeyValue(partner.uuid, partner.name))
                          .toList(),
                      onSelectedOpt: (value) {
                        item.partner = mapPartners[value.toString()]!;
                        if (mounted) setState(() {});
                      },
                      required: true,
                    )),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                          initialValue: item.amount.toString(),
                          decoration: InputDecoration(
                              labelText:
                                  'Importe (max: ${toCurrency(maxAllowed)})',
                              contentPadding: const EdgeInsets.only(bottom: 1)),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese un importe';
                            }
                            if (currencyToDouble(value) > maxAllowed) {
                              return 'Importe mayor que ${toCurrency(maxAllowed)}';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            item.amount = currencyToDouble(value);
                          },
                          onSaved: (value) =>
                              item.amount = currencyToDouble(value!),
                        ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                          initialValue: item.description,
                          decoration: const InputDecoration(
                              labelText: 'Descripción',
                              contentPadding: EdgeInsets.only(bottom: 1)),
                          onSaved: (value) => item.description = value!,
                        ))),
              ]),
              const SizedBox(height: 16.0),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: saveBtnForm(context, saveDistribution))),
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

class InvoiceDistributionForm extends StatefulWidget {
  final InvoiceDistrib item;

  const InvoiceDistributionForm({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  createState() => _InvoiceDistributionFormState();
}

class _InvoiceDistributionFormState extends State<InvoiceDistributionForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late InvoiceDistrib invoiceDistrib;
  late Invoice invoice;

  @override
  void initState() {
    super.initState();
    invoiceDistrib = widget.item;
    invoice = Invoice.getEmpty();

    Invoice.getByUuid(widget.item.invoice).then((value) {
      invoice = value;
      if (invoiceDistrib.taxes) {
        invoiceDistrib.amount = invoice.total;
      } else {
        invoiceDistrib.amount = invoice.base;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    void saveDistribution() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        invoiceDistrib.amount =
            invoice.total * invoiceDistrib.percentaje * 0.01;
        invoiceDistrib.save();
        Navigator.of(context).pop(invoiceDistrib);
      }
    }

    return Form(
      key: _formKey,
      child: SizedBox(
          width: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(
                    flex: 1,
                    child: CustomSelectFormField(
                      labelText: '¿Impuestos imputables?',
                      initial: invoiceDistrib.taxes.toString(),
                      options: [
                        KeyValue("true", "Sí"),
                        KeyValue("false", "No")
                      ],
                      onSelectedOpt: (value) {
                        invoiceDistrib.taxes = value.toString() == "true";
                        if (mounted) {
                          setState(() {
                            if (invoiceDistrib.taxes) {
                              invoiceDistrib.amount = invoice.total;
                            } else {
                              invoiceDistrib.amount = invoice.base;
                            }
                          });
                        }
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                          initialValue: invoiceDistrib.percentaje.toString(),
                          decoration: const InputDecoration(
                              labelText: 'Porcentaje asignado',
                              contentPadding: EdgeInsets.only(bottom: 1)),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese un porcentaje';
                            }
                            if ((currencyToDouble(value) < 0) ||
                                (currencyToDouble(value) > 100)) {
                              return 'Porcentaje debe estar entre 0 y 100';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            invoiceDistrib.percentaje = currencyToDouble(value);
                          },
                          onSaved: (value) => invoiceDistrib.percentaje =
                              currencyToDouble(value!),
                        ))),
                Expanded(
                    flex: 1,
                    child: ReadOnlyTextField(
                        label: "Importe",
                        textToShow:
                            toCurrency(invoiceDistrib.amount, invoice.currency),
                        textAlign: TextAlign.right)),
              ]),
              const SizedBox(height: 16.0),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: saveBtnForm(context, saveDistribution))),
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
    financiers.add(
        const DropdownMenuItem(value: "", child: Text("Selecciona un emisor")));
    for (Organization financier in widget.project!.financiersObj) {
      financiers.add(
          DropdownMenuItem(value: financier.uuid, child: Text(financier.name)));
    }

    List<DropdownMenuItem<Object>>? contacts = [];
    contacts.add(const DropdownMenuItem(
        value: "", child: Text("Selecciona un receptor")));
    //for (Contact contact in widget.project!.partnersObj) {
    for (Organization contact in widget.project!.partnersObj) {
      contacts.add(
          DropdownMenuItem(value: contact.uuid, child: Text(contact.name)));
    }

    List<Widget> buttons;

    Widget saveButton = actionButton(context, "Guardar", () {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _bankTransfer.save();
        Navigator.of(context).pop(_bankTransfer);
      }
    }, Icons.save, null);
    Widget removeButton = actionButton(context, "Borrar", () {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        customRemoveDialog(context, _bankTransfer, () {
          _bankTransfer.id = "";
          Navigator.of(context).pop(_bankTransfer);
        });
      }
    }, Icons.delete, null);

    Widget cancelButton = actionButton(context, "Cancelar", () {
      Navigator.of(context).pop(null);
    }, Icons.cancel, null);
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

    void updateExchange() {
      if (_bankTransfer.amountIntermediary > 0.0) {
        _bankTransfer.exchangeIntermediary = _bankTransfer.amountDestination /
            (_bankTransfer.amountIntermediary -
                _bankTransfer.commissionIntermediary);
        _bankTransfer.exchangeSource = _bankTransfer.amountIntermediary /
            (_bankTransfer.amountSource - _bankTransfer.commissionSource);
      } else {
        _bankTransfer.exchangeIntermediary = 0;
        _bankTransfer.exchangeSource = _bankTransfer.amountDestination /
            (_bankTransfer.amountSource - _bankTransfer.commissionSource);
      }
      setState(() {});
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
                  validator: (value) {
                    if (value == null || value == "") {
                      return 'Por favor, seleccione un emisor';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _bankTransfer.emissor = value.toString();
                  }),
              DropdownButtonFormField(
                  value: _bankTransfer.receiver,
                  decoration: const InputDecoration(labelText: 'Receptor'),
                  items: contacts,
                  validator: (value) {
                    if (value == null || value == "") {
                      return 'Por favor, seleccione un receptor';
                    }
                    return null;
                  },
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
                          _bankTransfer.amountSource = fromCurrency(value);
                        } catch (e) {
                          _bankTransfer.amountSource = 0.0;
                        }
                        updateExchange();
                      },
                      onSaved: (value) =>
                          _bankTransfer.amountSource = fromCurrency(value!),
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
                          _bankTransfer.commissionSource = fromCurrency(value);
                        } catch (e) {
                          _bankTransfer.commissionSource = 0.0;
                        }
                        updateExchange();
                      },
                      onSaved: (value) =>
                          _bankTransfer.commissionSource = fromCurrency(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: ReadOnlyTextField(
                      label: "Cambio Origen",
                      textToShow:
                          _bankTransfer.exchangeSource.toStringAsFixed(2),
                      textAlign: TextAlign.right,
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
                              fromCurrency(value);
                        } catch (e) {
                          _bankTransfer.amountIntermediary = 0.0;
                        }
                        updateExchange();
                      },
                      onSaved: (value) => _bankTransfer.amountIntermediary =
                          fromCurrency(value!),
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
                              fromCurrency(value);
                        } catch (e) {
                          _bankTransfer.commissionIntermediary = 0.0;
                        }
                        updateExchange();
                      },
                      onSaved: (value) => _bankTransfer.commissionIntermediary =
                          fromCurrency(value!),
                    )),
                Expanded(
                    flex: 1,
                    child: ReadOnlyTextField(
                      label: "Cambio Intermediario",
                      textToShow:
                          _bankTransfer.exchangeIntermediary.toStringAsFixed(2),
                      textAlign: TextAlign.right,
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
                          _bankTransfer.amountDestination = fromCurrency(value);
                        } catch (e) {
                          _bankTransfer.amountDestination = 0.0;
                        }
                        updateExchange();
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
                              fromCurrency(value);
                        } catch (e) {
                          _bankTransfer.commissionDestination = 0.0;
                        }
                        setState(() {});
                      },
                      onSaved: (value) => _bankTransfer.commissionDestination =
                          fromCurrency(value!),
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

class SFinnForm extends StatefulWidget {
  final SFinn? existingFinn;
  final SProject? project;
  final Map<String, Organization>? financiers;
  final Organization? financier;

  const SFinnForm(
      {Key? key,
      required this.existingFinn,
      required this.project,
      required this.financiers,
      required this.financier})
      : super(key: key);

  @override
  createState() => _SFinnFormState();
}

class _SFinnFormState extends State<SFinnForm> {
  final _formKey = GlobalKey<FormState>();
  late SFinn _finn;

  @override
  void initState() {
    super.initState();
    if (widget.existingFinn == null) {
      _finn = SFinn.getEmpty();
      _finn.project = widget.project!.uuid;
    } else {
      _finn = widget.existingFinn!;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<KeyValue> financierOptions = [];
    if (widget.financier != null) {
      financierOptions
          .add(KeyValue(widget.financier!.uuid, widget.financier!.name));
    } else {
      widget.financiers!.forEach((key, value) {
        financierOptions.add(KeyValue(key, value.name));
      });
    }

    if (widget.financier != null) {
      _finn.orgUuid = widget.financier!.uuid;
    }

    List<Widget> buttons;

    Widget saveButton = actionButton(context, "Guardar", () {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _finn.save();
        Navigator.of(context).pop(_finn);
      }
    }, Icons.save, null);
    Widget removeButton = actionButton(context, "Borrar", () {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        customRemoveDialog(context, _finn, () {
          _finn.id = "";
          Navigator.of(context).pop(_finn);
        });
      }
    }, Icons.delete, null);

    Widget cancelButton = actionButton(context, "Cancelar", () {
      Navigator.of(context).pop(null);
    }, Icons.cancel, null);

    if (widget.existingFinn!.id == "") {
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
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: TextFormField(
                          initialValue: _finn.name,
                          decoration:
                              const InputDecoration(labelText: 'Código'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese un código de partida';
                            }
                            return null;
                          },
                          onSaved: (value) => _finn.name = value!,
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 4),
                          child: DateTimePicker(
                            labelText: 'Fecha Inicio',
                            selectedDate: _finn.start,
                            onSelectedDate: (DateTime value) {
                              setState(() {
                                _finn.start = value;
                              });
                            },
                          ))),
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 4),
                        child: DateTimePicker(
                          labelText: 'Fecha Fin',
                          selectedDate: _finn.end,
                          onSelectedDate: (DateTime value) {
                            setState(() {
                              _finn.end = value;
                            });
                          },
                        ),
                      )),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: _finn.contribution.toString(),
                      decoration: const InputDecoration(labelText: 'Importe'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un importe';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _finn.contribution = currencyToDouble(value);
                      },
                      onSaved: (value) =>
                          _finn.contribution = currencyToDouble(value!),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              Row(children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextFormField(
                        initialValue: _finn.description,
                        decoration:
                            const InputDecoration(labelText: 'Descripción'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese la descripción';
                          }
                          return null;
                        },
                        onSaved: (value) => _finn.description = value!,
                      )),
                ),
              ]),
              Row(children: buttons),
            ],
          )),
    );
  }
}

class TaxKindForm extends StatefulWidget {
  final TaxKind? existingTaxKind;

  const TaxKindForm({Key? key, this.existingTaxKind}) : super(key: key);

  @override
  createState() => _TaxKindFormState();
}

class _TaxKindFormState extends State<TaxKindForm> {
  final _formKey = GlobalKey<FormState>();
  late TaxKind _taxKind;
  late List<Country> countries;

  @override
  void initState() {
    super.initState();
    if (widget.existingTaxKind == null) {
      _taxKind = TaxKind.getEmpty();
    } else {
      _taxKind = widget.existingTaxKind!;
    }
    countries = [];
    Country.getAll().then((value) {
      countries = value;
      if (countries.isEmpty) {
        countries.add(Country("España"));
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons;

    Widget saveButton = actionButton(context, "Guardar", () {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _taxKind.save();
        Navigator.of(context).pop(_taxKind);
      }
    }, Icons.save, null);
    Widget removeButton = actionButton(context, "Borrar", () {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        customRemoveDialog(context, _taxKind, () {
          _taxKind.id = "";
          Navigator.of(context).pop(_taxKind);
        });
      }
    }, Icons.delete, null);

    Widget cancelButton = actionButton(context, "Cancelar", () {
      Navigator.of(context).pop(null);
    }, Icons.cancel, null);

    if (widget.existingTaxKind!.id == "") {
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
      ];
    }
    // String id;
    // String uuid;
    // String code;
    // String name;
    // double percentaje;
    // DateTime from;
    // DateTime to;
    // Country? country;
    return Form(
      key: _formKey,
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextFormField(
                        initialValue: _taxKind.code,
                        decoration: const InputDecoration(labelText: 'Código'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese un código';
                          }
                          return null;
                        },
                        onSaved: (value) => _taxKind.code = value!,
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextFormField(
                        initialValue: _taxKind.name,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese un nombre';
                          }
                          return null;
                        },
                        onSaved: (value) => _taxKind.name = value!,
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextFormField(
                        initialValue: _taxKind.percentaje.toString(),
                        decoration:
                            const InputDecoration(labelText: 'Valor (%)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese un valor';
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            _taxKind.percentaje = double.parse(value!),
                      ),
                    )),
                //TextForField for code
              ]),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: CustomSelectFormField(
                        labelText: 'País',
                        initial: _taxKind.country,
                        options: countries
                            .map((country) =>
                                KeyValue(country.name, country.name))
                            .toList(),
                        onSelectedOpt: (value) {
                          _taxKind.country = value;
                          if (mounted) setState(() {});
                        },
                        required: true,
                      )),
                  //DateTimePicker for from
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: DateTimePicker(
                            labelText: 'Desde',
                            selectedDate: _taxKind.from,
                            onSelectedDate: (DateTime value) {
                              setState(() {
                                _taxKind.from = value;
                              });
                            },
                          ))),
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: DateTimePicker(
                            labelText: 'Hasta',
                            selectedDate: _taxKind.to,
                            onSelectedDate: (DateTime value) {
                              setState(() {
                                _taxKind.to = value;
                              });
                            },
                          ))),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(children: buttons),
            ],
          )),
    );
  }
}
