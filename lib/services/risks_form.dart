import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class MitigationForm extends StatefulWidget {
  final Map<String, dynamic> mitigation;
  final List<Contact> contacts;

  const MitigationForm({Key? key, required this.mitigation, required this.contacts}) : super(key: key);

  @override
  _MitigationFormState createState() => _MitigationFormState();
}

class _MitigationFormState extends State<MitigationForm> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> mitigation;
  late List<Contact> contacts;
  @override
  void initState() {
    super.initState();
    mitigation = widget.mitigation;
    contacts = widget.contacts;
  }

  @override
  Widget build(BuildContext context) {

    if (!mitigation.containsKey("type")) {
      mitigation["type"] = "Mitigación";
    }
    if (!mitigation.containsKey("fixed")) {
      mitigation["fixed"] = "No";
    }
    if (! ["Sí", "No", "Parcialmente"].contains(mitigation["fixed"])) {
      mitigation["fixed"] = "No";
    }

    List<KeyValue> contactOptions = contacts.map((e) => KeyValue(e.uuid, e.name)).toList();
    List<String> uuidContacts = contacts.map((e) => e.uuid).toList();
    if (!uuidContacts.contains(mitigation["responsible"] )) {
      mitigation["responsible"] = "-";
      contactOptions.insert(0,KeyValue("-", "<No asignado>"));
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
                    child: 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                    CustomTextField(
                      labelText: "Descripción",
                      initial: mitigation["description"],
                      size: MediaQuery.of(context).size.width * 0.6,
                      maxLines: 5,
                      fieldValue: (String val) {
                        mitigation["description"] = val;
                        setState(() {
                          
                        });
                      },
                    ),
                    customText((mitigation["description"]=="")?"El campo no puede estar vacío":"",12, textColor: Colors.red, align: TextAlign.left)
                    ])
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
                  child: Padding (padding: EdgeInsets.only(bottom:7, right:10, left:10),
                  child:
    
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    shape: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0)),
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
                  ))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 10, right:10),
                      
                      child: CustomSelectFormField(
                          labelText: "Responsable",
                          initial: mitigation["responsible"],
                          options: contactOptions,
                          onSelectedOpt: (String val) {
                            mitigation["responsible"] = val;
                          }))),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10),
                    child: CustomSelectFormField(
                      labelText: "Corrección",
                      initial: mitigation["fixed"],
                      options: List<KeyValue>.from([
                        KeyValue("Sí", "Sí"),
                        KeyValue("No", "No"),
                        KeyValue("Parcialmente", "Parcialmente"),
                      ]),
                      onSelectedOpt: (String val) {
                        mitigation["fixed"] = val;
                      },
                    ),
                  )),                          

            ]),
          ],
        ),
      )),
    );
  }
}
