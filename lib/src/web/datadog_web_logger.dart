@JS()
library datadog_flutter.web;

import 'package:datadog_flutter/src/web/interop/dd_logs.dart' as dd_logs;
import 'package:datadog_flutter/src/web/interop/utils.dart';

import 'package:flutter/services.dart';
import 'package:js/js.dart';

class DatadogWebLogger {
  /// Since multiple loggers can be created, this mirrors the native
  /// layers' tracking of log instances. Datadog Web has a nice feature
  /// called `getLogger` but it's not relevant here
  final Map<String, dd_logs.Logger> loggers = {};

  /// Datadog JS SDK doesn't support removing attributes; to achieve
  /// feature parity, the attributes are tracked internally by the
  /// plugin and the global context is overwritten when adding or
  /// removing attributes.
  final Map<String, Map<String, dynamic>> logAttributes = {};

  bool? handleMethodCall(MethodCall call) {
    switch (call.method) {
      case 'loggerCreateLogger':
        final logger =
            dd_logs.createLogger(call.arguments['loggerName'], 'debug', 'http');
        loggers[call.arguments['identifier']] = logger;
        return true;
      case 'loggerAddAttribute':
        logAttributes[call.arguments['identifier']] ??= {};
        logAttributes[call.arguments['identifier']]?[call.arguments['key']] =
            call.arguments['value'];
        dd_logs.setLoggerGlobalContext(
          logAttributes[call.arguments['identifier']] ?? {},
        );
        return true;
      case 'loggerAddTag':
        return false;
      case 'loggerRemoveAttribute':
        logAttributes[call.arguments['identifier']]
            ?.remove(call.arguments['key']);
        dd_logs.setLoggerGlobalContext(
          jsify(logAttributes[call.arguments['identifier']] ?? {}),
        );
        return true;
      case 'loggerRemoveTag':
        return false;
      case 'loggerLog':
        loggers[call.arguments['identifier']]?.log(
          call.arguments['message'],
          jsify(call.arguments['attributes'] ?? {}),
          call.arguments['level'],
        );
        return true;
      default:
        return null;
    }
  }

  void init(MethodCall call) {
    dd_logs.init(dd_logs.DatadogOptions(
      clientToken: call.arguments['clientToken'],
      env: call.arguments['environment'],
      service: call.arguments['serviceName'],
      site: call.arguments['useEUEndpoints'] ? 'datadoghq.eu' : 'datadoghq.com',
    ));
  }
}
