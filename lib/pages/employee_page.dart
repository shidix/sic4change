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
  bool altasVisible = true;
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
      if (mounted) {
        setState(() {});
      }
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

    Widget toolsEmployee = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        addBtnRow(context, dialogFormEmployee, -1),
        altasVisible
            ? gralBtnRow(context, (context) {
                altasVisible = false;
                setState(() {
                  contentPanel = content(context);
                });
              }, null, text: 'Ver Bajas', icon: Icons.thumb_down)
            : gralBtnRow(context, (context) {
                altasVisible = true;
                setState(() {
                  contentPanel = content(context);
                });
              }, null, text: 'Ver Altas', icon: Icons.thumb_up),
      ],
    );
    employees.sort(compareEmployee);

    List<Employee> employeesFiltered = employees
        .where((element) => element.isActive() == altasVisible)
        .toList();

    Widget listEmployees = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                return headerListBgColor;
              }),
              sortAscending: orderDirection == 1,
              sortColumnIndex: sortColumnIndex,
              columns: [
                'Código',
                'Apellidos, Nombre',
                'Fecha Nac.',
                'Alta',
                'Baja',
                'Cargo',
                'Días C.',
                'Salario',
                'Email',
                ''
              ].map((e) {
                return DataColumn(
                  onSort: (columnIndex, ascending) {
                    sortColumnIndex = columnIndex;
                    orderDirection = ascending ? 1 : -1;
                    if (mounted) {
                      setState(() {
                        contentPanel = content(context);
                      });
                    }
                  },
                  label: Text(
                    e,
                    style: headerListStyle,
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
              rows: employeesFiltered.map((e) {
                e.bornDate ??= DateTime.now();
                if (e.bornDate!.isAfter(
                    DateTime.now().subtract(const Duration(days: 365 * 16)))) {
                  e.bornDate =
                      DateTime.now().subtract(const Duration(days: 365 * 16));
                }
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08);
                    }
                    if (employees.indexOf(e).isEven) {
                      return e.isActive()
                          ? Colors.grey[200]
                          : Colors.red.shade50;
                    } else {
                      return e.isActive() ? Colors.white : Colors.red.shade100;
                    }
                  }),
                  cells: [
                    DataCell(
                      Text(e.code),
                    ),
                    DataCell(
                        Text('${e.lastName1} ${e.lastName2}, ${e.firstName}')),
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(
                        (e.bornDate != null) ? e.bornDate! : DateTime.now()))),
                    DataCell(
                        Text(DateFormat('dd/MM/yyyy').format(e.getAltaDate()))),
                    DataCell(Text((e.getBajaDate().isAfter(
                            DateTime.now().add(const Duration(days: 3650))))
                        ? ' Indefinido'
                        : ' ${DateFormat('dd/MM/yyyy').format(e.getBajaDate())}')),
                    DataCell(Text(e.position)),
                    DataCell(Text(e.altaDays().toString())),
                    DataCell(Text(toCurrency(e.getSalary()))),
                    DataCell(Text(e.email)),
                    DataCell(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.folder),
                            onPressed: () {
                              dialogDocuments(context, employees.indexOf(e));
                            },
                          ),
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                dialogFormEmployee(
                                    context, employees.indexOf(e));
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
                                          codeEmployee: e.code)));
                            },
                          ),
                          (e.isActive())
                              ? iconBtnConfirm(
                                  context, dialogFormBaja, employees.indexOf(e),
                                  text: 'Dar de baja', icon: Icons.thumb_down)
                              : iconBtnConfirm(
                                  context, dialogFormAlta, employees.indexOf(e),
                                  text: 'Dar de alta', icon: Icons.thumb_up),
                          removeConfirmBtn(context, () {
                            e.delete().then((value) {
                              employees.remove(e);
                              setState(() {
                                contentPanel = content(context);
                              });
                            });
                          }, null),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            )));

    return Card(
      child: Column(children: [
        titleBar,
        Padding(padding: const EdgeInsets.all(5), child: toolsEmployee),
        Padding(padding: const EdgeInsets.all(5), child: listEmployees),
      ] // ListView.builder
          ),
    );
  }

  void dialogDocuments(BuildContext context, int index) {
    showDialog<void>(
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
              title: 'Documentos del empleado ${employee.code}',
              icon: Icons.folder,
              content: EmployeeDocumentsForm(selectedItem: employee),
              actionBtns: null);
        });
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
