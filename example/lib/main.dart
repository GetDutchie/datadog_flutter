import 'dart:async';
import 'package:datadog_flutter/datadog_observer.dart';
import 'package:datadog_flutter/datadog_rum.dart';
import 'package:datadog_flutter/datadog_logger.dart';
import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:datadog_flutter/datadog_flutter.dart';

// DO NOT COMMIT TO GIT
// Ideally, your token is encrypted if it must be committed or its added at build
const DATADOG_CLIENT_TOKEN = 'YOUR_DATADOG_CLIENT_TOKEN';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatadogFlutter.initialize(
    clientToken: DATADOG_CLIENT_TOKEN,
    environment: 'production',
    androidRumApplicationId: 'YOUR_ANDROID_RUM_APPLICATION_ID',
    iosRumApplicationId: 'YOUR_IOS_RUM_APPLICATION_ID',
    webRumApplicationId: 'YOUR_WEB_RUM_APPLICATION_ID',
    serviceName: 'my-cool-app',
    trackingConsent: TrackingConsent.granted,
  );
  final ddLogger = DatadogLogger();
  // Capture Flutter errors automatically:
  FlutterError.onError = DatadogRum.instance.addFlutterError;

  await DatadogTracing.initialize();

  // Catch errors without crashing the app:
  runZonedGuarded(() {
    runApp(MyApp(ddLogger));
  }, (error, stackTrace) {
    DatadogRum.instance.addError(error, stackTrace);
  });
  runApp(MyApp(ddLogger));
}

class MyApp extends StatelessWidget {
  final Logger otherLogger;
  final DatadogLogger datadogLogger;

  MyApp(this.datadogLogger, {Key? key})
      : otherLogger = Logger('other logger'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Flutter Homepage'),
        ),
        body: ListView(
          children: [
            TextButton(
              onPressed: () => otherLogger.fine('FINE log from Flutter'),
              child: Text('FINE Log to Datadog'),
            ),
            TextButton(
              onPressed: () => otherLogger.warning('WARN log from Flutter'),
              child: Text('WARN Log to Datadog'),
            ),
            TextButton(
              onPressed: () => DatadogRum.instance.addUserAction('Send Event Button'),
              child: Text('Send Event To RUM'),
            ),
            TextButton(
              onPressed: () => throw StateError('State Error from Flutter'),
              child: Text('Report Zoned Error To RUM'),
            ),
          ],
        ),
      ),
      navigatorObservers: [
        DatadogObserver(),
      ],
    );
  }
}
