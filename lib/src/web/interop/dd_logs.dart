@JS('DD_LOGS')
library datadog_flutter.web.logger;

import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

@JS()
external void setLoggerGlobalContext(dynamic values);

@JS()
external Logger createLogger(String? name, String status, String handler);

@JS()
external Logger getLogger(String name);

@JS()
external void init(DatadogOptions options);

@JS()
external void onReady(VoidCallback callback);

@JS('logger')
class Logger {
  external void log(String message, dynamic attributes, String status);
}

@JS()
@anonymous
class DatadogOptions {
  external String get clientToken;
  external String get env;
  external String get service;
  external String get site;
  external String? get version;

  external factory DatadogOptions({
    String clientToken,
    String env,
    String service,
    String site,
    String? version,
  });
}
