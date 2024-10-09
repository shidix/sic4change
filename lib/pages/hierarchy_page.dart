import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Employee? manager;
  List<Department> allDepartments = [];
  List<KeyValue> optionsDepartment = [];

  late String name;
  late String supervisor;
  late String parent;

  @override
  void initState() {
    super.initState();
    department = widget.department ?? Department.getEmpty();
    profile = widget.profile;
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

  void save() {
    if (_formKey.currentState!.validate()) {
      print('Saving department');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
                  onChanged: (value) => department.name = value,
                  initialValue: department.name,
                  validator: (value) => (value!.isEmpty) ? 'Requerido' : null,
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
                  onSelectedOpt: (value) {},
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
                                        color: (currentEmployees.contains(e))
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
                                                          .contains(e))
                                                      ? Colors.black
                                                      : Colors.white))),
                                      Expanded(
                                          flex: 1,
                                          child: iconBtn(context, (context) {
                                            if (currentEmployees.contains(e)) {
                                              currentEmployees.remove(e);
                                            } else {
                                              currentEmployees.add(e);
                                            }
                                            if (mounted) {
                                              setState(() {});
                                            }
                                          }, null,
                                              text: '',
                                              icon:
                                                  (currentEmployees.contains(e))
                                                      ? Icons.remove
                                                      : Icons.add_outlined,
                                              color:
                                                  (currentEmployees.contains(e))
                                                      ? Colors.red
                                                      : Colors.white))
                                    ]))))
                            .toList(),
                      ),
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

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    Department.getDepartments().then((value) {
      departments = value;
      contentPanel = departmentPanel();

      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget departmentPanel() {
    Widget departmentsTable;
    if (departments.isEmpty) {
      departmentsTable = const Text('No hay departamentos definidos');
    } else {
      List<DataColumn> columns = [
        const DataColumn(label: const Text('ID')),
        const DataColumn(label: Text('Nombre')),
        const DataColumn(label: Text('Supervisor')),
        const DataColumn(label: Text('')),
      ];
      List<DataRow> rows = departments
          .map((department) => DataRow(cells: [
                DataCell(Text(department.id.toString())),
                DataCell(Text(department.name)),
                DataCell(Text(department.manager.toString())),
                DataCell(IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {},
                    color: Colors.blue))
              ]))
          .toList();
      departmentsTable = DataTable(columns: columns, rows: rows);
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
              });
        }, null)
      ],
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          titleBar,
          toolsBar,
          departmentsTable,
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
