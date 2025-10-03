// import 'dart:developer' as developer;
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/pages/admin_page.dart';
import 'package:sic4change/pages/contact_calendar_page.dart';
// import 'package:sic4change/pages/home_admin_page.dart';
import 'package:sic4change/pages/log_page.dart';
import 'package:sic4change/pages/index.dart';

// Importaciones de firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:sic4change/pages/invoices_pages.dart';
import 'package:sic4change/pages/orgchart_page.dart';
import 'package:sic4change/pages/profile_page.dart';
import 'package:sic4change/pages/project_transversal_page.dart';
import 'package:sic4change/pages/projects_list_page.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/cache_projects.dart';
import 'package:sic4change/services/cache_rrhh.dart';

import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// final navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.web,
//   );

//   initializeDateFormatting('es_ES', '').then((_) => runApp(
//         MultiProvider(
//           providers: [
//             ChangeNotifierProvider(create: (_) => ProfileProvider()),
//             ChangeNotifierProvider(create: (_) => ProjectsProvider()),
//             ChangeNotifierProvider(create: (_) => RRHHProvider()),
//           ],
//           child: MyApp(),
//         ),
//         // ChangeNotifierProvider(
//         //   create: (_) => ProfileProvider(),
//         //   child: MyApp(),
//         // ),
//       ));
//   // runApp(MyApp());
// }

// class MyCustomScrollBehavior extends MaterialScrollBehavior {
//   @override
//   Set<PointerDeviceKind> get dragDevices => {
//         PointerDeviceKind.touch,
//         PointerDeviceKind.mouse,
//       };
// }

// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   final _routes = {
//     '/': (context) => const LoginPage(),
//     '/home': (context) => const HomePage(),
//     '/home_operator': (context) => const HierarchyPage(),
//     // '/home_admin': (context) => const HomeAdminPage(),
//     '/projects': (context) => const ProjectsPage(),
//     '/project_list': (context) => const ProjectListPage(),
//     '/project_info': (context) => const ProjectInfoPage(),
//     '/project_reformulation': (context) => const ReformulationPage(),
//     '/contacts': (context) => const ContactsPage(),
//     '/contact_info': (context) => const ContactInfoPage(),
//     '/contact_claims': (context) => const ContactClaimPage(),
//     '/contact_claim_info': (context) => const ContactClaimInfoPage(),
//     '/contact_trackings': (context) => const ContactTrackingPage(contact: null),
//     '/contact_tracking_info': (context) => const ContactTrackingInfoPage(),
//     '/contact_calendars': (context) => const ContactCalendarPage(contact: null),
//     '/documents': (context) => const DocumentsPage(),
//     '/goals': (context) => const GoalsPage(),
//     '/results': (context) => const ResultsPage(),
//     '/finns': (context) => const FinnsPage(project: null),
//     '/activities': (context) => const ActivitiesPage(),
//     '/activity_indicators': (context) => const ActivityIndicatorsPage(),
//     '/result_tasks': (context) => const ResultTasksPage(),
//     '/rrhh': (context) => const HierarchyPage(),
//     '/risks': (context) => const RisksPage(),
//     '/transfers': (context) => TransfersPage(
//           project: null,
//         ),
//     '/transversal': (context) =>
//         const ProjectTransversalPage(currentProject: null),
//     '/tasks': (context) => const TasksPage(),
//     '/tasks_user': (context) => const TasksUserPage(),
//     '/task_info': (context) => const TaskInfoPage(),
//     '/orgchart': (context) => const Orgchart(),
//     '/profile': (context) => const ProfilePage(),
//     '/admin': (context) => const AdminPage(),
//     '/invoices': (context) => const InvoicePage(),
//     '/logs': (context) => const LogPage(),
//     '/hierarchy': (context) => const HierarchyPage(),
//   };

//   @override
//   /*Widget build(BuildContext context) => Scaffold(
//         body: StreamBuilder<User?>(
//             stream: FirebaseAuth.instance.authStateChanges(),
//             builder: ((context, snapshot) {
//               if (snapshot.hasData) {
//                 return HomePage();
//               } else {
//                 return LoginPage();
//               }
//             })),
//       );*/
//   Widget build(BuildContext context) {
//     Widget app = MaterialApp(
//       //navigatorKey: navigatorKey,
//       title: 'Worket. Mejorando la gestión de las ONGs',
//       initialRoute: '/',
//       routes: _routes,
//       localizationsDelegates: AppLocalizations.localizationsDelegates,
//       supportedLocales: AppLocalizations.supportedLocales,
//       locale: const Locale('es', ''),
//       scrollBehavior: MyCustomScrollBehavior(),

//       onGenerateRoute: (settings) {
//         return MaterialPageRoute(builder: (context) => const Page404());
//       },
//     );

//     return app;
//   }
// }

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

//========================
// 1) Wrapper de reinicio
//========================
class RestartApp extends StatefulWidget {
  final Widget child;
  const RestartApp({super.key, required this.child});

  static void restart(BuildContext context) {
    final state = context.findAncestorStateOfType<_RestartAppState>();
    state?._restart();
  }

  @override
  State<RestartApp> createState() => _RestartAppState();
}

class _RestartAppState extends State<RestartApp> {
  Key _key = UniqueKey();
  void _restart() => setState(() => _key = UniqueKey());

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

//========================
// 2) Tu MyApp (sin cambios de lógica, solo tal cual lo tenías)
//========================
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _routes = {
    '/': (context) => const LoginPage(),
    '/home': (context) => const HomePage(),
    '/home_operator': (context) => const HierarchyPage(),
    // '/home_admin': (context) => const HomeAdminPage(),
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
    '/rrhh': (context) => const HierarchyPage(),
    '/risks': (context) => const RisksPage(),
    '/transfers': (context) => TransfersPage(project: null),
    '/transversal': (context) =>
        const ProjectTransversalPage(currentProject: null),
    '/tasks': (context) => const TasksPage(),
    '/tasks_user': (context) => const TasksUserPage(),
    '/task_info': (context) => const TaskInfoPage(),
    '/orgchart': (context) => const Orgchart(),
    '/profile': (context) => const ProfilePage(),
    '/admin': (context) => const AdminPage(),
    '/invoices': (context) => const InvoicePage(),
    '/logs': (context) => const LogPage(),
    '/hierarchy': (context) => const HierarchyPage(),
  };

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Worket. Mejorando la gestión de las ONGs',
      // initialRoute: '/',
      routes: _routes,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es', ''),
      scrollBehavior: MyCustomScrollBehavior(),
      onGenerateRoute: (settings) {
        final builder = _routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }
        return MaterialPageRoute(builder: (context) => const Page404());
      },
    );

    return app;
  }
}

//========================
// 3) Punto de entrada (envuelve MyApp con RestartApp)
//========================
// void main2() {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await Firebase.initializeApp(); // si corresponde

//   runApp(
//     // Si usas MultiProvider, colócalo DENTRO de RestartApp
//     // para que se reconstruyan también tus providers al reiniciar:
//     //
//     // RestartApp(
//     //   child: MultiProvider(
//     //     providers: [ /* tus providers */ ],
//     //     child: MyApp(),
//     //   ),
//     // ),
//     RestartApp(child: MyApp()),
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  try {
    // Check if persistence is enabled
    final settings = FirebaseFirestore.instance.settings;
    if (settings.persistenceEnabled == true) {
      return;
    } else {
      FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    }
  } catch (e) {
    // Si la persistencia ya está habilitada, se lanzará una excepción.
    // Puedes manejarla aquí si es necesario.
  }
  print("Initializing app...");
  initializeDateFormatting('es_ES', '').then((_) => runApp(RestartApp(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => ProjectsProvider()),
            ChangeNotifierProvider(create: (_) => RRHHProvider()),
          ],
          child: MyApp(),
        ),
      )));
}
