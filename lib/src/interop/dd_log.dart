@JS('DD_LOGS')
library datadog_flutter.web;

import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

@JS()
external void addLoggerGlobalContext(String key, dynamic value);
@JS()
external void setLoggerGlobalContext(Map<String, dynamic> values);

@JS()
external Logger createLogger(String name, String status, String handler);

@JS()
external Logger getLogger(String name);

@JS()
external void init(Map<String, dynamic> options);

@JS()
external void onReady(VoidCallback callback);

@JS('logger')
class Logger {
  external void log(String message, Map<String, dynamic> attributes, String status);
}

@JS()
@anonymous
class DatadogOptions {
  external String clientToken;
  external String site;
  external bool forwardErrorsToLogs;
  external int sampleRate;
  external String service;
  external String env;
  external String version;
}
