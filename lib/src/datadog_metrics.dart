import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart' show visibleForTesting, protected;
import 'package:http/http.dart' as http;
import 'package:datadog_flutter/src/metric.dart';

/// A manager for reporting measurable statistics to Datadog.
///
/// While this library doesn't implement statsd, it aspires to be a
/// [similar API](https://docs.datadoghq.com/api/?lang=bash#post-timeseries-points).
///
/// To batch outbound requests, [startQueue] may be invoked, sending metrics every x interval.
class DatadogMetrics {
  /// The host name reported to Datadog
  final String host;

  /// Tags that should be submitted with every metric
  final List<String> defaultTags;

  /// A prefix for every metric. Does **not** end in `.`
  final String? prefix;

  /// URL with API key
  final String _endpoint;

  /// Datadog expects the time to be in seconds.
  int get currentTime =>
      (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round();

  Timer? _timer;

  bool get _queueIsRunning => _timer?.isActive == true;
  @visibleForTesting
  List<Metric> queue = <Metric>[];

  DatadogMetrics(
    String apiKey, {
    required this.host,
    this.defaultTags = const <String>[],
    this.prefix,
  }) : _endpoint = '$_DATADOG_ENDPOINT?api_key=$apiKey';

  /// ????
  Metric count(
    String name,
    int value, {
    int interval = 1,
    List<String> tags = const <String>[],
  }) {
    final metric = Metric(
      name,
      MetricType.count,
      [
        [currentTime, value]
      ],
      host: host,
      interval: interval,
      prefix: prefix,
      tags: mergeTags(tags),
    );

    send(metric);
    return metric;
  }

  /// ????
  Metric rate(
    String name,
    int value, {
    int interval = 1,
    List<String> tags = const <String>[],
  }) {
    final metric = Metric(
      name,
      MetricType.rate,
      [
        [currentTime, value]
      ],
      host: host,
      interval: interval,
      prefix: prefix,
      tags: mergeTags(tags),
    );

    send(metric);
    return metric;
  }

  /// ????
  Metric gauge(
    String name,
    int value, {
    List<String> tags = const <String>[],
  }) {
    final metric = Metric(
      name,
      MetricType.gauge,
      [
        [currentTime, value]
      ],
      host: host,
      prefix: prefix,
      tags: mergeTags(tags),
    );

    send(metric);
    return metric;
  }

  /// Log the time delta for a metric
  Metric time(
    String name,
    Stopwatch stopwatch, {
    int? interval,
    List<String> tags = const <String>[],
  }) {
    // since currentTime is in seconds
    final elapsed = (stopwatch.elapsedMilliseconds / 1000).round();
    stopwatch.stop();
    final metric = Metric(
      name,
      MetricType.gauge,
      [
        [currentTime - elapsed, currentTime - elapsed],
        [currentTime, currentTime]
      ],
      host: host,
      interval: interval,
      prefix: prefix,
      tags: mergeTags(tags),
    );

    send(metric);
    return metric;
  }

  /// Increase metric counter by one
  Metric increment(
    String name, {
    int? interval,
    List<String> tags = const <String>[],
  }) {
    return rate(name, 1, tags: tags);
  }

  /// Report the metric to Datadog or add to the queue if it's running
  @protected
  Future<void> send(Metric metric) async {
    if (_queueIsRunning) return queue.add(metric);

    return await _httpSend([metric]);
  }

  /// By starting the queue, all metrics are batched and sent every x [interval].
  /// This would reduce the number of outbound requests.
  /// [interval] defaults to 10 seconds
  void startQueue([Duration? interval]) {
    interval ??= Duration(seconds: 10);
    stopQueue();
    _timer = Timer.periodic(interval, _sendQueuedMetrics);
  }

  /// Attempts to send queue and invalidates timer
  void stopQueue() {
    _sendQueuedMetrics(_timer);
    _timer?.cancel();
  }

  @visibleForTesting
  Set<String> mergeTags([
    List<String> tags = const <String>[],
  ]) {
    final list = <String>[];
    list.addAll(defaultTags);
    list.addAll(tags);
    return list.toSet();
  }

  /// Batch report metrics to Datadog
  void _sendQueuedMetrics(Timer? timer) {
    if (queue.isEmpty) return;

    _httpSend(queue).then((_) => queue.clear());
  }

  Future<void> _httpSend(List<Metric> metrics) async {
    try {
      await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          'series':
              metrics.map((m) => m.asMap).toList().cast<Map<String, dynamic>>(),
        }),
      );
    } catch (e) {
      // do nothing
      return Future.value();
    }
  }
}

const _DATADOG_ENDPOINT = 'https://api.datadoghq.com/api/v1/series';
