//import 'dart:collection';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/contacts_page.dart';
import 'package:sic4change/pages/index.dart';
import 'package:sic4change/services/form_organization.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:sic4change/services/models_profile.dart';
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
  // OrganizationBilling? orgBilling;
  Widget? orgInfoDetailsPanel;
  List<Country> countriesList = [];
  ProfileProvider? _provider;
  Organization? _currentOrg;
  Profile? _currentProfile;
  List<Organization> organizationsList = [];

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<ProfileProvider>(context, listen: false);
    _provider?.addListener(() {
      if (!mounted) return;
      _currentOrg = _provider?.organization;
      _currentProfile = _provider?.profile;
      if (_currentOrg == null || _currentProfile == null) {
        _provider?.loadProfile();
      }
      setState(() {
        _currentOrg = _provider?.organization;
        _currentProfile = _provider?.profile;
      });
    });

    _currentOrg = _provider?.organization;
    _currentProfile = _provider?.profile;
    if (_currentOrg == null || _currentProfile == null) {
      _provider?.loadProfile();
    }

    Organization.getOrganizations().then((val) {
      organizationsList = val;
    });

    Country.getAll().then((val) {
      countriesList = val;
    });
    org = widget.org;
    orgInfoDetailsPanel = Container();
    //getOrganizationBilling(org);

    org!.getCountry().then((val) {
      org!.countryObj = val;
      setState(() {
        isLoading = false;
        orgInfoDetailsPanel = orgInfoDetails(context);
      });
    });

    // org!.getBilling().then((val) {
    //   orgBilling = val;
    //   setState(() {
    //     isLoading = false;
    //     orgInfoDetailsPanel = orgInfoDetails(context);
    //   });
    // });
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
                        addBtn(context, callEditOrgDialog, {'org': org},
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
    if (org == null) {
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
    if (countriesList.any((element) => element.uuid == org!.country)) {
      org!.countryObj =
          countriesList.firstWhere((element) => element.uuid == org!.country);
    } else {
      org!.country = countriesList.first.uuid;
      org!.countryObj = countriesList.first;
      org!.save();
    }

    return Table(
        //defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            customText("Código", 14, bold: FontWeight.bold),
            customText("Nombre", 14, bold: FontWeight.bold),
            customText("País", 14, bold: FontWeight.bold),
            customText("Dominio", 14, bold: FontWeight.bold),
          ]),
          TableRow(children: [
            space(height: 10),
            space(height: 10),
            /*space(height: 10),
            space(height: 10),
            space(height: 10),*/
            space(height: 10),
            space(height: 10),
          ]),
          TableRow(children: [
            customText(org?.code, 16),
            customText(org?.name, 16),
            /*Icon(org?.isFinancier()),
            Icon(org?.isPartner()),
            Icon(org?.isPublic()),*/
            customText(org?.countryObj?.name, 16),
            customText(org?.domain, 16),
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
          customText(org?.cif, 16),
          customText(org?.billingName, 16),
          customText(org?.account, 16, align: TextAlign.center),
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
          customText(org?.address, 16),
        ])
      ])
    ]);
  }

/*-------------------------------------------------------------
                    ORGANIZATIONS EDIT
-------------------------------------------------------------*/
  void saveOrganization(List args) async {
    Organization org = args[0];
    // OrganizationBilling billing = args[1];
    org.save();
    // billing.save();
    setState(() {
      orgInfoDetailsPanel = orgInfoDetails(context);
    });

    Navigator.pop(context);
  }

  void callEditOrgDialog(context, Map<String, dynamic> args) async {
    Organization org = args["org"];
    if ((_currentOrg?.id != org.id) ||
        ([Profile.ADMIN, Profile.RRHH].contains(_currentProfile?.mainRole))) {
      // OrganizationBilling billing = args["billing"];
      List<KeyValue> types = await OrganizationType.getOrganizationsTypeHash();
      // List<Country> countriesList = await Country.getAll();
      List<KeyValue> countries = await Country.getCountriesHash(null);
      if (countriesList.any((element) => element.uuid == org.country)) {
        org.countryObj =
            countriesList.firstWhere((element) => element.uuid == org.country);
      } else {
        org.country = countriesList.first.uuid;
        org.countryObj = countriesList.first;
        org.save();
      }

      orgEditDialog(context, org, types, countries);
    } else {
      // Show alert informing that the user cannot edit this organizarion
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "No tienes permisos para editar esta organización porque es a la que perteneces.\n Si deseas realizar cambios, contacta a un administrador."),
            actions: <Widget>[
              TextButton(
                child: Text("Cerrar"),
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

  Future<void> orgEditDialog(context, org, types, countries) {
    // Check if country in countries

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: s4cTitleBar("Organización"),
            content: SizedBox(
              width: min(MediaQuery.of(context).size.width * 0.8, 800),
              child: SingleChildScrollView(
                  child: OrganizationForm(
                selectedOrganization: org,
                otherOrganizations: organizationsList
                    .where((element) => element.uuid != org.uuid)
                    .toList(),
                onSubmit: (formData) {
                  // Handle form submission
                  if (mounted) {
                    setState(() {
                      if (org.id == currentOrganization?.id) {
                        // _currentOrg = org;
                        _provider?.organization = org;
                      }
                      orgInfoDetailsPanel = orgInfoDetails(context);
                    });
                  }
                },
                countries: countriesList,
              )),
            ));
      },
    );
  }
}
