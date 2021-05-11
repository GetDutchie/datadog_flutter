import 'package:flutter/material.dart';
import 'package:datadog_flutter/src/channel.dart';

enum RUMAction {
  tap,
  scroll,
  swipe,

  /// Reported as `custom` on iOS
  click,
  custom,
}

class DatadogRum {
  /// Before invoking any methods, `DatadogFlutter.initialize` must be invoked
  /// with a non-empty `rumApplicationId`.
  static const DatadogRum instance = DatadogRum._();

  const DatadogRum._();

  /// Adds a global attribute to all future RUM events.
  Future<void> addAttribute(String attributeName, String value) async {
    return await channel.invokeMethod('rumAddAttribute', {
      'key': attributeName,
      'value': value,
    });
  }

  Future<void> addError(Object error, StackTrace stackTrace) async {
    if (error is FlutterErrorDetails) {
      return await addFlutterError(error);
    }

    return await channel.invokeMethod('rumAddError', {
      'message': error.toString(),
      'stack': stackTrace.toString(),
    });
  }

  /// Convenience method for [addError]
  Future<void> addFlutterError(FlutterErrorDetails error) async {
    return await channel.invokeMethod('rumAddError', {
      'message': error.exceptionAsString(),
      'stack': error.stack.toString(),
    });
  }

  /// Manually track screen load time. See [DatadogObserver].
  Future<void> addTiming(String event) async {
    return await channel.invokeMethod('rumAddTiming', {'name': event});
  }

  /// Manually track a user event.
  Future<void> addUserAction(
    String name, {
    RUMAction action = RUMAction.tap,
    Map<String, dynamic> attributes = const <String, dynamic>{},
  }) async {
    return await channel.invokeMethod('rumAddUserAction', {
      'name': name,
      'type': action.index,
      'attributes': attributes,
    });
  }

  /// Removes a global attribute from all future RUM events.
  Future<void> removeAttribute(String attributeName) async {
    return await channel.invokeMethod('rumRemoveAttribute', {
      'key': attributeName,
    });
  }

  /// Notifies that the Resource starts being loaded from given [url].
  ///
  /// [key] should be a uniquely generated identifier. This identifier
  /// should be used by [stopLoading] when ready.
  ///
  /// [method] should be an uppercase HTTP method.
  static Future<void> startResourceLoading(
    String key, {
    required String url,
    String method = 'GET',
    Map<String, dynamic> attributes = const <String, dynamic>{},
  }) async {
    return await channel.invokeMethod('resourceStartLoading', {
      'key': key,
      'url': url,
      'method': method.toUpperCase(),
      'attributes': attributes,
    });
  }

  /// Manually track entry to a screen. See [DatadogObserver].
  Future<void> startView(String screenName) async {
    return await channel.invokeMethod('rumStartView', {'key': screenName});
  }

  /// Manually track a user event.
  ///
  /// This is used to track long running user actions (e.g. "scroll").
  /// Such an User Action must be stopped with [stopUserAction], and
  /// will be stopped automatically if it lasts for more than 10 seconds.
  Future<void> startUserAction(
    String name, {
    RUMAction action = RUMAction.tap,
  }) async {
    return await channel.invokeMethod('rumStartUserAction', {
      'name': name,
      'type': action.index,
    });
  }

  /// Notifies that the Resource stops being loaded.
  ///
  /// [errorMessage] and [statusCode]/[kind] cannot be used in conjunction.
  /// If [errorMessage] is present, [statusCode] will not be reported on iOS
  /// but will be reported together on Android.
  ///
  /// [kind] is one of "document", "xhr", "beacon", "fetch", "css", "js",
  /// "image". "font", "media", "other". Defaults to `fetch`.
  ///
  /// [attributes] will not be reported if [errorMessage] is present
  /// on Android.
  static Future<void> stopResourceLoading(
    String key, {
    int? statusCode,
    String? errorMessage,
    String kind = 'fetch',
    Map<String, dynamic> attributes = const <String, dynamic>{},
  }) async {
    return await channel.invokeMethod('resourceStopLoading', {
      'key': key,
      'errorMessage': errorMessage,
      'kind': kind,
      'statusCode': statusCode,
      'attributes': attributes,
    });
  }

  /// Manually track a user event.
  ///
  /// This is used to stop tracking long running user actions (e.g. "scroll"),
  /// started with [startUserAction].
  Future<void> stopUserAction(
    String name, {
    RUMAction action = RUMAction.tap,
  }) async {
    return await channel.invokeMethod('rumStopUserAction', {
      'name': name,
      'type': action.index,
    });
  }

  /// Manually track exit from a screen. See [DatadogObserver].
  Future<void> stopView(String screenName) async {
    return await channel.invokeMethod('rumStopView', {'key': screenName});
  }
}
