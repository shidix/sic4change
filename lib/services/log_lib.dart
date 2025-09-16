import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

Future<void> sendAnalyticsEvent(name, details) async {
  await analytics.logEvent(
    name: name,
    parameters: <String, Object>{
      'string': details,
      /*'int': 42,
      'long': 12345678910,
      'double': 42.0,
      'bool': true.toString(),*/
    },
  );
}
