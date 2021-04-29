import 'package:datadog_flutter/src/tracking_consent.dart';
import 'package:datadog_flutter/src/channel.dart';
export 'package:datadog_flutter/src/tracking_consent.dart';

class DatadogFlutter {
  /// By default, **events will not be sent to Datadog**. This is a requirement
  /// of the SDK to maintain GDPR compliance. To maintain backwards
  /// functionality, use `trackingConsent: TrackingConsent.granted`. For more,
  /// see [TrackingConsent].
  ///
  /// [flavorName] is requested by Datadog's Android SDK, this is the
  /// "VARIANT NAME" in their documentation. It can be retrieved dynamically
  /// from packages like `flutter_config` or `build_config` but is largely, and
  /// safely, ignorable.
  ///
  /// [rumApplicationId] must be provided to track RUM errors, actions, and views.
  static Future<void> initialize({
    required String clientToken,
    required String serviceName,
    required TrackingConsent trackingConsent,
    String? androidRumApplicationId,
    String environment = 'development',
    String flavorName = '',
    String? iosRumApplicationId,
    bool useEUEndpoints = false,
  }) async {
    await channel.invokeMethod('initWithClientToken', {
      'androidRumApplicationId': androidRumApplicationId,
      'clientToken': clientToken,
      'environment': environment,
      'flavorName': flavorName,
      'iosRumApplicationId': iosRumApplicationId,
      'serviceName': serviceName,
      'trackingConsent': trackingConsent.index,
      'useEUEndpoints': useEUEndpoints,
    });
  }

  /// Sets current user information.
  /// Those will be added to logs, traces and RUM events automatically.
  static Future<void> setUserInfo({
    String? id,
    String? email,
    Map<String, dynamic>? extraInfo,
    String? name,
  }) async {
    return await channel.invokeMethod('setUserInfo', {
      'id': id,
      'email': email,
      'extraInfo': extraInfo,
      'name': name,
    });
  }

  /// The SDK changes its behavior according to the new `trackingConsent`
  /// value. For example, if the current tracking consent is `.pending`:
  /// and it is changed to `.granted`, the SDK will send all current and
  /// future data to Datadog; if changed to `.notGranted`, the SDK will
  /// wipe all current data and will not collect any future data.
  static Future<void> updateTrackingConsent(
    TrackingConsent trackingConsent,
  ) async {
    return await channel.invokeMethod('updateTrackingConsent', {
      'trackingConsent': trackingConsent.index,
    });
  }
}
