import 'package:datadog_flutter/datadog_flutter.dart';
import 'package:datadog_flutter/datadog_rum.dart';
import 'package:flutter/widgets.dart';

class DatadogObserver extends RouteObserver<PageRoute<dynamic>> {
  /// Creates a [NavigatorObserver] that sends `stopView` and `startView` to [DatadogFlutter].
  /// Heavily inspired and borrowed from [FirebaseAnalyticsObserver].
  ///
  /// `DatadogFlutter.initialize` must be called before accessing the observer
  /// with a non-empty `rumApplicationId`.
  DatadogObserver();

  Future<void> _sendScreenView(String? newRoute, String? oldRoute) async {
    if (oldRoute != null) await DatadogRum.instance.stopView(oldRoute);
    if (newRoute != null) await DatadogRum.instance.startView(newRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute && previousRoute is PageRoute) {
      _sendScreenView(route.settings.name, previousRoute.settings.name);
    }
    super.didPush(route, previousRoute);
    DatadogRum.instance.addTiming('push');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is PageRoute && oldRoute is PageRoute) {
      _sendScreenView(newRoute.settings.name, oldRoute.settings.name);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    DatadogRum.instance.addTiming('replace');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(route.settings.name, previousRoute.settings.name);
    }
    super.didPop(route, previousRoute);
    DatadogRum.instance.addTiming('pop');
  }
}
