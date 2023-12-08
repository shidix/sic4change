import 'package:flutter/material.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_profile.dart';

class ProfileForm extends StatefulWidget {
  final Profile? currentProfile;

  const ProfileForm({Key? key, this.currentProfile}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late Profile profile;
  late Contact contact;

  @override
  void initState() {
    super.initState();
    if (widget.currentProfile != null) {
      profile = widget.currentProfile!;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Expanded> deleteButton = [];
    int flex = 5;
    if (widget.currentProfile!.id != "") {
      flex = 3;
      deleteButton = [
        Expanded(flex: 1, child: Container()),
        Expanded(
            flex: flex,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  profile.delete();
                  Navigator.of(context).pop(profile);
                }
              },
              child: const Text('Eliminar'),
            ))
      ];
    }

    Widget roleField;
    if (profile.mainRole == "") {
      profile.mainRole = "Usuario";
    }
    roleField = DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'Rol'),
        value: profile.mainRole,
        onChanged: (val) => setState(() => profile.mainRole = val!),
        validator: (val) =>
            (val == null || val.isEmpty) ? 'Este campo es obligatorio' : null,
        items: [
          for (var item in Profile.profiles)
            DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            )
        ]);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: (profile.email != "") ? profile.email : "",
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (val) => setState(() => profile.email = val!),
              ),
              TextFormField(
                initialValue: (profile.holidaySupervisor.isNotEmpty)
                    ? profile.holidaySupervisor.join(",")
                    : "",
                decoration: const InputDecoration(
                    labelText:
                        'Supervisor de vacaciones (emails separados por ",")'),
                onSaved: (val) =>
                    setState(() => profile.holidaySupervisor = val!.split(",")),
              ),
              roleField,
              const SizedBox(height: 16.0),
              Row(
                  children: [
                        Expanded(
                            flex: flex,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blueGrey),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  profile.save();
                                  Navigator.of(context).pop(profile);
                                }
                              },
                              child: const Text('Enviar'),
                            )),
                        Expanded(flex: 1, child: Container()),
                        Expanded(
                            flex: flex,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(profile);
                              },
                              child: const Text('Cancelar'),
                            ))
                      ] +
                      deleteButton),
            ],
          ),
        ),
      ),
    );
  }
}
