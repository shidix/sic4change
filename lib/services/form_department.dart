import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class DepartmentForm extends StatefulWidget {
  final Profile profile;
  final Department department;
  final Function onSaved;
  final Function onDelete;
  final List<Department> allDepartments;
  final List<Employee> employees;
  final List<Employee> supervisors;

  @override
  _DepartmentFormState createState() => _DepartmentFormState();

  const DepartmentForm(
      {super.key,
      required this.profile,
      required this.department,
      required this.allDepartments,
      required this.employees,
      required this.supervisors,
      required this.onSaved,
      required this.onDelete});
}

class _DepartmentFormState extends State<DepartmentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Profile? profile;
  late Department department;
  late List<Employee> employees = [];
  late List<Employee> supervisors = [];
  List<KeyValue> supervisorsOptions = [];
  List<Employee> currentEmployees = [];
  List<Department> allDepartments = [];
  List<KeyValue> optionsDepartment = [];

  late String name;
  late Employee? manager;
  late Department? parent;

  int getLevel(Department? department) {
    if (department == null || department.parent == null) return 0;
    return getLevel(allDepartments.firstWhere((d) => d.id == department.parent,
            orElse: () => Department.getEmpty())) +
        1;
  }

  @override
  void initState() {
    super.initState();
    department = widget.department;
    profile = widget.profile;
    name = department.name;
    employees = widget.employees;
    supervisors = widget.supervisors;

    parent = widget.allDepartments.firstWhere((d) => d.id == department.parent,
        orElse: () => Department.getEmpty());

    for (String e in department.employees) {
      // Check if employee exists in the list, if not, add an empty employee
      if (employees.any((emp) => emp.id == e)) {
        currentEmployees.add(employees.firstWhere((emp) => emp.id == e));
      }
    }

    supervisorsOptions =
        supervisors.map((e) => KeyValue(e.id!, e.getFullName())).toList();

    if (supervisors.any((e) => e.id == department.manager)) {
      manager = supervisors.firstWhere((e) => e.id == department.manager);
    } else {
      // If the manager is not in the list, set it to empty
      manager = Employee.getEmpty();
    }

    List<Department> value = widget.allDepartments;

    Queue<Department> queue = Queue<Department>();
    value.sort((a, b) => b.name.compareTo(a.name));
    for (Department d in value) {
      if (d.parent == null) {
        queue.addFirst(d);
      }
    }
    allDepartments = [];
    while (queue.isNotEmpty) {
      Department d = queue.removeFirst();
      allDepartments.add(d);

      for (Department child in value) {
        if (child.parent == d.id) {
          queue.addFirst(child);
        }
      }
    }

    optionsDepartment = allDepartments
        .map((d) => KeyValue(d.id.toString(), " " * getLevel(d) * 10 + d.name))
        .toList();

    optionsDepartment.insert(0, KeyValue('none', '-- NINGUNO --'));
    parent = allDepartments.firstWhere((d) => d.id == department.parent,
        orElse: () => Department.getEmpty());
    // For every department, check if parent is in keys; if not, set to empty
  }

  void save(context) {
    //check if the form is valid
    if (_formKey.currentState!.validate()) {
      department.name = name;
      department.parent = parent?.id;
      department.manager = manager?.id;
      department.employees = currentEmployees.map((e) => e.id!).toList();
      department.save().then((value) {
        widget.onSaved();
        Navigator.of(context).pop(department);
      });
    }
  }

  void delete(context) {
    //check if the form is valid
    if (_formKey.currentState!.validate()) {
      department.delete().then((value) {
        widget.onDelete();
        Navigator.of(context).pop(department);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Padding> employeesPadding = [];
    for (Employee e in employees) {
      employeesPadding.add(Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
              decoration: BoxDecoration(
                  color: (currentEmployees
                          .any((element) => element.code == e.code))
                      ? Colors.white
                      : Colors.grey,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.all(5),
              child: Row(children: [
                Expanded(
                    flex: 3,
                    child: Text(e.getFullName(),
                        style: TextStyle(
                            color: (currentEmployees
                                    .any((element) => element.code == e.code))
                                ? Colors.black
                                : Colors.white))),
                Expanded(
                    flex: 1,
                    child: iconBtn(context, (context) {
                      if (currentEmployees
                          .any((element) => element.code == e.code)) {
                        currentEmployees
                            .removeWhere((element) => element.code == e.code);
                      } else {
                        currentEmployees.add(e);
                      }
                      if (mounted) {
                        setState(() {});
                      }
                    }, null,
                        text: '',
                        icon: (currentEmployees
                                .any((element) => element.code == e.code))
                            ? Icons.remove
                            : Icons.add_outlined,
                        color: (currentEmployees
                                .any((element) => element.code == e.code))
                            ? Colors.red
                            : Colors.white))
              ]))));
    }

    if (employeesPadding.length % 3 != 0) {
      int missing = 3 - (employeesPadding.length % 3);
      for (int i = 0; i < missing; i++) {
        employeesPadding.add(const Padding(padding: EdgeInsets.all(5)));
      }
    }

    List<List<Padding>> employeesMatrix = resize(employeesPadding, 3);

    return Form(
        key: _formKey,
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Nombre departamento'),
                  onChanged: (value) => name = value,
                  initialValue: department.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduzca un nombre';
                    }
                    return null;
                  },
                ),
                CustomSelectFormField(
                  labelText: "Depende de",
                  initial:
                      (department.parent != null) ? department.parent! : 'none',
                  options: optionsDepartment,
                  onSelectedOpt: (value) {
                    if (value == department.id) {
                      return;
                    }
                    if (value == 'none') {
                      parent = null;
                    } else {
                      parent = allDepartments.firstWhere(
                          (d) => d.id.toString() == value,
                          orElse: () => Department.getEmpty());
                    }
                  },
                ),
                CustomSelectFormField(
                  labelText: "Supervisor",
                  initial: department.manager ?? '',
                  options: supervisorsOptions,
                  onSelectedOpt: (value) {
                    manager = employees.firstWhere((e) => e.id == value,
                        orElse: () => Employee.getEmpty());
                  },
                ),
                const Text('Empleados', style: mainText),
                employees.isEmpty
                    ? const Text('No hay empleados definidos')
                    : Column(
                        children: employeesMatrix
                            .map((row) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: row
                                      .map((e) => Expanded(
                                            flex: 1,
                                            child: e,
                                          ))
                                      .toList(),
                                ))
                            .toList(),
                        // employees
                        //     .map((e) => Padding(
                        //         padding: const EdgeInsets.all(5),
                        //         child: Container(
                        //             decoration: BoxDecoration(
                        //                 color: (currentEmployees.any(
                        //                         (element) =>
                        //                             element.code == e.code))
                        //                     ? Colors.white
                        //                     : Colors.grey,
                        //                 border: Border.all(color: Colors.grey),
                        //                 borderRadius: BorderRadius.circular(5)),
                        //             padding: const EdgeInsets.all(5),
                        //             child: Row(children: [
                        //               Expanded(
                        //                   flex: 3,
                        //                   child: Text(e.getFullName(),
                        //                       style: TextStyle(
                        //                           color: (currentEmployees.any(
                        //                                   (element) =>
                        //                                       element.code ==
                        //                                       e.code))
                        //                               ? Colors.black
                        //                               : Colors.white))),
                        //               Expanded(
                        //                   flex: 1,
                        //                   child: iconBtn(context, (context) {
                        //                     if (currentEmployees.any(
                        //                         (element) =>
                        //                             element.code == e.code)) {
                        //                       currentEmployees.removeWhere(
                        //                           (element) =>
                        //                               element.code == e.code);
                        //                     } else {
                        //                       currentEmployees.add(e);
                        //                     }
                        //                     if (mounted) {
                        //                       setState(() {});
                        //                     }
                        //                   }, null,
                        //                       text: '',
                        //                       icon: (currentEmployees.any(
                        //                               (element) =>
                        //                                   element.code ==
                        //                                   e.code))
                        //                           ? Icons.remove
                        //                           : Icons.add_outlined,
                        //                       color: (currentEmployees.any(
                        //                               (element) =>
                        //                                   element.code ==
                        //                                   e.code))
                        //                           ? Colors.red
                        //                           : Colors.white))
                        //             ]))))
                        //     .toList(),
                      ),
                Row(children: [
                  Expanded(flex: 1, child: Container()),
                  Expanded(flex: 2, child: saveBtnForm(context, save, context)),
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                      flex: 2, child: removeBtnForm(context, delete, context)),
                  Expanded(flex: 1, child: Container()),
                ]),
              ],
            ))));
  }
}
