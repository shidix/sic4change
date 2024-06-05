import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class MitigationForm extends StatefulWidget {
  final Map<String, dynamic> mitigation;

  const MitigationForm({Key? key, required this.mitigation}) : super(key: key);

  @override
  _MitigationFormState createState() => _MitigationFormState();
}

class _MitigationFormState extends State<MitigationForm> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> mitigation;
  @override
  void initState() {
    super.initState();
    mitigation = widget.mitigation;
  }

  @override
  Widget build(BuildContext context) {

    if (!mitigation.containsKey("type")) {
      mitigation["type"] = "Mitigación";
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
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, top: 10),
                    child: CustomTextField(
                      labelText: "Descripción",
                      initial: mitigation["description"],
                      size: MediaQuery.of(context).size.width * 0.6,
                      maxLines: 5,
                      fieldValue: (String val) {
                        mitigation["description"] = val;
                      },
                    ),
                  )),
            ]),
            Row(children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 0, top: 10, right:10),
                      child: CustomSelectFormField(
                          labelText: "Implementada",
                          initial: mitigation["implemented"] ? "Sí" : "No",
                          options: List<KeyValue>.from([
                            KeyValue("Sí", "Sí"),
                            KeyValue("No", "No"),
                          ]),
                          onSelectedOpt: (String val) {
                            mitigation["implemented"] = (val == "Sí");
                          }))),
              Expanded(flex: 1, child: 
              
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: CustomSelectFormField(
                  labelText: "Tipo",
                  initial: mitigation["type"],
                  options: List<KeyValue>.from([
                    KeyValue("Mitigación", "Mitigación"),
                    KeyValue("Transferencia", "Transferencia"),
                    KeyValue("Evitación", "Evitación"),
                    KeyValue("Aceptación", "Aceptación"),
                    KeyValue("Contingencia", "Contingencia"),
                  ]),
                  onSelectedOpt: (String val) {
                    mitigation["type"] = val;
                  },
                ),
              )
                  ),
              Expanded(
                  flex: 1,
                  child: ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text("Fecha"),
                    subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(mitigation["date"])),
                    onTap: () async {
                      DateTime dateTracking = mitigation["date"];
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dateTracking,
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101));
                      if (picked != null && picked != dateTracking && mounted) {
                        setState(() {
                          mitigation["date"] = picked;
                        });
                      }
                    },
                  )),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: CustomTextField(
                        labelText: "Responsable",
                        initial: mitigation["responsible"],
                        size: 220,
                        fieldValue: (String val) {
                          mitigation["responsible"] = val;
                        },
                      )))
            ]),
          ],
        ),
      )),
    );
  }
}
