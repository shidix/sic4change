import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';

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
  bool userExists = false;

  void initState() {
    super.initState();
    _checkUser();
  }


  Future<void> _checkUser() async {
    try {
      // Check if user exists
      final user = await _auth.fetchSignInMethodsForEmail(widget.email);
      if (user.isNotEmpty) {
        setState(() {
          userExists = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Error desconocido";
      });
    }
  }


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
        //password with random string
        password: Uuid().v4(),
      );
      // Send email with the password
      // await userCredential.user?.sendEmailVerification();
      await _auth.sendPasswordResetEmail(email: widget.email);
      setState(() {
        userExists = true;
        _errorMessage =
            "Usuario registrado. Se le ha enviado un email al usuario para que genere su password. Puedes cerrar el formulario.";
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
                // TextFormField(
                //   decoration: InputDecoration(labelText: "Contraseña"),
                //   obscureText: true,
                //   onChanged: (value) {
                //     password = value;
                //   },
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return "Por favor, introduzca una contraseña";
                //     }
                //     return null;
                //   },
                // ),
                SizedBox(height: 20),
                !userExists?
                actionButton(context, 'Crear cuenta de usuario', _register, Icons.key, null):
                actionButton(
                    context, 'Solicitar cambio de password', _sendEmail, Icons.key, null),
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
