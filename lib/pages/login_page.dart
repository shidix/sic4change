import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/home_page.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';

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
  Widget build(BuildContext context) {
    /*return Scaffold(
      /*appBar: AppBar(
        title: const Text('Login Page'),
      ),*/
      body: loginBody(context, emailController, passwdController),
    );*/
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Something went wrong!"));
            } else if (snapshot.hasData) {
              //Navigator.pushReplacementNamed(context, '/home');
              return HomePage();
            } else {
              return loginBody(context, emailController, passwdController);
            }
          }),
    );
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
    child: TextField(
      controller: passwdController,
      obscureText: true,
      decoration: const InputDecoration(
          hintText: "Introduce contraseña",
          fillColor: Colors.white,
          filled: true),
    ),
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
      builder: (context) => Center(
            child: CircularProgressIndicator(),
          ));

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwdController.text.trim(),
    );
  } on FirebaseException catch (e) {
    print(e);
  }
  //navigatorKey.currentState!.popUntil((route) => route.isFirst);
  Navigator.pop(context);
}
