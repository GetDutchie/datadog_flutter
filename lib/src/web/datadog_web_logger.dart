import 'dart:html' as html;

import 'package:datadog_flutter/src/web/interop/dd_log.dart' as dd_logs;

import 'package:flutter/services.dart';

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
        _onLogsReady(() {
          final logger = dd_logs.createLogger(call.arguments['loggerName'], 'debug', 'http');
          loggers[call.arguments['identifier']] = logger;
        });
        return true;
      case 'loggerAddAttribute':
        logAttributes[call.arguments['identifier']] ??= {};
        logAttributes[call.arguments['identifier']]?[call.arguments['key']] =
            call.arguments['value'];
        _onLogsReady(() {
          dd_logs.setLoggerGlobalContext(logAttributes[call.arguments['identifier']] ?? {});
        });
        return true;
      case 'loggerAddTag':
        return false;
      case 'loggerRemoveAttribute':
        logAttributes[call.arguments['identifier']]?.remove(call.arguments['key']);
        dd_logs.setLoggerGlobalContext(logAttributes[call.arguments['identifier']] ?? {});
        return true;
      case 'loggerRemoveTag':
        return false;
      case 'log':
        _onLogsReady(() {
          loggers[call.arguments['identifier']]?.log(
            call.arguments['message'],
            call.arguments['attributes'],
            call.arguments['level'],
          );
        });
        return true;
      default:
        return null;
    }
  }

  void init(MethodCall call) {
    _onLogsReady(() {
      dd_logs.init({
        'clientToken': call.arguments['clientToken'],
        'env': call.arguments['environment'],
        'service': call.arguments['service'],
        'site': call.arguments['useEUEndpoints'] ? 'datadoghq.eu' : 'datadoghq.com',
      });
    });
  }

  /// Fires after document is ready and after window.DD_LOGS is available
  static void _onLogsReady(void Function() callback) {
    html.document.addEventListener('ready', (event) {
      dd_logs.onReady(callback);
    });
  }
}
