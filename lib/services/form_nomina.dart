import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NominaForm extends StatefulWidget {
  const NominaForm({Key? key}) : super(key: key);

  @override
  _NominaFormState createState() => _NominaFormState();
}

class _NominaFormState extends State<NominaForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Apellido'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Cedula'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Cargo'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Salario'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Fecha de ingreso'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Fecha de egreso'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Dias trabajados'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Horas extras'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Bonificaciones'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Deducciones'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Total a pagar'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Guardar'),
          )
        ],
      ),
    );
  }
}
