// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/contacts_page.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const orgInvoicesPageTitle = "Seguimiento";
List invoiceList = [];

class OrganizationInvoicesPage extends StatefulWidget {
  final Organization? org;
  const OrganizationInvoicesPage({super.key, required this.org});

  @override
  State<OrganizationInvoicesPage> createState() =>
      _OrganizationInvoicesPageState();
}

class _OrganizationInvoicesPageState extends State<OrganizationInvoicesPage> {
  Organization? org;

  @override
  void initState() {
    super.initState();
    org = widget.org;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mainMenu(context),
        orgInvoicesHeader(context),
        //contactMenu(context, widget.contact, widget.contactInfo, "tracking"),
        contentTab(context, orgInvoicesList, null)
      ]),
    );
  }

/*-------------------------------------------------------------
                            TRACKINGS
-------------------------------------------------------------*/
  Widget orgInvoicesHeader(context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 300,
                    child: customText(org!.name, 22),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        /*addBtn(context, editDialog,
                            {'tracking': ContactTracking(contact!.uuid)}),
                        space(width: 10),*/
                        goPage(context, "Volver", const ContactsPage(),
                            Icons.arrow_circle_left_outlined),
                      ],
                    ),
                  ),
                ]),
          ),
        ]));
  }

  Widget orgInvoicesList(context, param) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: dataBody(context),
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
                  label: customText("Proyecto", 14, bold: FontWeight.bold),
                  tooltip: "Proyecto"),
              DataColumn(
                  label: customText("Partida", 14, bold: FontWeight.bold),
                  tooltip: "Partida"),
              DataColumn(
                  label: customText("Número", 14, bold: FontWeight.bold),
                  tooltip: "Número"),
              DataColumn(
                  label: customText("Código", 14, bold: FontWeight.bold),
                  tooltip: "Código"),
              DataColumn(
                  label: customText("Fecha", 14, bold: FontWeight.bold),
                  tooltip: "Fecha"),
              DataColumn(
                  label: customText("Base", 14, bold: FontWeight.bold),
                  tooltip: "Base"),
              DataColumn(
                  label: customText("%", 14, bold: FontWeight.bold),
                  tooltip: "%"),
              DataColumn(
                  label: Expanded(
                      child: customText("Acciones", 14,
                          bold: FontWeight.bold, align: TextAlign.end)),
                  tooltip: "Acciones"),
            ],
            rows: invoiceList
                .map(
                  (invoice) => DataRow(cells: [
                    DataCell(Text(invoice.projectObj.name)),
                    DataCell(Text(invoice.finnObj.name)),
                    DataCell(Text(invoice.number)),
                    DataCell(Text(invoice.code)),
                    DataCell(
                        Text(DateFormat('dd-MM-yyyy').format(invoice.date))),
                    DataCell(Text(invoice.base.toString())),
                    DataCell(Text(invoice.taxes.toString())),
                    const DataCell(Text("")),
                    /*DataCell(
                      Text(DateFormat('yyyy-MM-dd').format(tracking.date)),
                    ),
                    DataCell(Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          goPageIcon(
                              context,
                              "Detalles",
                              Icons.info,
                              ContactTrackingInfoPage(
                                  tracking: tracking, contact: contact)),
                          //editBtn(context, editDialog, {'claim': claim}),
                          removeBtn(context, removeTrackingDialog,
                              {"tracking": tracking})
                        ]))*/
                  ]),
                )
                .toList(),
          ),
        ));
  }
}
