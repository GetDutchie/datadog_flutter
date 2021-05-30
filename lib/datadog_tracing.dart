import 'package:datadog_flutter/src/channel.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

/// Add trace headers to all requests
class DatadogTracingHttpClient extends http.BaseClient {
  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  ///
  /// By default, a new [http.Client] will be instantiated and used.
  final http.Client _innerClient;

  DatadogTracingHttpClient(
    http.Client innerClient,
  ) : _innerClient = innerClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) return await _innerClient.send(request);

    if ((request as http.Request).body.isEmpty) {
      return await _innerClient.send(request);
    }
    final traceHeaders = await DatadogTracing.createHeaders(
      method: request.method,
      url: request.url.toString(),
    );
    request.headers.addAll(traceHeaders);
    // To make sure the generated traces from Real User Monitoring
    // don’t affect your APM Index Spans counts.
    // https://docs.datadoghq.com/real_user_monitoring/connect_rum_and_traces/?tab=iosrum
    request.headers.addAll({'x-datadog-origin': 'rum'});

    http.StreamedResponse response;
    try {
      return response = await _innerClient.send(request);
    } finally {
      final spanId = traceHeaders['x-datadog-parent-id'];
      if (spanId != null) {
        await DatadogTracing.finishSpan(
          spanId,
          statusCode: response?.statusCode,
        );
      }
    }
  }
}

class DatadogTracing {
  static Future<void> initialize() async {
    return await channel.invokeMethod('tracingInitialize');
  }

  static Future<Map<String, String>> createHeaders({
    String method,
    String resourceName,
    String url,
  }) async {
    return await channel.invokeMapMethod<String, String>(
      'tracingCreateHeadersForRequest',
      {
        'method': method,
        'resourceName': resourceName ?? 'network request',
        'url': url,
      },
    );
  }

  /// Acknowledges the completion of a task.
  @protected
  static Future<void> finishSpan(String spanId, {int statusCode}) async {
    return await channel.invokeMethod('tracingFinishSpan', {
      'spanId': spanId,
      'statusCode': statusCode,
    });
  }
}
