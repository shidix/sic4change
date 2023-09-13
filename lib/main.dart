import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/index.dart';

// Importaciones de firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _routes = {
    '/': (context) => const LoginPage(),
    '/home': (context) => const HomePage(),
    '/projects': (context) => const ProjectsPage(),
    '/contacts': (context) => const ContactsPage(),
  };

  @override
  /*Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                return HomePage();
              } else {
                return LoginPage();
              }
            })),
      );*/
  Widget build(BuildContext context) {
    return MaterialApp(
      //navigatorKey: navigatorKey,
      title: 'Material App',
      initialRoute: '/',
      routes: _routes,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const Page404());
      },
    );
  }
}
