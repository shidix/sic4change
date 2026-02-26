import 'package:flutter/material.dart';
import 'package:sic4change/services/models_quality.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class TransversalQuestionForm extends StatefulWidget {
  final Transversal? currentTransversal;
  final TransversalQuestion? currentQuestion;

  const TransversalQuestionForm(
      {Key? key, this.currentTransversal, this.currentQuestion})
      : super(key: key);
  @override
  createState() => _TransversalQuestionFormState();
}

class _TransversalQuestionFormState extends State<TransversalQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  late TransversalQuestion transversalQuestion;
  late Transversal transversal;
  bool isNewItem = false;

  @override
  void initState() {
    super.initState();
    isNewItem = (widget.currentQuestion!.code == "");
    transversalQuestion = widget.currentQuestion!;
    transversal = widget.currentTransversal!;
  }

  void saveItem(Map<String, dynamic> args) {
    BuildContext context = args["context"];
    GlobalKey<FormState> formKey = args["formKey"];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isNewItem) {
        transversal.questions.add(transversalQuestion);
      }
      transversal.save();
      Navigator.of(context).pop(transversal);
    }
  }

  void removeItem(Map<String, dynamic> args) {
    BuildContext context = args['context'];
    TransversalQuestion transversalQuestion = args['transversalQuestion'];
    GlobalKey<FormState> formKey = args['formKey'];
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      transversal.questions.remove(transversalQuestion);
      transversal.save();
      Navigator.of(context).pop(transversal);
    }
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  void toogletransversalQuestion(bool? value) {
    setState(() {
      transversalQuestion.completed = value!;
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
              'transversalQuestion': transversalQuestion,
              'formKey': _formKey
            }))
      ];
    }

    Widget docPanel = Container();
    if (transversalQuestion.files.isNotEmpty) {
      List<Widget> iconFiles = [];
      for (SFile file in transversalQuestion.files) {
        IconData icon = Icons.insert_drive_file;
        if (file.name.split(".").length > 1) {
          String ext = file.name.split(".").last.toLowerCase();
          if (ext == "pdf") {
            icon = Icons.picture_as_pdf;
          } else if (["jpg", "jpeg", "png"].contains(ext)) {
            icon = Icons.image;
          }
        } 
        iconFiles.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            child: customRowFileBtn(context, file.name, file.loc,
                icon, file.link)));
      }

      docPanel = Column(children: [
        const Row(children: [
          Expanded(
              flex: 1,
              child: Text('Lista de archivos',
                  style: normalText, textAlign: TextAlign.left))
        ]),
        const Divider(),
        Row(
          children: iconFiles,
        ),
        const Divider(),
      ]);
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          docPanel,
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: transversalQuestion.code,
                    decoration: const InputDecoration(
                      labelText: 'Orden',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '1, 1.1, 2, etc.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      transversalQuestion.code = value!;
                    },
                  )),
              Expanded(
                flex: 2,
                child: Container(),
              ),
              Expanded(
                  flex: 1,
                  child: customCheckBox('Cumple', transversalQuestion.completed,
                      toogletransversalQuestion)),
            ],
          ),
          TextFormField(
            initialValue: transversalQuestion.subject,
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
              transversalQuestion.subject = value!;
            },
          ),
          TextFormField(
            initialValue: transversalQuestion.comments,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Comentarios',
            ),
            onSaved: (value) {
              transversalQuestion.comments = value!;
            },
          ),
          TextFormField(
            initialValue: transversalQuestion.docs.join(","),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Documentos (localizador, separador por coma)',
            ),
            onSaved: (value) {
              transversalQuestion.docs = value!.split(",");
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
