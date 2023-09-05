import 'dart:js';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Login Page'),
      ),*/
      body: loginBody(context),
    );
  }
}

Widget loginBody(context) {
  return Container(
    /*decoration: BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
            "https://www.freecodecamp.org/news/content/images/size/w2000/2022/09/jonatan-pie-3l3RwQdHRHg-unsplash.jpg"),
        fit: BoxFit.cover,
      ),
    ),*/
    child: Container(
      margin: const EdgeInsets.all(20.0),
      child: Container(
        //margin: EdgeInsets.all(120.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [loginLogo()],
              ),
              space(),
              usernameText(),
              usernameField(),
              space(),
              passsowdText(),
              passwordField(),
              space(),
              forgotText(),
              space(),
              loginBtn(context)
            ]),
      ),
    ),
  );
}

Widget space() {
  return SizedBox(
    height: 30.0,
  );
}

Widget loginLogo() {
  return Image(
    image: AssetImage('assets/images/logo.jpg'),
    alignment: Alignment.center,
  );
}

Widget usernameText() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 95),
    child: Text(
      "Correo electrónico",
      style: TextStyle(
        fontSize: 20.0,
      ),
    ),
  );
}

Widget usernameField() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 95),
    child: TextField(
      decoration: InputDecoration(
          hintText: "Introduce un correo electrónico válido",
          fillColor: Colors.white,
          filled: true),
    ),
  );
}

Widget passsowdText() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 95),
    child: Text(
      "Contraseña",
      style: TextStyle(
        fontSize: 20.0,
      ),
    ),
  );
}

Widget passwordField() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 95),
    child: TextField(
      obscureText: true,
      decoration: InputDecoration(
          hintText: "Introduce contraseña",
          fillColor: Colors.white,
          filled: true),
    ),
  );
}

Widget forgotText() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 95),
    child: Text(
      "He olvidado mi contraseña",
      style: TextStyle(
        fontSize: 16.0,
        color: const Color(0xFF1BC3C0),
      ),
    ),
  );
}

Widget loginBtn(context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 95),
    child: ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, "/home");
      },
      child: Text(
        "Entrar",
        style: TextStyle(fontSize: 20),
      ),
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF1BC3C0),
        minimumSize: const Size.fromHeight(50),
      ),
    ),
  );
}
