import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/project_info_menu_widget.dart';

const reformulationTitle = "Detalles del Proyecto";
//SProject? _project;
List refList = [];

class ReformulationPage extends StatefulWidget {
  final SProject? project;
  const ReformulationPage({super.key, this.project});

  @override
  State<ReformulationPage> createState() => _ReformulationPageState();
}

class _ReformulationPageState extends State<ReformulationPage> {
  SProject? project;

  void loadReformulations() async {
    await getReformulationsByProject(project!.uuid).then((val) {
      refList = val;
    });
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    project = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          projectInfoHeader(context, project),
          profileMenu(context, project, "reformulation"),
          contentTab(context, reformulationList, null)
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
                    customText("En ejecución:", 16, textColor: Colors.green),
                    space(height: 5),
                    customLinearPercent(context, 2.3, 0.8, Colors.green),
                  ],
                ),
                space(width: 50),
                /* VerticalDivider(
                  width: 10,
                  color: Colors.grey,
                ),*/
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Presupuesto total:   ${project.budget} €", 16),
                  space(height: 5),
                  customLinearPercent(context, 2.3, 0.8, Colors.blue),
                ]),
              ],
            ),
          ),
          space(height: 20)
        ]));
  }

  /*Widget projectInfoMenu(context, project) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          menuTab(context, "Datos generales", "/project_info",
              {'project': project}),
          menuTabSelect(context, "Comunicación con el financiador",
              "/project_reformulation", {'project': project}),
        ],
      ),
    );
  }*/

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
                    );
                  });
            } else
              return const Text("");
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
                customText(
                    'Comunicación con el financiador: ${ref.financierObj.name}',
                    16,
                    textColor: const Color(0xff00809a)),
                reformulationRowOptions(context, ref),
              ],
            ),
            space(height: 20),
            customText("Reformulaciones", 14, bold: FontWeight.bold),
            space(height: 5),
            customText(ref.reformulation, 14),
            space(height: 10),
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
            customText(ref.request, 14),
            /*Text(
          'Fuente',
          style: TextStyle(color: Colors.blueGrey, fontSize: 16),
        ),*/
          ],
        ));
  }

  Widget reformulationRowOptions(context, ref) {
    return Row(children: [
      /*IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Editar',
          onPressed: () async {
            callEditDialog(context, ref);
          }),
      IconButton(
          icon: const Icon(Icons.remove_circle),
          tooltip: 'Borrar',
          onPressed: () {
            removeReformulationDialog(context, ref);
          }),*/
      editBtn(context, callEditDialog, {'ref': ref}),
      removeBtn(context, removeReformulationDialog, {"ref": ref})
    ]);
  }

/*-------------------------------------------------------------
                       EDIT REFORMULATION
-------------------------------------------------------------*/
  /*Widget addBtn2(context) {
    return FilledButton(
      onPressed: () {
        callEditDialog(context, null);
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
  }*/

  void saveReformulation(List args) async {
    Reformulation ref = args[0];
    ref.save();
    loadReformulations();

    Navigator.pop(context);
  }

  void callEditDialog(context, args) async {
    Reformulation ref = args["ref"];
    List<KeyValue> financierList = [];

    await getFinanciers().then((value) async {
      for (Financier item in value) {
        financierList.add(item.toKeyValue());
      }
      _editDialog(context, ref, financierList);
    });
  }

  Future<void> _editDialog(context, ref, financierList) {
    /*TextEditingController financierController = TextEditingController(text: "");
    TextEditingController reformulationController =
        TextEditingController(text: "");
    TextEditingController correctionController =
        TextEditingController(text: "");
    TextEditingController requestController = TextEditingController(text: "");
    KeyValue fin = KeyValue("", "");*/

    /*if (ref != null) {
      financierController = TextEditingController(text: ref.financier);
      reformulationController = TextEditingController(text: ref.reformulation);
      correctionController = TextEditingController(text: ref.correction);
      requestController = TextEditingController(text: ref.request);
      Financier financier = ref.financierObj;
      fin = financier.toKeyValue();
    }*/

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: (ref != null)
              ? s4cTitleBar("Editar reformualción")
              : s4cTitleBar("Añadir reformualción"),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /*customText("Financiador:", 16, textColor: Colors.blue),
                customDropdownField(financierController, financierList, fin,
                    "Selecciona financiador"),*/
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
                /*customText("Reformulaciones:", 16, textColor: Colors.blue),
                customTextField(reformulationController, "Reformulaciones"),*/
                CustomTextField(
                  labelText: 'Reformulaciones',
                  size: 220,
                  initial: ref.reformulation,
                  fieldValue: (String val) {
                    ref.reformulation = val;
                    /*setState(() {
                        proj.budget = val;
                      });*/
                  },
                ),
              ]),
              space(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /*customText("Subsanación:", 16, textColor: Colors.blue),
                customTextField(correctionController, "Subsanación"),*/
                CustomTextField(
                  labelText: 'Subsanación',
                  size: 220,
                  initial: ref.correction,
                  fieldValue: (String val) {
                    ref.correction = val;
                    /*setState(() {
                        proj.budget = val;
                      });*/
                  },
                ),
              ]),
              space(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                /*customText("Solicitud de subcontratación:", 16,
                    textColor: Colors.blue),
                customTextField(
                    requestController, "Solicitud de subcontratación"),*/
                CustomTextField(
                  labelText: 'Solicitud de subcontratación',
                  size: 220,
                  initial: ref.request,
                  fieldValue: (String val) {
                    ref.request = val;
                    /*setState(() {
                        proj.budget = val;
                      });*/
                  },
                ),
              ])
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveReformulation, ref),
            /*actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                saveReformulation(
                    context,
                    ref,
                    financierController.text,
                    reformulationController.text,
                    correctionController.text,
                    requestController.text);
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),*/
          ],
        );
      },
    );
  }

  /*void saveReformulation(
    context,
    ref,
    financier,
    reformulation,
    correction,
    request,
  ) async {
    ref ??= Reformulation(project!.uuid);
    ref.financier = financier;
    ref.reformulation = reformulation;
    ref.correction = correction;
    ref.request = request;
    ref.save();
    loadReformulations();
    Navigator.pop(context);
  }*/

  void removeReformulationDialog(context, args) {
    customRemoveDialog(context, args["ref"], loadReformulations, null);
  }

  /*Future<void> removeReformulationDialog(context, ref) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Borrar reformulación'),
          content: const SingleChildScrollView(
            child: Text("Esta seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Borrar'),
              onPressed: () async {
                ref.delete();
                loadReformulations();
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
}
