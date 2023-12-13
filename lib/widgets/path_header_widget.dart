import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';
// import 'package:sic4change/widgets/common_widgets.dart';

Widget pathHeader(context, name) {
  return Container(
      padding: EdgeInsets.only(top: 20, left: 20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: headerTitleText,
            ),
            /*space(height: 10),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("En ejecución"),
                ),
                space(height: 10),
                customLinearPercent(context, 750, 0.5, Colors.green),
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text("Presupuesto total"),
                  ),
                  space(height: 10),
                  customLinearPercent(context, 750, 0.5, Colors.blue)
                ],
              ),
            ])*/
          ]));
}
