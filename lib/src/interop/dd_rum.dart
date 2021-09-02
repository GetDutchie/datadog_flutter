@JS('DD_RUM')
library datadog_flutter.web;

import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

@JS()
external void addRumGlobalContext(String key, dynamic value);

@JS()
external void setRumGlobalContext(Map<String, dynamic> values);

@JS()
external void startView(String name);

@JS()
external void init(Map<String, dynamic> options);

@JS()
external void setUser(Map<String, dynamic> options);

@JS()
external void onReady(VoidCallback callback);

@JS()
external void addAction(String name, [Map<String, dynamic> attributes]);

@JS()
external void addTiming(String name);

@JS()
external void addError(dynamic error, [Map<String, dynamic> attributes]);
