import 'package:flutter/material.dart';

Color getStatusColor(status) {
  if (status == "Completado") {
    return Colors.green;
  } else {
    if (status == "En proceso") {
      return Colors.orange;
    } else {
      if (status == "No iniciado") return Colors.red;
    }
  }

  return Colors.white;
}

Widget customTextStatus(text, {double size = 12}) {
  if (!['Completado', 'En proceso', 'No iniciado'].contains(text)) {
    text = 'No iniciado';
  }

  Color color = getStatusColor(text);
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      color: color,
    ),
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: size),
    ),
  );
}
