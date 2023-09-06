import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [mainMenu(context), projectsBody(context)],
        ),
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
      children: [projectSearch(), space(width: 50), projectCard(context)],
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

Widget projectCard(context) {
  return FractionallySizedBox(
      widthFactor: 0.45,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: projectCardDatas(context),
      ));
}

Widget projectCardDatas(context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Educación Rural",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      space(height: 10),
      Text(
        "Breve descripción del prouecto Educación Rural",
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
