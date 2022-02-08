import 'package:flutter_test/flutter_test.dart';
import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:datadog_flutter/src/channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tester =
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger;

  final map = {
    'resourceName': 'http',
    'method': 'get',
    'url': 'https://datadoghq.com',
  };

  tester.setMockMethodCallHandler(channel, (methodCall) async {
    if (methodCall.method == 'tracingCreateHeadersForRequest') {
      return map;
    }

    if (methodCall.method == 'tracingFinishSpan') {
      return <String, String>{};
    }
    return null;
  });

  group('DatadogTracing', () {
    const spanId = 'test-test';
    test('.finishSpan', () async {
      await DatadogTracing.initialize();
      final httpClient = DatadogTracingHttpClient();
      final response = await httpClient.get(Uri(path: 'https://datadoghq.com'));
      expect(
        () =>
            DatadogTracing.finishSpan(spanId, statusCode: response.statusCode),
        returnsNormally,
      );
    });

    test('.createHeaders', () async {
      expect(
        await DatadogTracing.createHeaders(
            resourceName: 'greenbits',
            method: 'get',
            url: 'https://datadoghq.com'),
        map,
      );
    });
  });
}
