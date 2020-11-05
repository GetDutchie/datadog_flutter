import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:datadog_flutter/datadog_flutter.dart';

// DO NOT COMMIT TO GIT
// Ideally, your token is encrypted if it must be committed or its added at build
const DATADOG_CLIENT_TOKEN = 'YOUR_DATADOG_CLIENT_TOKEN';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final DatadogFlutter datadogLogger;
  final Logger otherLogger;

  MyHomePage({Key key, this.title})
      : otherLogger = Logger('other logger'),
        datadogLogger = DatadogFlutter(
          clientToken: DATADOG_CLIENT_TOKEN,
          environment: 'production',
          serviceName: 'my-cool-app',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: FlatButton(
          child: Text('Log to Datadog'),
          onPressed: () => otherLogger.fine('hello datadog'),
        ),
      ),
    );
  }
}
