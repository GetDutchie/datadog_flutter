import 'dart:async';
import 'package:datadog_flutter/datadog_observer.dart';
import 'package:datadog_flutter/datadog_rum.dart';
import 'package:datadog_flutter/datadog_logger.dart';
import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:flutter/material.dart';

import 'package:datadog_flutter/datadog_flutter.dart';
import 'rum.dart';
import 'logs.dart';
import 'tracing.dart';

// DO NOT COMMIT TO GIT
// Ideally, your token is encrypted if it must be committed or its added at build
const DATADOG_CLIENT_TOKEN = 'YOUR_DATADOG_CLIENT_TOKEN';
const ANDROID_RUM_APPLICATION_ID = 'YOUR_ANDROID_RUM_APPLICATION_ID';
const IOS_RUM_APPLICATION_ID = 'YOUR_IOS_RUM_APPLICATION_ID';
const WEB_RUM_APPLICATION_ID = 'YOUR_WEB_RUM_APPLICATION_ID';
const ENVIRONMENT = 'demo';
const SERVICE_NAME = 'my-example-app';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatadogFlutter.initialize(
    androidRumApplicationId: ANDROID_RUM_APPLICATION_ID,
    clientToken: DATADOG_CLIENT_TOKEN,
    environment: ENVIRONMENT,
    iosRumApplicationId: IOS_RUM_APPLICATION_ID,
    serviceName: SERVICE_NAME,
    trackingConsent: TrackingConsent.granted,
    webRumApplicationId: WEB_RUM_APPLICATION_ID,
  );

  // Capture Flutter errors automatically:
  FlutterError.onError = DatadogRum.instance.addFlutterError;

  await DatadogTracing.initialize();

  // Catch errors without crashing the app:
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    DatadogRum.instance.addError(error, stackTrace);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Datadog Flutter Examples'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Logs'),
                Tab(text: 'RUM'),
                Tab(text: 'Tracing'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Logs(),
              Rum(),
              Tracing(),
            ],
          ),
        ),
      ),
      navigatorObservers: [
        DatadogObserver(),
      ],
    );
  }
}
