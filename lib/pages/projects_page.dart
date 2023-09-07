import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/project.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

final pr = SProject("Proyecto de prueba", "Descripción del proyecto de prueba");
List<SProject> projects = [
  SProject("Proyecto de prueba", "Descripción del proyecto de prueba"),
  SProject("Proyecto de prueba 2", "Descripción del proyecto de prueba 2"),
];

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
          projectsBody(context),
          Expanded(child: projectList(context))
        ],
      ),
    );
  }
}

const PROJECT_TITLE = "Proyectos";

Widget projectsBody(context) {
  return Container(
    padding: EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        projectSearch(),
        space(width: 50),
        //projectCard(context, pr),
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
  return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1,
        //childAspectRatio: 1,
        //crossAxisSpacing: 0,
        //mainAxisSpacing: 0
      ),
      itemCount: projects.length,
      itemBuilder: (_, index) {
        return projectCard(context, projects[index]);
        /*return Container(
          //padding: const EdgeInsets.all(8),
          //color: Colors.teal[100],
          child: projectCard(context, projects[index]),
          //child: Text(projects[index].name),
        );*/
      });
}
/*Widget projectList(context) {
  return GridView.count(
    primary: false,
    padding: const EdgeInsets.all(20),
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    crossAxisCount: 2,
    children: <Widget>[
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[100],
        child: const Text("He'd have you all unravel at the"),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[200],
        child: const Text('Heed not the rabble'),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[300],
        child: const Text('Sound of screams but the'),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[400],
        child: const Text('Who scream'),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[500],
        child: const Text('Revolution is coming...'),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[600],
        child: const Text('Revolution, they...'),
      ),
    ],
  );
}*/

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

  /*return FractionallySizedBox(
      widthFactor: 0.45,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: projectCardDatas(context, _project),
      ));
      */
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
        _project.desc,
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
      Row(
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
      space(height: 20),
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
          customBtn(context, "Presupuesto", Icons.euro, "/projects"),
          customBtn(context, "Marco lógico", Icons.task, "/projects"),
          customBtn(context, "Editar", Icons.edit, "/projects"),
          customBtn(context, "Eliminar", Icons.remove_circle, "/projects"),
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
