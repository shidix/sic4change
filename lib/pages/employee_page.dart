import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/pages/nominas_page.dart';
import 'package:sic4change/services/form_employee.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';

class EmployeesPage extends StatefulWidget {
  final Profile? profile;
  const EmployeesPage({Key? key, this.profile}) : super(key: key);

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  GlobalKey mainMenuKey = GlobalKey();
  Profile? profile;
  List<Employee> employees = [];
  Widget contentPanel = const Text('Loading...');
  Widget mainMenuPanel = const Text('');
  Widget secondaryMenuPanel = const Row(children: []);
  int sortColumnIndex = 1;
  int orderDirection = 1;

  int compareEmployee(Employee a, Employee b) {
    switch (sortColumnIndex) {
      case 0:
        return a.code.compareTo(b.code) * orderDirection;
      case 1:
        return a.compareTo(b) * orderDirection;
      case 2:
        return a.getAltaDate().compareTo(b.getAltaDate()) * orderDirection;
      case 3:
        return a.getBajaDate().compareTo(b.getBajaDate()) * orderDirection;
      case 4:
        return a.email.compareTo(b.email) * orderDirection;
      default:
        return a.compareTo(b) * orderDirection;
    }
  }

  @override
  void initState() {
    super.initState();
    Employee.getEmployees().then((value) {
      employees = value;
      contentPanel = content(context);
      setState(() {});
    });
    secondaryMenuPanel = secondaryMenu(context, EMPLOYEE_ITEM, profile);
    if (widget.profile == null) {
      Profile.getProfile(FirebaseAuth.instance.currentUser!.email!)
          .then((value) {
        profile = value;
        mainMenuPanel = mainMenuOperator(context,
            url: "/rrhh", profile: profile, key: mainMenuKey);

        if (mounted) {
          setState(() {});
        }
      });
    } else {
      profile = widget.profile;
      mainMenuPanel = mainMenuOperator(context,
          url: "/rrhh", profile: profile, key: mainMenuKey);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget content(context) {
    return Column(
      children: [
        employessPanel(context),
      ],
    );
  }

  Widget employessPanel(context) {
    Widget titleBar = s4cTitleBar(const Padding(
        padding: EdgeInsets.all(5),
        child: Text('Listado de Empleados',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold))));

    Widget toolsNomina = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [addBtnRow(context, dialogFormEmployee, -1)],
    );
    employees.sort(compareEmployee);

    //employees.sort((a, b) => a.compareTo(b));

    Widget listEmployees = ListView.builder(
      shrinkWrap: true,
      itemCount: employees.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
              color: headerListBgColor,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Row(children: [
                            iconBtn(context, (context) {
                              sortColumnIndex = 0;
                              orderDirection = 1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_downward_outlined,
                                text: 'Ordenar por código'),
                            const Text(
                              'Código',
                              style: headerListStyle,
                            ),
                            iconBtn(context, (context) {
                              sortColumnIndex = 0;
                              orderDirection = -1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_upward_outlined,
                                text: 'Ordenar por Código'),
                          ])),
                      Expanded(
                          flex: 1,
                          child: Row(children: [
                            iconBtn(context, (context) {
                              sortColumnIndex = 1;
                              orderDirection = 1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_downward_outlined,
                                text: 'Ordenar por nombre'),
                            Text('Apellidos, Nombre', style: headerListStyle),
                            iconBtn(context, (context) {
                              sortColumnIndex = 1;
                              orderDirection = -1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_upward_outlined,
                                text: 'Ordenar por nombre'),
                          ])),
                      Expanded(
                          flex: 1,
                          child: Row(children: [
                            iconBtn(context, (context) {
                              sortColumnIndex = 2;
                              orderDirection = 1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_downward_outlined,
                                text: 'Ordenar por fecha de alta'),
                            const Text(
                              'Fecha Alta',
                              style: headerListStyle,
                            ),
                            iconBtn(context, (context) {
                              sortColumnIndex = 2;
                              orderDirection = -1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_upward_outlined,
                                text: 'Ordenar por fecha de alta'),
                          ])),
                      Expanded(
                          flex: 1,
                          child: Row(children: [
                            iconBtn(context, (context) {
                              sortColumnIndex = 3;
                              orderDirection = 1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_downward_outlined,
                                text: 'Ordenar por fecha de baja'),
                            const Text(
                              'Fecha de baja',
                              style: headerListStyle,
                            ),
                            iconBtn(context, (context) {
                              sortColumnIndex = 3;
                              orderDirection = -1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_upward_outlined,
                                text: 'Ordenar por fecha de baja'),
                          ])),
                      Expanded(
                          flex: 1,
                          child: Row(children: [
                            iconBtn(context, (context) {
                              sortColumnIndex = 4;
                              orderDirection = 1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_downward_outlined,
                                text: 'Ordenar por email'),
                            const Text(
                              'Email',
                              style: headerListStyle,
                              textAlign: TextAlign.center,
                            ),
                            iconBtn(context, (context) {
                              sortColumnIndex = 4;
                              orderDirection = -1;
                              setState(() {
                                contentPanel = content(context);
                              });
                            }, null,
                                icon: Icons.arrow_upward_outlined,
                                text: 'Ordenar por email'),
                          ])),
                      const Expanded(flex: 1, child: Text('')),
                    ],
                  )));
        } else {
          Employee employee = employees[index - 1];
          Color? colorRow;
          if (index.isEven) {
            colorRow =
                employee.isActive() ? Colors.grey[200] : Colors.red.shade50;
          } else {
            colorRow = employee.isActive() ? Colors.white : Colors.red.shade100;
          }
          return Container(
              color: colorRow,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Text(employee.code)),
                      Expanded(
                          flex: 1,
                          child: Text(
                              '${employee.lastName1} ${employee.lastName2}, ${employee.firstName}')),
                      Expanded(
                          flex: 1,
                          child: Text(DateFormat('dd/MM/yyyy')
                              .format(employee.getAltaDate()))),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            (employee.isActive() &&
                                    !employee.getBajaDate().isAfter(
                                        DateTime.now()
                                            .add(const Duration(days: 3650))))
                                ? const Tooltip(
                                    message: 'Baja planificada',
                                    child: Icon(Icons.restore,
                                        color: Colors.green))
                                : Container(),
                            Text((employee.getBajaDate().isAfter(DateTime.now()
                                    .add(const Duration(days: 3650))))
                                ? ' Indefinido'
                                : ' ${DateFormat('dd/MM/yyyy').format(employee.getBajaDate())}'),
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child:
                              Text(employee.email, textAlign: TextAlign.left)),
                      Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    dialogFormEmployee(context, index - 1);
                                  }),
                              IconButton(
                                icon: const Icon(Icons.euro_symbol),
                                tooltip: 'Nóminas del empleado',
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => NominasPage(
                                              profile: profile,
                                              codeEmployee: employee.email)));
                                },
                              ),
                              (employee.isActive())
                                  ? iconBtnConfirm(
                                      context, dialogFormBaja, index - 1,
                                      text: 'Dar de baja',
                                      icon: Icons.thumb_down)
                                  : iconBtnConfirm(
                                      context, dialogFormAlta, index - 1,
                                      text: 'Dar de alta',
                                      icon: Icons.thumb_up),
                              removeConfirmBtn(context, () {
                                employee.delete().then((value) {
                                  employees.removeAt(index - 1);
                                  setState(() {
                                    contentPanel = content(context);
                                  });
                                });
                              }, null),
                            ],
                          ))
                    ],
                  )));
        }
      },
    );

    return Card(
      child: Column(children: [
        titleBar,
        Padding(padding: const EdgeInsets.all(5), child: toolsNomina),
        Padding(padding: const EdgeInsets.all(5), child: listEmployees),
      ] // ListView.builder
          ),
    );
  }

  void dialogFormEmployee(BuildContext context, int index) {
    showDialog<Employee>(
        context: context,
        builder: (BuildContext context) {
          Employee? employee;
          if (index == -1) {
            employee = Employee.getEmpty();
          } else {
            employee = employees[index];
          }
          return CustomPopupDialog(
              context: context,
              title: 'Empleado',
              icon: Icons.add_outlined,
              content: EmployeeForm(selectedItem: employee),
              actionBtns: null);
        }).then(
      (value) {
        if (value != null) {
          if (index == -1) {
            employees.add(value);
          } else {
            employees[index] = value;
          }
          setState(() {
            contentPanel = content(context);
          });
        }
      },
    );
  }

  void dialogFormBaja(BuildContext context, int index) {
    showDialog<Employee>(
        context: context,
        builder: (BuildContext context) {
          Employee? employee;
          if (index >= employees.length) {
            //show error message
            return AlertDialog(
              title: s4cTitleBar('Error', context, Icons.error),
              content: const Text('No se puede dar de baja al empleado'),
            );
          } else {
            employee = employees[index];
          }
          return AlertDialog(
            title: s4cTitleBar('Bajas de empleado', context, Icons.thumb_down),
            content: EmployeeBajaForm(
              selectedItem: employee,
            ),
          );
        }).then(
      (value) {
        if (value != null) {
          if (index == -1) {
            employees.add(value);
          } else {
            employees[index] = value;
          }
          setState(() {
            contentPanel = content(context);
          });
        }
      },
    );
  }

  void dialogFormAlta(BuildContext context, int index) {
    showDialog<Employee>(
        context: context,
        builder: (BuildContext context) {
          Employee? employee;
          if ((index >= employees.length) || (index < 0)) {
            //show error message
            return AlertDialog(
              title: s4cTitleBar('Error', context, Icons.error),
              content: const Text('No se puede dar de alta al empleado'),
            );
          } else {
            employee = employees[index];
          }
          return AlertDialog(
            title: s4cTitleBar('Altas de empleado', context, Icons.thumb_up),
            content: EmployeeAltaForm(
              selectedItem: employee,
            ),
          );
        }).then(
      (value) {
        if (value != null) {
          employees[index] = value;
          setState(() {
            contentPanel = content(context);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return to login_page if profile is null
    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuOperator(context, url: "/rrhh", profile: profile),
              const CircularProgressIndicator(),
              const Text(
                'Loading profile...',
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mainMenuPanel,
              Padding(
                  padding: const EdgeInsets.all(30), child: secondaryMenuPanel),
              contentPanel,
            ],
          ),
        ),
      );
    }
  }
}
