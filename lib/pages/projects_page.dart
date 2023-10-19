import 'package:flutter/material.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/services/firebase_service.dart';
import 'package:sic4change/services/firebase_service_contact.dart';

//final pr = SProject("Proyecto de prueba", "Descripción del proyecto de prueba");
/*List<SProject> projects = [
  SProject("Proyecto de prueba", "Descripción del proyecto de prueba"),
  SProject("Proyecto de prueba 2", "Descripción del proyecto de prueba 2"),
  SProject("Proyecto de prueba 3", "Descripción del proyecto de prueba 3"),
  SProject("Proyecto de prueba 4", "Descripción del proyecto de prueba 4"),
];*/

const PROJECT_TITLE = "Proyectos";
List project_list = [];

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  void loadProjects() async {
    await getProjects().then((val) {
      project_list = val;
      //print(contact_list);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Service Page'),
      ),*/
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          projectsHeader(context),
          Expanded(
              child: Container(
            child: projectList(context),
            padding: EdgeInsets.all(10),
          ))
        ],
      ),
    );
  }

  Widget projectsHeader(context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          projectSearch(),
          space(width: 50),
        ],
      ),
    );
  }

  Widget projectSearch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(PROJECT_TITLE, style: TextStyle(fontSize: 20)),
        Container(
          width: 500,
          child: SearchBar(
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 10.0)),
            onTap: () {},
            onChanged: (_) {},
            leading: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }

  Widget projectList(context) {
    return FutureBuilder(
        future: getProjects(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            project_list = snapshot.data!;

            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: .8,
                ),
                itemCount: project_list.length,
                itemBuilder: (_, index) {
                  return projectCard(context, project_list[index]);
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget projectCard(context, _project) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: SingleChildScrollView(
        child: projectCardDatas(context, _project),
      ),
    );
  }

  Widget projectCardDatasHeader(context, _project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _project.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar proyecto',
              onPressed: () {
                _callProjectEditDialog(context, _project);
              },
            ),
          ],
        ),
        space(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            _project.description,
            style: TextStyle(fontSize: 15),
          ),
          space(height: 10),
          Text(
            _project.type.toUpperCase(),
            style: TextStyle(fontSize: 15, color: Colors.blueGrey),
          ),
        ]),
      ],
    );
  }

  Widget projectCardDatasFinancier(_project) {
    var _list = _project.financiers;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        customText("Financiador/es:", 16, textColor: Colors.grey),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Añadir financiador',
          onPressed: () {
            _callFinancierEditDialog(context, _project);
          },
        )
      ]),
      ListView.builder(
          //padding: const EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: _list.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                padding: EdgeInsets.all(5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_list[index]}'),
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          size: 12,
                        ),
                        tooltip: 'Eliminar financiador',
                        onPressed: () async {
                          _project.financiers.remove(_list[index]);
                          _removeFinancier(context, _project);
                        },
                      )
                    ]));
          })
    ]);
  }

  Widget projectCardDatasPartners(_project) {
    var _list = _project.partners;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        customText("Socios del proyecto/programa:", 16, textColor: Colors.grey),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Añadir socio',
          onPressed: () {
            _callPartnerEditDialog(context, _project);
          },
        )
      ]),
      ListView.builder(
          //padding: const EdgeInsets.all(8),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: _list.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                padding: EdgeInsets.all(5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_list[index]}'),
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          size: 12,
                        ),
                        tooltip: 'Eliminar socio',
                        onPressed: () async {
                          _project.partners.remove(_list[index]);
                          _removePartner(context, _project);
                        },
                      )
                    ]));
          })
    ]);
  }

  Widget projectCardDatas(context, _project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        projectCardDatasHeader(context, _project),
        space(height: 5),
        Divider(color: Colors.grey),
        space(height: 5),
        IntrinsicHeight(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText("En ejecución:", 16, textColor: Colors.green),
                  space(height: 5),
                  customLinearPercent(context, 4.5, 0.8, Colors.green),
                ],
              ),
              VerticalDivider(
                width: 10,
                color: Colors.grey,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                customText("Presupuesto total:   ${_project.budget} €", 16),
                space(height: 5),
                customLinearPercent(context, 4.5, 0.8, Colors.blue),
              ]),
            ],
          ),
        ),
        space(height: 5),
        Divider(color: Colors.grey),
        space(height: 5),
        customText("Responsable del proyecto:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(_project.manager, 16),
        space(height: 5),
        Divider(color: Colors.grey),
        space(height: 5),
        projectCardDatasFinancier(_project),
        space(height: 5),
        Divider(color: Colors.grey),
        space(height: 5),
        customText("Programa:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(_project.programme, 16),
        space(height: 5),
        Divider(color: Colors.grey),
        space(height: 5),
        projectCardDatasPartners(_project),
        space(height: 5),
        Divider(color: Colors.grey),
        space(height: 5),
        customText("País de ejecución:", 16, textColor: Colors.grey),
        space(height: 5),
        customText(_project.country, 16),
        space(height: 5),
        Divider(color: Colors.grey),
        space(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            customPushBtn(context, "+ Info", Icons.info, "/project_info",
                {"project": _project}),
            customPushBtn(context, "Marco técnico", Icons.task, "/goals",
                {"project": _project}),
            customPushBtn(context, "Presupuesto", Icons.euro, "/finns",
                {"project": _project}),
            customBtn(context, "Personal", Icons.people, "/projects", {}),
            /*customBtn(context, "Editar", Icons.edit, "/projects", {}),
            customBtn(
                context, "Eliminar", Icons.remove_circle, "/projects", {}),*/
          ],
        ),
        space(height: 5),
        Divider(color: Colors.grey),
      ],
    );
  }

  void _saveProject(context, _project, _types, _contacts, _programmes, _name,
      _desc, _type, _budget, _manager, _programme, _country) async {
    if (_project != null) {
      await updateProject(
              _project.id,
              _project.uuid,
              _name,
              _desc,
              _type,
              _budget,
              _manager,
              _programme,
              _country,
              _project.financiers,
              _project.partners)
          .then((value) async {
        loadProjects();
      });
    } else {
      await addProject(
              _name, _desc, _type, _budget, _manager, _programme, _country)
          .then((value) async {
        loadProjects();
      });
    }
    if (!_types.contains(_type)) await addProjectType(_type);
    if (!_contacts.contains(_manager))
      await addContact(_manager, "", [], "", "", "");
    if (!_programmes.contains(_programme)) await addProgramme(_programme);
    Navigator.of(context).pop();
  }

  void _callProjectEditDialog(context, _project) async {
    List<String> types = [];
    List<String> contacts = [];
    List<String> programmes = [];
    await getProjectTypes().then((value) async {
      for (ProjectType item in value) {
        types.add(item.name);
      }
      await getContacts().then((value) async {
        for (Contact item2 in value) {
          contacts.add(item2.name);
        }
        await getProgrammes().then((value) async {
          for (Programme item3 in value) {
            programmes.add(item3.name);
          }
          _editProjectDialog(context, _project, types, contacts, programmes);
        });
      });
    });
  }

  Future<void> _editProjectDialog(
      context, _project, _types, _contacts, _programmes) {
    TextEditingController nameController = TextEditingController(text: "");
    TextEditingController descController = TextEditingController(text: "");
    TextEditingController typeController = TextEditingController(text: "");
    TextEditingController budgetController = TextEditingController(text: "");
    TextEditingController managerController = TextEditingController(text: "");
    TextEditingController programmeController = TextEditingController(text: "");
    TextEditingController countryController = TextEditingController(text: "");

    if (_project != null) {
      nameController = TextEditingController(text: _project.name);
      descController = TextEditingController(text: _project.description);
      typeController = TextEditingController(text: _project.type);
      budgetController = TextEditingController(text: _project.budget);
      managerController = TextEditingController(text: _project.manager);
      programmeController = TextEditingController(text: _project.programme);
      countryController = TextEditingController(text: _project.country);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Project edit'),
          content: SingleChildScrollView(
            child: Column(children: [
              Row(children: <Widget>[
                customTextField(nameController, "Enter name"),
                space(width: 20),
                customTextField(descController, "Enter description"),
                space(width: 20),
                customAutocompleteField(
                    typeController, _types, "Write or select project type..."),
                space(width: 20),
                customTextField(budgetController, "Enter budget"),
              ]),
              Row(children: <Widget>[
                customAutocompleteField(
                    managerController, _contacts, "Write or select manager..."),
                space(width: 20),
                customAutocompleteField(programmeController, _programmes,
                    "Write or select programme..."),
                space(width: 20),
                customTextField(countryController, "Enter country"),
              ]),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveProject(
                    context,
                    _project,
                    _types,
                    _contacts,
                    _programmes,
                    nameController.text,
                    descController.text,
                    typeController.text,
                    budgetController.text,
                    managerController.text,
                    programmeController.text,
                    countryController.text);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           FINACIERS                                */
  /*--------------------------------------------------------------------*/
  void _saveFinancier(context, _project, _name, _financiers) async {
    _project.financiers.add(_name);
    await updateProjectFinanciers(_project.id, _project.financiers)
        .then((value) async {
      if (!_financiers.contains(_name)) await addFinancier(_name);
      loadProjects();
    });
    Navigator.of(context).pop();
  }

  void _removeFinancier(context, _project) async {
    await updateProjectFinanciers(_project.id, _project.financiers)
        .then((value) async {
      loadProjects();
    });
  }

  void _callFinancierEditDialog(context, _project) async {
    List<String> financiers = [];
    await getFinanciers().then((value) async {
      for (Financier item in value) {
        financiers.add(item.name);
      }

      _editProjectFinancierDialog(context, _project, financiers);
    });
  }

  Future<void> _editProjectFinancierDialog(context, _project, _financiers) {
    TextEditingController nameController = TextEditingController(text: "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Add financier'),
          content: SingleChildScrollView(
            child: Column(children: [
              customAutocompleteField(
                  nameController, _financiers, "Write or select financier..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _saveFinancier(
                    context, _project, nameController.text, _financiers);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*--------------------------------------------------------------------*/
  /*                           PARTNERS                                 */
  /*--------------------------------------------------------------------*/
  void _savePartner(context, _project, _name, _contacts) async {
    _project.partners.add(_name);
    await updateProjectPartners(_project.id, _project.partners)
        .then((value) async {
      if (!_contacts.contains(_name))
        await addContact(_name, "", [], "", "", "");
      loadProjects();
    });
    Navigator.of(context).pop();
  }

  void _removePartner(context, _project) async {
    await updateProjectPartners(_project.id, _project.partners)
        .then((value) async {
      loadProjects();
    });
  }

  void _callPartnerEditDialog(context, _project) async {
    List<String> contacts = [];
    await getContacts().then((value) async {
      for (Contact item in value) {
        contacts.add(item.name);
      }

      _editProjectPartnerDialog(context, _project, contacts);
    });
  }

  Future<void> _editProjectPartnerDialog(context, _project, _contacts) {
    TextEditingController nameController = TextEditingController(text: "");

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Add partner'),
          content: SingleChildScrollView(
            child: Column(children: [
              customAutocompleteField(
                  nameController, _contacts, "Write or select contact..."),
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _savePartner(context, _project, nameController.text, _contacts);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
