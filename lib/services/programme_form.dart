import 'package:flutter/material.dart';
import 'package:googleapis/driveactivity/v2.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class ProgrammeForm extends StatefulWidget {
  final Programme? currentProgramme;
  final Function? onSaved;

  const ProgrammeForm({Key? key, this.currentProgramme, this.onSaved})
      : super(key: key);

  @override
  ProgrammeFormState createState() => ProgrammeFormState();
}

class ProgrammeFormState extends State<ProgrammeForm> {
  final _formKey = GlobalKey<FormState>();
  late Programme programme;
  String logoPath = '';

  void saveForm(args) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.onSaved != null) {
        widget.onSaved!([programme]);
      }
    }
  }

  @override
  void initState() {
    String tmpPath = '';
    String tmpExtension = '';

    super.initState();

    if (widget.currentProgramme != null) {
      programme = widget.currentProgramme!;
    } else {
      programme = Programme('Nuevo programa');
    }

    tmpExtension = programme.logo.split('?').first.split('.').last;
    String auxPath = "files/programmes/${programme.id}/logo.$tmpExtension";
    tmpPath = auxPath.replaceFirst('logo.', 'logoTemp.');
    logoPath = programme.logo;

    copyFileInStorage(programme.logo, tmpPath).then((value) {
      getDownloadUrl(tmpPath).then((url) {
        setState(() {
          logoPath = url;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  Row(children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: UploadImageField(
                              rootPath: "files/programmes/${programme.id}/",
                              fileName: "logoTemp.png",
                              pathImage: logoPath,
                              textToShow: "Subir Imagen",
                              onSelectedFile: (file) {
                                // move file to new path
                                String tmpPath =
                                    "files/programmes/${programme.id}/logoTemp.png";
                                getDownloadUrl(tmpPath).then((url) {
                                  setState(() {
                                    logoPath = url;
                                  });
                                });
                              },
                            ))),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: programme.name,
                        decoration: const InputDecoration(
                            labelText: 'Nombre del Programa'),
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Este campo es obligatorio'
                            : null,
                        onSaved: (val) => programme.name = val!,
                      ),
                    ),
                  ]),
                  space(height: 20),
                  Row(children: [
                    Expanded(
                        flex: 5,
                        child: actionButton(context, "Enviar", saveForm,
                            Icons.save, [programme])),
                    space(width: 10),
                    Expanded(
                        flex: 5,
                        child: actionButton(context, "Cancelar", cancelItem,
                            Icons.cancel, context))
                  ])
                ]))));
  }
}
