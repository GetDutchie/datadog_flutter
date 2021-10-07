import 'package:flutter_test/flutter_test.dart';
import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:datadog_flutter/src/channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tester =
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger;

  final map = {
    "resourceName": "greenbits",
    "method": "get",
    "url": "http://greenbits.com"
  };

  tester.setMockMethodCallHandler(channel, (methodCall) async {
    if (methodCall.method == 'tracingCreateHeadersForRequest') {
      return map;
    }

    if (methodCall.method == "tracingFinishSpan") {
      return <String, String>{};
    }
  });

  group("DatadogTracing", () {
    const spanId = "test-test";
    group('#finishSpan', () {
      test("tracing finished", () async {
        await DatadogTracing.initialize();
        final httpClient = DatadogTracingHttpClient();
        final response =
            await httpClient.get(Uri(path: 'http://greenbits.com'));
        expect(
            () => DatadogTracing.finishSpan(spanId,
                statusCode: response.statusCode),
            returnsNormally);
      });
    });

    group('#createHeaders', () {
      test("create headers", () async {
        expect(
            () => DatadogTracing.createHeaders(
                resourceName: "greenbits",
                method: "get",
                url: "http://greenbits.com"),
            returnsNormally);
      });
    });
  });
}
