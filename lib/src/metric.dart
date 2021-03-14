import 'dart:convert';

/// Supported Datadog types
enum MetricType { count, gauge, rate }

/// A reportable metric to be synced with Datadog
class Metric {
  final String name;
  final MetricType type;
  final List<List<int>> value;
  final String? host;
  final int? interval;
  final String? prefix;
  final Set<String>? tags;

  const Metric(
    String _name,
    this.type,
    this.value, {
    this.host,
    this.interval,
    this.prefix,
    this.tags,
  })  : assert(
          type != MetricType.gauge || interval == null,
          '`interval` is only applicable for `count` and `rate`',
        ),
        name = prefix == null ? _name : '$prefix.$_name';

  Map<String, dynamic> get asMap {
    final map = {
      'metric': name,
      'points': value,
      'type': typeAsString,
      'host': host,
    };

    if (interval != null) {
      map['interval'] = interval;
    }

    if (tags != null && tags!.isNotEmpty) {
      map['tags'] = tags;
    }

    return map;
  }

  String get asJson => jsonEncode(asMap);

  String get typeAsString {
    switch (type) {
      case MetricType.count:
        return 'count';
      case MetricType.rate:
        return 'rate';
      case MetricType.gauge:
        return 'gauge';
      default:
        throw FallThroughError();
    }
  }

  @override
  String toString() => asJson;
}
