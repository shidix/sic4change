import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';

class RegisterForm extends StatefulWidget {
  final String email;

  const RegisterForm({Key? key, required this.email}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    try {
      //Check if email has email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(widget.email)) {
        setState(() {
          _errorMessage = "El email no tiene un formato válido";
          print("El email no tiene un formato válido");
        });
        return;
      }

      // Check if user exists
      final user = await _auth.fetchSignInMethodsForEmail(widget.email);
      if (user.isNotEmpty) {
        setState(() {
          // Send email with the password
          _errorMessage = "El usuario ya existe";
          print("El usuario ya existe");
        });
        return;
      }
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: password,
      );
      print("Usuario registrado: ${userCredential.user?.email}");

      // Send email with the password
      await userCredential.user?.sendEmailVerification();
      await _auth.sendPasswordResetEmail(email: widget.email);
      setState(() {
        _errorMessage =
            "Usuario registrado. Se le han enviado dos emails al usuario, uno para que verifique la cuenta y otra para que resetee la contraseña. Puedes cerrar el formulario";
      });

      // Send email for password recovery
      //close the form
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Error desconocido";
      });
    }
  }

  Future<void> _sendEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: widget.email);
      //close the form
      // show dialog wieth message and close the form
      setState(() {
        _errorMessage =
            "Se ha enviado un email para recuperar la contraseña. Puede cerrar el formulario";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Error desconocido";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.email,
                  decoration: InputDecoration(labelText: "Email"),
                  readOnly: true,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Contraseña"),
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor, introduzca una contraseña";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                saveBtnForm(context, _register),
                actionButton(
                    context, 'Cambiar Password', _sendEmail, Icons.key, null),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
