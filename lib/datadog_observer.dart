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

  Future<void> _sendScreenView(Route? route, Route? previousRoute) async {
    if (previousRoute is PageRoute) {
      final previousRouteName = previousRoute.settings.name;
      if (previousRouteName != null) {
        await DatadogRum.instance.stopView(previousRouteName);
      }
    }
    if (route is PageRoute) {
      final routeName = route.settings.name;
      if (routeName != null) {
        await DatadogRum.instance.startView(routeName);
      }
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _sendScreenView(route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _sendScreenView(newRoute, oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _sendScreenView(route, previousRoute);
    super.didPop(route, previousRoute);
  }
}
