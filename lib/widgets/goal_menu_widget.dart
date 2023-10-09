import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget goalMenu(context, _project) {
  return Container(
    /*decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
            "https://www.freecodecamp.org/news/content/images/size/w2000/2022/09/jonatan-pie-3l3RwQdHRHg-unsplash.jpg"),
        fit: BoxFit.cover,
      ),
    ),*/
    child: Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      //margin: EdgeInsets.all(120.0),
      //color: Colors.white,
      child: Row(
        children: [
          menuTabSelect(
              context, "Marco lógico", "/goals", {'project': _project}),
          menuTab(context, "Riesgos", "/goals", {'project': _project}),
          menuTab(context, "Bitácora", "/goals", {'project': _project}),
          menuTab(context, "Eva. externa y calidad", "/goals",
              {'project': _project}),
          menuTab(context, "Aprendizajes", "/goals", {'project': _project}),
          menuTab(context, "Req. calidad", "/goals", {'project': _project}),
          menuTab(context, "Transparencia y calidad", "/goals",
              {'project': _project}),
          menuTab(context, "Género", "/goals", {'project': _project}),
          menuTab(context, "Medio ambiente", "/goals", {'project': _project}),
        ],
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    ),
  );
}

Widget logo() {
  return Image(
    image: AssetImage('assets/images/logo.jpg'),
    width: 100,
  );
}
