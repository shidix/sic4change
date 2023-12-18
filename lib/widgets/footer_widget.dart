import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget footer(context) {
  return Container(
      padding: const EdgeInsets.all(3),
      child: Column(children: [
        space(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customText("Realizado por:", 15),
            space(width: 150),
            customText("En colaboración con:", 15),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/logo_s4c.png'),
              width: 100,
            ),
            space(width: 150),
            const Image(
              image: AssetImage('assets/images/logo_ministerio.png'),
              width: 140,
            )
          ],
        ),
      ]));
}
