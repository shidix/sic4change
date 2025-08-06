import 'dart:collection';

// import 'package:excel/excel.dart' as excelPackage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/form_department.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_widgets.dart';

class HierarchyPage extends StatefulWidget {
  // final Profile? profile;

  @override
  _HierarchyPageState createState() => _HierarchyPageState();

  const HierarchyPage({super.key});
}

class _HierarchyPageState extends State<HierarchyPage> {
  Profile? profile;
  Widget secondaryMenuPanel = Container();
  Widget contentPanel = const Text('Hierarchy Page');
  Widget mainMenuPanel = Container();

  List<Department> departments = [];
  List<Employee> employees = [];
  List<Widget> treeView = [];
  List<Department> allDepartments = [];
  Map<String, Department> departmentsHash = {};
  Map<String, bool> expanded = {};
  Map<String, String> departmentKeys = {};
  String? parentDepartment;
  Department? currentDepartment;
  Organization? currentOrganization;

  List<Color> colors = [
    Colors.white,
    Colors.grey[100]!,
    Colors.grey[200]!,
    Colors.grey[400]!
  ];

  TreeNode? rootNode;

  void createFullTree() {
    List<Department> departmentsWithoutParent = allDepartments
        .where((d) => (d.parent == null || d.parent == ''))
        .toList();
    departmentsWithoutParent.sort((a, b) => a.name.compareTo(b.name));

    Queue<Department> queue = Queue<Department>.from(departmentsWithoutParent);
    // Generate a Queue<int> with queue.length elements, each initialized to 0
    Queue<int> levels =
        Queue<int>.from(Iterable.generate(queue.length, (i) => 0));

    List<TreeNode> fullTree = [];

    while (queue.isNotEmpty) {
      Department last = queue.removeFirst();
      int level = levels.removeFirst();

      // Generate label from department: // "Department Name - Supervisor "
      Employee? manager = (last.manager != null && last.manager != '')
          ? employees.firstWhere(
              (emp) => emp.id == last.manager,
              orElse: () => Employee.getEmpty(),
            )
          : null;
      String managerName = manager?.getFullName() ?? '';

      String employeesNames = (last.employees).map((e) {
        Employee? emp = employees.firstWhere(
          (emp) => emp.id == e,
          orElse: () => Employee.getEmpty(),
        );
        return emp.getFullName();
      }).join(', ');

      TreeNode node = TreeNode(
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(last.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Supervisor: $managerName',
                style:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
            Text('Empleados: $employeesNames',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        item: last,
        level: level,
        expanded: true,
        visible: true,
        onSelected: (node) {
          currentDepartment = node.item as Department;
          dialogEditDepartment(context);
        },
      );
      fullTree.add(node);
      List<Department> children =
          allDepartments.where((d) => d.parent == last.id).toList();
      children.sort((a, b) => a.name.compareTo(b.name));
      for (Department child in children) {
        queue.addFirst(child);
        levels.addFirst(level + 1);
      }
    }
    treeView = fullTree;
  }

  Department dialogEditDepartment(BuildContext contextt) {
    List<Employee> allowedEmployees = [];
    Department department = currentDepartment!;
    parentDepartment = department.parent;

    // Copy employees in allowedEmployees
    for (Employee emp in employees) {
      allowedEmployees.add(emp);
    }

    List<Department> otherDepartments =
        allDepartments.where((d) => d.id != department.id).toList();

    List<Employee> employeesInOtherDepartments = [];
    for (Department d in otherDepartments) {
      employeesInOtherDepartments.addAll(d.employees.map((e) =>
          employees.firstWhere((emp) => emp.id == e,
              orElse: () => Employee.getEmpty())));
    }

    employeesInOtherDepartments
        .removeWhere((testEmp) => (testEmp.id == '' || testEmp.id == null));

    for (Employee emp in employeesInOtherDepartments) {
      if (!department.employees.contains(emp.id)) {
        allowedEmployees.removeWhere((testEmp) => testEmp.id == emp.id);
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return CustomPopupDialog(
            context: context,
            title: 'Editar Departamento',
            icon: Icons.edit,
            content: DepartmentForm(
                profile: profile!,
                department: department,
                employees: [...allowedEmployees],
                supervisors: employees,
                allDepartments: [...allDepartments],
                onSaved: () {
                  if (mounted) {
                    setState(() {
                      // Update the department in the list
                      int index = allDepartments
                          .indexWhere((d) => d.id == department.id);
                      if (index != -1) {
                        allDepartments[index] = department;
                      } else {
                        allDepartments.add(department);
                      }
                      departmentsHash[department.id!] = department;
                      contentPanel = departmentPanel();
                    });
                  }
                },
                onDelete: () {
                  if (mounted) {
                    setState(() {
                      List<Department> childrens = allDepartments
                          .where((d) => d.parent == department.id)
                          .map((d) => d)
                          .toList();
                      for (Department child in childrens) {
                        child.parent = department.parent;
                        child.save();
                      }
                      allDepartments.removeWhere((d) => d.id == department.id);
                      departmentsHash.remove(department.id);
                      contentPanel = departmentPanel();
                    });
                  }
                }),
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
    return department;
  }

  Future<void> initializeData(context) async {
    try {
      DateTime startTime = DateTime.now();
      while (
          DateTime.now().difference(startTime) < const Duration(seconds: 5) &&
              (Provider.of<ProfileProvider>(context, listen: false).profile ==
                      null ||
                  Provider.of<ProfileProvider>(context, listen: false)
                          .organization ==
                      null)) {}
      profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      currentOrganization =
          Provider.of<ProfileProvider>(context, listen: false).organization;
      final results = await Future.wait([
        Department.getDepartments(organization: currentOrganization),
        Employee.getEmployees(organization: currentOrganization),
      ]);

      var aux = results[0] as List<Department>;
      if (aux.isEmpty) {
        aux = await Department.getDepartments();
        for (Department d in aux) {
          d.organization = currentOrganization?.id;
          await d.save();
        }
      }
      if (mounted) {
        setState(() {
          allDepartments = aux;
          employees = results[1] as List<Employee>;
          contentPanel = departmentPanel();
          mainMenuPanel = mainMenu(context, "/rrhh");
          secondaryMenuPanel = secondaryMenu(context, HIERARCHY_ITEM);
        });
      }
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        setState(() {
          allDepartments = List<Department>.empty();
          employees = List<Employee>.empty();
          contentPanel = departmentPanel();
          return;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileProvider>(context, listen: false).addListener(() {
      if (!mounted) return;
      profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      currentOrganization =
          Provider.of<ProfileProvider>(context, listen: false).organization;

      if (profile != null && currentOrganization != null) {
        mainMenuPanel = mainMenu(context, "/rrhh");
        secondaryMenuPanel = secondaryMenu(context, HIERARCHY_ITEM);
        initializeData(context);
      }
    });

    profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    currentOrganization =
        Provider.of<ProfileProvider>(context, listen: false).organization;
    mainMenuPanel = mainMenu(context, "/rrhh");
    secondaryMenuPanel = secondaryMenu(context, HIERARCHY_ITEM);
    contentPanel = const Text('Cargando perfil...',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));

    if (profile == null || currentOrganization == null) {
      Provider.of<ProfileProvider>(context, listen: false).loadProfile();
    } else {
      initializeData(context);
    }
  }

  String createIndentationFromDepartment(Department department) {
    Department current = department;
    int level = 0;
    while (current.parent != '') {
      level++;
      current = departmentsHash[current.parent]!;
    }
    return ' ' * (level * 8);
  }

  int getLevel(Department department) {
    Department current = department;
    int level = 0;
    while (current.parent != '') {
      level++;
      current = departmentsHash[current.parent]!;
    }
    return level;
  }

  Widget departmentPanel() {
    List<Employee> allowedEmployees = [];

    // Copy employees in allowedEmployees
    for (Employee emp in employees) {
      allowedEmployees.add(emp);
    }

    List<Department> otherDepartments = [];
    for (Department d in allDepartments) {
      otherDepartments.add(d);
    }

    List<Employee> employeesInOtherDepartments = [];
    for (Department d in otherDepartments) {
      employeesInOtherDepartments.addAll(d.employees.map((e) =>
          employees.firstWhere((emp) => emp.id == e,
              orElse: () => Employee.getEmpty())));
    }

    employeesInOtherDepartments
        .removeWhere((testEmp) => (testEmp.id == '' || testEmp.id == null));

    for (Employee emp in employeesInOtherDepartments) {
      if (allowedEmployees.any((testEmp) => testEmp.id == emp.id)) {
        allowedEmployees.removeWhere((testEmp) => testEmp.id == emp.id);
      }
    }

    List<Employee> supervisors = [];
    for (Employee emp in employees) {
      // Check if the employee has tha same domain as the current organization

      if ((emp.organization == currentOrganization?.id) ||
          (emp.email.isNotEmpty &&
              emp.email.contains('@') &&
              emp.email.endsWith('@${currentOrganization!.domain}'))) {
        supervisors.add(emp);
      }
    }

    Widget titleBar = s4cTitleBar(const Padding(
        padding: EdgeInsets.all(5),
        child: Text('Departamentos',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold))));
    Widget toolsBar = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        addBtnRow(context, (context) {
          showDialog(
            context: context,
            builder: (context) {
              currentDepartment = Department(
                name: 'Nuevo Departamento',
                parent: parentDepartment,
                manager: profile!.id,
                employees: [],
                organization: currentOrganization?.id,
              );
              return CustomPopupDialog(
                context: context,
                title: 'Nuevo Departamento',
                icon: Icons.add,
                content: DepartmentForm(
                    profile: profile!,
                    department: currentDepartment!,
                    supervisors: [...supervisors],
                    employees: [...allowedEmployees],
                    allDepartments: [...allDepartments],
                    onSaved: () {
                      if (mounted) {
                        allDepartments.add(currentDepartment!);
                        departmentsHash[currentDepartment!.id!] =
                            currentDepartment!;

                        setState(() {
                          contentPanel = departmentPanel();
                        });
                      }
                    },
                    onDelete: () {
                      // Do nothing, no delete action for new department
                    }),
                actionBtns: null,
              );
            },
          );
        }, null, text: 'Nuevo Departamento'),
      ],
    );

    createFullTree();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        titleBar,
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [toolsBar, space(height: 10), ...treeView],
              )),
        ),
        // Padding(padding: const EdgeInsets.all(5), child: toolsBar),
        // Padding(
        //     padding: const EdgeInsets.all(5),
        //     child: Column(children: treeView)),
      ] // ListView.builder
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    profile = context.watch<ProfileProvider>().profile;

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
