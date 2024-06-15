import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_learning.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class LearningForm extends StatefulWidget {
  final Learning? item;
  //final List<Contact>? partners;

  const LearningForm({Key? key, this.item}) : super(key: key);

  @override
  State<LearningForm> createState() => _LearningFormState();
}

class _LearningFormState extends State<LearningForm> {
  final formKey = GlobalKey<FormState>();
  late Learning? item;

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    List<KeyValue> kindOptions = [
      KeyValue("Logro", "Logro"),
      KeyValue("Buena práctica", "Buena práctica"),
      KeyValue("Experiencia", "Experiencia"),
    ];
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: item?.description,
                  decoration: const InputDecoration(labelText: "Descripción"),
                  onSaved: (value) {
                    item?.description = value!;
                  },
                ),
              ),
              space(width: 10),
              Expanded(
                flex: 1,
                child: CustomSelectFormField(
                    labelText: "Tipo",
                    initial: item!.kind,
                    options: kindOptions,
                    onSelectedOpt: (value) {
                      item?.kind = value;
                      setState(() {
                        item = item;
                      });
                    },
                    required: true),
              ),
              space(width: 10),
              Expanded(
                flex: 1,
                child: CustomDateField(
                    labelText: "Fecha",
                    selectedDate: item!.date,
                    onSelectedDate: (value) {
                      item?.date = value;
                      setState(() {
                        item = item;
                      });
                    }),
              ),
            ],
          ),
          space(height: 10),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: actionButton(context, "Guardar", () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          Navigator.pop(context, item);
                        }
                      }, Icons.save, null))),
              Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: actionButton(context, "Cancelar", () {
                        Navigator.pop(context, null);
                      }, Icons.cancel, null))),
            ],
          )
        ],
      ),
    );
  }
}
