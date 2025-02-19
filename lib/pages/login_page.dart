import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:sic4change/generated/l10n.dart';
import 'package:sic4change/pages/home_admin_page.dart';
// import 'package:sic4change/pages/nominas_page.dart';
import 'package:sic4change/pages/home_page.dart';
import 'package:sic4change/pages/employee_page.dart';
import 'package:sic4change/services/log_lib.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';

Profile? profile;
bool loadProf = false;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwdController = TextEditingController();
  late String message;

  @override
  void dispose() {
    emailController.dispose();
    passwdController.dispose();

    super.dispose();
  }

  @override
  initState() {
    message = "";
    super.initState();
    //final user = FirebaseAuth.instance.currentUser!;
    //getProfile(user);
    setState(() {
      loadProf = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      Profile.getProfile(user.email!).then((value) {
        profile = value;
        setState(() {
          loadProf = false;
        });
      });
    } catch (e) {
      setState(() {
        loadProf = false;
      });
    }
  }

  void sendResetEmail(context, emailController) async {
    String email = emailController.text.trim();
    if ((email.isNotEmpty) &&
        (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email))) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        message = "Se ha enviado un email para recuperar la contraseña";
      } on FirebaseAuthException catch (e) {
        message = e.message ?? "Error desconocido";
      }
    } else {
      message = "Introduce un email válido";
      // Wait 5 seconds and then clear the message with fadeout
      Timer(const Duration(seconds: 3), () {
        setState(() {
          message = "";
        });
      });
    }
    setState(() {
      message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      final user = FirebaseAuth.instance.currentUser!;

      if (loadProf == true) {
        return const Center(child: CircularProgressIndicator());
      } else {
        sendAnalyticsEvent("Nuevo acceso", "Usuario: ${profile?.name}");
        if (profile?.mainRole == "Admin") {
          return const HomeAdminPage();
        } else {
          return const HomePage();
        }
      }
    } catch (e) {
      return Scaffold(
        body: Center(
            child: loginBody(emailController, passwdController, message)),
      );
    }
  }

  Widget loginBody(emailController, passwdController, message) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [loginLogo()],
            ),
            space(height: 20),
            Center(
                child: SizedBox(
              width: // min between(100, MediaQuery.of(context).size.width * 0.5),
                  max(700.0, MediaQuery.of(context).size.width * 0.5),
              child: Column(
                children: [
                  usernameText(),
                  usernameField(emailController),
                  space(height: 20),
                  passsowdText(),
                  passwordField(passwdController),
                  space(height: 20),
                  loginBtn(context, emailController, passwdController),
                  space(height: 20),
                  askPassButton(context, emailController),
                  space(height: 20),
                  Center(
                      child: Text(message,
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            )),
            space(height: 20),
            footer(context),
          ]),
    );
  }

  Widget askPassButton(context, emailController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 95),
      child: ElevatedButton(
        onPressed: () {
          sendResetEmail(context, emailController);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          minimumSize: const Size.fromHeight(50),
        ),
        child: customText("He olvidado mi contraseña", 20,
            textColor: Colors.white),
      ),
    );
  }

  Widget loginLogo() {
    return const Image(
      image: AssetImage('assets/images/logo.jpg'),
      alignment: Alignment.center,
      height: 66,
      fit: BoxFit.fitHeight,
    );
  }

  Widget usernameText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 95),
      alignment: Alignment.centerLeft,
      child: customText("Correo electrónico", 20),
    );
  }

  Widget usernameField(emailController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 95),
      child: TextField(
        controller: emailController,
        decoration: const InputDecoration(
            hintText: "Introduce un correo electrónico válido",
            fillColor: Colors.white,
            filled: true),
      ),
    );
  }

  Widget passsowdText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 95),
      alignment: Alignment.centerLeft,
      child: customText("Contraseña", 20),
    );
  }

  Widget passwordField(passwdController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 95),
      child: PasswordField(controller: passwdController),
    );
  }

  Widget forgotText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 95),
      child: customText("He olvidado mi contraseña", 16, textColor: mainColor),
    );
  }

  Widget loginBtn(context, emailController, passwdController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 95),
      child: ElevatedButton(
        onPressed: () {
          //Navigator.pushReplacementNamed(context, "/home");
          signIn(context, emailController, passwdController);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          minimumSize: const Size.fromHeight(50),
        ),
        child: customText("Entrar", 20, textColor: Colors.white),
      ),
    );
  }

  Future signIn(context, emailController, passwdController) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwdController.text.trim(),
      );
      final user = FirebaseAuth.instance.currentUser!;
      if (FirebaseAuth.instance.currentUser != null) {
        profile = await Profile.getProfile(user.email!);
      } else {
        Navigator.pop(context);
        return;
      }
    } on FirebaseException catch (e) {
      message = e.message ?? "Error desconocido";
      setState(() {
        message = message;
      });
    }
    //navigatorKey.currentState!.popUntil((route) => route.isFirst);

    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pop(context);
      return;
    } else {
      Navigator.pop(context);
      if (profile?.mainRole == "Admin") {
        Navigator.push(context,
            MaterialPageRoute(builder: ((context) => const HomeAdminPage())));
      } else if (profile?.mainRole == "Administrativo") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => EmployeesPage(profile: profile))));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: ((context) => const HomePage())));
      }
    }
  }
}
