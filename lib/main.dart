// import 'dart:developer' as developer;
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/admin_page.dart';
import 'package:sic4change/pages/contact_calendar_page.dart';
import 'package:sic4change/pages/home_admin_page.dart';
import 'package:sic4change/pages/index.dart';

// Importaciones de firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:sic4change/pages/orgchart_page.dart';
import 'package:sic4change/pages/profile_page.dart';
import 'package:sic4change/pages/project_transversal_page.dart';
import 'package:sic4change/pages/projects_list_page.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );

  initializeDateFormatting('es_ES', '').then((_) => runApp(MyApp()));
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _routes = {
    '/': (context) => const LoginPage(),
    '/home': (context) => const HomePage(),
    '/home_admin': (context) => const HomeAdminPage(),
    '/projects': (context) => const ProjectsPage(),
    '/project_list': (context) => const ProjectListPage(),
    '/project_info': (context) => const ProjectInfoPage(),
    '/project_reformulation': (context) => const ReformulationPage(),
    '/contacts': (context) => const ContactsPage(),
    '/contact_info': (context) => const ContactInfoPage(),
    '/contact_claims': (context) => const ContactClaimPage(),
    '/contact_claim_info': (context) => const ContactClaimInfoPage(),
    '/contact_trackings': (context) => const ContactTrackingPage(contact: null),
    '/contact_tracking_info': (context) => const ContactTrackingInfoPage(),
    '/contact_calendars': (context) => const ContactCalendarPage(contact: null),
    '/documents': (context) => const DocumentsPage(),
    '/goals': (context) => const GoalsPage(),
    '/results': (context) => const ResultsPage(),
    '/finns': (context) => const FinnsPage(project: null),
    '/activities': (context) => const ActivitiesPage(),
    '/activity_indicators': (context) => const ActivityIndicatorsPage(),
    '/result_tasks': (context) => const ResultTasksPage(),
    '/risks': (context) => const RisksPage(),
    '/transfers': (context) => TransfersPage(
          project: null,
        ),
    '/transversal': (context) =>
        const ProjectTransversalPage(currentProject: null),
    '/tasks': (context) => const TasksPage(),
    '/tasks_user': (context) => const TasksUserPage(),
    '/task_info': (context) => const TaskInfoPage(),
    '/orgchart': (context) => const Orgchart(),
    '/profile': (context) => const ProfilePage(),
    '/admin': (context) => const AdminPage(),
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
    Widget app = MaterialApp(
      //navigatorKey: navigatorKey,
      title: 'Worket. Mejorando la gestión de las ONGs',
      initialRoute: '/',
      routes: _routes,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es', ''),

      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const Page404());
      },
    );

    return app;
  }
}
