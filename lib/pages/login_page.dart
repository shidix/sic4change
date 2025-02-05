import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    emailController.dispose();
    passwdController.dispose();

    super.dispose();
  }

  @override
  initState() {
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

  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      /*appBar: AppBar(
        title: const Text('Login Page'),
      ),*/
      body: loginBody(context, emailController, passwdController),
    );*/

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
            child: loginBody(context, emailController, passwdController)),
      );
    }
/*
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong!"));
            } else if (snapshot.hasData) {
              print(snapshot.data);
              //final user = FirebaseAuth.instance.currentUser!;
              print("--1--");
              print(profile);
              if (profile?.mainRole == "Admin") {
                print("--2--");
                return const HomeAdminPage();
              }
              //Navigator.pushReplacementNamed(context, '/home');
              return const HomePage();
            } else {
              return loginBody(context, emailController, passwdController);
            }
          }),
    );*/
  }
}

Widget loginBody(context, emailController, passwdController) {
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
          space(height: 29),
          usernameText(),
          usernameField(emailController),
          space(height: 29),
          passsowdText(),
          passwordField(passwdController),
          space(height: 29),
          forgotText(),
          space(height: 29),
          loginBtn(context, emailController, passwdController),
          footer(context),
        ]),
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
    child: customText("Contraseña", 20),
  );
}

Widget passwordField(passwdController) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 95),
    child: PasswordField(controller: passwdController),
    // child: TextField(
    //   controller: passwdController,
    //   obscureText: true,
    //   decoration: const InputDecoration(
    //       hintText: "Introduce contraseña",
    //       fillColor: Colors.white,
    //       filled: true),
    // ),
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
    print(e);
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
      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => const HomePage())));
    }
  }
}
