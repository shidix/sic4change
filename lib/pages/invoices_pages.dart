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
  List<Invoice> invoices = [];
  List<TaxKind> taxes = [];

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
                  //mainMenu(context),
                  containerMenu,
                  mainHeader("", [
                    //boton para añadir factura
                    gralButton(context, listInvoices, null, "Facturas",
                        icon: Icons.euro),
                    space(width: 10),
                    gralButton(context, listTaxes, null, 'Impuestos',
                        icon: Icons.list),
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
    containerMenu = mainMenu(context);
    TaxKind.getAll().then((value) {
      taxes = value;
    });
    populateInvoices().then((value) {
      setState(() {
        containerInvoices = value;
      });
    });
    super.initState();
  }

  Future<void> listTaxes(context) async {
    if (taxes.isEmpty) {
      taxes = await TaxKind.getAll();
    }

    taxes.sort((a, b) => a.code.compareTo(b.code));
    DataTable table = DataTable(
      headingRowColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return headerListBgColor.withOpacity(0.5);
        }
        return headerListBgColor;
      }),
      columns: const <DataColumn>[
        DataColumn(label: Text('Código', style: headerListStyle)),
        DataColumn(
            label: Text(
          'Nombre',
          style: headerListStyle,
        )),
        DataColumn(label: Text('Porcentaje', style: headerListStyle)),
        DataColumn(label: Text('País', style: headerListStyle)),
        DataColumn(label: Text('Válido desde', style: headerListStyle)),
        DataColumn(label: Text('Válido hasta', style: headerListStyle)),
        DataColumn(label: Text('')),
      ],
      rows: taxes
          .map((e) => DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.grey.withOpacity(0.3);
                    }
                    if (taxes.indexOf(e).isEven) {
                      return Colors.grey.withOpacity(0.1);
                    }

                    return null;
                  }),
                  cells: [
                    DataCell(Text(e.code)),
                    DataCell(Text(e.name)),
                    DataCell(Text('${e.percentaje.toStringAsFixed(2)}%')),
                    DataCell(Text(e.country)),
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(e.from))),
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(e.to))),
                    DataCell(Row(
                      children: [
                        editBtn(context, addTaxKindDialog, e),
                        removeConfirmBtn(context, (e) {
                          e.delete().then((value) {
                            taxes.remove(e);
                            listTaxes(context);
                          });
                        }, e),
                      ],
                    )),
                  ]))
          .toList(),
    );

    containerInvoices = Column(children: [
      s4cTitleBar("Tipos de impuestos"),
      space(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          addBtnRow(context, addTaxKindDialog, null, text: "Añadir impuesto"),
        ],
      ),
      space(height: 10),
      SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Padding(padding: const EdgeInsets.all(10), child: table),
        ),
      ),
    ]);

    setState(() {
      containerInvoices = containerInvoices;
    });
  }

  Future<void> listInvoices(context) async {
    populateInvoices().then((value) {
      containerInvoices = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<Widget> populateInvoices() async {
    if (invoices.isEmpty) {
      invoices = await Invoice.all();
    }
    invoices.sort((a, b) => b.date.compareTo(a.date));
    List<SProject> projects = await SProject.all();
    List<Distribution> listDistr = await Distribution.all();
    for (var element in listDistr) {
      if (projects.where((e) => e.uuid == element.finn.project).isEmpty) {
        element.delete();
      }
    }
    listDistr.removeWhere((element) =>
        projects.where((e) => e.uuid == element.finn.project).isEmpty);

    List<InvoiceDistrib> distribs = await InvoiceDistrib.getByInvoice(invoices);
    for (var element in distribs) {
      if (listDistr.where((e) => e.uuid == element.distribution).isEmpty) {
        element.delete();
      }
    }
    distribs.removeWhere((element) =>
        listDistr.where((e) => e.uuid == element.distribution).isEmpty);

    Map<String, double> imputed = {};
    for (Invoice invoice in invoices) {
      imputed[invoice.uuid] = 0.0;
    }
    for (var element in distribs) {
      if (!imputed.keys.contains(element.invoice)) {
        imputed[element.invoice] = 0.0;
      }
      imputed[element.invoice] = imputed[element.invoice]! + element.percentaje;
    }

    DataTable table = DataTable(
        headingRowColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return headerListBgColor.withOpacity(0.5);
          }
          return headerListBgColor;
        }),
        columns: const [
          DataColumn(label: Text('Tracker', style: headerListStyle)),
          DataColumn(label: Text('Número', style: headerListStyle)),
          DataColumn(label: Text('Fecha', style: headerListStyle)),
          DataColumn(label: Text('Pago', style: headerListStyle)),
          DataColumn(label: Text('Proveedor', style: headerListStyle)),
          DataColumn(
              label: Text('Base',
                  style: headerListStyle, textAlign: TextAlign.right)),
          DataColumn(
              label: Text('TAX',
                  style: headerListStyle, textAlign: TextAlign.right)),
          DataColumn(
              label: Text('Tipo',
                  style: headerListStyle, textAlign: TextAlign.center)),
          DataColumn(
              label: Text('Total',
                  style: headerListStyle, textAlign: TextAlign.right)),
          DataColumn(
              label: Text('Imputado',
                  style: headerListStyle, textAlign: TextAlign.right)),
          DataColumn(label: Text('')),
        ],
        rows: [
          ...invoices.map((e) {
            return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.grey.withOpacity(0.3);
                  }
                  if (invoices.indexOf(e).isEven) {
                    return Colors.grey.withOpacity(0.1);
                  }

                  return null;
                }),
                cells: [
                  DataCell(Text(e.tracker)),
                  DataCell(Text(e.number)),
                  DataCell(
                      Text(DateFormat('dd/MM/yyyy').format(getDate(e.date)))),
                  DataCell(Text(
                      DateFormat('dd/MM/yyyy').format(getDate(e.paidDate)))),
                  DataCell(Text(e.provider)),
                  DataCell(Text(
                    toCurrency(e.base, e.currency),
                    textAlign: TextAlign.right,
                  )),
                  DataCell(Text(
                    toCurrency(e.taxes, e.currency),
                    textAlign: TextAlign.right,
                  )),
                  DataCell(Text(
                    (e.taxKind == null ? '--' : e.taxKind!),
                    textAlign: TextAlign.center,
                  )),
                  DataCell(Text(
                    toCurrency(e.total, e.currency),
                    textAlign: TextAlign.right,
                  )),
                  DataCell(Text(
                    '${imputed[e.uuid]!.toStringAsFixed(2)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: imputed[e.uuid]! <= 100.0
                            ? Colors.green
                            : Colors.red),
                  )),
                  DataCell(Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      iconBtn(context, viewProjects, e,
                          icon: Icons.list, text: 'Proyectos'),
                      editBtn(context, addInvoiceDialog, e),
                      removeConfirmBtn(context, removeInvoice, e),
                    ],
                  )),
                ]);
          })
        ]);

    return SelectionArea(
        child: SingleChildScrollView(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(children: [
                  s4cTitleBar("Listado de Facturas"),
                  const Text(
                      "Si no ves los iconos de las facturas, haz scroll horizontal para ver más datos",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.start),
                  space(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      addBtnRow(context, addInvoiceDialog, null,
                          text: "Añadir factura"),
                    ],
                  ),
                  space(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                          padding: const EdgeInsets.all(10), child: table),
                    ),
                  ),
                ]))));
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Añadir factura', context),
          content: InvoiceForm(
            key: null,
            existingInvoice: invoice,
            partner: null,
            tracker: tracker,
            taxes: taxes
                .where((element) => element.to.isAfter(DateTime.now()))
                .toList(),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            titlePadding: EdgeInsets.zero,
            title: s4cTitleBar('Imputaciones', context),
            content: const Text('No hay imputaciones para esta factura.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
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
      rows.add(const Divider());
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            titlePadding: EdgeInsets.zero,
            title: s4cTitleBar('Imputaciones', context),
            content: SingleChildScrollView(
              child: SizedBox(
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

  Future<void> addTaxKindDialog(context, [TaxKind? tax]) async {
    tax ??= TaxKind.getEmpty();
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          titlePadding: EdgeInsets.zero,
          title: s4cTitleBar('Tipo de impuesto', context),
          content: TaxKindForm(
            key: null,
            existingTaxKind: tax,
          ),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          if (taxes.contains(value)) {
            // Replace the existing tax
            taxes.remove(value);
          }
          taxes.add(value);
          listTaxes(context);
        }
      },
    );
  }
}
