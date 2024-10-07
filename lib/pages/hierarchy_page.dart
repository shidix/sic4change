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

  @override
  _DepartmentFormState createState() => _DepartmentFormState();

  const DepartmentForm({super.key, this.profile});
}

class _DepartmentFormState extends State<DepartmentForm> {
  Profile? profile;
  Department department = Department.getEmpty();
  List<Employee> employees = [];
  List<KeyValue> supervisors = [];
  Employee? manager;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    Employee.getEmployees().then((value) {
      employees = value;
      supervisors =
          employees.map((e) => KeyValue(e.email, e.getFullName())).toList();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nombre'),
          onChanged: (value) => department.name = value,
        ),
        CustomSelectFormField(
          labelText: "Supervisor",
          initial: profile!.email,
          options: supervisors,
          onSelectedOpt: (value) {},
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        )
      ],
    ));
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
    DataTable departmentsTable = DataTable(columns: columns, rows: rows);

    Widget titleBar = s4cTitleBar('Departamentos');
    Widget toolsBar = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        addBtnRow(context, (context) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: s4cTitleBar('Nuevo Departamento', context, Icons.add),
                  content: DepartmentForm(profile: profile),
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
