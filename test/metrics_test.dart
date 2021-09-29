import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:datadog_flutter/metrics.dart';

const elapsedTime = 1000;

class MockStopwatch extends Mock implements Stopwatch {
  // While `when(elapsedMilliseconds).then` is the proper way
  // to do this, an error was thrown in mockito becuase the
  // stubbed property started as null
  @override
  int elapsedMilliseconds = elapsedTime;
}

const apiKey = '1234nonexistent';
const DATADOG_URL = 'https://api.datadoghq.com/api/v1/series?api_key=$apiKey';

void main() {
  group('DatadogMetrics', () {
    final manager = DatadogMetrics(
      apiKey,
      host: '123',
      prefix: 'flutterdog',
      defaultTags: ['home:'],
    );

    group('#count', () {
      test('with default tags', () async {
        final metric = manager.count('my.count.metric', 1, tags: ['login:']);
        expect(metric.tags, hasLength(2));
        expect(metric.tags, containsAllInOrder(['home:', 'login:']));
      });

      test('with prefix', () {
        final metric = manager.count('my.count.metric', 1);
        expect(metric.name, 'flutterdog.my.count.metric');
      });
    });

    group('#gauge', () {
      test('with default tags', () async {
        final metric = manager.count('my.gauge.metric', 1, tags: ['login:']);
        expect(metric.tags, hasLength(2));
        expect(metric.tags, containsAllInOrder(['home:', 'login:']));
      });

      test('with prefix', () {
        final metric = manager.count('my.gauge.metric', 1);
        expect(metric.name, 'flutterdog.my.gauge.metric');
      });
    });

    group('#rate', () {
      test('with default tags', () async {
        final metric = manager.rate('my.rate.metric', 1, tags: ['login:']);
        expect(metric.tags, hasLength(2));
        expect(metric.tags, containsAllInOrder(['home:', 'login:']));
      });

      test('with prefix', () {
        final metric = manager.rate('my.rate.metric', 1);
        expect(metric.name, 'flutterdog.my.rate.metric');
      });
    });

    group('#time', () {
      late Stopwatch watch;
      setUpAll(() {
        watch = MockStopwatch();
      });

      test('with stopwatch', () {
        final metric = manager.time('my.time.metric', watch, tags: ['login:']);
        final map = metric.asMap;

        expect(map['points'], hasLength(2));
        expect(map['points'][0][0], equals(map['points'][0][1]));
        expect(map['points'][1][0], equals(map['points'][1][1]));
        expect(map['points'][0][1] + elapsedTime, greaterThanOrEqualTo(map['points'][1][1]));
      });

      test('with default tags', () {
        final metric = manager.time('my.time.metric', watch, tags: ['login:']);
        expect(metric.tags, hasLength(2));
        expect(metric.tags, containsAllInOrder(['home:', 'login:']));
      });

      test('with prefix', () {
        final metric = manager.time('my.time.metric', watch);
        expect(metric.name, 'flutterdog.my.time.metric');
      });
    });

    test('#increment', () {
      final metric = manager.increment('my.increment.metric');
      expect(metric.name, 'flutterdog.my.increment.metric');
      expect(metric.value.last.last, 1);
    });

    test('#mergeTags', () {
      final tags = manager.mergeTags(['login:', 'misc:', 'login:']);
      expect(manager.defaultTags, {'home:'});
      expect(tags, {'login:', 'home:', 'misc:'});
    });

    group('#startQueue', () {
      tearDown(() {
        manager.queue.clear();
        manager.stopQueue();
      });

      test('collects metrics', () {
        expect(manager.queue, isEmpty);
        manager.startQueue();
        final metric = manager.increment('my.increment.metric');
        expect(manager.queue, contains(metric));
      });
    });
  });
}
