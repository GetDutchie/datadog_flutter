import 'dart:convert';
import 'package:datadog_flutter/src/platform/active_platform.dart';
import 'package:flutter/foundation.dart';
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
  final String? loggerName;

  DatadogLogger({
    this.loggerName,
    bool bindOnRecord = true,
  }) {
    channel.invokeMethod('loggerCreateLogger', {
      'identifier': hashCode.toString(),
      'loggerName': loggerName,
    });
    if (bindOnRecord) Logger.root.onRecord.listen(onRecordCallback);
  }

  /// Adds an attribute to all future messages from this logger.
  Future<void> addAttribute(String attributeName, String value) async {
    return await channel.invokeMethod('loggerAddAttribute', {
      'identifier': hashCode.toString(),
      'key': attributeName,
      'value': value,
    });
  }

  /// Adds a tag to all future messages from this logger.
  ///
  /// This is not invoked and resolves silently when using Flutter web.
  Future<void> addTag(String tagName, String value) async {
    return await channel.invokeMethod('loggerAddTag', {
      'identifier': hashCode.toString(),
      'key': tagName,
      'value': value,
    });
  }

  /// Log message directly.
  Future<void> log(
    String logMessage,
    Level logLevel, {
    Map<String, dynamic>? attributes,
  }) async {
    if (logLevel == Level.OFF) {
      return;
    }

    return await channel.invokeMethod('loggerLog', {
      'identifier': hashCode.toString(),
      'level': levelAsStatus(logLevel),
      'message': logMessage,
      if (attributes != null)
        'attributes': platform.isIOS ? jsonEncode(attributes) : attributes,
    });
  }

  /// Useful shorthand to attch to the logger stream:
  /// `Logger.root.onRecord.listen(myDatadogLogger.onRecordCallback);`
  Future<void> onRecordCallback(LogRecord record) => log(
        record.message,
        record.level,
        attributes: {'loggerName': record.loggerName},
      );

  /// Removes a previously-added attribute from all future messages from this logger.
  Future<void> removeAttribute(String attributeName) async {
    return await channel.invokeMethod('loggerRemoveAttribute', {
      'identifier': hashCode.toString(),
      'key': attributeName,
    });
  }

  /// Removes a previously-added tag from all future messages from this logger.
  ///
  /// This is not invoked and resolves silently when using Flutter web.
  Future<void> removeTag(String tagName) async {
    return await channel.invokeMethod('loggerRemoveTag', {
      'identifier': hashCode.toString(),
      'key': tagName,
    });
  }

  @protected
  @visibleForTesting
  String levelAsStatus(Level level) {
    // Capture 'fine' logs as well as `SHOUT` since SHOUT
    // is intended for debugging
    if (level.value <= 500 || level == Level.SHOUT) return 'debug';

    if (level == Level.INFO) return 'info';

    if (level == Level.CONFIG) return 'notice';

    if (level == Level.WARNING) return 'warn';

    if (level == Level.SEVERE) return 'error';

    return 'critical';
  }
}
