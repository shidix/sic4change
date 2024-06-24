import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/finn_form.dart';
import 'package:sic4change/services/models.dart';
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
              padding: const EdgeInsets.all(0),
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
        [1, const Text('Tracker', style: headerListStyle)],
        [1, const Text('Número', style: headerListStyle)],
        [1, const Text('Fecha', style: headerListStyle)],
        [1, const Text('Pago', style: headerListStyle)],
        [3, const Text('Proveedor', style: headerListStyle)],
        [
          1,
          const Text('Base', style: headerListStyle, textAlign: TextAlign.right)
        ],
        [
          1,
          const Text('TAX', style: headerListStyle, textAlign: TextAlign.right)
        ],
        [
          1,
          const Text('Tipo',
              style: headerListStyle, textAlign: TextAlign.center)
        ],
        [
          1,
          const Text('Total',
              style: headerListStyle, textAlign: TextAlign.right)
        ],
        [
          1,
          const Text('Imputado',
              style: headerListStyle, textAlign: TextAlign.right)
        ],
        [2, const Text('')],
      ]
          .map((List e) => Expanded(
              flex: e[0],
              child: Container(padding: const EdgeInsets.all(5), child: e[1])))
          .toList(),
    );

    List<Invoice> invoices = await Invoice.all();
    List<InvoiceDistrib> distribs = await InvoiceDistrib.getByInvoice(invoices);
    Map<String, double> distribsMap = {};
    for (var element in distribs) {
      if (!distribsMap.keys.contains(element.invoice)) {
        distribsMap[element.invoice] = 0.0;
      }
      distribsMap[element.invoice] =
          distribsMap[element.invoice]! + element.percentaje;
    }

    Row fromInvoice(Invoice invoice) {
      double imputed = distribsMap.keys.contains(invoice.uuid)
          ? distribsMap[invoice.uuid]!
          : 0.0;
      return Row(
        children: [
          [1, Text(invoice.tracker)],
          [1, Text(invoice.number)],
          [1, Text(DateFormat('dd/MM/yyyy').format(getDate(invoice.date)))],
          [1, Text(DateFormat('dd/MM/yyyy').format(getDate(invoice.paidDate)))],
          [3, Text(invoice.provider)],
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
              (invoice.taxKind == null ? '--' : invoice.taxKind!.name),
              textAlign: TextAlign.center,
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
            Text(
              '${imputed.toStringAsFixed(2)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: imputed <= 100.0 ? Colors.green : Colors.red),
            )
          ],
          [
            2,
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              iconBtn(context, viewProjects, invoice,
                  icon: Icons.list, text: 'Proyectos'),
              editBtn(context, addInvoiceDialog, invoice),
              removeConfirmBtn(context, removeInvoice, invoice),
            ])
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

    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Column(children: widgetInvoices)));
  }

  Future<Invoice?> addInvoiceDialog(context, [Invoice? invoice]) async {
    String tracker;
    if (invoice == null) {
      tracker = await Invoice.newTracker();
    } else {
      tracker = invoice.tracker;
    }
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

  Future<void> removeInvoice(context, Invoice invoice) async {
    invoice.delete().then((value) {
      if (value) {
        populateInvoices().then((value) {
          setState(() {
            containerInvoices = value;
          });
        });
      }
    });
  }

  Future<void> viewProjects(context, Invoice invoice) async {
    List<InvoiceDistrib> imputations =
        await InvoiceDistrib.getByInvoice(invoice);
    if (imputations.isEmpty) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: s4cTitleBar('Imputaciones', context),
            content: Text('No hay imputaciones para esta factura.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } else {
      List<Distribution> distribs = await Distribution.listByUuid(
          imputations.map((e) => e.distribution).toList());
      List<SProject> projects = await SProject.listByUuid(
          distribs.map((e) => e.finn.project).toList());

      Widget headerRow = Container(
        color: Colors.green.shade50,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Row(
              children: [
                [1, const Text('Proyecto', style: headerListStyle)],
                [1, const Text('Porcentaje', style: headerListStyle)],
              ]
                  .map((List e) => Expanded(
                      flex: e[0],
                      child: Container(
                          padding: const EdgeInsets.all(5), child: e[1])))
                  .toList(),
            )),
      );

      List<Widget> rows = [headerRow];
      rows.addAll(List.generate(projects.length, (index) {
        double imputed = imputations[index].percentaje;
        return Container(
            color: !index.isEven ? Colors.grey.shade100 : Colors.white,
            child: Row(
              children: [
                [1, Text(projects[index].name)],
                [1, Text('${imputed.toStringAsFixed(2)}%')],
              ]
                  .map((List e) => Expanded(
                      flex: e[0],
                      child: Container(
                          padding: const EdgeInsets.all(5), child: e[1])))
                  .toList(),
            ));
      }));
      rows.add(Divider());
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: s4cTitleBar('Imputaciones', context),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  children: rows,
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
