import 'package:datadog_flutter/src/channel.dart';
import 'package:meta/meta.dart';

class DatadogResources {
  /// Notifies that the Resource starts being loaded from given [url].
  ///
  /// [key] should be a uniquely generated identifier. This identifier
  /// should be used by [stopLoading] when ready.
  ///
  /// [method] should be an uppercase HTTP method.
  static Future<void> startLoading(
    String key, {
    @required String url,
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
  static Future<void> stopLoading(
    String key, {
    int statusCode,
    String errorMessage,
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
}
