import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sic4change/pages/documents_page.dart';
import 'package:sic4change/pages/tasks_user_page.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/services/task_form.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/task_widgets.dart';

const taskInfoTitle = "Detalles de la tarea";

class TaskInfoPage extends StatefulWidget {
  final STask? task;
  const TaskInfoPage({super.key, this.task});

  @override
  State<TaskInfoPage> createState() => _TaskInfoPageState();
}

class _TaskInfoPageState extends State<TaskInfoPage> {
  STask? task;
  var user;
  List<TasksComments> taskComments = [];
  List<Organization> orgListCache = [];
  List<Contact> contactListCache = [];
  List<Profile> profileListCache = [];
  List<SProject> projectListCache = [];
  List<TasksStatus> statusListCache = [];

  void updateObjects() {
    task!.assignedObj = profileListCache
        .where((prof) => task!.assigned.contains(prof.email))
        .toList();
    task!.receiversOrgObj = orgListCache
        .where((org) => task!.receiversOrg.contains(org.uuid))
        .toList();
    task!.receiversObj = contactListCache
        .where((contact) => task!.receivers.contains(contact.uuid))
        .toList();
    task!.projectObj =
        projectListCache.firstWhere((proj) => proj.uuid == task!.project);
    task!.statusObj =
        statusListCache.firstWhere((status) => status.uuid == task!.status);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  initState() {
    super.initState();
    task = widget.task;
    user = FirebaseAuth.instance.currentUser!;
    Profile.getProfiles().then((value) {
      profileListCache = value;
      task!.assignedObj = profileListCache
          .where((prof) => task!.assigned.contains(prof.email))
          .toList();
      if (mounted) {
        setState(() {});
      }
    });
    Organization.getOrganizations().then((value) {
      orgListCache = value;
      task!.receiversOrgObj = orgListCache
          .where((org) => task!.receiversOrg.contains(org.uuid))
          .toList();
      if (mounted) {
        setState(() {});
      }
    });
    Contact.getContacts().then((value) {
      contactListCache = value;

      task!.receiversObj = contactListCache
          .where((contact) => task!.receivers.contains(contact.uuid))
          .toList();
      if (mounted) {
        setState(() {});
      }
      SProject.getProjects().then((value) {
        projectListCache = value;
        task!.projectObj =
            projectListCache.firstWhere((proj) => proj.uuid == task!.project);
        if (mounted) {
          setState(() {});
        }
      });
      TasksStatus.getTasksStatus().then((value) {
        statusListCache = value;
        task!.statusObj =
            statusListCache.firstWhere((status) => status.uuid == task!.status);
        if (mounted) {
          setState(() {});
        }
      });
    });
    TasksComments.getCommentsByTasks(task!.uuid).then((value) {
      taskComments = value;
    });
    task!.getFolder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context, "/tasks_user"),
          projectTaskHeader(context, task),
          space(height: 20),
          contentTab(context, taskInfoDetails, null)
        ],
      ),
    );
  }

  Widget projectTaskHeader(context, task) {
    return Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customText(task.name, 22),
                  customTextStatus(task.statusObj.name, size: 16),
                  // Text(task.statusObj.name,
                  //     style: TextStyle(
                  //         fontSize: 16,
                  //         color: getStatusColor(task.statusObj.name))),
                  Row(children: [
                    addBtn(context, callEditDialog, {"task": task},
                        icon: Icons.edit, text: "Editar"),
                    space(width: 10),
                    goPage(
                      context,
                      "Volver",
                      const TasksUserPage(),
                      Icons.arrow_circle_left_outlined,
                    )
                  ]),
                ]),
          )
        ]));
  }

/*--------------------------------------------------------------------*/
/*                           PROJECT CARD                             */
/*--------------------------------------------------------------------*/
  Widget taskInfoDetails(context, param) {
    String receivers =
        task!.receiversObj.map((e) => e.name).toList().join(", ");
    String receiversOrg =
        task!.receiversOrgObj.map((e) => e.name).toList().join(", ");
    String assigned = task!.assignedObj.map((e) => e.email).toList().join(", ");

    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //customRowDivider(),
                taskInfoRow1(context),
                space(height: 5),
                taskInfoRow2(context),
                space(height: 15),
                taskInfoRow3(context),
                space(height: 15),
                customText("Descripción de la tarea:", 16,
                    textColor: smallColor),
                space(height: 5),
                customText(task?.description, 16),
                space(height: 10),
                customText("Ejecutores:", 16, textColor: smallColor),
                space(height: 5),
                customText(assigned, 16),
                space(height: 10),
                customText("Destinatarios:", 16, textColor: smallColor),
                space(height: 5),
                customText(receivers, 16),
                space(height: 10),
                customText("Destinatarios organizaciones:", 16,
                    textColor: smallColor),
                space(height: 5),
                customText(receiversOrg, 16),
                space(height: 10),
                //customText("Comentarios:", 16, textColor: smallColor),
                taskCommentsHeader(context),
                space(height: 5),
                //customText(task?.comments, 16),
                taskCommentsRow(context),

                //customRowDivider(),
                /*taskAssignedHeader(context, task),
                taskAssigned(context, task),
                space(height: 5),
                customRowDivider(),
                space(height: 5),*/
                //taskProgrammesHeader(context, task),
                //taskProgrammes(context, task),
              ],
            )));
  }

  Widget taskInfoRow1(context) {
    String public = (task!.public) ? "Si" : "No";
    String revision = (task!.revision) ? "Si" : "No";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width / 5,
            child: Row(
              children: [
                customText("Proyecto:", 16, textColor: Colors.grey),
                space(width: 5),
                customText(task!.projectObj.name, 16),
              ],
            )),
        Row(
          children: [
            /*const VerticalDivider(
                width: 10,
                color: Colors.grey,
              ),*/
            customText("Documentos:", 16, textColor: Colors.grey),
            space(width: 5),
            goPageIcon(
                context,
                "Ver",
                Icons.folder,
                DocumentsPage(
                  currentFolder: task!.folderObj,
                ), callback: () {
              setState(() {});
            })
          ],
        ),
        Row(children: [
          customText("Pública:", 16, textColor: Colors.grey),
          space(width: 5),
          customText(public, 16),
        ]),
        Row(children: [
          customText("Revisión:", 16, textColor: Colors.grey),
          space(width: 5),
          customText(revision, 16),
        ]),
      ],
    );
  }

  Widget taskInfoRow2(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 4,
          child: Row(
            children: [
              customText("Estado:", 16, textColor: Colors.grey),
              space(height: 5),
              customText(task!.statusObj.name, 16),
            ],
          ),
        ),
        Row(
          children: [
            customText("Prioridad:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(task!.statusObj.name, 16),
          ],
        ),
        Row(children: [
          customText("Duración horas:", 16, textColor: Colors.grey),
          space(height: 5),
          customText(task!.duration.toString(), 16),
        ]),
        Row(children: [
          customText("Duración minutos:", 16, textColor: Colors.grey),
          space(height: 5),
          customText(task!.durationMin.toString(), 16),
        ]),
      ],
    );
  }

  Widget taskInfoRow3(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
          width: MediaQuery.of(context).size.width / 4.3,
          child: Row(children: [
            customText("Acuerdo:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(DateFormat('yyyy-MM-dd').format(task!.dealDate), 16),
          ])),
      Row(children: [
        customText("Deadline:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(DateFormat('yyyy-MM-dd').format(task!.deadLineDate), 16),
      ]),
      Row(children: [
        customText("Nuevo deadline", 16, textColor: Colors.grey),
        space(height: 5),
        customText(DateFormat('yyyy-MM-dd').format(task!.newDeadLineDate), 16),
      ])
    ]);
  }

  Widget taskCommentsHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Comentarios", 16, textColor: smallColor),
      addBtnRow(context, editCommentDialog, TasksComments(task!.uuid),
          text: "Añadir comentario", icon: Icons.add_circle_outline),
    ]);
  }

  Widget taskCommentsRow(context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: taskComments.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(taskComments[index].comment, 14),
                removeBtn(context, removeCommentDialog,
                    {"comment": taskComments[index]}),
              ]);
        });
  }

/*--------------------------------------------------------------------*/
/*                           EDIT TASK                                */
/*--------------------------------------------------------------------*/
  void callEditDialog(context, args) async {
    // List<KeyValue> statusList = await getTasksStatusHash();
    // List<KeyValue> projectList = await getProjectsHash();
    // List<KeyValue> contactList = await getContactsHash();
    // List<KeyValue> profileList = await Profile.getProfileHash();
    // List<KeyValue> orgList = await getOrganizationsHash();

    List<KeyValue> projectList =
        projectListCache.map((e) => e.toKeyValue()).toList();
    List<KeyValue> contactList =
        contactListCache.map((e) => e.toKeyValue()).toList();
    List<KeyValue> profileList =
        profileListCache.map((e) => e.toKeyValue()).toList();
    List<KeyValue> orgList = orgListCache.map((e) => e.toKeyValue()).toList();
    List<KeyValue> statusList =
        statusListCache.map((e) => e.toKeyValue()).toList();

    final List<MultiSelectItem<KeyValue>> cList = contactList
        .map((contact) => MultiSelectItem<KeyValue>(contact, contact.value))
        .toList();
    final List<MultiSelectItem<KeyValue>> oList = orgList
        .map((org) => MultiSelectItem<KeyValue>(org, org.value))
        .toList();
    final List<MultiSelectItem<KeyValue>> pList = profileList
        .map((prof) => MultiSelectItem<KeyValue>(prof, prof.value))
        .toList();

    taskEditDialog(context, args["task"] as STask, statusList, projectList,
        pList, cList, oList);
  }

  void saveTask(List args) async {
    STask task = args[0];
    task.save();
    await task.getFolder();
    updateObjects();

    Navigator.pop(context);
  }

  Future<void> taskEditDialog(context, task, statusList, projectList,
      profileList, contactList, orgList) {
    task.sender = user.email!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Nueva tarea'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return taskForm(task, projectList, statusList, profileList,
                contactList, orgList, setState);
          }),
          actions: <Widget>[
            dialogsBtns(context, saveTask, task),
          ],
        );
      },
    );
  }

  /*void removeTaskDialog(context, args) {
    customRemoveDialog(context, args["task"], loadUsers);
  }*/

  /*--------------------------------------------------------------------*/
  /*                           COMMENTS                                 */
  /*--------------------------------------------------------------------*/
  void saveComment(List args) async {
    TasksComments comment = args[0];
    comment.save();
    taskComments.add(comment);
    setState(() {});

    Navigator.pop(context);
  }

  void removeCommentDialog(context, Map<String, dynamic> args) {
    TasksComments comment = args["comment"];
    customRemoveDialog(context, null, removeComment, comment);
  }

  void removeComment(comment) async {
    taskComments.remove(comment);
    comment.delete();
    setState(() {});
  }

  Future<void> editCommentDialog(context, comment) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Añadir comentario'),
          content: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Comentario",
                initial: comment.comment,
                size: 600,
                minLines: 2,
                maxLines: 999,
                fieldValue: (String val) {
                  comment.comment = val;
                },
              )
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveComment, comment)],
        );
      },
    );
  }

  /* VIEJO */
  /*void _callEditDialog(context, task) async {
    List<KeyValue> statusList = await getTasksStatusHash();
    List<KeyValue> contactList = await getContactsHash();
    List<KeyValue> projectList = await getProjectsHash();
    _taskEditDialog(context, task, statusList, contactList, projectList);
  }

  void saveTask(List args) async {
    STask task = args[0];
    task.save();
    loadTask(task);
    Navigator.pop(context);
  }

  void cancelItem(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _taskEditDialog(
      context, task, statusList, contactList, projectList) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Modificar tarea'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
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
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Pública:", 16, textColor: mainColor),
                  FormField<bool>(builder: (FormFieldState<bool> state) {
                    return Checkbox(
                      value: task.public,
                      onChanged: (bool? value) {
                        task.public = value!;
                        state.didChange(task.public);
                        /*setState(() {
                        task.public = value!;
                        state.didChange(task.public);
                      });*/
                      },
                    );
                  })
                ])
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Proyecto:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Proyecto',
                    size: 700,
                    selected: task.projectObj.toKeyValue(),
                    options: projectList,
                    onSelectedOpt: (String val) {
                      task.project = val;
                    },
                  ),
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Descripción",
                    initial: task.description,
                    size: 600,
                    fieldValue: (String val) {
                      task.description = val;
                    },
                  )
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CustomTextField(
                    labelText: "Comentarios",
                    initial: task.comments,
                    size: 600,
                    fieldValue: (String val) {
                      task.comments = val;
                    },
                  )
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customText("Estado:", 16, textColor: mainColor),
                  CustomDropdown(
                    labelText: 'Estado',
                    size: 340,
                    selected: task.statusObj.toKeyValue(),
                    options: statusList,
                    onSelectedOpt: (String val) {
                      task.status = val;
                    },
                  ),
                ]),
                space(width: 20),
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
                ]),
              ]),
              space(height: 20),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Acuerdo',
                        selectedDate: task.dealDate,
                        onSelectedDate: (DateTime date) {
                          //task.dealDate = date;
                          setState(() {
                            task.dealDate = date;
                          });
                        },
                      )),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Deadline',
                        selectedDate: task.deadLineDate,
                        onSelectedDate: (DateTime date) {
                          task.deadLineDate = date;
                        },
                      )),
                ]),
                space(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 220,
                      child: DateTimePicker(
                        labelText: 'Nuevo deadline',
                        selectedDate: task.newDeadLineDate,
                        onSelectedDate: (DateTime date) {
                          task.newDeadLineDate = date;
                        },
                      )),
                ]),
                space(width: 20),
              ])
            ]));
          }),
          actions: <Widget>[
            dialogsBtns(context, saveTask, task),
          ],
        );
      },
    );
  }*/

  /*--------------------------------------------------------------------*/
  /*                           ASSIGNED                                 */
  /*--------------------------------------------------------------------*/
  /*void saveAssigned(List args) async {
    STask task = args[0];
    task.updateAssigned();
    loadTask(task);
    Navigator.of(context).pop();
  }

  void _callAssignedEditDialog(context, task) async {
    List<KeyValue> contacts = await getContactsHash();
    _editTaskAssignedDialog(context, task, contacts);
  }

  Future<void> _editTaskAssignedDialog(context, task, contacts) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Añadir responsable'),
          content: SingleChildScrollView(
            child: Column(children: [
              CustomDropdown(
                labelText: 'Responsable',
                size: 340,
                selected: KeyValue("", ""),
                options: contacts,
                onSelectedOpt: (String val) {
                  task.assigned.add(val);
                  /*setState(() {
                      task.sender = val;
                    });*/
                },
              ),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveAssigned, task)],
        );
      },
    );
  }*/

  /*--------------------------------------------------------------------*/
  /*                           PROGRAMMES                               */
  /*--------------------------------------------------------------------*/
  /*void saveProgrammes(List args) async {
    STask task = args[0];
    task.updateProgrammes();
    loadTask(task);
    Navigator.of(context).pop();
  }*/

  /*void _callProgrammesEditDialog(context, task) async {
    List<KeyValue> programmeList = await getProgrammesHash();
    _editTaskProgrammesDialog(context, task, programmeList);
  }*/

  /*Future<void> _editTaskProgrammesDialog(context, task, programmeList) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar('Añadir programa'),
          content: SingleChildScrollView(
            child: Column(children: [
              CustomDropdown(
                labelText: 'Programa',
                size: 340,
                selected: KeyValue("", ""),
                options: programmeList,
                onSelectedOpt: (String val) {
                  task.programmes.add(val);
                },
              ),
            ]),
          ),
          actions: <Widget>[dialogsBtns(context, saveProgrammes, task)],
        );
      },
    );
  }*/
/*  Widget taskInfoSenderPublic(context, task) {
    String public = (task.public) ? "Si" : "No";
    String revision = (task.revision) ? "Si" : "No";

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Proyecto:", 16, textColor: Colors.grey),
                  space(height: 5),
                  customText(task.projectObj.name, 16),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: Colors.grey,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("Documentos:", 16, textColor: Colors.grey),
                  space(height: 5),
                  customText(task.folder, 16),
                ],
              )),
          const VerticalDivider(
            width: 10,
            color: smallColor,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Pública:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(public, 16),
          ]),
          const VerticalDivider(
            width: 10,
            color: smallColor,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            customText("Revisión:", 16, textColor: Colors.grey),
            space(height: 5),
            customText(revision, 16),
          ]),
        ],
      ),
    );
  }*/

  /*Widget taskInfoDates(context, task) {
    return Column(children: [
      Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              customText("Acuerdo", 16, textColor: Colors.grey),
              customText("Deadline", 16, textColor: Colors.grey),
              customText("Nuevo deadline", 16, textColor: Colors.grey),
            ]),
            TableRow(children: [
              customText(DateFormat('yyyy-MM-dd').format(task.dealDate), 16),
              customText(
                  DateFormat('yyyy-MM-dd').format(task.deadLineDate), 16),
              customText(
                  DateFormat('yyyy-MM-dd').format(task.newDeadLineDate), 16),
            ])
          ])
    ]);
  }*/

  /*Widget taskAssignedHeader(context, task) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Responsables:", 16, textColor: Colors.grey),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir responsable',
        onPressed: () {
          _callAssignedEditDialog(context, task);
        },
      )
    ]);
  }

  Widget taskAssigned(context, task) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: task.assignedObj.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${task.assignedObj[index].name}'),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar responsable',
                      onPressed: () async {
                        task.assigned.remove(task.assigned[index]);
                        task.updateAssigned();
                        loadTask(task);
                        //_removeAssigned(context, _task);
                      },
                    )
                  ]));
        });
  }*/

  /*Widget taskProgrammesHeader(context, task) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      customText("Programas:", 16, textColor: smallColor),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Añadir programa',
        onPressed: () {
          _callProgrammesEditDialog(context, task);
        },
      )
    ]);
  }*/

  /*Widget taskProgrammes(context, task) {
    return ListView.builder(
        //padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: task.programmesObj.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${task.programmesObj[index].name}'),
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        size: 12,
                      ),
                      tooltip: 'Eliminar programa',
                      onPressed: () async {
                        task.programmes.remove(task.programmes[index]);
                        //_removeProgrammes(context, _task);
                        task.updateProgrammes();
                        loadTask(task);
                      },
                    )
                  ]));
        });
  }*/
}
