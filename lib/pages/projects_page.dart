import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/services/firebase_service.dart';

//final pr = SProject("Proyecto de prueba", "Descripción del proyecto de prueba");
/*List<SProject> projects = [
  SProject("Proyecto de prueba", "Descripción del proyecto de prueba"),
  SProject("Proyecto de prueba 2", "Descripción del proyecto de prueba 2"),
  SProject("Proyecto de prueba 3", "Descripción del proyecto de prueba 3"),
  SProject("Proyecto de prueba 4", "Descripción del proyecto de prueba 4"),
];*/

const PROJECT_TITLE = "Proyectos";

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
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
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .8,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (_, index) {
                return projectCard(context, snapshot.data?[index]);
                //return projectCard(context, projects[index]);
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
    child: projectCardDatas(context, _project),
  );
}

Widget projectCardDatas(context, _project) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _project.name,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      space(height: 10),
      Text(
        _project.description,
        style: TextStyle(fontSize: 15),
      ),
      space(height: 10),
      Divider(color: Colors.grey),
      space(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          customText("Fecha de Aprobación ", 14),
          customText("Fecha de Inicio     ", 14),
        ],
      ),
      space(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          customText("03/11/2023", 18),
          customText("11/11/2023", 18),
        ],
      ),
      space(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          customText("Fecha de Financiación ", 14),
          customText("Fecha de Justificación", 14),
        ],
      ),
      space(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          customText("15/12/2023", 18),
          customText("31/12/2023", 18),
        ],
      ),
      space(height: 10),
      Divider(color: Colors.grey),
      space(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customText("Responsable del proyecto:", 16),
          customText("Jonh Doe", 16),
        ],
      ),
      space(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customText("Financiador:", 16),
          customText("Ministerio de educación", 16),
        ],
      ),
      space(height: 10),
      Divider(color: Colors.grey),
      space(height: 10),
      /*Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 8.0,
            percent: 0.6,
            center: new Text("60%"),
            progressColor: Colors.lightGreen,
          ),
        ],
      ),
      space(height: 20),*/
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customText("Activo", 18, textColor: Colors.lightGreen),
        ],
      ),
      space(height: 10),
      Divider(color: Colors.grey),
      space(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          customPushBtn(context, "Presupuesto", Icons.euro, "/finns", {"project":_project}),
          /*customBtnArgs(context, "Marco lógico", Icons.task, "/goals",
              {"project": _project}),*/
          customPushBtn(context, "Marco lógico", Icons.task, "/goals",
              {"project": _project}),
          customBtn(context, "Editar", Icons.edit, "/projects", {}),
          customBtn(context, "Eliminar", Icons.remove_circle, "/projects", {}),
        ],
      ),
      space(height: 10),
      Divider(color: Colors.grey),
      space(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customText("Presupuesto Total:", 20),
          customText("70.702,21 €", 20),
        ],
      ),
    ],
  );
}
