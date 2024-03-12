// import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/contact_claim_info_page.dart';
import 'package:sic4change/pages/contacts_page.dart';
// import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_contact_claim.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/contact_menu_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const contactClaimPageTitle = "Seguimiento";
// Contact? contact;

class ContactClaimPage extends StatefulWidget {
  final Contact? contact;
  final ContactInfo? contactInfo;
  const ContactClaimPage({super.key, this.contact, this.contactInfo});

  @override
  State<ContactClaimPage> createState() => _ContactClaimPageState();
}

class _ContactClaimPageState extends State<ContactClaimPage> {
  Contact? contact;
  List claimList = [];

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
    loadContactClaim(contact?.uuid);
  }

  void loadContactClaim(value) async {
    await getClaimsByContact(value).then((val) {
      claimList = val;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        contactClaimHeader(context),
        contactMenu(context, contact, widget.contactInfo, "claim"),
        contentTab(context, claimListDetails, null)
        /*Expanded(
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
                )))*/
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
                        addBtn(context, editDialog,
                            {'claim': ContactClaim(widget.contact!.uuid)}),
                        space(width: 10),
                        goPage(context, "Volver", const ContactsPage(),
                            Icons.arrow_circle_left_outlined),
                      ],
                    ),
                  ),
                ]),
          ),
        ]));
  }

  Widget claimListDetails(context, param) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: dataBody(context),
    );
  }

  void saveClaim(List args) async {
    ContactClaim claim = args[0];
    claim.save();
    loadContactClaim(contact!.uuid);
    Navigator.of(context).pop();
  }

  void editDialog(context, Map<String, dynamic> args) {
    ContactClaim claim = args["claim"];
    _editDialog(context, claim);
  }

  Future<void> _editDialog(context, claim) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar reclamación'),
          content: SingleChildScrollView(
              child: Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: claim.name,
                size: 220,
                fieldValue: (String val) {
                  claim.name = val;
                },
              )
            ]),
            /*space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Responsable:",
                initial: claim.manager,
                size: 220,
                fieldValue: (String val) {
                  claim.manager = val;
                },
              )
            ]),
            space(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: 220,
                  child: DateTimePicker(
                    labelText: 'Fecha:',
                    selectedDate: claim.date,
                    onSelectedDate: (DateTime date) {
                      claim.date = date;
                    },
                  )),
            ]),*/
          ])),
          actions: <Widget>[dialogsBtns(context, saveClaim, claim)],
        );
      },
    );
  }

  SingleChildScrollView dataBody(context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            sortColumnIndex: 0,
            showCheckboxColumn: false,
            columns: [
              DataColumn(
                  label: customText("Nombre", 14, bold: FontWeight.bold),
                  tooltip: "Nombre"),
              DataColumn(
                label: customText("Responsable", 14, bold: FontWeight.bold),
                tooltip: "Responsable",
              ),
              DataColumn(
                  label: customText("Fecha:", 14, bold: FontWeight.bold),
                  tooltip: "Fecha"),
              DataColumn(
                  label: Expanded(
                      child: customText("Acciones", 14,
                          bold: FontWeight.bold, align: TextAlign.end)),
                  tooltip: "Acciones"),
            ],
            rows: claimList
                .map(
                  (claim) => DataRow(cells: [
                    DataCell(Text(claim.name)),
                    DataCell(Text(claim.managerObj.name)),
                    DataCell(
                      Text(DateFormat('yyyy-MM-dd').format(claim.date)),
                    ),
                    DataCell(Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          goPageIcon(
                              context,
                              "Detalles",
                              Icons.info,
                              ContactClaimInfoPage(
                                  claim: claim, contact: contact)),
                          //editBtn(context, editDialog, {'claim': claim}),
                          removeBtn(
                              context, removeClaimDialog, {"claim": claim})
                        ]))
                  ]),
                )
                .toList(),
          ),
        ));
  }

  void removeClaimDialog(context, args) {
    customRemoveDialog(context, args["claim"], loadContactClaim, null);
  }

  /*Widget contactClaimList(context, contact) {
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
  }*/

  /* Widget claimHeaderRow(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
          children: [
            customText(claim.name, 14, bold: FontWeight.bold),
          ],
        ),
        Column(children: [
          customText(claim.manager, 14, bold: FontWeight.bold),
        ]),
        Column(children: [
          customText(DateFormat('yyyy-MM-dd').format(claim.date), 14,
              bold: FontWeight.bold),
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
  }*/

  /*Widget customDateField(context, dateController) {
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
  }*/
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

  // Widget addBtn(context) {
  //   return FilledButton(
  //     onPressed: () {
  //       _editDialog(context, null);
  //     },
  //     style: FilledButton.styleFrom(
  //       side: const BorderSide(width: 0, color: Color(0xffffffff)),
  //       backgroundColor: const Color(0xffffffff),
  //     ),
  //     child: const Column(
  //       children: [
  //         Icon(Icons.add, color: Colors.black54),
  //         SizedBox(height: 5),
  //         Text(
  //           "Añadir",
  //           style: TextStyle(color: Colors.black54, fontSize: 12),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
