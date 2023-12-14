import 'package:flutter/material.dart';
import 'package:sic4change/services/models_quality.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class QualityQuestionForm extends StatefulWidget {
  final Quality? currentQuality;
  final QualityQuestion? currentQuestion;

  const QualityQuestionForm(
      {Key? key, this.currentQuality, this.currentQuestion})
      : super(key: key);
  @override
  _QualityQuestionFormState createState() => _QualityQuestionFormState();
}

class _QualityQuestionFormState extends State<QualityQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  late QualityQuestion qualityQuestion;
  late Quality quality;
  bool isNewItem = false;

  @override
  void initState() {
    super.initState();
    isNewItem = (widget.currentQuestion!.code == "");
    qualityQuestion = widget.currentQuestion!;
    quality = widget.currentQuality!;
  }

  void saveItem(Map<String, dynamic> args) {
    BuildContext context = args["context"];
    //QualityQuestion qualityQuestion = args["qualityQuestion"];
    GlobalKey<FormState> formKey = args["formKey"];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isNewItem) {
        quality.qualityQuestions.add(qualityQuestion);
      }
      quality.save();
      Navigator.of(context).pop(quality);
    }
  }

  void removeItem(Map<String, dynamic> args) {
    BuildContext context = args['context'];
    QualityQuestion qualityQuestion = args['qualityQuestion'];
    GlobalKey<FormState> formKey = args['formKey'];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      quality.qualityQuestions.remove(qualityQuestion);
      quality.save();
      Navigator.of(context).pop(quality);
    }
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  void toogleQualityQuestion(bool? value) {
    setState(() {
      qualityQuestion.completed = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Expanded> deleteButton = [];
    int flex = 5;
    if (!isNewItem) {
      flex = 3;
      deleteButton = [
        Expanded(flex: 1, child: Container()),
        Expanded(
            flex: flex,
            child: actionButton(context, "Eliminar", removeItem, Icons.delete, {
              'context': context,
              'qualityQuestion': qualityQuestion,
              'formKey': _formKey
            }))
      ];
    }
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(children: [
            Expanded(flex:1, child:          TextFormField(
            initialValue: qualityQuestion.code,
            decoration: const InputDecoration(
              labelText: 'Código',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return '1, 1.1, 2, etc.';
              }
              return null;
            },
            onSaved: (value) {
              qualityQuestion.code = value!;
            },
          )),
          Expanded(flex:2, child: Container(),),
          Expanded(flex:1, child: 
          customCheckBox(
              'Completado', qualityQuestion.completed, toogleQualityQuestion)),
          ],)
,
          TextFormField(
            initialValue: qualityQuestion.subject,
            decoration: const InputDecoration(
              labelText: 'Pregunta',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Objetivo de calidad a cumplir';
              }
              return null;
            },
            onSaved: (value) {
              qualityQuestion.subject = value!;
            },
          ),

          TextFormField(
            initialValue: qualityQuestion.comments,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Comentarios',
            ),

            onSaved: (value) {
              qualityQuestion.comments = value!;
            },
          ),

          const SizedBox(height: 16.0),
          Row(
              children: [
                    Expanded(
                        flex: flex,
                        child: actionButton(
                            context,
                            "Enviar",
                            saveItem,
                            Icons.save_outlined,
                            {'context': context, 'formKey': _formKey})),
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                        flex: flex,
                        child: actionButton(context, "Cancelar", cancelItem,
                            Icons.cancel, context))
                  ] +
                  deleteButton),
        ],
      ),
    );
  }
}
