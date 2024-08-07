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

    Widget listEmployees = ListView.builder(
      shrinkWrap: true,
      itemCount: employees.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
              color: headerListBgColor,
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text(
                            'Código',
                            style: headerListStyle,
                          )),
                      Expanded(
                          flex: 1,
                          child: Text('Apellidos, Nombre',
                              style: headerListStyle)),
                      Expanded(
                          flex: 1,
                          child: Text('Fecha Alta', style: headerListStyle)),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Fecha de baja',
                          style: headerListStyle,
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Text('Email',
                              style: headerListStyle,
                              textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text('')),
                    ],
                  )));
        } else {
          Employee employee = employees[index - 1];
          return Container(
              color: index.isEven ? Colors.grey[200] : Colors.white,
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text(employee.code)),
                  Expanded(
                      flex: 1,
                      child: Text(
                          '${employee.lastName1} ${employee.lastName2}, ${employee.firstName}')),
                  Expanded(
                      flex: 1,
                      child: employee.altas.isNotEmpty
                          ? Text(DateFormat('dd/MM/yyyy')
                              .format(getDate(employees[index - 1].altas.last)))
                          : const Text('--')),
                  Expanded(
                    flex: 1,
                    child: (employee.bajas.isNotEmpty)
                        ? Text(DateFormat('dd/MM/yyyy')
                            .format(getDate(employees[index - 1].bajas.last)))
                        : Text('ACTIVO'),
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(employee.email, textAlign: TextAlign.center)),
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
              ));
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
          return AlertDialog(
            title: s4cTitleBar('Empleado', context, Icons.add_outlined),
            content: EmployeeForm(
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
