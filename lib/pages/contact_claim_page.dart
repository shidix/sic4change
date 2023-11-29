import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_contact_claim.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/contact_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactClaimPageTitle = "Seguimiento";
List claimList = [];
//Contact? contactC;

class ContactClaimPage extends StatefulWidget {
  const ContactClaimPage({super.key});

  @override
  State<ContactClaimPage> createState() => _ContactClaimPageState();
}

class _ContactClaimPageState extends State<ContactClaimPage> {
  void loadContactClaim(value) async {
    await getClaimsByContact(value).then((val) {
      claimList = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      contact = args["contact"];
    } else {
      contact = null;
    }

    if (contact == null) return const Page404();

    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        contactClaimHeader(context),
        contactMenu(context, contact, "claim"),
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xffdfdfdf),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: contactClaimList(context, contact),
                )))
      ]),
    );
  }

/*-------------------------------------------------------------
                            CLAIMS
-------------------------------------------------------------*/
  Widget contactClaimHeader(context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: customText(contact!.name, 22),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        addBtn(context),
                        returnBtn(context),
                      ],
                    ),
                  ),
                ]),
          ),
        ]));
  }

  /*Widget contactClaimMenu(context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          menuTab(context, "Info", "/contact_info", {'contact': contact}),
          menuTabSelect(context, "Seguimiento", "/contact_trackings",
              {'contact': contact}),
          menuTab(
              context, "Reclamaciones", "/project_info", {'contact': contact}),
        ],
      ),
    );
  }*/

  Widget addBtn(context) {
    return FilledButton(
      onPressed: () {
        _editDialog(context, null);
      },
      style: FilledButton.styleFrom(
        side: const BorderSide(width: 0, color: Color(0xffffffff)),
        backgroundColor: const Color(0xffffffff),
      ),
      child: const Column(
        children: [
          Icon(Icons.add, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Añadir",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void saveClaim(context, claim, name, manager, date, contact) async {
    claim ??= ContactClaim(contact.uuid);
    claim.name = name;
    claim.manager = manager;
    claim.date = date;
    claim.save();
    loadContactClaim(contact.uuid);
    Navigator.of(context).pop();
  }

  Future<void> _editDialog(context, claim) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController managerController = TextEditingController(text: "");
    TextEditingController dateController = TextEditingController(text: "");

    print("--1--");
    print(claim);
    print(claim.name);
    if (claim != null) {
      nameController = TextEditingController(text: claim.name);
      managerController = TextEditingController(text: claim.manager);
      dateController = TextEditingController(text: claim.date);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar reclamación'),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Nombre:", 16, textColor: Colors.blue),
              customTextField(nameController, "Nombre..."),
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Responsable:", 16, textColor: Colors.blue),
              customTextField(managerController, "Responsable..."),
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              customText("Fecha:", 16, textColor: Colors.blue),
              customDateField(context, dateController),
            ]),
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                saveClaim(context, claim, nameController.text,
                    managerController.text, dateController, contact);
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget customDateField(context, dateController) {
    return SizedBox(
        width: 220,
        child: TextField(
          controller: dateController, //editing controller of this TextField
          decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Introducir fecha" //label text of field
              ),
          readOnly: true, //set it true, so that user will not able to edit text
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(
                    2000), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2101));

            if (pickedDate != null) {
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);

              setState(() {
                dateController.text = formattedDate;
              });
            } else {
              //print("Date is not selected");
            }
          },
        ));
  }

  Widget contactClaimList(context, contact) {
    return FutureBuilder(
        future: getClaimsByContact(contact.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            claimList = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: claimHeaderRow(context),
                ),
                Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: claimList.length,
                        itemBuilder: (BuildContext context, int index) {
                          ContactClaim claim = claimList[index];
                          return Container(
                            height: 100,
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Color(0xffdfdfdf), width: 1)),
                            ),
                            child: claimRow(context, claim),
                          );
                        }))
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget claimHeaderRow(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText("Nombre", 16,
                textColor: titleColor, bold: FontWeight.bold),
          ],
        ),
        Column(children: [
          customText("Responsable", 16,
              textColor: titleColor, bold: FontWeight.bold),
        ]),
        Column(children: [
          customText("Fecha", 16, textColor: titleColor, bold: FontWeight.bold),
        ]),
        Column(children: [
          customText("Acciones", 16,
              textColor: titleColor, bold: FontWeight.bold),
        ]),
      ],
    );
  }

  Widget claimRow(context, claim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(claim.name, 14, bold: FontWeight.bold),
            space(height: 10),
            customText(claim.description, 14),
          ],
        ),
        Column(children: [
          customText(claim.date, 14, bold: FontWeight.bold),
        ]),
        Column(children: [
          claimRowOptions(context, claim),
        ])
      ],
    );
  }

  Widget claimRowOptions(context, claim) {
    return Row(children: [
      IconButton(
          icon: const Icon(Icons.info),
          tooltip: 'Detalles',
          onPressed: () {
            Navigator.pushNamed(context, "/contact_claim_info",
                arguments: {'contact': contact, 'claim': claim});
          }),
      IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Editar',
          onPressed: () async {
            _editDialog(context, claim);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Borrar',
          onPressed: () {
            _removeDialog(context, claim);
          }),
    ]);
  }

  Future<void> _removeDialog(context, claim) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Borrar reclamación'),
          content: const SingleChildScrollView(
            child: Text("Está seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Borrar'),
              onPressed: () async {
                claim.delete();
                loadContactClaim(contact?.uuid);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
