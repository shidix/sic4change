// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_bitacora.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class BitacoraForm extends StatefulWidget {
  final Bitacora bitacora;
  final int type;
  final int index;

  const BitacoraForm(
      {Key? key,
      required this.bitacora,
      required this.type,
      required this.index})
      : super(key: key);

  @override
  _BitacoraFormState createState() => _BitacoraFormState();
}

class _BitacoraFormState extends State<BitacoraForm> {
  final _formKey = GlobalKey<FormState>();
  final _keysDictionary = [
    "summary",
    "delays",
    "financial",
    "technicals",
    "fromPartners",
    "others"
  ];
  late Map<String, dynamic> item;
  late String keyIndex;

  @override
  void initState() {
    super.initState();
    keyIndex = _keysDictionary[widget.type % 6];
    if (widget.index >= 0) {
      item = widget.bitacora.toJson()[keyIndex][widget.index];
    } else {
      item = {
        'date': DateTime.now(),
        'description': "",
        'change': false,
        'approved': false
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    Row actions = Row(children: [
      Expanded(flex: 3, child: Container()),
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: actionButton(context, "Guardar", () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  updateBitacora(widget.type, item);
                  Navigator.pop(context, widget.bitacora);
                }
              }, Icons.save, null))),
      Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: actionButton(context, "Cancelar", () {
                Navigator.pop(context, null);
              }, Icons.cancel, null))),
    ]);
    DateTime dateTracking;
    try {
      dateTracking = item["date"].toDate();
    } catch (e) {
      dateTracking = item["date"];
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                        flex: 2,
                        child: Padding(
                            padding: const EdgeInsets.only(right: 10, top: 0),
                            child: ListTile(
                              leading: const Icon(Icons.date_range),
                              shape: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade500, width: 1.0)),
                              title: const Text("Fecha"),
                              subtitle: Text(DateFormat('dd/MM/yyyy')
                                  .format(dateTracking)),
                              onTap: () async {
                                DateTime dateTracking;
                                try {
                                  dateTracking = item["date"].toDate();
                                } catch (e) {
                                  dateTracking = item["date"];
                                }
                                final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: dateTracking,
                                    firstDate: DateTime(2015, 8),
                                    lastDate: DateTime(2101));
                                if (picked != null &&
                                    picked != dateTracking &&
                                    mounted) {
                                  setState(() {
                                    item["date"] = picked;
                                    // updateBitacora(widget.type, item);
                                  });
                                }
                              },
                            ))),
                    Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, top: 18),
                          child: CustomTextField(
                              labelText: "Descripción",
                              initial: item["description"],
                              size: 220,
                              fieldValue: (String val) {
                                item["description"] = val;
                                // updateBitacora(widget.type, item);
                              }),
                        )),
                    Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, top: 18),
                          child: CustomSelectFormField(
                              labelText: "Cambio sustancial",
                              initial: item["change"] ? "Sí" : "No",
                              options: List<KeyValue>.from([
                                KeyValue("Sí", "Sí"),
                                KeyValue("No", "No"),
                              ]),
                              onSelectedOpt: (String val) {
                                item["change"] = (val == "Sí");
                                // updateBitacora(widget.type, item);
                              }),
                        )),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(right: 10, top: 18),
                            child: CustomSelectFormField(
                                labelText: "Aprobado",
                                initial: item["approved"] ? "Sí" : "No",
                                options: List<KeyValue>.from([
                                  KeyValue("Sí", "Sí"),
                                  KeyValue("No", "No"),
                                ]),
                                onSelectedOpt: (String val) {
                                  item["approved"] = (val == "Sí");
                                  // updateBitacora(widget.type, item);
                                }))),
                  ]),
                  actions
                ],
              ))),
    );
  }

  void updateBitacora(type, item) {
    if (item["description"] == "") {
      return;
    }
    switch (type) {
      case 0:
        if (widget.index >= 0) {
          widget.bitacora.summary[widget.index] = item;
        } else {
          widget.bitacora.summary.add(item);
        }
        break;
      case 1:
        if (widget.index >= 0) {
          widget.bitacora.delays[widget.index] = item;
        } else {
          widget.bitacora.delays.add(item);
        }
        break;
      case 2:
        if (widget.index >= 0) {
          widget.bitacora.financial[widget.index] = item;
        } else {
          widget.bitacora.financial.add(item);
        }
        break;
      case 3:
        if (widget.index >= 0) {
          widget.bitacora.technicals[widget.index] = item;
        } else {
          widget.bitacora.technicals.add(item);
        }
        break;
      case 4:
        if (widget.index >= 0) {
          widget.bitacora.fromPartners[widget.index] = item;
        } else {
          widget.bitacora.fromPartners.add(item);
        }
        break;
      case 5:
        if (widget.index >= 0) {
          widget.bitacora.others[widget.index] = item;
        } else {
          widget.bitacora.others.add(item);
        }
        break;
    }
    widget.bitacora.save();
  }
}
