// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models_evaluation.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class EvaluationForm extends StatefulWidget {
  final Evaluation evaluation;
  final int type;
  final int index;

  const EvaluationForm(
      {Key? key,
      required this.evaluation,
      required this.type,
      required this.index})
      : super(key: key);

  @override
  _EvaluationFormState createState() => _EvaluationFormState();
}

class _EvaluationFormState extends State<EvaluationForm> {
  final _formKey = GlobalKey<FormState>();
  final _keysDictionary = [
    "conclussions",
    "requirements",
  ];
  late Map<String, dynamic> item;
  late String keyIndex;

  @override
  void initState() {
    super.initState();
    keyIndex = _keysDictionary[widget.type % 2];
    if (widget.index >= 0) {
      item = widget.evaluation.toJson()[keyIndex][widget.index];
    } else {
      item = {
        'description': "",
        'stakeholder': "",
        'isRefML': "No",
        'unit': "",
        'relevance': 1,
        'feasibility': 1,
        'recipientResponse': "",
        'improvementAction': "",
        'deadline': DateTime.now(),
        'verificationMethod': "",
        'followUp': "",
        'followUpDate': DateTime.now(),
        'supervision': "",
        'observations': "",
      };
    }
  }

  void updateEvaluation(type, item) {
    if (type == 0) {
      if (widget.index >= 0) {
        widget.evaluation.conclussions[widget.index] = item;
      } else {
        widget.evaluation.conclussions.add(item);
      }
    } else {
      if (widget.index >= 0) {
        widget.evaluation.requirements[widget.index] = item;
      } else {
        widget.evaluation.requirements.add(item);
      }
    }
    widget.evaluation.save();
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
                  updateEvaluation(widget.type, item);
                  Navigator.pop(context, widget.evaluation);
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    child: CustomTextField(
                      labelText: "Descripción",
                      initial: item["description"],
                      size: 220,
                      fieldValue: (value) {
                        item["description"] = value;
                      },
                    )))
          ]),
          Row(children: [
            Expanded(
                flex: 2,
                child: (widget.type == 0)? Container() : Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 20),
                    child: CustomTextField(
                      labelText: "Partes interesadas",
                      initial: item["stakeholder"],
                      size: 220,
                      fieldValue: (value) {
                        item["stakeholder"] = value;
                      },
                    ))),

            Expanded(
                flex: 2,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 20),
                    child: CustomTextField(
                      labelText: "Unidad/Dpto",
                      initial: item["unit"],
                      size: 220,
                      fieldValue: (value) {
                        item["unit"] = value;
                      },
                    ))),

            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 20),
                    child: CustomSelectFormField(
                      labelText:
                          (widget.type == 0) ? "Referencial MML" : "Necesidad",
                      initial: item["isRefML"],
                      options: List<KeyValue>.from([
                        KeyValue("Sí", "Sí"),
                        KeyValue("No", "No"),
                      ]),
                      onSelectedOpt: (value) {
                        item["isRefML"] = value;
                      },
                    ))),
            // relevancia
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 20),
                    child: CustomSelectFormField(
                      labelText: "Relevancia",
                      initial: item["relevance"].toString(),
                      options: List<KeyValue>.from([
                        KeyValue("1", "1"),
                        KeyValue("2", "2"),
                        KeyValue("3", "3"),
                        KeyValue("4", "4"),
                      ]),
                      onSelectedOpt: (value) {
                        item["relevance"] = int.parse(value);
                      },
                    ))),
            // factibilidad
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 20),
                    child: CustomSelectFormField(
                      labelText: "Viabilidad",
                      initial: item["feasibility"].toString(),
                      options: List<KeyValue>.from([
                        KeyValue("1", "1"),
                        KeyValue("2", "2"),
                        KeyValue("3", "3"),
                        KeyValue("4", "4"),
                      ]),
                      onSelectedOpt: (value) {
                        item["feasibility"] = int.parse(value);
                      },
                    ))),
          ]),
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 0),
                    child: CustomTextField(
                      labelText: "Respuesta del receptor",
                      initial: item["recipientResponse"],
                      size: 220,
                      fieldValue: (value) {
                        item["recipientResponse"] = value;
                      },
                    )))
          ]),
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 0),
                    child: CustomTextField(
                      labelText: "Acción de mejora",
                      initial: item["improvementAction"],
                      size: 220,
                      fieldValue: (value) {
                        item["improvementAction"] = value;
                      },
                    )))
          ]),
          Row(children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 20),
                    child: CustomTextField(
                      labelText: "Método de verificación",
                      initial: item["verificationMethod"],
                      size: 220,
                      fieldValue: (value) {
                        item["verificationMethod"] = value;
                      },
                    ))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 0),
                    child: CustomDateField(
                        labelText: 'Fecha límite',
                        selectedDate: getDate(item["deadline"]),
                        onSelectedDate: (value) {
                          item["deadline"] = value;
                          setState(() {});
                        })))
          ]),
          Row(children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 20),
                    child: CustomTextField(
                      labelText: "Seguimiento",
                      initial: item["followUp"],
                      size: 220,
                      fieldValue: (value) {
                        item["followUp"] = value;
                      },
                    ))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 0),
                    child: CustomDateField(
                        labelText: 'Fecha Seguimiento',
                        selectedDate: getDate(item["followUpDate"]),
                        onSelectedDate: (value) {
                          item["followUpDate"] = value;
                          setState(() {});
                        })))
          ]),
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 0),
                    child: CustomTextField(
                      labelText: "Supervisión",
                      initial: item["supervision"],
                      size: 220,
                      fieldValue: (value) {
                        item["supervision"] = value;
                      },
                    )))
          ]),
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 0),
                    child: CustomTextField(
                      labelText: "Observaciones",
                      initial: item["observations"],
                      size: 220,
                      fieldValue: (value) {
                        item["observations"] = value;
                      },
                    )))
          ]),
          actions
        ],
      ),
    );
  }
}
