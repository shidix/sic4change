import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/404_page.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const CONTACT_INFO_TITLE = "Detalles del Contacto";
ContactInfo? _contactInfo;
Contact? _contact;

class ContactInfoPage extends StatefulWidget {
  const ContactInfoPage({super.key});

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  void loadContactInfo(contactInfo) async {
    await contactInfo.reload.then((val) {
      Navigator.popAndPushNamed(context, "/contact_info",
          arguments: {"contactInfo": val, "contact": _contact});
      /*setState(() {
        _project = val;
        print(_project?.announcement);
      });*/
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      _contactInfo = args["contactInfo"];
      _contact = args["contact"];
    } else {
      _contactInfo = null;
      _contact = null;
    }

    if (_contactInfo == null) return Page404();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          contactInfoHeader(context),
          contactInfoMenu(context, _contact),
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: contactInfoDetails(context),
                    //child: projectInfoDetails(context, _project),
                  ))),
        ],
      ),
    );
  }

  Widget contactInfoHeader(context) {
    return Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Text(_task.name, style: TextStyle(fontSize: 20)),
                  Container(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(_contact!.name, 22),
                  ),
                  /*VerticalDivider(
                    width: 10,
                    color: Colors.grey,
                  ),*/
                  /*Text(_task.status,
                      style: TextStyle(
                          fontSize: 16, color: getStatusColor(_task.status))),*/
                  IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                      onPressed: () async {
                        _callContactInfoEditDialog(
                            context, _contactInfo, _contact);
                      }),
                ]),
          ),
        ]));
  }

  Widget contactInfoMenu(context, _project) {
    return Container(
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: [
            menuTabSelect(context, "Info", "/contact_info",
                {'contactInfo': _contactInfo, 'contact': _contact}),
            menuTab(context, "Seguimiento", "/project_info",
                {'contactInfo': _contactInfo, 'contact': _contact}),
            menuTab(context, "Reclamaciones", "/project_info",
                {'contactInfo': _contactInfo, 'contact': _contact}),
          ],
        ),
      ),
    );
  }

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget contactInfoDetails(context) {
    return SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText("Organización:", 16, textColor: Colors.grey),
                space(height: 5),
                customText(_contactInfo?.organization, 16),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                contactInfoDetailsRow1(context, _contactInfo),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                contactInfoDetailsRow2(context, _contactInfo),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                contactInfoDetailsRow3(context, _contactInfo),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                contactInfoDetailsRow4(context, _contactInfo),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                contactInfoDetailsRow5(context, _contactInfo),
                space(height: 5),
                Divider(
                  color: Colors.grey,
                ),
                space(height: 5),
                contactInfoDetailsRow6(context, _contactInfo),
              ],
            )));
  }

  Widget contactInfoDetailsRow1(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Cargo", 16, textColor: Colors.grey),
            customText("Categoría", 16, textColor: Colors.grey),
            customText("Subcategoría", 16, textColor: Colors.grey),
          ]),
          TableRow(children: [
            customText(_contactInfo.charge, 16),
            customText(_contactInfo.category, 16),
            customText(_contactInfo.subcategory, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow2(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Zona greográfica de influencia", 16,
                textColor: Colors.grey),
            customText("Sub Zona geográfica de influencia", 16,
                textColor: Colors.grey),
            customText("Email", 16, textColor: Colors.grey),
          ]),
          TableRow(children: [
            customText(_contactInfo.zone, 16),
            customText(_contactInfo.subzone, 16),
            customText(_contactInfo.email, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow3(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Teléfono fijo", 16, textColor: Colors.grey),
            customText("Móvil", 16, textColor: Colors.grey),
            customText("Linkedin", 16, textColor: Colors.grey),
          ]),
          TableRow(children: [
            customText(_contactInfo.phone, 16),
            customText(_contactInfo.mobile, 16),
            customText(_contactInfo.linkedin, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow4(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Twitter", 16, textColor: Colors.grey),
            customText("Otras redes sociales", 16, textColor: Colors.grey),
            customText("Grado de decisión", 16, textColor: Colors.grey),
          ]),
          TableRow(children: [
            customText(_contactInfo.twitter, 16),
            customText(_contactInfo.networks, 16),
            customText(_contactInfo.decision, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow5(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("¿Se considera un KOL?", 16, textColor: Colors.grey),
            customText("Proyecto o programa", 16, textColor: Colors.grey),
            customText("Persona de contacto", 16, textColor: Colors.grey),
          ]),
          TableRow(children: [
            customText(_contactInfo.kol, 16),
            customText(_contactInfo.project, 16),
            customText(_contactInfo.contactPerson, 16),
          ])
        ]);
  }

  Widget contactInfoDetailsRow6(context, _contactInfo) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Tipo de skateholder", 16, textColor: Colors.grey),
            customText("Tipo de sector", 16, textColor: Colors.grey),
            customText("Ámbito", 16, textColor: Colors.grey),
          ]),
          TableRow(children: [
            customText(_contactInfo.skateholder, 16),
            customText(_contactInfo.sector, 16),
            customText(_contactInfo.ambit, 16),
          ])
        ]);
  }

/*--------------------------------------------------------------------*/
/*                           EDIT PROJECT                             */
/*--------------------------------------------------------------------*/
  void _callContactInfoEditDialog(context, _contactInfo, _contact) async {
    List<String> organizations = [];
    List<String> charges = [];
    List<String> categories = [];
    await getOrganizations().then((value) async {
      for (Organization item in value) {
        organizations.add(item.name);
      }
      await getContactCharges().then((value) async {
        for (ContactCharge item2 in value) {
          charges.add(item2.name);
        }
        await getContactCategories().then((value) async {
          for (ContactCategory item3 in value) {
            categories.add(item3.name);
          }
          _editContactInfoDialog(context, _contactInfo, _contact, organizations,
              charges, categories);
        });
      });
    });
  }

  Future<void> _editContactInfoDialog(
      context, _contactInfo, _contact, _organizations, _charges, _categories) {
    TextEditingController orgController =
        TextEditingController(text: _contactInfo.organization);
    TextEditingController chargeController =
        TextEditingController(text: _contactInfo.charge);
    TextEditingController catController =
        TextEditingController(text: _contactInfo.category);
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
                  customAutocompleteField(subcatController, _categories,
                      "Escribe o selecciona una sub categoría..."),
                ]),
              ]),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _contactInfo.organization = orgController.text;
                _contactInfo.charge = chargeController.text;
                _contactInfo.category = catController.text;
                _contactInfo.subcategory = subcatController.text;
                _saveContactInfo(context, _contactInfo, _organizations,
                    _charges, _categories);
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

  void _saveContactInfo(
      context, _contactInfo, _organizations, _charges, _categories) async {
    _contactInfo.save();
    loadContactInfo(_contactInfo);

    if (!_organizations.contains(_contactInfo.organization)) {
      Organization _org = Organization(_contactInfo.organization);
      _org.save();
    }
    if (!_charges.contains(_contactInfo.charge)) {
      ContactCharge _charge = ContactCharge(_contactInfo.charge);
      _charge.save();
    }
    if (!_categories.contains(_contactInfo.category)) {
      ContactCategory _cat = ContactCategory(_contactInfo.category);
      _cat.save();
    }

    if (!_categories.contains(_contactInfo.subcategory)) {
      ContactCategory _cat = ContactCategory(_contactInfo.subcategory);
      _cat.save();
    }
    Navigator.of(context).pop();
  }

  /*--------------------------------------------------------------------*/
  /*                           FINACIERS                                */
  /*--------------------------------------------------------------------*/
/*  void _saveFinancier(context, _project, _name, _financiers) async {
    _project.financiers.add(_name);
    await updateProjectFinanciers(_project.id, _project.financiers)
        .then((value) async {
      if (!_financiers.contains(_name)) await addFinancier(_name);
      loadContact(_project.id);
    });
    Navigator.of(context).pop();
  }

  void _removeFinancier(context, _project) async {
    await updateProjectFinanciers(_project.id, _project.financiers)
        .then((value) async {
      loadContact(_project.id);
    });
  }

  void _callFinancierEditDialog(context, _project) async {
    List<String> financiers = [];
    await getFinanciers().then((value) async {
      for (Financier item in value) {
        financiers.add(item.name);
      }

      _editProjectFinancierDialog(context, _project, financiers);
    });
  }

  Future<void> _editProjectFinancierDialog(context, _project, _financiers) {
    TextEditingController nameController = TextEditingController(text: "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Add financier'),
          content: SingleChildScrollView(
            child: Column(children: [
              customAutocompleteField(
                  nameController, _financiers, "Write or select financier..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveFinancier(
                    context, _project, nameController.text, _financiers);
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
  }*/
}
