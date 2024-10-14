//import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/pages/contacts_page.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const orgInfoTitle = "Detalles del Contacto";
bool isLoading = true;

class OrganizationInfoPage extends StatefulWidget {
  final Organization? org;

  const OrganizationInfoPage({super.key, this.org});

  @override
  State<OrganizationInfoPage> createState() => _OrganizationInfoPageState();
}

class _OrganizationInfoPageState extends State<OrganizationInfoPage> {
  Organization? org;
  OrganizationBilling? orgBilling;
  Widget? orgInfoDetailsPanel;

  @override
  void initState() {
    super.initState();
    org = widget.org;
    orgInfoDetailsPanel = orgInfoDetails(context);
    //getOrganizationBilling(org);

    org!.getCountry().then((val) {
      org!.countryObj = val;
      setState(() {
        isLoading = false;
        orgInfoDetailsPanel = orgInfoDetails(context);
      });
    });

    org!.getBilling().then((val) {
      orgBilling = val;
      setState(() {
        isLoading = false;
        orgInfoDetailsPanel = orgInfoDetails(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          isLoading
              ? const Center(
                  child: Text(""),
                )
              : orgInfoHeader(context),
          /*isLoading
              //? contactInfoMenu(context)
              ? contactMenu(context, widget.org, "info")
              : const Center(
                  child: Text(""),
                ),*/
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xffdfdfdf),
                            width: 2,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: orgInfoDetailsPanel ?? Container(),
                        //child: projectInfoDetails(context, _project),
                      ))),
        ],
      ),
    );
  }

  Widget orgInfoHeader(context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: customText(org!.name, 22),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        addBtn(context, callEditOrgDialog,
                            {'org': org, 'billing': orgBilling},
                            text: "Editar", icon: Icons.edit),
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

/*--------------------------------------------------------------------*/
/*                           ORG INFO CARD                            */
/*--------------------------------------------------------------------*/
  Widget orgInfoDetails(context) {
    if (orgBilling == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                orgInfo(context),
                space(height: 20),
                customRowDivider(),
                space(height: 20),
                orgInfo2(context),
                space(height: 20),
                customRowDivider(),
                space(height: 20),
                orgBillingInfo(context),
              ],
            )));
  }

  Widget orgInfo(context) {
    return Table(
        //defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Código", 14, bold: FontWeight.bold),
            customText("Nombre", 14, bold: FontWeight.bold),
            /*       customText("Financiador", 14,
                bold: FontWeight.bold, align: TextAlign.center),
            customText("Socio", 14,
                bold: FontWeight.bold, align: TextAlign.center),
            customText("Público", 14,
                bold: FontWeight.bold, align: TextAlign.center),*/
            customText("País", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            space(height: 10),
            space(height: 10),
            /*space(height: 10),
            space(height: 10),
            space(height: 10),*/
            space(height: 10),
          ]),
          TableRow(children: [
            customText(org?.code, 16),
            customText(org?.name, 16),
            /*Icon(org?.isFinancier()),
            Icon(org?.isPartner()),
            Icon(org?.isPublic()),*/
            customText(org?.countryObj.name, 16),
          ])
        ]);
  }

  Widget orgInfo2(context) {
    return Table(
        //defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Financiador", 14, bold: FontWeight.bold),
            customText("Socio", 14, bold: FontWeight.bold),
            customText("Público", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            space(height: 10),
            space(height: 10),
            space(height: 10),
          ]),
          TableRow(children: [
            Row(children: [
              Icon(org?.isFinancier()),
            ]),
            Row(children: [
              Icon(org?.isPartner()),
            ]),
            Row(children: [
              Icon(org?.isPublic()),
            ]),
          ])
        ]);
  }

  Widget orgBillingInfo(context) {
    return Column(children: [
      Table(children: [
        TableRow(children: [
          customText("CIF", 14, bold: FontWeight.bold),
          customText("Nombre Facturación", 14, bold: FontWeight.bold),
          customText("Cuenta", 14,
              bold: FontWeight.bold, align: TextAlign.center),
          customText("", 14, bold: FontWeight.bold),
        ]),
        TableRow(children: [
          space(height: 10),
          space(height: 10),
          space(height: 10),
          space(height: 10),
        ]),
        TableRow(children: [
          customText(orgBilling?.cif, 16),
          customText(orgBilling?.name, 16),
          customText(orgBilling?.account, 16, align: TextAlign.center),
          customText("", 16),
        ])
      ]),
      space(height: 20),
      customRowDivider(),
      space(height: 20),
      Table(children: [
        TableRow(children: [
          customText("Dirección", 14, bold: FontWeight.bold),
        ]),
        TableRow(children: [
          space(height: 10),
        ]),
        TableRow(children: [
          customText(orgBilling?.address, 16),
        ])
      ])
    ]);
  }

/*-------------------------------------------------------------
                    ORGANIZATIONS EDIT
-------------------------------------------------------------*/
  void saveOrganization(List args) async {
    Organization org = args[0];
    OrganizationBilling billing = args[1];
    org.save();
    billing.save();
    setState(() {
      orgInfoDetailsPanel = orgInfoDetails(context);
    });

    Navigator.pop(context);
  }

  void callEditOrgDialog(context, Map<String, dynamic> args) async {
    Organization org = args["org"];
    OrganizationBilling billing = args["billing"];
    List<KeyValue> types = await getOrganizationsTypeHash();
    List<KeyValue> countries = await getCountriesHash();
    orgEditDialog(context, org, billing, types, countries);
  }

  Future<void> orgEditDialog(context, org, billing, types, countries) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Organización"),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Nombre",
                  initial: org.name,
                  size: 300,
                  fieldValue: (String val) {
                    org.name = val;
                  },
                )
              ]),
              space(width: 20),
              Column(children: [
                customText("Financiador", 12),
                FormField<bool>(builder: (FormFieldState<bool> state) {
                  return Checkbox(
                    value: org.financier,
                    onChanged: (bool? value) {
                      setState(() {
                        org.financier = value!;
                        state.didChange(org.financier);
                      });
                    },
                  );
                })
              ]),
              space(width: 20),
              Column(children: [
                customText("Socio", 12),
                FormField<bool>(builder: (FormFieldState<bool> state) {
                  return Checkbox(
                    value: org.partner,
                    onChanged: (bool? value) {
                      setState(() {
                        org.partner = value!;
                        state.didChange(org.partner);
                      });
                    },
                  );
                })
              ]),
              space(width: 20),
              Column(children: [
                customText("Público", 12),
                FormField<bool>(builder: (FormFieldState<bool> state) {
                  return Checkbox(
                    value: org.public,
                    onChanged: (bool? value) {
                      org.public = value!;
                      setState(() {
                        //org.public = value!;
                        state.didChange(org.public);
                      });
                    },
                  );
                })
              ]),
            ]),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'País',
                  size: 600,
                  selected: org.countryObj.toKeyValue(),
                  options: countries,
                  onSelectedOpt: (String val) {
                    org.country = val;
                    /*setState(() {
                    });*/
                  },
                ),
              ]),
            ]),
            /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdown(
                  labelText: 'Tipo',
                  size: 220,
                  selected: org.typeObj.toKeyValue(),
                  options: types,
                  onSelectedOpt: (String val) {
                    org.type = val;
                  },
                ),
              ]),*/

            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Nombre Facturación",
                  initial: billing!.name,
                  size: 300,
                  fieldValue: (String val) {
                    billing!.name = val;
                    //setState(() => org.name = val);
                  },
                )
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "CIF",
                  initial: billing.cif,
                  size: 280,
                  fieldValue: (String val) {
                    billing.cif = val;
                  },
                )
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Dirección",
                  initial: billing.address,
                  size: 600,
                  fieldValue: (String val) {
                    billing.address = val;
                  },
                )
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: "Número de cuenta",
                  initial: billing.account,
                  size: 600,
                  fieldValue: (String val) {
                    billing.account = val;
                  },
                )
              ]),
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns2(context, saveOrganization, [org, billing]),
          ],
        );
      },
    );
  }
}
