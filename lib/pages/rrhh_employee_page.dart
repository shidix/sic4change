import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/pages/rrhh_nominas_page.dart';
import 'package:sic4change/services/form_employee.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/models_rrhh.dart';
import 'package:sic4change/services/register_form.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/rrhh_menu_widget.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  bool altasVisible = true;
  GlobalKey mainMenuKey = GlobalKey();
  late final Profile profile;
  List<Employee> employees = [];
  Widget contentPanel = const Text('Loading...');
  Widget mainMenuPanel = const Text('');
  Widget secondaryMenuPanel = const Row(children: []);
  int sortColumnIndex = 1;
  int orderDirection = 1;

  String employeeFilter = '';
  double minSalaryFilter = 0.0;
  double maxSalaryFilter = 1e6;
  String positionFilter = '';
  DateTime minBornDateFilter =
      DateTime.now().subtract(const Duration(days: 365 * 100));
  DateTime maxBornDateFilter = DateTime.now();
  DateTime minAltaDateFilter =
      DateTime.now().subtract(const Duration(days: 365 * 10));
  DateTime maxAltaDateFilter =
      DateTime.now().add(const Duration(days: 365 * 1));
  DateTime minBajaDateFilter =
      DateTime.now().subtract(const Duration(days: 365 * 10));
  DateTime maxBajaDateFilter =
      DateTime.now().add(const Duration(days: 365 * 100));

  late List<bool> selectedEmployees;

  Future<void> exportToCVS(filename) async {
    String csv =
        'Código,Apellidos,Nombre,Fecha Nac.,Alta,Baja,Cargo,Días C.,Salario,Email\n';
    employeeFilter = employeeFilter.toLowerCase();
    List<Employee> employeesFiltered = employees
        .where((Employee element) =>
            element.isActive() == altasVisible &&
            (element.getFullName().toLowerCase().contains(employeeFilter) ||
                (element.code.toLowerCase().startsWith(employeeFilter)) ||
                (element.email.toLowerCase().contains(employeeFilter))) &&
            (element
                    .getPosition()
                    .toLowerCase()
                    .contains(positionFilter.toLowerCase()) ||
                (positionFilter == '')) &&
            element.getSalary() >= minSalaryFilter &&
            element.getSalary() <= maxSalaryFilter &&
            element.getBornDate().isAfter(minBornDateFilter) &&
            element.getBornDate().isBefore(maxBornDateFilter) &&
            element.getAltaDate().isAfter(minAltaDateFilter))
        .toList();
    for (var element in employeesFiltered) {
      csv +=
          '${element.code},${element.lastName1} ${element.lastName2},${element.firstName},${DateFormat('dd/MM/yyyy').format(element.bornDate!)},${DateFormat('dd/MM/yyyy').format(element.getAltaDate())},${DateFormat('dd/MM/yyyy').format(element.getBajaDate())},${element.getPosition()},${element.altaDays()},${element.getSalary()},${element.email}\n';
    }
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', "$filename.csv")
      ..click();
  }

  int compareEmployee(Employee a, Employee b) {
    switch (sortColumnIndex) {
      case 0:
        return a.code.compareTo(b.code) * orderDirection;
      case 1:
        return a.compareTo(b) * orderDirection;
      case 2:
        return a.bornDate!.compareTo(b.bornDate!) * orderDirection;
      case 3:
        return a.getAltaDate().compareTo(b.getAltaDate()) * orderDirection;
      case 4:
        return a.getBajaDate().compareTo(b.getBajaDate()) * orderDirection;
      case 5:
        return a.getPosition().compareTo(b.getPosition()) * orderDirection;
      case 6:
        return a.altaDays().compareTo(b.altaDays()) * orderDirection;
      case 7:
        return a.getSalary().compareTo(b.getSalary()) * orderDirection;
      case 8:
        return a.email.compareTo(b.email) * orderDirection;
      case 9:
        return a.email.compareTo(b.email) * orderDirection;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    mainMenuPanel = mainMenu(context, "/rrhh");

    profile = Provider.of<ProfileProvider>(context, listen: false).profile ??
        Profile.getEmpty();

    Employee.getEmployees().then((value) {
      employees = value;
      selectedEmployees = List.filled(employees.length, true);
      // contentPanel = content(context);
      if (mounted) {
        setState(() {
          contentPanel = content(context);
        });
      }
    });
    secondaryMenuPanel = secondaryMenu(context, EMPLOYEE_ITEM);

    // if (widget.profile == null) {
    //   Profile.getProfile(FirebaseAuth.instance.currentUser!.email!)
    //       .then((value) {
    //     profile = value;
    //     mainMenuPanel = mainMenuOperator(context,
    //         url: "/rrhh", profile: profile, key: mainMenuKey);

    //     if (mounted) {
    //       setState(() {});
    //     }
    //   });
    // } else {
    //   profile = widget.profile;
    //   mainMenuPanel = mainMenuOperator(context,
    //       url: "/rrhh", profile: profile, key: mainMenuKey);
    //   secondaryMenuPanel = secondaryMenu(context, EMPLOYEE_ITEM, profile);

    //   if (mounted) {
    //     setState(() {});
    //   }
    // }
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
        gralBtnRow(context, (context) async {
          String? filename = await showDialog(
              context: context, builder: (context) => const FileNameDialog());
          if (filename != null && filename.isNotEmpty) exportToCVS(filename);
        }, null, text: 'Exportar', icon: Icons.download),
      ],
    );
    employees.sort(compareEmployee);

    Widget filterPanel = Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
                labelText: 'Filtrar por empleado',
                hintText: 'Nombre, apellidos o DNI/NIE/ID/Email',
                prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              if (value.isNotEmpty) {
                employeeFilter = value;
              } else {
                employeeFilter = '';
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ), //
        // Filter by salary
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Salario anual mínimo',
                hintText: toCurrency(minSalaryFilter),
                prefixIcon: const Icon(Icons.search)),
            onChanged: (value) {
              try {
                minSalaryFilter = double.parse(value);
              } catch (e) {
                minSalaryFilter = 0.0;
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                labelText: 'Salario anual máximo',
                hintText: toCurrency(maxSalaryFilter),
                prefixIcon: const Icon(Icons.search)),
            onChanged: (value) {
              try {
                maxSalaryFilter = double.parse(value);
              } catch (e) {
                maxSalaryFilter = 1e6;
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
                labelText: 'Filtrar por cargo',
                hintText: 'Cargo o categoría',
                prefixIcon: Icon(Icons.search)),
            onChanged: (value) {
              if (value.isNotEmpty) {
                positionFilter = value;
              } else {
                positionFilter = '';
              }
              if (mounted) {
                setState(() {
                  contentPanel = content(context);
                });
              }
            },
          ),
        ),
        Expanded(
          child: FilterDateField(
              labelText: 'Alta desde',
              bottom: 17,
              minYear: 1900,
              maxYear: 2100,
              selectedDate: minAltaDateFilter,
              onSelectedDate: (value) {
                minAltaDateFilter = value;
                if (mounted) {
                  setState(() {
                    contentPanel = content(context);
                  });
                }
              }),
        ),
        Expanded(
          child: FilterDateField(
              labelText: 'Alta hasta',
              bottom: 17,
              minYear: 1900,
              maxYear: 2100,
              selectedDate: maxAltaDateFilter,
              onSelectedDate: (value) {
                maxAltaDateFilter = value;
                if (mounted) {
                  setState(() {
                    contentPanel = content(context);
                  });
                }
              }),
        ),
        // Filter by baja date
        Expanded(
          child: FilterDateField(
              labelText: 'Baja desde',
              bottom: 17,
              minYear: 1900,
              maxYear: 2100,
              selectedDate: minBajaDateFilter,
              onSelectedDate: (value) {
                minBajaDateFilter = value;
                if (mounted) {
                  setState(() {
                    contentPanel = content(context);
                  });
                }
              }),
        ),
        Expanded(
          child: FilterDateField(
              labelText: 'Baja hasta',
              bottom: 17,
              minYear: 1900,
              maxYear: 2100,
              selectedDate: maxBajaDateFilter,
              onSelectedDate: (value) {
                maxBajaDateFilter = value;
                if (mounted) {
                  setState(() {
                    contentPanel = content(context);
                  });
                }
              }),
        ),
      ],
    );
    employeeFilter = employeeFilter.toLowerCase();

    List<Employee> employeesFiltered = employees
        .where((Employee element) =>
            element.isActive() == altasVisible &&
            (element.getFullName().toLowerCase().contains(employeeFilter) ||
                (element.code.toLowerCase().startsWith(employeeFilter)) ||
                (element.email.toLowerCase().contains(employeeFilter)) ||
                (employeeFilter.isEmpty)) &&
            (element
                    .getPosition()
                    .toLowerCase()
                    .contains(positionFilter.toLowerCase()) ||
                (positionFilter == '')) &&
            element.getSalary() >= minSalaryFilter &&
            element.getSalary() <= maxSalaryFilter &&
            // element.getBornDate().isAfter(minBornDateFilter) &&
            // element.getBornDate().isBefore(maxBornDateFilter) &&
            element.getAltaDate().isAfter(minAltaDateFilter) &&
            element.getAltaDate().isBefore(maxAltaDateFilter) &&
            element.getBajaDate().isAfter(minBajaDateFilter) &&
            element.getBajaDate().isBefore(maxBajaDateFilter))
        .toList();

    DataTable dataTable = DataTable(
      headingRowColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        return headerListBgColor;
      }),
      sortAscending: orderDirection == 1,
      sortColumnIndex: sortColumnIndex,
      columns: [
        'Código',
        'Apellidos, Nombre',
        // 'Fecha Nac.',
        'Alta',
        'Baja',
        // 'Cargo',
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
        if (e.bornDate!
            .isAfter(DateTime.now().subtract(const Duration(days: 365 * 16)))) {
          e.bornDate = DateTime.now().subtract(const Duration(days: 365 * 16));
        }
        return DataRow(
          color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
            }
            if (employeesFiltered.indexOf(e).isEven) {
              return e.isActive() ? Colors.grey[200] : Colors.red.shade50;
            } else {
              return e.isActive() ? Colors.white : Colors.red.shade100;
            }
          }),
          cells: [
            DataCell(
              Text(e.code),
            ),
            DataCell(Text('${e.lastName1} ${e.lastName2}, ${e.firstName}')),
            // DataCell(Text(DateFormat('dd/MM/yyyy').format((e.bornDate != null) ? e.bornDate! : DateTime.now()))),
            DataCell(Text(DateFormat('dd/MM/yyyy').format(e.getAltaDate()))),
            DataCell(Text((e
                    .getBajaDate()
                    .isAfter(DateTime.now().add(const Duration(days: 3650))))
                ? ' Indefinido'
                : ' ${DateFormat('dd/MM/yyyy').format(e.getBajaDate())}')),
            // DataCell(Text(e.getPosition())),
            DataCell(Text(e.altaDays().toString())),
            DataCell(Text(toCurrency(e.getSalary()),
                style: (e.getSalary() <= 0.0)
                    ? const TextStyle(color: Colors.red)
                    : null)),
            DataCell(Text(e.email)),
            DataCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder),
                    tooltip: 'Documentos del empleado',
                    onPressed: () {
                      dialogDocuments(context, employees.indexOf(e));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.badge_outlined),
                    tooltip: 'Información del empleado',
                    onPressed: () {
                      showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return EmployeeInfoCard(employee: e);
                          });
                    },
                  ),
                  e.isActive()
                      ? IconButton(
                          icon: const Icon(Icons.trending_up_outlined),
                          tooltip: 'Modificar salario',
                          onPressed: () {
                            dialogModifySalary(context, employees.indexOf(e));
                          },
                        )
                      : Container(),
                  e.isActive()
                      ? IconButton(
                          icon: const Icon(Icons.access_time_outlined),
                          tooltip: 'Modificar jornada laboral',
                          onPressed: () {
                            dialogModifyShift(context, employees.indexOf(e));
                          },
                        )
                      : Container(),
                  (e.isActive() || (!e.isActive()))
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            dialogFormEmployee(context, employees.indexOf(e));
                          })
                      : Container(),
                  //Button for RegisterForm
                  IconButton(
                    icon: const Icon(Icons.lock),
                    tooltip: 'Credenciales',
                    onPressed: () {
                      dialogFormRegister(context, employees.indexOf(e));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.euro_symbol),
                    tooltip: 'Nóminas del empleado',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NominasPage(codeEmployee: e.code)));
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
    );

    // SingleChildScrollView(
    //     scrollDirection: Axis.vertical,
    //     child: SingleChildScrollView(
    //         controller: ScrollController(),
    //         scrollDirection: Axis.horizontal,
    //         child: dataTable));

    Widget listEmployees = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            child: dataTable));

    return Card(
      child: Column(children: [
        titleBar,
        Padding(padding: const EdgeInsets.all(5), child: toolsEmployee),
        Padding(padding: const EdgeInsets.all(5), child: filterPanel),
        Padding(padding: const EdgeInsets.all(5), child: listEmployees),
      ] // ListView.builder
          ),
    );
  }

  void dialogModifySalary(BuildContext context, int index) {
    showDialog<Employee>(
        context: context,
        builder: (BuildContext context) {
          Employee? employee;
          if (index >= employees.length) {
            //show error message
            return AlertDialog(
              title: s4cTitleBar('Error', context, Icons.error),
              content: const Text('No se puede modificar el salario'),
            );
          } else {
            employee = employees[index];
          }
          return AlertDialog(
            title: s4cTitleBar('Modificar salario', context, Icons.euro_symbol),
            content: EmployeeSalaryForm(
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

  void dialogModifyShift(BuildContext context, int index) {
    showDialog<Employee>(
        context: context,
        builder: (BuildContext context) {
          Employee? employee;
          if (index >= employees.length) {
            //show error message
            return AlertDialog(
              title: s4cTitleBar('Error', context, Icons.error),
              content: const Text('No se puede modificar la jornada laboral'),
            );
          } else {
            employee = employees[index];
          }
          return AlertDialog(
            title: s4cTitleBar('Modificar jornada', context,
                Icons.access_time_filled_outlined),
            content: EmployeeShiftForm(
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

  void dialogFormRegister(context, int indexOf) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          Employee? employee;
          if (indexOf >= employees.length) {
            //show error message
            return AlertDialog(
              title: s4cTitleBar('Error', context, Icons.error),
              content: const Text('No se puede registrar el usuario'),
            );
          } else {
            employee = employees[indexOf];
          }
          return AlertDialog(
            title: s4cTitleBar('Credenciales', context, Icons.lock),
            content: RegisterForm(
              email: employee.email,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // return to login_page if profile is null
    return SelectionArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            mainMenuPanel,
            Padding(
                padding: const EdgeInsets.all(30), child: secondaryMenuPanel),
            contentPanel,
            footer(context),
          ],
        ),
      ),
    ));
  }
}

class InfoField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final int flex;
  final TextAlign textAlign;
  final Function? onPressed;
  const InfoField(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      this.flex = 1,
      this.textAlign = TextAlign.left,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (onPressed != null) {
      return Expanded(
          flex: flex,
          child: GestureDetector(
              onTap: onPressed as void Function()?,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(icon),
                          Text(value,
                              textAlign: textAlign,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              )));
    } else {
      return Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.all(12), // Padding para el contenido
                  decoration: BoxDecoration(
                    color:
                        Colors.grey[300], // Fondo con una tonalidad más oscura
                    borderRadius:
                        BorderRadius.circular(8), // Bordes redondeados
                  ),
                  child: Row(
                    children: [
                      Icon(icon),
                      Text(value,
                          textAlign: textAlign,
                          style: const TextStyle(
                            fontSize:
                                16, // Tamaño de texto más grande para el contenido
                            color: Colors.black87, // Texto oscuro
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ));
    }
  }
}

class EmployeeInfoCard extends StatefulWidget {
  final Employee employee;
  const EmployeeInfoCard({super.key, required this.employee});

  @override
  State<EmployeeInfoCard> createState() => _EmployeeInfoCardState();
}

class _EmployeeInfoCardState extends State<EmployeeInfoCard> {
  @override
  Widget build(BuildContext context) {
    List<Row> contracts = [];

    for (Alta alta in widget.employee.altas) {
      contracts.add(Row(children: [
        InfoField(
          icon: Icons.calendar_today,
          label: "Alta",
          value: DateFormat('dd/MM/yyyy').format(alta.date),
        ),
        InfoField(
            icon: Icons.calendar_today,
            label: "Baja",
            value: (alta.baja != null &&
                    alta.baja!.date.isBefore(
                        DateTime.now().add(const Duration(days: 3650))))
                ? DateFormat('dd/MM/yyyy').format(alta.baja!.date)
                : "Indefinido"),
        InfoField(
            label: "Puesto",
            icon: Icons.work,
            value: widget.employee.getPosition(),
            flex: 2),
        InfoField(
            label: "Categoría",
            icon: Icons.work,
            value: widget.employee.getCategory(),
            flex: 2),
        InfoField(
          icon: Icons.euro,
          label: "Salario (${alta.salary.length})",
          value: (alta.salary.isNotEmpty)
              ? toCurrency(alta.salary.last.amount)
              : toCurrency(0.0),
          onPressed: () {
            showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return CustomPopupDialog(
                      context: context,
                      title: 'Histórico de Salario',
                      icon: Icons.euro,
                      content: SizedBox(
                          child: SingleChildScrollView(
                              child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: alta.salary
                            .map((e) => Row(children: [
                                  InfoField(
                                      icon: Icons.calendar_today,
                                      value: DateFormat('dd/MM/yyyy')
                                          .format(e.date),
                                      label: 'Fecha de actualización'),
                                  InfoField(
                                      icon: Icons.euro,
                                      label: 'Nuevo salario anual',
                                      value: toCurrency(e.amount))
                                ]))
                            .toList(),
                      ))),
                      actionBtns: null);
                });
          },
        ),
        InfoField(
          label: 'Días de contrato',
          icon: Icons.work_history_outlined,
          value: alta.altaDays().toString().padLeft(4, '0'),
          textAlign: TextAlign.right,
        ),
      ]));
    }
    return CustomPopupDialog(
        context: context,
        actionBtns: const [],
        title: 'Información del empleado',
        icon: Icons.badge_outlined,
        content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            Row(children: [
                              InfoField(
                                  icon: Icons.fingerprint,
                                  label: 'Código',
                                  value: widget.employee.code),
                              InfoField(
                                  icon: Icons.calendar_today,
                                  label: 'Fecha de nacimiento',
                                  value: DateFormat('dd/MM/yyyy')
                                      .format(widget.employee.bornDate!)),
                              InfoField(
                                  icon: Icons.person,
                                  label: 'Nombre y apellidos',
                                  value:
                                      '${widget.employee.lastName1} ${widget.employee.lastName2}, ${widget.employee.firstName}',
                                  flex: 3),
                              InfoField(
                                  icon: Icons.email,
                                  label: 'Email',
                                  value: widget.employee.email,
                                  flex: 3),
                            ]),
                            const Divider(),

                            ...contracts,
                            // InfoField(icon: Icons.calendar_today,
                            //     label: 'Fecha de alta',
                            //     value: DateFormat('dd/MM/yyyy')
                            //         .format(widget.employee.getAltaDate())),
                            // InfoField(icon: Icons.calendar_today,
                            //     label: 'Fecha de baja',
                            //     value: DateFormat('dd/MM/yyyy')
                            //         .format(widget.employee.getBajaDate())),
                            // InfoField(icon: Icons.work,
                            //   label: 'Cargo', value: widget.employee.position),
                            // InfoField(
                            //     icon: Icons.calendar_today,
                            //     label: 'Días de contrato',
                            //     value: widget.employee.altaDays().toString()),
                            // InfoField(
                            //     icon: Icons.euro,
                            //     label: 'Salario',
                            //     value: toCurrency(widget.employee.getSalary())),
                          ],
                        )),
                  ),
                ],
              ),
            )));
  }
}
