import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/documents_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/project_info_menu_widget.dart';

const reformulationTitle = "Detalles del Proyecto";
//SProject? _project;
List refList = [];
Widget? _mainMenu;
bool refLoading = false;

class ReformulationPage extends StatefulWidget {
  final SProject? project;
  const ReformulationPage({super.key, this.project});

  @override
  State<ReformulationPage> createState() => _ReformulationPageState();
}

class _ReformulationPageState extends State<ReformulationPage> {
  SProject? project;

  void loadReformulations() async {
    setState(() {
      refLoading = true;
    });
    await getReformulationsByProject(project!.uuid).then((val) {
      refList = val;
      setState(() {
        refLoading = false;
      });
      for (Reformulation item in refList) {
        item.loadObjs();
      }
    });
  }

  @override
  initState() {
    super.initState();
    project = widget.project;
    _mainMenu = mainMenu(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //mainMenu(context),
          _mainMenu!,
          projectInfoHeader(context, project),
          profileMenu(context, project, "reformulation"),
          refLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : contentTab(context, reformulationList, null)
        ],
      ),
    );
  }

  Widget projectInfoHeader(context, project) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(project.name, style: const TextStyle(fontSize: 20)),
            Container(
                padding: const EdgeInsets.all(10),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  addBtn(context, callEditDialog,
                      {"ref": Reformulation(project.uuid)}),
                  space(width: 10),
                  returnBtn(context),
                ]))
          ]),
          space(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText("En ejecución:", 16),
                    space(height: 5),
                    customLinearPercent(context, 2.3, 0.8, percentBarPrimary),
                  ],
                ),
                space(width: 50),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Presupuesto total:   ${project!.budget} €", 16),
                  space(height: 5),
                  customLinearPercent(context, 2.3, 0.8, blueColor),
                ]),
              ],
            ),
          ),
          space(height: 20)
        ]));
  }

/*-------------------------------------------------------------
                       REFORMULATION
-------------------------------------------------------------*/
  Widget reformulationList(context, args) {
    return FutureBuilder(
        future: getReformulationsByProject(project!.uuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            refList = snapshot.data!;
            if (refList.isNotEmpty) {
              /*return SizedBox(
                width: double.infinity,
                child: DataTable(
                  sortColumnIndex: 0,
                  showCheckboxColumn: false,
                  //headingRowHeight: 0,
                  columns: [
                    DataColumn(
                        label: customText("Financiador", 14,
                            bold: FontWeight.bold)),
                    DataColumn(
                        label: customText("Descripción", 14,
                            bold: FontWeight.bold)),
                    DataColumn(
                        label: customText("Estado", 14, bold: FontWeight.bold)),
                    DataColumn(
                      label: customText("", 14),
                    ),
                  ],
                  rows: refList
                      .map(
                        (ref) => DataRow(cells: [
                          DataCell(
                            customText(ref.financierObj.name, 14),
                          ),
                          DataCell(
                            customText(ref.description, 14),
                          ),
                          DataCell(
                            customText(ref.statusObj.name, 14),
                          ),
                          DataCell(Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                reformulationRowOptions(context, ref),
                                /*removeBtn(context, removeDateAuditDialog,
                                  {"dateAudit": date}),*/
                              ]))
                        ]),

                      )
                      .toList(),
                ),
              );*/
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: refList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Reformulation ref = refList[index];
                    return Container(
                      //height: 400,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Color(0xffdfdfdf), width: 2)),
                      ),
                      child: reformulationRow(context, ref),
                      /*child: customCollapse(
                          context,
                          "Comunicación con el financiador: ${ref.financierObj.name}",
                          reformulationDetails,
                          ref,
                          expanded: false),*/
                    );
                  });
            } else {
              return const Text("");
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget reformulationRow(context, ref) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    customText('Financiador: ', 14, bold: FontWeight.bold),
                    space(width: 5),
                    customText('${ref.financierObj.name}', 14),
                  ],
                ),
                Row(
                  children: [
                    customText('Tipología: ', 14, bold: FontWeight.bold),
                    customText('${ref.typeObj.name}', 14),
                  ],
                ),
                Row(
                  children: [
                    customText('Estado: ', 14, bold: FontWeight.bold),
                    customText('${ref.statusObj.name}', 14),
                  ],
                ),
                Row(
                  children: [
                    customText('Presentación: ', 14, bold: FontWeight.bold),
                    customText(
                        DateFormat("dd-MM-yyyy").format(ref.presentationDate),
                        14),
                  ],
                ),
                ref.statusObj.uuid == "2"
                    ? Row(
                        children: [
                          customText('Resolución: ', 14, bold: FontWeight.bold),
                          customText(
                              DateFormat("dd-MM-yyyy")
                                  .format(ref.resolutionDate),
                              14),
                        ],
                      )
                    : Container(),
                reformulationRowOptions(context, ref),
              ],
            ),
            Row(
              children: [
                customText('Descripción: ', 14, bold: FontWeight.bold),
                space(width: 5),
                customText('${ref.description}', 14),
              ],
            ),

            /*space(height: 10),
            customRowDivider(),
            space(height: 10),
            customText("Subsanación", 14, bold: FontWeight.bold),
            space(height: 5),
            customText(ref.correction, 14),
            space(height: 10),
            customRowDivider(),
            space(height: 10),
            customText("Solicitud de subcontratación", 14,
                bold: FontWeight.bold),
            space(height: 5),
            customText(ref.request, 14),*/
            /*Text(
          'Fuente',
          style: TextStyle(color: Colors.blueGrey, fontSize: 16),
        ),*/
          ],
        ));
  }

  Widget reformulationRowOptions(context, ref) {
    return Row(children: [
      /*customCollapse(context, "Resultados", reformulationDetails, ref,
          expanded: false),*/
      goPageIcon(context, "Documentos", Icons.document_scanner_outlined,
          DocumentsPage(currentFolder: ref.folderObj)),
      editBtn(context, callEditDialog, {'ref': ref}),
      removeBtn(context, removeReformulationDialog, {"ref": ref})
    ]);
  }

  /*Widget reformulationDetails(context, ref) {
    return Row(
      children: [
        customText("Fecha de presentación", 14),
        space(width: 10),
        customText(DateFormat("dd-MM-yyyy").format(ref.presentationDate), 14),
        space(width: 10),
        customText("Fecha de resolución", 14),
        space(width: 10),
        customText(DateFormat("dd-MM-yyyy").format(ref.resolutionDate), 14),
        space(width: 10),
        customText("Tipo de comunicación", 14),
        space(width: 10),
        customText(ref.financierObj.name, 14)
      ],
    );
  }*/

/*-------------------------------------------------------------
                       EDIT REFORMULATION
-------------------------------------------------------------*/
  void saveReformulation(List args) async {
    Reformulation ref = args[0];
    ref.save();
    //ref.getFolder();
    loadReformulations();

    Navigator.pop(context);
  }

  void callEditDialog(context, args) async {
    Reformulation ref = args["ref"];
    //List<KeyValue> financierList = [];

    /*await getOrganizations().then((value) async {
      for (Organization item in value) {
        financierList.add(item.toKeyValue());
      }
      _editDialog(context, ref, financierList);
    });*/
    //List<KeyValue> financierList = await getFinanciersHash();
    List<KeyValue> financierList = [];
    SProject project = await ref.getProject();
    List<Organization> finList = await project.getFinanciers();
    for (Organization fin in finList) {
      financierList.add(fin.toKeyValue());
    }
    List<KeyValue> typeList = await getReformulationTypesHash();
    List<KeyValue> statusList = await getReformulationStatusHash();
    _editDialog(context, ref, financierList, typeList, statusList);
  }

  Future<void> _editDialog(context, ref, financierList, typeList, statusList) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: (ref != null)
              ? s4cTitleBar("Editar comunicación")
              : s4cTitleBar("Añadir comunicación"),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                child: Column(children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Financiador',
                    size: 220,
                    selected: ref.financierObj.toKeyValue(),
                    options: financierList,
                    onSelectedOpt: (String val) {
                      ref.financier = val;
                      /*setState(() {
                        proj.type = val;
                      });*/
                    },
                  ),
                ]),
                space(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Tipo',
                    size: 210,
                    selected: ref.typeObj.toKeyValue(),
                    options: typeList,
                    onSelectedOpt: (String val) {
                      ref.type = val;
                    },
                  ),
                ]),
                space(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomDropdown(
                    labelText: 'Estado',
                    size: 210,
                    selected: ref.statusObj.toKeyValue(),
                    options: statusList,
                    onSelectedOpt: (String val) {
                      ref.status = val;
                    },
                  ),
                ]),
              ]),
              space(height: 10),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 320,
                      child: DateTimePicker(
                        labelText: 'Presentación',
                        selectedDate: ref.getPresentation(),
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            ref.presentationDate = date;
                          });
                        },
                      )),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 320,
                      child: DateTimePicker(
                        labelText: 'Resolución',
                        selectedDate: ref.getResolution(),
                        onSelectedDate: (DateTime date) {
                          setState(() {
                            ref.resolutionDate = date;
                          });
                        },
                      )),
                ]),
              ]),
              space(height: 10),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: 'Descripción',
                    size: 660,
                    initial: ref.description,
                    fieldValue: (String val) {
                      ref.description = val;
                    },
                  ),
                ]),
                /*space(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: 'Subsanación',
                  size: 220,
                  initial: ref.correction,
                  fieldValue: (String val) {
                    ref.correction = val;
                  },
                ),
              ]),
              space(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomTextField(
                  labelText: 'Solicitud de subcontratación',
                  size: 220,
                  initial: ref.request,
                  fieldValue: (String val) {
                    ref.request = val;
                  },
                ),
              ])*/
              ]),
            ]));
          }),
          actions: <Widget>[
            dialogsBtns(context, saveReformulation, ref),
          ],
        );
      },
    );
  }

  void removeReformulationDialog(context, args) {
    customRemoveDialog(context, args["ref"], loadReformulations, null);
  }
}
