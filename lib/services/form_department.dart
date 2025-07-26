import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class DepartmentForm extends StatefulWidget {
  final Profile? profile;
  final Department? department;
  final Function? onSaved;
  final Function? onDelete;

  @override
  _DepartmentFormState createState() => _DepartmentFormState();

  const DepartmentForm(
      {super.key, this.profile, this.department, this.onSaved, this.onDelete});
}

class _DepartmentFormState extends State<DepartmentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Profile? profile;
  late Department department;
  List<Employee> employees = [];
  List<KeyValue> supervisors = [];
  List<Employee> currentEmployees = [];
  List<Department> allDepartments = [];
  List<KeyValue> optionsDepartment = [];

  late String name;
  late Employee? manager;
  late Department? parent;

  @override
  void initState() {
    super.initState();
    department = widget.department ?? Department.getEmpty();
    profile = widget.profile;
    name = department.name;

    // parent = allDepartments.firstWhere((d) => d.id == department.parent,
    //     orElse: () => Department.getEmpty());
    for (String e in department.employees) {
      currentEmployees.add(employees.firstWhere(
        (emp) => emp.id == e,
        orElse: () => Employee.getEmpty(name: ''),
      ));
    }
    Employee.getEmployees().then((value) {
      employees = value;
      supervisors =
          employees.map((e) => KeyValue(e.id!, e.getFullName())).toList();

      manager = employees.firstWhere((e) => e.id == department.manager,
          orElse: () => Employee.getEmpty());

      if (mounted) {
        setState(() {});
      }
    });

    Department.getDepartments().then((value) {
      allDepartments = value;
      optionsDepartment = allDepartments
          .where((d) => (d.id != department.id))
          .map((d) => KeyValue(d.id.toString(), d.name))
          .toList();
      parent = allDepartments.firstWhere((d) => d.id == department.parent,
          orElse: () => Department.getEmpty());
      // For every department, check if parent is in keys; if not, set to empty
      for (Department d in allDepartments) {
        if (!optionsDepartment.any((e) => e.key == d.parent)) {
          d.parent = null;
          d.save();
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  void save(context) {
    //check if the form is valid
    if (_formKey.currentState!.validate()) {
      department.name = name;
      department.parent = parent?.id;
      department.manager = manager?.id;
      department.employees = currentEmployees.map((e) => e.id!).toList();
      department.save().then((value) {
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
        Navigator.of(context).pop(department);
      });
    }
  }

  void delete(context) {
    //check if the form is valid
    if (_formKey.currentState!.validate()) {
      department.delete().then((value) {
        if (widget.onDelete != null) {
          widget.onDelete!();
        }
        Navigator.of(context).pop(department);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SizedBox(
            width: 400,
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
                      (department.parent != null) ? department.parent! : '',
                  options: optionsDepartment,
                  onSelectedOpt: (value) {
                    parent = allDepartments.firstWhere((d) => d.id == value,
                        orElse: () => Department.getEmpty());
                  },
                ),
                CustomSelectFormField(
                  labelText: "Supervisor",
                  initial: department.manager ?? '',
                  options: supervisors,
                  onSelectedOpt: (value) {
                    manager = employees.firstWhere((e) => e.id == value,
                        orElse: () => Employee.getEmpty());
                  },
                ),
                const Text('Empleados', style: mainText),
                employees.isEmpty
                    ? const Text('No hay empleados definidos')
                    : Column(
                        children: employees
                            .map((e) => Padding(
                                padding: const EdgeInsets.all(5),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color:
                                            // check if any employee in currentEmployee have the same email as e
                                            (currentEmployees.any((element) =>
                                                    element.code == e.code))
                                                ? Colors.white
                                                : Colors.grey,
                                        // (currentEmployees.contains(e))
                                        //     ? Colors.white
                                        //     : Colors.grey,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5)),
                                    padding: const EdgeInsets.all(5),
                                    child: Row(children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text(e.getFullName(),
                                              style: TextStyle(
                                                  color: (currentEmployees.any(
                                                          (element) =>
                                                              element.code ==
                                                              e.code))
                                                      ? Colors.black
                                                      : Colors.white))),
                                      Expanded(
                                          flex: 1,
                                          child: iconBtn(context, (context) {
                                            if (currentEmployees.any(
                                                (element) =>
                                                    element.code == e.code)) {
                                              currentEmployees.removeWhere(
                                                  (element) =>
                                                      element.code == e.code);
                                            } else {
                                              currentEmployees.add(e);
                                            }
                                            if (mounted) {
                                              setState(() {});
                                            }
                                          }, null,
                                              text: '',
                                              icon: (currentEmployees.any(
                                                      (element) =>
                                                          element.code ==
                                                          e.code))
                                                  ? Icons.remove
                                                  : Icons.add_outlined,
                                              color: (currentEmployees.any(
                                                      (element) =>
                                                          element.code ==
                                                          e.code))
                                                  ? Colors.red
                                                  : Colors.white))
                                    ]))))
                            .toList(),
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
