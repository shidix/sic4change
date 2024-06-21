import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/finn_form.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Widget containerInvoices = Container();
  Widget containerMenu = Container();
  Widget containerHeader = Container();
  Widget containerFooter = Container();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  mainMenu(context),
                  mainHeader("Facturas", [
                    //boton para añadir factura
                    addBtn(context, addInvoiceDialog, null,
                        text: "Añadir factura")
                  ]),
                  containerInvoices,
                  const Divider(),
                  footer(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    populateInvoices().then((value) {
      setState(() {
        containerInvoices = value;
      });
    });
    super.initState();
  }

  Future<Widget> populateInvoices() async {
    Row rowHeader = Row(
      children: [
        [
          1,
          const Text('Tracker', style: TextStyle(fontWeight: FontWeight.bold))
        ],
        [
          1,
          const Text('Número', style: TextStyle(fontWeight: FontWeight.bold))
        ],
        [1, const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))],
        [
          4,
          const Text('Proveedor', style: TextStyle(fontWeight: FontWeight.bold))
        ],
        [1, const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))],
        [
          1,
          const Text('Base',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right)
        ],
        [
          1,
          const Text('TAX',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right)
        ],
        [
          1,
          const Text('Total',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right)
        ],
        [1, const Text('')],
      ]
          .map((List e) => Expanded(
              flex: e[0],
              child: Padding(padding: const EdgeInsets.all(5), child: e[1])))
          .toList(),
    );

    List<Invoice> invoices = await Invoice.all();

    Row fromInvoice(Invoice invoice) {
      return Row(
        children: [
          [1, Text(invoice.tracker)],
          [1, Text(invoice.number)],
          [1, Text(DateFormat('dd/MM/yyyy').format(getDate(invoice.date)))],
          [4, Text(invoice.provider)],
          [1, Text(DateFormat('dd/MM/yyyy').format(getDate(invoice.paidDate)))],
          [
            1,
            Text(
              toCurrency(invoice.base, invoice.currency),
              textAlign: TextAlign.right,
            )
          ],
          [
            1,
            Text(
              toCurrency(invoice.taxes, invoice.currency),
              textAlign: TextAlign.right,
            )
          ],
          [
            1,
            Text(
              toCurrency(invoice.total, invoice.currency),
              textAlign: TextAlign.right,
            )
          ],
          [
            1,
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [editBtn(context, addInvoiceDialog, invoice)])
          ]
        ]
            .map((List e) => Expanded(
                flex: e[0],
                child: Padding(padding: const EdgeInsets.all(5), child: e[1])))
            .toList(),
      );
    }

    List<Widget> widgetInvoices = [
      Container(
          color: Colors.green.shade50,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: rowHeader))
    ];
    widgetInvoices.addAll(List.generate(invoices.length, (index) {
      return Container(
        color: !index.isEven ? Colors.grey.shade100 : Colors.white,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: fromInvoice(invoices[index])),
      );
    }));

    return SingleChildScrollView(child: Column(children: widgetInvoices));
  }

  Future<Invoice?> addInvoiceDialog(context, Invoice invoice) async {
    String tracker = await Invoice.newTracker();
    return showDialog<Invoice>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir factura', context),
          content: InvoiceForm(
            key: null,
            existingInvoice: invoice,
            partner: null,
            tracker: tracker,
          ),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          populateInvoices().then((value) {
            setState(() {
              containerInvoices = value;
            });
          });
        }
        return null;
      },
    );
  }
}
