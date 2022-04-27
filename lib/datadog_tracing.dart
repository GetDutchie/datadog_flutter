import 'package:datadog_flutter/src/channel.dart';
import 'package:http/http.dart' as http;

/// Add trace headers to all requests
class DatadogTracingHttpClient extends http.BaseClient {
  /// Populates APM's "RESOURCE" column. Defaults to `dart.http`.
  final String resourceName;

  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  ///
  /// By default, a new [http.Client] will be instantiated and used.
  final http.Client _innerClient;

  DatadogTracingHttpClient({
    http.Client? innerClient,
    this.resourceName = 'dart.http',
  }) : _innerClient = innerClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final traceHeaders = await DatadogTracing.createHeaders(
      method: request.method,
      resourceName: resourceName,
      url: request.url.toString(),
    );
    request.headers.addAll(traceHeaders);
    // To make sure the generated traces from Real User Monitoring
    // don’t affect your APM Index Spans counts.
    // https://docs.datadoghq.com/real_user_monitoring/connect_rum_and_traces/?tab=iosrum
    request.headers.addAll({'x-datadog-origin': 'rum'});

    http.StreamedResponse? response;
    try {
      return response = await _innerClient.send(request);
    } finally {
      final spanId = traceHeaders['x-datadog-parent-id'];
      if (spanId != null) {
        // the native DD layer should not delay completion of the request
        // errors are also swallowed
        // ignore: unawaited_futures
        DatadogTracing.finishSpan(
          spanId,
          statusCode: response?.statusCode,
        ).catchError((e) => null);
      }
    }
  }
}

class DatadogTracing {
  /// The tracer **must** be initialized before making any requests
  /// with [DatadogTracingHttpClient].
  static Future<void> initialize() async {
    return await channel.invokeMethod('tracingInitialize');
  }

  /// Generates headers to inject in [DatadogTracingHttpClient].
  static Future<Map<String, String>> createHeaders({
    String? method,
    required String resourceName,
    String? url,
  }) async {
    final result = await channel.invokeMapMethod<String, String>(
      'tracingCreateHeadersForRequest',
      {
        if (method != null) 'method': method,
        'resourceName': resourceName,
        if (url != null) 'url': url,
      },
    );
    return result ?? <String, String>{};
  }

  /// Acknowledges the completion of a task.
  static Future<void> finishSpan(String spanId, {int? statusCode}) async {
    return await channel.invokeMethod('tracingFinishSpan', {
      'spanId': spanId,
      if (statusCode != null) 'statusCode': statusCode,
    });
  }
}
