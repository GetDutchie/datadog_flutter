import 'package:logging/logging.dart';
import 'package:datadog_flutter/src/channel.dart';
export 'package:datadog_flutter/src/tracking_consent.dart';

class DatadogLogger {
  /// The value for the `logger.name` attribute attached to all logs
  /// sent to Datadog. This can be overriden by providing the
  /// `loggerName` attribute.
  ///
  /// Flutter `Logger#name` adds the `loggerName` attribute to every record.
  ///
  /// This is different than `service` which is inherited from [DatadogFlutter]
  /// or can be defined as the `service` attribute per log.
  final String loggerName;

  DatadogLogger({
    this.loggerName,
    bool bindOnRecord = true,
  }) {
    channel.invokeMethod('createLogger', {
      'identifier': hashCode.toString(),
      'loggerName': loggerName,
    });
    if (bindOnRecord) Logger.root.onRecord.listen(onRecordCallback);
  }

  Future<void> addAttribute(String attributeName, String value) async {
    return await channel.invokeMethod('addAttribute', {
      'identifier': hashCode.toString(),
      'key': attributeName,
      'value': value,
    });
  }

  Future<void> addTag(String tagName, String value) async {
    return await channel.invokeMethod('addTag', {
      'identifier': hashCode.toString(),
      'key': tagName,
      'value': value,
    });
  }

  /// Useful shorthand to attch to the logger stream:
  /// `Logger.root.onRecord.listen(myDatadogLogger.onRecordCallback);`
  Future<void> onRecordCallback(LogRecord record) => log(
        record.message,
        record.level,
        attributes: {'loggerName': record.loggerName},
      );

  Future<void> removeAttribute(String attributeName) async {
    return await channel.invokeMethod('removeAttribute', {
      'identifier': hashCode.toString(),
      'key': attributeName,
    });
  }

  Future<void> removeTag(String tagName) async {
    return await channel.invokeMethod('removeTag', {
      'identifier': hashCode.toString(),
      'key': tagName,
    });
  }

  Future<void> log(
    String logMessage,
    Level logLevel, {
    Map<String, dynamic> attributes,
  }) async {
    return await channel.invokeMethod('log', {
      'identifier': hashCode.toString(),
      'level': _levelAsStatus(logLevel),
      'message': logMessage,
      if (attributes != null) 'attributes': attributes,
    });
  }

  String _levelAsStatus(Level level) {
    if (level.value <= 500) return 'debug';

    if (level.value <= 700) return 'info';

    if (level.value <= 800) return 'notice';

    if (level == Level.WARNING) return 'warn';

    if (level == Level.SEVERE) return 'error';

    return 'critical';
  }
}
