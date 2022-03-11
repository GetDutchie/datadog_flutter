@JS('DD_RUM')
library datadog_flutter.web.rum;

import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

@JS()
external void addAction(String name, [dynamic attributes]);

@JS()
external void addError(dynamic error, [dynamic attributes]);

@JS()
external void addTiming(String name);

@JS()
external void init(DatadogOptions options);

@JS()
external void onReady(VoidCallback callback);

@JS()
external void setRumGlobalContext(dynamic values);

@JS()
external void setUser(dynamic options);

@JS()
external void startView(String name);

@JS()
@anonymous
class DatadogOptions {
  external String get applicationId;
  external String get clientToken;
  external String get env;
  external String get service;
  external String get site;
  external bool get trackInteractions;

  external factory DatadogOptions({
    String applicationId,
    String clientToken,
    String env,
    String service,
    String site,
    bool trackInteractions,
  });
}
