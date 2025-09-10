import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
  bool isNewUser = false;
  UserCredential? userCredential;

  void initState() {
    super.initState();
    if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(widget.email)) {
      _checkUser();
    }
  }

  Future<void> _checkUser() async {
    try {
      FirebaseApp app = await Firebase.initializeApp(
          name: 'Register User', options: Firebase.app().options);
      try {
        userCredential = await FirebaseAuth.instanceFor(app: app)
            .createUserWithEmailAndPassword(
          email: widget.email,
          password: const Uuid().v4(),
        );

        // Register userCredential in this app
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          setState(() {
            userExists = true;
          });
          return;
        }
      } finally {
        await app.delete();
        if (userCredential == null) {
          if (!userExists) {
            setState(() {
              _errorMessage = "Error desconocido";
            });
          }
        } else {
          await Future.sync(() => userCredential);
          userExists = true;
          isNewUser = true;
          setState(() {
            _errorMessage =
                "Usuario registrado. Se le ha enviado un email al usuario para que genere su password.";
          });
        }
      }

      return;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'email-already-in-use') {
        setState(() {
          userExists = true;
        });
      } else {
        setState(() {
          // _errorMessage = e.message ?? "Error desconocido";
        });
      }
    }
  }

  // Future<void> _register() async {
  //   try {
  //     //Check if email has email format
  //     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(widget.email)) {
  //       setState(() {
  //         _errorMessage = "El email no tiene un formato válido";
  //       });
  //       return;
  //     }

  //     // Check if user exists
  //     final user = await _auth.fetchSignInMethodsForEmail(widget.email);
  //     if (user.isNotEmpty) {
  //       setState(() {
  //         userExists = true;
  //         // Send email with the password
  //         _errorMessage = "El usuario ya existe";
  //       });
  //       return;
  //     }
  //     // UserCredential userCredential =
  //     //     await _auth.createUserWithEmailAndPassword(
  //     //   email: widget.email,
  //     //   //password with random string
  //     //   password: Uuid().v4(),
  //     // );

  //     await _auth.createUserWithEmailAndPassword(
  //       email: widget.email,
  //       password: const Uuid().v4(),
  //     );
  //     // Send email with the password
  //     // await userCredential.user?.sendEmailVerification();
  //     await _auth.sendPasswordResetEmail(email: widget.email);
  //     setState(() {
  //       userExists = true;
  //       _errorMessage =
  //           "Usuario registrado. Se le ha enviado un email al usuario para que genere su password. Puedes cerrar el formulario.";
  //     });

  //     // Send email for password recovery
  //     //close the form
  //   } on FirebaseAuthException catch (e) {
  //     setState(() {
  //       _errorMessage = e.message ?? "Error desconocido";
  //     });
  //   }
  // }

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
    if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(widget.email)) {
      if ((isNewUser) && userCredential != null) {
        FirebaseAuth.instance
            .sendPasswordResetEmail(email: widget.email)
            .then((value) => null);
        _errorMessage =
            "Se han creado las credenciales del usuario.\nSe le ha enviado un email al usuario para que genere su password.";
        isNewUser = false;
      }
      return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: widget.email,
                    decoration: const InputDecoration(labelText: "Email"),
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
                  const SizedBox(height: 20),
                  !userExists
                      ? const Text(
                          "Creando cuenta de usuario. Este proceso puede tardar unos minutos.",
                          style: TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        )
                      : actionButton(context, 'Solicitar cambio de password',
                          _sendEmail, Icons.key, null),
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
    } else {
      return const SizedBox(
          width: double.infinity,
          height: 100,
          child: Center(
            child: Text("Email no válido"),
          ));
    }
  }
}
