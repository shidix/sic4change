import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/monitoring/v3.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_bitacora.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class BitacoraForm extends StatefulWidget {
  final Bitacora bitacora;
  final int type;
  final int index;

  const BitacoraForm({Key? key, required this.bitacora, required this.type, required this.index}) : super(key: key);

  @override
  _BitacoraFormState createState() => _BitacoraFormState();
}

class _BitacoraFormState extends State<BitacoraForm> {
  final _formKey = GlobalKey<FormState>();
  final _keysDictionary = ["summary", "delays", "financial", "technicals", "fromPartners", "others"];
  late Map<String, dynamic> item;
  late String keyIndex;

  @override
  void initState() {
    super.initState();
    keyIndex = _keysDictionary[widget.type % 6];
    if (widget.index >= 0) {
      item = widget.bitacora.toJson()[keyIndex][widget.index];
    }
    else {
      item = {'date': DateTime.now(), 'description': "", 'change': false, 'approved': false};

    }
  }

  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children:[
            Row(children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, top: 10),
                    child:  ListTile(
                    leading: const Icon(Icons.date_range),
                    shape: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0)),
                    title: const Text("Fecha"),
                    subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(item["date"])),
                    onTap: () async {
                      DateTime dateTracking = item["date"];
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dateTracking,
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101));
                      if (picked != null && picked != dateTracking && mounted) {
                        setState(() {
                          item["date"] = picked;
                        });
                      }
                    },
                  )
                  )),
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, top: 10),
                    child: CustomTextField(labelText: "descripción", initial: item["description"], size: 220, fieldValue: (String val) {
                      item["description"] = val;
                    }),
                  )),
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, top: 10),
                    child: CustomSelectFormField(
                        labelText: "Cambio sustancial",
                        initial: item["change"] ? "Sí" : "No",
                        options: List<KeyValue>.from([
                          KeyValue("Sí", "Sí"),
                          KeyValue("No", "No"),
                        ]),
                        onSelectedOpt: (String val) {
                          item["change"] = (val == "Sí");
                        }),
                  )),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, top: 10),
                    child: CustomSelectFormField(
                        labelText: "Aprobado",
                        initial: item["approved"] ? "Sí" : "No",
                        options: List<KeyValue>.from([
                          KeyValue("Sí", "Sí"),
                          KeyValue("No", "No"),
                        ]),
                        onSelectedOpt: (String val) {
                          item["approved"] = (val == "Sí");
                        })
                  )),
            ]),
            ],)
      )),
    );
  }
}

