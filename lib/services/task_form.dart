import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget taskForm(task, projectList, programmeList, statusList, profileList,
    contactList, orgList, setState) {
  List<KeyValue> selectedAssigned = [];
  if (task.assigned.isNotEmpty) {
    for (MultiSelectItem<KeyValue> item in profileList) {
      if (task.assigned.contains(item.value.key)) {
        selectedAssigned.add(item.value);
      }
    }
  }
  List<KeyValue> selectedReceivers = [];
  if (task.receivers.isNotEmpty) {
    for (MultiSelectItem<KeyValue> item in contactList) {
      if (task.receivers.contains(item.value.key)) {
        selectedReceivers.add(item.value);
      }
    }
  }
  List<KeyValue> selectedReceiversOrg = [];
  if (task.receiversOrg.isNotEmpty) {
    for (MultiSelectItem<KeyValue> item in orgList) {
      if (task.receiversOrg.contains(item.value.key)) {
        selectedReceiversOrg.add(item.value);
      }
    }
  }

  return SingleChildScrollView(
      child: Column(children: [
    Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomTextField(
          labelText: "Nombre",
          initial: task.name,
          size: 600,
          fieldValue: (String val) {
            task.name = val;
            //setState(() => task.comments = val);
          },
        )
      ]),
      space(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        customText("Pública", 15, textColor: fieldColor),
        FormField<bool>(builder: (FormFieldState<bool> state) {
          return Checkbox(
            value: task.public,
            onChanged: (bool? value) {
              task.public = value!;
              state.didChange(task.public);
            },
          );
        })
      ]),
      space(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        customText("Revisión", 15, textColor: fieldColor),
        FormField<bool>(builder: (FormFieldState<bool> state) {
          return Checkbox(
            value: task.revision,
            onChanged: (bool? value) {
              task.revision = value!;
              state.didChange(task.revision);
            },
          );
        })
      ])
    ]),
    space(height: 20),
    Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //customText("Proyecto:", 16, textColor: mainColor),
        CustomDropdown(
          labelText: 'Proyecto',
          size: 340,
          selected: task.projectObj.toKeyValue(),
          options: projectList,
          onSelectedOpt: (String val) {
            task.project = val;
          },
        ),
      ]),
      space(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomDropdown(
          labelText: 'Programa',
          size: 340,
          selected: task.programmeObj.toKeyValue(),
          options: programmeList,
          onSelectedOpt: (String val) {
            task.programme = val;
          },
        ),
      ]),
      space(width: 10),
    ]),
    space(height: 20),
    Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomTextField(
          labelText: "Documentos",
          initial: task.folder,
          size: 700,
          fieldValue: (String val) {
            task.folder = val;
            //setState(() => task.comments = val);
          },
        )
      ]),
    ]),
    space(height: 20),
    Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomTextField(
          labelText: "Descripción",
          initial: task.description,
          minLines: 2,
          maxLines: 999,
          size: 700,
          fieldValue: (String val) {
            task.description = val;
          },
        )
      ]),
    ]),
    /*space(height: 20),
    Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomTextField(
          labelText: "Comentarios",
          initial: task.comments,
          minLines: 2,
          maxLines: 999,
          size: 700,
          fieldValue: (String val) {
            task.comments = val;
          },
        )
      ]),
    ]),*/
    space(height: 20),
    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //customText("Estado:", 16, textColor: mainColor),
        CustomDropdown(
          labelText: 'Estado',
          size: 230,
          selected: task.statusObj.toKeyValue(),
          options: statusList,
          onSelectedOpt: (String val) {
            task.status = val;
          },
        ),
      ]),
      space(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //customText("Prioridad:", 16, textColor: mainColor),
        CustomDropdown(
          labelText: 'Prioridad',
          size: 230,
          selected: task.priorityKeyValue(),
          options: STask.priorityList(),
          onSelectedOpt: (String val) {
            task.priority = val;
          },
        ),
      ]),
      space(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomIntField(
          labelText: "Duración Horas",
          initial: task.duration,
          size: 110,
          fieldValue: (int val) {
            task.duration = val;
          },
        )
      ]),
      space(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomIntField(
          labelText: "Duración Min",
          initial: task.durationMin,
          size: 110,
          fieldValue: (int val) {
            task.durationMin = val;
          },
        )
      ]),
      /*space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Devolución:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Devolución',
                    size: 340,
                    selected: task.senderObj.toKeyValue(),
                    options: contactList,
                    onSelectedOpt: (String val) {
                      task.sender = val;
                    },
                  ),
                ]),*/
    ]),
    space(height: 20),
    Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 330,
            child: DateTimePicker(
              labelText: 'Acuerdo',
              selectedDate: task.dealDate,
              onSelectedDate: (DateTime date) {
                setState(() {
                  task.dealDate = date;
                });
              },
            )),
      ]),
      space(width: 20),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 330,
            child: DateTimePicker(
              labelText: 'Deadline',
              selectedDate: task.deadLineDate,
              onSelectedDate: (DateTime date) {
                setState(() {
                  task.deadLineDate = date;
                });
              },
            )),
      ]),
      /*space(width: 20),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 220,
            child: DateTimePicker(
              labelText: 'Nuevo deadline',
              selectedDate: task.newDeadLineDate,
              onSelectedDate: (DateTime date) {
                setState(() {
                  task.newDeadLineDate = date;
                });
              },
            )),
      ]),*/
      space(width: 20),
    ]),
    space(height: 20),
    // Row(children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MultiSelectDialogField(
        items: profileList,
        initialValue: selectedAssigned,
        title: customText("Ejecutores", 16),
        selectedColor: mainColor,
        decoration: multiSelectDecoration,
        buttonIcon: const Icon(
          Icons.arrow_drop_down,
          color: mainColor,
        ),
        //buttonText: customText("Seleccionar ejecutores", 16, textColor: mainColor),
        buttonText: const Text(
          "Ejecutores",
          style: TextStyle(
            color: mainColor,
            fontSize: 16,
          ),
        ),
        onConfirm: (results) {
          List<String> assigned = [];
          for (KeyValue kv in results) {
            assigned.add(kv.key);
          }
          task.assigned = assigned;
        },
      ),
    ]),
    space(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MultiSelectDialogField(
        items: contactList,
        initialValue: selectedReceivers,
        title: customText("Revisor/Supervisor", 16),
        selectedColor: mainColor,
        decoration: multiSelectDecoration,
        buttonIcon: const Icon(
          Icons.arrow_drop_down,
          color: mainColor,
        ),
        //buttonText: customText("Seleccionar ejecutores", 16, textColor: mainColor),
        buttonText: const Text(
          "Revisor/Supervisor",
          style: TextStyle(
            color: mainColor,
            fontSize: 16,
          ),
        ),
        onConfirm: (results) {
          List<String> receivers = [];
          for (KeyValue kv in results) {
            receivers.add(kv.key);
          }
          task.receivers = receivers;
        },
      ),
    ]),
    /*space(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MultiSelectDialogField(
        items: orgList,
        initialValue: selectedReceiversOrg,
        title: customText("Destinatarios Organizaciones", 16),
        selectedColor: mainColor,
        decoration: multiSelectDecoration,
        buttonIcon: const Icon(
          Icons.arrow_drop_down,
          color: mainColor,
        ),
        //buttonText: customText("Seleccionar ejecutores", 16, textColor: mainColor),
        buttonText: const Text(
          "Destinatarios organizaciones",
          style: TextStyle(
            color: mainColor,
            fontSize: 16,
          ),
        ),
        onConfirm: (results) {
          List<String> receiversOrg = [];
          for (KeyValue kv in results) {
            receiversOrg.add(kv.key);
          }
          task.receiversOrg = receiversOrg;
        },
      ),
    ]),*/
    // ]),
  ]));
}
