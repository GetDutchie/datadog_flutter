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

  Future<void> addError(Object error, StackTrace stackTrace) async {
    if (error is FlutterErrorDetails) {
      return await addFlutterError(error);
    }

    return await channel.invokeMethod('addError', {
      'message': error.toString(),
      'stack': stackTrace.toString(),
    });
  }

  /// Convenience method for [addError]
  Future<void> addFlutterError(FlutterErrorDetails error) async {
    return await channel.invokeMethod('addError', {
      'message': error.exceptionAsString(),
      'stack': error.stack.toString(),
    });
  }

  /// Manually track a user event.
  Future<void> addUserAction(
    String name, {
    RUMAction action = RUMAction.tap,
    Map<String, dynamic> attributes = const <String, dynamic>{},
  }) async {
    return await channel.invokeMethod('addUserAction', {
      'key': name,
      'type': action.index,
      'attributes': attributes,
    });
  }

  /// Manually track entry to a screen. See [DatadogObserver].
  Future<void> startView(String screenName) async {
    return await channel.invokeMethod('startView', {'key': screenName});
  }

  /// Manually track exit from a screen. See [DatadogObserver].
  Future<void> stopView(String screenName) async {
    return await channel.invokeMethod('stopView', {'key': screenName});
  }
}
