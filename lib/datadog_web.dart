import 'dart:async';

import 'package:datadog_flutter/src/web/datadog_web_logger.dart';
import 'package:datadog_flutter/src/web/datadog_web_rum.dart';

import 'package:flutter/services.dart';
import 'package:datadog_flutter/src/channel.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class DatadogFlutterPlugin {
  final logger = DatadogWebLogger();
  final rum = DatadogWebRum();

  static void registerWith(Registrar registrar) {
    final _channel = MethodChannel(
      channel.name,
      const StandardMethodCodec(),
      registrar,
    );
    final instance = DatadogFlutterPlugin();
    _channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'initWithClientToken':
        logger.init(call);
        if (call.arguments['webRumApplicationId'] != null) {
          rum.init(call);
        }

        return true;
      // tracing is handled natively on the browser
      case 'tracingCreateHeadersForRequest':
        return {};
      case 'tracingInitialize':
        return false;
      case 'tracingFinishSpan':
        return true;
      // trackingConsent is handled by `site:` on the browser
      case 'updateTrackingConsent':
        return false;

      default:
        final result =
            logger.handleMethodCall(call) ?? rum.handleMethodCall(call);
        if (result != null) return result;
        throw PlatformException(
          code: 'Unimplemented',
          details:
              "The datadog_flutter plugin for web doesn't implement '${call.method}'",
        );
    }
  }
}
