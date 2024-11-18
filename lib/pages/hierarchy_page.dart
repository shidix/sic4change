import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/generated/l10n.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';

class DepartmentForm extends StatefulWidget {
  final Profile? profile;
  final Department? department;

  @override
  _DepartmentFormState createState() => _DepartmentFormState();

  const DepartmentForm({super.key, this.profile, this.department});
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
  late String manager;
  late String parent;

  @override
  void initState() {
    super.initState();
    department = widget.department ?? Department.getEmpty();
    profile = widget.profile;
    name = department.name;
    if (department.manager != null) {
      manager = department.manager!.email;
    } else {
      manager = profile!.email;
    }
    parent = department.parent.toString();
    for (Employee e in department.employees!) {
      currentEmployees.add(e);
    }
    Employee.getEmployees().then((value) {
      employees = value;
      supervisors =
          employees.map((e) => KeyValue(e.email, e.getFullName())).toList();
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
      if (mounted) {
        setState(() {});
      }
    });
  }

  void save(context) {
    //check if the form is valid
    if (_formKey.currentState!.validate()) {
      department.name = name;
      department.parent = parent;
      department.manager = employees.firstWhere((e) => e.email == manager,
          orElse: () => Employee.getEmpty());
      department.employees = currentEmployees;
      department.save().then((value) {
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
                  initial: (department.parent != null)
                      ? department.parent.toString()
                      : '',
                  options: optionsDepartment,
                  onSelectedOpt: (value) {
                    parent = value;
                  },
                ),
                CustomSelectFormField(
                  labelText: "Supervisor",
                  initial: profile!.email,
                  options: supervisors,
                  onSelectedOpt: (value) {
                    manager = value;
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
                ]),
              ],
            ))));
  }
}

class HierarchyPage extends StatefulWidget {
  final Profile? profile;

  @override
  _HierarchyPageState createState() => _HierarchyPageState();

  const HierarchyPage({super.key, this.profile});
}

class _HierarchyPageState extends State<HierarchyPage> {
  Profile? profile;
  Widget secondaryMenuPanel = Container();
  Widget contentPanel = const Text('Hierarchy Page');
  Widget mainMenuPanel = Container();

  List<Department> departments = [];
  Map<String, Department> departmentsHash = {};
  Map<String, bool> expanded = {};
  Map<String, String> departmentKeys = {};
  List<Color> colors = [
    Colors.white,
    Colors.grey[100]!,
    Colors.grey[200]!,
    Colors.grey[400]!
  ];

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    Department.getDepartments().then((value) {
      departments = value;

      for (Department d in departments) {
        expanded[d.id!] = false;
        departmentsHash[d.id!] = d;
      }
      for (Department d in departments) {
        departmentKeys[d.id!] = d.name;
        String parent = d.parent!;
        while (parent != '') {
          departmentKeys[d.id!] =
              '${departmentsHash[parent]!.name}>${departmentKeys[d.id!]!}';
          parent = departmentsHash[parent]!.parent!;
        }
      }

      departments.sort(
          (a, b) => departmentKeys[a.id!]!.compareTo(departmentKeys[b.id!]!));
      contentPanel = departmentPanel();

      if (mounted) {
        setState(() {});
      }
    });
  }

  String createIndentationFromKey(String key) {
    int count = key.split('>').length;
    return ' ' * (count * 8);
  }

  Widget departmentPanel() {
    Widget departmentsTable;
    if (departments.isEmpty) {
      departmentsTable = const Text('No hay departamentos definidos');
    } else {
      List<DataColumn> columns = [
        const DataColumn(
            label: Text(
          'Nombre',
          style: headerListStyle,
        )),
        const DataColumn(
            label: Text(
          'Depende de',
          style: headerListStyle,
        )),
        const DataColumn(
            label: Text(
          'Supervisor/a',
          style: headerListStyle,
        )),
        const DataColumn(label: Text('')),
      ];
      List<Department> departmentsRoot = departments
          .where((department) => ((department.parent == null) ||
              (department.parent == '') ||
              (expanded[department.parent] == true)))
          .toList();
      List<DataRow> rows = departmentsRoot
          .map((department) => DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (department.parent == '') {
                      return colors[0];
                    }
                    return colors[
                        departmentKeys[department.id]!.split('>').length];
                  }),
                  cells: [
                    (department.parent == '')
                        ? DataCell(Text(department.name))
                        : DataCell(Text(
                            '${createIndentationFromKey(departmentKeys[department.id!]!)}${department.name}')),
                    DataCell(Text((department.parent != null)
                        ? departments
                            .firstWhere((d) => d.id == department.parent,
                                orElse: () => Department(name: '--'))
                            .name
                        : '--')),
                    DataCell(Text((department.manager != null)
                        ? department.manager!.getFullName()
                        : 'Sin supervisor/a')),
                    DataCell(Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // IconButton(
                          //     icon: const Icon(Icons.edit),
                          //     onPressed: () {},
                          //     color: Colors.black),
                          IconButton(
                              icon: Icon((!expanded[department.id]!)
                                  ? Icons.expand_more_outlined
                                  : Icons.expand_less_outlined),
                              onPressed: () {
                                expanded[department.id!] =
                                    !expanded[department.id]!;
                                if (!expanded[department.id]!) {
                                  for (String key in departmentKeys.keys) {
                                    if (departmentKeys[key]!
                                        .contains('${department.name}>')) {
                                      expanded[key] = false;
                                    }
                                  }
                                }
                                if (mounted) {
                                  setState(() {
                                    contentPanel = departmentPanel();
                                  });
                                }
                              }),
                          editBtn(context, (context, department) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return CustomPopupDialog(
                                    context: context,
                                    title: 'Editar Departamento',
                                    icon: Icons.edit,
                                    content: DepartmentForm(
                                        profile: profile,
                                        department: department),
                                    actionBtns: null,
                                  );
                                }).then((value) {
                              if (value != null) {
                                if (mounted) {
                                  setState(() {
                                    contentPanel = departmentPanel();
                                  });
                                }
                              }
                            });
                          }, department),
                          removeConfirmBtn(context, (context) {
                            department.delete().then((value) {
                              departments.remove(department);
                              if (mounted) {
                                setState(() {
                                  contentPanel = departmentPanel();
                                });
                              }
                            });
                          }, null)
                        ]))
                  ]))
          .toList();
      departmentsTable = DataTable(
          headingRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            return headerListBgColor;
          }),
          columns: columns,
          rows: rows);
    }

    Widget titleBar = s4cTitleBar('Departamentos');
    Widget toolsBar = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        addBtnRow(context, (context) {
          showDialog(
              context: context,
              builder: (context) {
                return CustomPopupDialog(
                  context: context,
                  title: 'Nuevo Departamento',
                  icon: Icons.add,
                  content: DepartmentForm(profile: profile),
                  actionBtns: null,
                );
              }).then((value) {
            if (value != null) {
              departments.add(value);
              if (mounted) {
                setState(() {
                  contentPanel = departmentPanel();
                });
              }
            }
          });
        }, null)
      ],
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          titleBar,
          toolsBar,
          space(height: 10),
          SizedBox(width: double.infinity, child: departmentsTable),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return to login_page if profile is null
    if (profile == null) {
      Profile.getProfile(FirebaseAuth.instance.currentUser!.email!)
          .then((value) {
        profile = value;
        mainMenuPanel =
            mainMenuOperator(context, url: "/rrhh", profile: profile);
        secondaryMenuPanel = secondaryMenu(context, HIERARCHY_ITEM, profile);

        if (mounted) {
          setState(() {});
        }
      });
    } else {
      mainMenuPanel = mainMenuOperator(context, url: "/rrhh", profile: profile);
      secondaryMenuPanel = secondaryMenu(context, HIERARCHY_ITEM, profile);
    }
    return SelectionArea(
        child: Scaffold(
            body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            mainMenuPanel,
            Padding(
                padding: const EdgeInsets.all(30), child: secondaryMenuPanel),
            contentPanel,
            footer(context)
          ],
        ),
      ),
    )));
  }
}
