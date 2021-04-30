import 'package:datadog_flutter/src/channel.dart';
import 'package:http/http.dart' as http;

/// Add trace headers to all requests
class DatadogTraceClient extends http.BaseClient {
  /// A normal HTTP client, treated like a manual `super`
  /// as detailed by [the Dart team](https://github.com/dart-lang/http/blob/378179845420caafbf7a34d47b9c22104753182a/README.md#using)
  ///
  /// By default, a new [http.Client] will be instantiated and used.
  final http.Client _innerClient;

  DatadogTraceClient(
    http.Client innerClient,
  ) : _innerClient = innerClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) return _innerClient.send(request);

    if ((request as http.Request).body.isEmpty) return _innerClient.send(request);

    var newRequest = http.Request(request.method, request.url);
    final traceHeaders = await DatadogTrace.createHeaders();
    print(traceHeaders);
    newRequest.headers.addAll(traceHeaders);
    newRequest.headers.addAll(request.headers);

    return _innerClient.send(newRequest);
  }
}

class DatadogTrace {
  static Future<Map<String, String>> createHeaders() async {
    return await channel.invokeMapMethod<String, String>('traceCreateHeadersForRequest');
  }
}
