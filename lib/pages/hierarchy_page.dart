import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/form_department.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';

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
  List<Widget> treeView = [];
  List<Department> allDepartments = [];
  Map<String, Department> departmentsHash = {};
  Map<String, bool> expanded = {};
  Map<String, String> departmentKeys = {};
  String? parentDepartment;
  Department? currentDepartment;
  

  List<Color> colors = [
    Colors.white,
    Colors.grey[100]!,
    Colors.grey[200]!,
    Colors.grey[400]!
  ];

  TreeNode? rootNode;

  void createFullTree() {
      Department rootDepartment = Department.getEmpty();
      rootDepartment.name = 'Departamentos';
      rootNode = TreeNode.createTreeNode(rootDepartment, null, level: -1,
          onSelected: (node) {
        setState(() {
          contentPanel = departmentPanel();
        });
      }, onMainSelected: (node) {});

      rootNode!.childrens = allDepartments
          .where((d) => d.parent == '')
          .map((d) => TreeNode.createTreeNode(d, rootNode, onSelected: (node) {
                setState(() {
                  expanded[d.id!] = node.expanded;
                  contentPanel = departmentPanel();
                });
              }, onMainSelected: (node) {
                currentDepartment = node.item as Department;
                dialogEditDepartment(context);
              }, allItems: allDepartments))
          .toList();

    }

  List<TreeNode> getTreeNodes(TreeNode? node, {int level = 0}) {

    List<TreeNode> nodes = [];
    if (node == null) return nodes;
    node.level = level;
    if (node.visible) {
      nodes.add(node);
    }
    if (node.childrens.isNotEmpty && node.expanded) {
      for (TreeNode child in node.childrens) {
        nodes.addAll(getTreeNodes(child, level: level + 1));
      }
    }
    return nodes;
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

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
    Department.getDepartments().then((value) {
      allDepartments = value;
      for (Department d in allDepartments) {
        expanded[d.id!] = false;
        departmentsHash[d.id!] = d;
      }
      departments = allDepartments.where((d) => d.parent == '').toList();

      for (Department d in departments) {
        expanded[d.id!] = true;
        departmentsHash[d.id!] = d;
      }
      for (Department d in departments) {
        departmentKeys[d.id!] = d.name;
        String parent = d.parent!;
        while (parent != '') {
          if (departmentsHash[parent] == null) {
            parent = '';
            break;
          }
          departmentKeys[d.id!] =
              '${departmentsHash[parent]!.name}>${departmentKeys[d.id!]!}';
          parent = departmentsHash[parent]!.parent!;
        }
      }

      departments.sort(
          (a, b) => departmentKeys[a.id!]!.compareTo(departmentKeys[b.id!]!));
      createFullTree();

      // Department rootDepartment = Department.getEmpty();
      // rootDepartment.name = 'Departamentos';
      // rootNode = TreeNode.createTreeNode(rootDepartment, null, level: -1,
      //     onSelected: (node) {
      //   setState(() {
      //     contentPanel = departmentPanel();
      //   });
      // }, onMainSelected: (node) {});

      // rootNode!.childrens = allDepartments
      //     .where((d) => d.parent == '')
      //     .map((d) => TreeNode.createTreeNode(d, rootNode, onSelected: (node) {
      //           setState(() {
      //             expanded[d.id!] = node.expanded;
      //             contentPanel = departmentPanel();
      //           });
      //         }, onMainSelected: (node) {
      //           currentDepartment = node.item as Department;
      //           dialogEditDepartment(context);
      //         }, allItems: allDepartments))
      //     .toList();

      contentPanel = departmentPanel();

      if (mounted) {
        setState(() {});
      }
    });
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
    Widget departmentsTable;

    createFullTree();
    treeView = getTreeNodes(rootNode);

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

      List<Department> departmentsRoot = departments;
      List<DataRow> rows = departmentsRoot
          .map((department) => DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    if (department.parent == '') {
                      return colors[0];
                    }
                    return colors[getLevel(department) % 4];
                  }),
                  cells: [
                    (department.parent == '')
                        ? DataCell(Text(department.name))
                        : DataCell(Text(
                            '${createIndentationFromDepartment(department)}${department.name}')),
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
                          IconButton(
                              icon: Icon((!expanded[department.id]!)
                                  ? Icons.expand_more_outlined
                                  : Icons.expand_less_outlined),
                              onPressed: () {
                                expanded[department.id!] =
                                    !expanded[department.id]!;
                                if (!expanded[department.id]!) {
                                  departments.removeWhere(
                                      (d) => d.parent == department.id);
                                } else {
                                  int index = departments.indexOf(department);
                                  List<Department> children = allDepartments
                                      .where((d) => d.parent == department.id)
                                      .toList();

                                  departments.insertAll(index + 1, children);
                                }
                                if (mounted) {
                                  contentPanel = departmentPanel();

                                  setState(() {});
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
              String parent = value.parent;
              if (parent == '') {
                departments.add(value);
              } else {
                int index = departments
                    .indexOf(departments.firstWhere((d) => d.id == parent));
                departments.insert(index + 1, value);
              }
              departmentsHash[value.id!] = value;
              while (parent != '') {
                expanded[parent] = true;
                parent = departmentsHash[parent]!.parent!;
              }

              // remove brothers

              expanded[value.id!] = false;
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

    createFullTree();
    treeView = getTreeNodes(rootNode);

    return SingleChildScrollView(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: Column(children: [titleBar, ...treeView])),
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
                    SizedBox(width: double.infinity, child: departmentsTable),
                  ],
                ),
              ),
            ),
          ]),
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
