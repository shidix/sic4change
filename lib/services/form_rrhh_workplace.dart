// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_rrhh.dart';

class WorkplaceForm extends StatefulWidget {
  final Workplace selectedItem;
  final List<Workplace> existingWorkplaces;
  final Function(Workplace) onSaved;

  const WorkplaceForm(
      {super.key,
      required this.selectedItem,
      required this.existingWorkplaces,
      required this.onSaved});

  @override
  WorkplaceFormState createState() => WorkplaceFormState();
}

class WorkplaceFormState extends State<WorkplaceForm> {
  final _formKey = GlobalKey<FormState>();
  late Workplace newItem;
  bool isNew = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    newItem = widget.selectedItem;
    isNew = (newItem.id == "");
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5.0),
            child: TextFormField(
              initialValue: newItem.name,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre';
                }
                return null;
              },
              onSaved: (value) {
                newItem.name = value!;
              },
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5.0),
            child: TextFormField(
              initialValue: newItem.address,
              decoration: const InputDecoration(labelText: 'Dirección'),
              onSaved: (value) {
                newItem.address = value ?? "";
              },
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5.0),
            child: TextFormField(
              initialValue: newItem.city,
              decoration: const InputDecoration(labelText: 'Ciudad'),
              onSaved: (value) {
                newItem.city = value ?? "";
              },
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5.0),
            child: TextFormField(
              initialValue: newItem.postalCode,
              decoration: const InputDecoration(labelText: 'Código Postal'),
              onSaved: (value) {
                newItem.postalCode = value ?? "";
              },
            )),
        // Add coutnry, phone and email fields
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5.0),
            child: TextFormField(
              initialValue: newItem.country,
              decoration: const InputDecoration(labelText: 'País'),
              onSaved: (value) {
                newItem.country = value ?? "";
              },
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 5.0),
            child: TextFormField(
              initialValue: newItem.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              onSaved: (value) {
                newItem.phone = value ?? "";
              },
            )),
        // Add row with Cancel and Save buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: const Text("Guardar"),
                onPressed: () {
                  // Save logic here
                  saveForm();
                  Navigator.of(context).pop();
                }),
          ],
        )
      ]),
    );
  }

  void saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await newItem.save();
      if (widget.onSaved != null) {
        widget.onSaved(newItem);
      }
      // Save newItem to database or perform other actions
    }
  }
}
