import 'dart:collection';

import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        label:
            '${last.name} - Supervisor: $managerName\nEmpleados: $employeesNames',
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

  void dialogDeleteDepartment(BuildContext contextt) {
    Department department = currentDepartment!;
    parentDepartment = department.parent;
    showDialog(
        context: context,
        builder: (context) {
          return CustomPopupDialog(
            context: context,
            title: 'Eliminar Departamento',
            icon: Icons.delete,
            content: Text(
                '¿Está seguro de que desea eliminar el departamento ${department.name}?'),
            actionBtns: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  allDepartments.removeWhere((d) => d.id == department.id);
                  departmentsHash.remove(department.id);
                  await department.delete();
                  if (mounted) {
                    setState(() {
                      contentPanel = departmentPanel();
                    });
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Eliminar'),
              ),
            ],
          );
        });
  }

  Department dialogEditDepartment(BuildContext contextt) {
    Department department = currentDepartment!;
    parentDepartment = department.parent;
    showDialog(
        context: context,
        builder: (context) {
          return CustomPopupDialog(
            context: context,
            title: 'Editar Departamento',
            icon: Icons.edit,
            content: DepartmentForm(
                profile: profile,
                department: department,
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
      while (Provider.of<ProfileProvider>(context, listen: false).profile ==
          null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      currentOrganization = await Organization.byDomain(
          FirebaseAuth.instance.currentUser!.email!);
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

      setState(() {
        allDepartments = aux;
        employees = results[1] as List<Employee>;
        contentPanel = departmentPanel();
        mainMenuPanel = mainMenu(context, "/rrhh");
        secondaryMenuPanel = secondaryMenu(context, HIERARCHY_ITEM);

        // for (Department d in allDepartments) {
        //   departmentsHash[d.id!] = d;
        //   expanded[d.id!] = false;
        // }

        // for (Department d in allDepartments) {
        //   if (d.parent == '') {
        //     departments.add(d);
        //   }
        // }

        // for (Department d in departments) {
        //   departmentKeys[d.id!] = d.name;
        //   String parent = d.parent!;
        //   while (parent != '') {
        //     if (departmentsHash[parent] == null) {
        //       parent = '';
        //       break;
        //     }
        //     departmentKeys[d.id!] =
        //         '${departmentsHash[parent]!.name}>${departmentKeys[d.id!]!}';
        //     parent = departmentsHash[parent]!.parent!;
        //   }
        // }

        // departments.sort((a, b) =>
        //     departmentKeys[a.id!]!.compareTo(departmentKeys[b.id!]!));

        // currentOrganization = organizations.isNotEmpty ? organizations.first : null;

        // createFullTree();
      });
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
    mainMenuPanel = mainMenu(context, "/rrhh");
    secondaryMenuPanel = secondaryMenu(context, HIERARCHY_ITEM);
    initializeData(context);
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

    createFullTree();
    return SingleChildScrollView(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(flex: 2, child: Column(children: [titleBar, ...treeView])),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBar,
                    toolsBar,
                    space(height: 10),
                    ...treeView,
                    // SizedBox(width: double.infinity, child: departmentsTable),
                  ],
                ),
              ),
            ),
          ]),
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
