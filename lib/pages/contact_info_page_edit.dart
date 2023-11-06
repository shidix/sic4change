import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:uuid/uuid.dart';

/*--------------------------------------------------------------------*/
/*                           EDIT PROJECT                             */
/*--------------------------------------------------------------------*/
/*  void _saveProject(
      context,
      _project,
      _types,
      _contacts,
      _programmes,
      _name,
      _desc,
      _type,
      _budget,
      _manager,
      _programme,
      _announcement,
      _ambit,
      _audit,
      _evaluation) async {
    if (_project != null) {
      await updateProject(
              _project.id,
              _project.uuid,
              _name,
              _desc,
              _type,
              _budget,
              _manager,
              _programme,
              _announcement,
              _ambit,
              _audit,
              _evaluation,
              _project.financiers,
              _project.partners)
          .then((value) async {
        loadContact(_project.id);
      });
    } else {
      await addProject(_name, _desc, _type, _budget, _manager, _programme,
              _announcement, _ambit, false, false)
          .then((value) async {
        loadContact(_project.id);
      });
    }
    if (!_types.contains(_type)) await addProjectType(_type);
    if (!_contacts.contains(_manager)) {
      Contact _contact = Contact(_manager, "", "", "", "");
      _contact.save();
    }
    if (!_programmes.contains(_programme)) await addProgramme(_programme);
    Navigator.of(context).pop();
  }

  void _callProjectEditDialog(context, _project) async {
    List<String> types = [];
    List<String> contacts = [];
    List<String> programmes = [];
    await getProjectTypes().then((value) async {
      for (ProjectType item in value) {
        types.add(item.name);
      }
      await getContacts().then((value) async {
        for (Contact item2 in value) {
          contacts.add(item2.name);
        }
        await getProgrammes().then((value) async {
          for (Programme item3 in value) {
            programmes.add(item3.name);
          }
          _editProjectDialog(context, _project, types, contacts, programmes);
        });
      });
    });
  }*/

Future<void> _editContactInfoDialog(
    context, _contactInfo, _contact, _organizations, _charges, _categories) {
  TextEditingController orgController =
      TextEditingController(text: _contactInfo.organization);
  TextEditingController chargeController =
      TextEditingController(text: _contactInfo.charge);
  TextEditingController catController =
      TextEditingController(text: _contactInfo.catgory);
  TextEditingController subcatController =
      TextEditingController(text: _contactInfo.subcategory);

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: const Text('Modificar información de contacto'),
        content: SingleChildScrollView(
          child: Column(children: [
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Organización:", 16, textColor: Colors.blue),
                customAutocompleteField(orgController, _organizations,
                    "Escribe o selecciona una organización..."),
              ]),
            ]),
            space(height: 20),
            Row(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Cargo:", 16, textColor: Colors.blue),
                customAutocompleteField(chargeController, _charges,
                    "Escribe o selecciona un cargo..."),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Categoría:", 16, textColor: Colors.blue),
                customAutocompleteField(catController, _categories,
                    "Escribe o selecciona una categoría..."),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Subcategoría:", 16, textColor: Colors.blue),
                customAutocompleteField(catController, _categories,
                    "Escribe o selecciona una sub categoría..."),
              ]),
            ]),
          ]),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              /*_saveProject(
                    context,
                    _project,
                    _types,
                    _contacts,
                    _programmes,
                    nameController.text,
                    descController.text,
                    typeController.text,
                    budgetController.text,
                    managerController.text,
                    programmeController.text,
                    announcementController.text,
                    ambitController.text,
                    _audit,
                    _evaluation);*/
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
