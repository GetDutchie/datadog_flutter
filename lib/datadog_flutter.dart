import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart';

class DatadogFlutter {
  static const MethodChannel _channel =
      MethodChannel('plugins.greenbits.com/datadog_flutter');

  final String clientToken;

  final String? loggerName;

  final String serviceName;

  DatadogFlutter({
    required this.clientToken,
    required this.serviceName,
    this.loggerName,
    bool bindOnRecord = true,
    String environment = 'development',
    bool useEUEndpoints = false,
  }) {
    _channel.invokeMethod('initWithClientToken', {
      'clientToken': clientToken,
      'serviceName': serviceName,
      'loggerName': loggerName,
      'environment': environment,
      'useEUEndpoints': useEUEndpoints,
    });

    if (bindOnRecord) Logger.root.onRecord.listen(onRecordCallback);
  }

  Future<void> addTag(String tagName, String value) async {
    return await _channel.invokeMethod('addTag', {
      'key': tagName,
      'value': value,
    });
  }

  Future<void> removeTag(String tagName) async {
    return await _channel.invokeMethod('removeTag', {
      'key': tagName,
    });
  }

  Future<void> addAttribute(String attributeName, String value) async {
    return await _channel.invokeMethod('addAttribute', {
      'key': attributeName,
      'value': value,
    });
  }

  Future<void> removeAttribute(String attributeName) async {
    return await _channel.invokeMethod('removeAttribute', {
      'key': attributeName,
    });
  }

  Future<void> log(String logMessage, Level logLevel,
      {Map<String, dynamic>? attributes}) async {
    return await _channel.invokeMethod('log', {
      'level': _levelAsStatus(logLevel),
      'message': logMessage,
      if (attributes != null) 'attributes': attributes,
    });
  }

  /// Useful shorthand to attch to the logger stream:
  /// `Logger.root.onRecord.listen(myDatadogLogger.onRecordCallback);`
  Future<void> onRecordCallback(LogRecord record) => log(
        record.message,
        record.level,
        attributes: {'loggerName': record.loggerName},
      );

  String _levelAsStatus(Level level) {
    if (level.value <= 500) return 'debug';

    if (level.value <= 700) return 'info';

    if (level.value <= 800) return 'notice';

    if (level == Level.WARNING) return 'warn';

    if (level == Level.SEVERE) return 'error';

    return 'critical';
  }
}
