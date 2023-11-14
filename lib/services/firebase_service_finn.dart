//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';

class InvoiceForm extends StatefulWidget {
  final Invoice? existingInvoice;

  InvoiceForm({Key? key, this.existingInvoice}) : super(key: key);

  @override
  _InvoiceFormState createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  late Invoice _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.existingInvoice ??
        Invoice(
          '',
          const Uuid().v4(),
          '',
          '',
          '',
          '',
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
          0.0,
          0.0,
          0.0,
          '',
          '',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _invoice.number,
            decoration: InputDecoration(labelText: 'Número'),
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
            decoration: InputDecoration(labelText: 'Código'),
            onSaved: (value) => _invoice.code = value!,
          ),
          TextFormField(
            initialValue: _invoice.concept,
            decoration: InputDecoration(labelText: 'Concepto'),
            onSaved: (value) => _invoice.concept = value!,
          ),
          TextFormField(
            initialValue: _invoice.provider,
            decoration: InputDecoration(labelText: 'Proveedor'),
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
            initialValue: _invoice.base.toString(),
            decoration: InputDecoration(labelText: 'Base'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            decoration: InputDecoration(labelText: 'Impuestos'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            decoration: InputDecoration(labelText: 'Documento'),
            onSaved: (value) => _invoice.document = value!,
          ),
          const SizedBox(height: 16.0),
          Row(children: [
            Expanded(
                flex: 5,
                child: ElevatedButton(
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
      ),
    );
  }
}
