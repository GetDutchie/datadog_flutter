import 'dart:async';
import 'package:datadog_flutter/datadog_observer.dart';
import 'package:datadog_flutter/datadog_rum.dart';
import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:flutter/material.dart';

import 'package:datadog_flutter/datadog_flutter.dart';

import 'config.dart';
import 'rum.dart';
import 'logs.dart';
import 'tracing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatadogFlutter.initialize(
    androidRumApplicationId: ANDROID_RUM_APPLICATION_ID,
    clientToken: DATADOG_CLIENT_TOKEN,
    environment: ENVIRONMENT,
    iosRumApplicationId: IOS_RUM_APPLICATION_ID,
    serviceName: SERVICE_NAME,
    trackingConsent: TrackingConsent.granted,
  );

  // Capture Flutter errors automatically:
  FlutterError.onError = DatadogRum.instance.addFlutterError;

  await DatadogTracing.initialize();

  // Catch errors without crashing the app:
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stackTrace) {
    DatadogRum.instance.addError(error, stackTrace);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/logs': (_) => const Logs(),
        '/rum': (_) => const Rum(),
        '/tracing': (_) => Tracing(),
      },
      home: const Logs(),
      navigatorObservers: [
        DatadogObserver(),
      ],
    );
  }
}
