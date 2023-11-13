import 'package:flutter/material.dart';
import 'package:sic4change/services/models_tasks.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const PAGE_TASK_TITLE = "Tareas";
List task_list = [];

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  var searchController = new TextEditingController();

  void loadTasks() async {
    await getTasks().then((val) {
      task_list = val;
    });
    setState(() {});
  }

  @override
  void initState() {
    loadTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        mainMenu(context),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: EdgeInsets.only(left: 40),
            child: Text(PAGE_TASK_TITLE, style: TextStyle(fontSize: 20)),
          ),
          SearchBar(
            controller: searchController,
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
            onSubmitted: (value) {
              loadTasks();
            },
            leading: const Icon(Icons.search),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                taskAddBtn(context),
              ],
            ),
          ),
        ]),
        //contactsHeader(context),
        Expanded(
            child: Container(
          child: taskList(context),
          padding: EdgeInsets.all(10),
        ))
      ]),
    );
  }

/*-------------------------------------------------------------
                            TASKS
-------------------------------------------------------------*/
  Widget taskAddBtn(context) {
    return ElevatedButton(
      onPressed: () {
        _callEditDialog(context, null);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          Text(
            "Añadir tarea",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget taskList(context) {
    return FutureBuilder(
        future: getTasks(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Expanded(
                    child: Container(
                  padding: EdgeInsets.all(5),
                  child: dataBody(context),
                ))
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
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
              DataColumn(label: Text("Tarea"), tooltip: "Tarea"),
              DataColumn(
                label: Text("Acuerdo"),
                tooltip: "Acuerdo",
              ),
              DataColumn(label: Text("Deadline"), tooltip: "Deadline"),
              DataColumn(
                  label: Text("Nuevo deadline"), tooltip: "Nuevo deadline"),
              DataColumn(label: Text("Devolución"), tooltip: "Devolución"),
              DataColumn(label: Text("Responsables"), tooltip: "Responsables"),
              DataColumn(label: Text("Estado"), tooltip: "Estado"),
              DataColumn(label: Text(""), tooltip: ""),
            ],
            rows: task_list
                .map(
                  (_task) => DataRow(cells: [
                    DataCell(Text(_task.name)),
                    DataCell(
                      Text(_task.deal_date),
                    ),
                    DataCell(Text(_task.deadline_date)),
                    DataCell(Text(_task.new_deadline_date)),
                    DataCell(Text(_task.senderObj.name)),
                    DataCell(Text(_task.assigned.join(","))),
                    DataCell(Text(_task.statusObj.name)),
                    DataCell(Row(children: [
                      IconButton(
                          icon: const Icon(Icons.view_compact),
                          tooltip: 'Ver',
                          onPressed: () async {
                            Navigator.pushNamed(context, "/task_info",
                                arguments: {'task': _task});
                            //_callEditDialog(context, _task);
                          }),

                      /*IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () async {
                            _callEditDialog(context, _task);
                          }),*/
                      IconButton(
                          icon: const Icon(Icons.remove_circle),
                          tooltip: 'Remove',
                          onPressed: () {
                            _removeTaskDialog(context, _task);
                          }),
                    ]))
                  ]),
                )
                .toList(),
          ),
        ));
  }

  void _callEditDialog(context, task) async {
    _taskEditDialog(context, task);
    /*List<String> status_list = [];
    List<String> contact_list = [];
    await getTasksStatus().then((value) async {
      for (TasksStatus item in value) {
        status_list.add(item.name);
      }
      await getContacts().then((value) async {
        for (Contact item in value) {
          contact_list.add(item.name);
        }

        _taskEditDialog(context, task, status_list, contact_list);
      });
    });*/
  }

  void _saveTask(
    context,
    _task,
    _name,
  ) async {
    STask _task = STask(_name);
    _task.save();

    Navigator.pushNamed(context, "/task_info", arguments: {'task': _task});
    /*await addTask(_name, _description, _status, _deal_date, _deadline_date,
              _new_deadline_date, _sender, List.empty())
          .then((value) async {
        if (!_status_list.contains(_status)) await addTasksStatus(_status);
        loadTasks();
        Navigator.pop(context);
        //Navigator.popAndPushNamed(context, "/contacts");
      });*/
  }

  /*void _saveTask(
      context,
      _task,
      _name,
      _description,
      _status,
      _deal_date,
      _deadline_date,
      _new_deadline_date,
      _sender,
      _assigned,
      _status_list) async {
    if (_task != null) {
      await updateTask(
          _task.id,
          _task.uuid,
          _name,
          _description,
          _status,
          _deal_date,
          _deadline_date,
          _new_deadline_date,
          _sender, []).then((value) async {
        if (!_status_list.contains(_status)) await addTasksStatus(_status);
        loadTasks();
        Navigator.pop(context);
        //Navigator.popAndPushNamed(context, "/contacts");
      });
    } else {
      await addTask(_name, _description, _status, _deal_date, _deadline_date,
              _new_deadline_date, _sender, List.empty())
          .then((value) async {
        if (!_status_list.contains(_status)) await addTasksStatus(_status);
        loadTasks();
        Navigator.pop(context);
        //Navigator.popAndPushNamed(context, "/contacts");
      });
    }
  }*/

  /*Widget customDateField(context, dateController) {
    return SizedBox(
        width: 220,
        child: TextField(
          controller: dateController, //editing controller of this TextField
          decoration: InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Enter Date" //label text of field
              ),
          readOnly: true, //set it true, so that user will not able to edit text
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(
                    2000), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2101));

            if (pickedDate != null) {
              //print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);
              //print(formattedDate); //formatted date output using intl package =>  2021-03-16

              setState(() {
                dateController.text = formattedDate;
              });
            } else {
              print("Date is not selected");
            }
          },
        ));
  }*/

  //Future<void> _taskEditDialog(context, _task, _status_list, _contact_list) {
  Future<void> _taskEditDialog(context, _task) {
    TextEditingController nameController = TextEditingController(text: "");
    /* TextEditingController descriptionController =
        TextEditingController(text: "");
    TextEditingController statusController = TextEditingController(text: "");
    TextEditingController dealDateController = TextEditingController(text: "");
    TextEditingController deadlineDateController =
        TextEditingController(text: "");
    TextEditingController newDeadlineDateController =
        TextEditingController(text: "");
    TextEditingController senderController = TextEditingController(text: "");*/

    if (_task != null) {
      nameController = TextEditingController(text: _task.name);
      /*descriptionController = TextEditingController(text: _task.description);
      statusController = TextEditingController(text: _task.status);
      dealDateController = TextEditingController(text: _task.deal_date);
      deadlineDateController = TextEditingController(text: _task.deadline_date);
      newDeadlineDateController =
          TextEditingController(text: _task.new_deadline_date);
      senderController = TextEditingController(text: _task.sender);*/
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Contact edit'),
          content: SingleChildScrollView(
              child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Nombre:", 16, textColor: Colors.blue),
                customTextField(nameController, "Nombre", size: 700),
              ])
            ]),
            /*space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Descripción:", 16, textColor: Colors.blue),
                customTextField(descriptionController, "Descripción",
                    size: 700),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Estado:", 16, textColor: Colors.blue),
                customAutocompleteField(
                    statusController, _status_list, "Write or select status...",
                    width: 340),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Devolución:", 16, textColor: Colors.blue),
                customAutocompleteField(senderController, _contact_list,
                    "Write or select contact...",
                    width: 340),
              ]),
            ]),
            space(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Acuerdo:", 16, textColor: Colors.blue),
                customDateField(context, dealDateController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Deadline:", 16, textColor: Colors.blue),
                customDateField(context, deadlineDateController),
              ]),
              space(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Nuevo Deadline:", 16, textColor: Colors.blue),
                customDateField(context, newDeadlineDateController),
              ]),
              space(width: 20),
            ])*/
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveTask(context, _task, nameController.text);
                /*descriptionController.text,
                    statusController.text,
                    dealDateController.text,
                    deadlineDateController.text,
                    newDeadlineDateController.text,
                    senderController.text,
                    [],
                    _status_list);*/
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeTaskDialog(context, _task) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Borrar tarea'),
          content: SingleChildScrollView(
            child: Text("Are you sure to remove this element?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Borrar'),
              onPressed: () async {
                _task.delete();
                loadTasks();
                Navigator.of(context).pop();
                /*await deleteTask(id).then((value) {
                  loadTasks();
                  Navigator.of(context).pop();
                  //Navigator.popAndPushNamed(context, "/contacts");
                });*/
              },
            ),
            TextButton(
              child: const Text('Cancel'),
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
