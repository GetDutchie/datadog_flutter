import 'dart:html' as html;

import 'package:datadog_flutter/src/web/interop/dd_rum.dart' as dd_rum;

import 'package:flutter/services.dart';

class DatadogWebRum {
  /// Datadog JS SDK doesn't support removing attributes; to achieve
  /// feature parity, the attributes are tracked internally by the
  /// plugin and the global context is overwritten when adding or
  /// removing attributes.
  final Map<String, dynamic> rumAttributes = {};

  bool? handleMethodCall(MethodCall call) {
    switch (call.method) {
      case 'resourceStartLoading':
      case 'resourceStopLoading':
        return false;
      case 'rumAddAttribute':
        rumAttributes[call.arguments['key']] = call.arguments['value'];
        _onRumReady(() {
          dd_rum.setRumGlobalContext(rumAttributes);
        });
        return true;
      case 'rumAddError':
        _onRumReady(() {
          dd_rum.addError(call.arguments['message']);
        });
        return true;
      case 'rumAddTiming':
        _onRumReady(() {
          dd_rum.addTiming(call.arguments['name']);
        });
        return false;
      case 'rumAddUserAction':
        _onRumReady(() {
          dd_rum.addAction(call.arguments['name'], call.arguments['attributes']);
        });
        return true;
      case 'rumRemoveAttribute':
        rumAttributes.remove(call.arguments['key']);
        dd_rum.setRumGlobalContext(rumAttributes);
        return false;
      case 'rumStartView':
        _onRumReady(() {
          dd_rum.startView(call.arguments['key']);
        });
        return true;
      case 'rumStartUserAction':
      case 'rumStopUserAction':
      case 'rumStopView':
        return false;
      case 'setUserInfo':
        _onRumReady(() {
          dd_rum.setUser({
            'email': call.arguments['email'],
            'id': call.arguments['id'],
            'name': call.arguments['name'],
            ...?call.arguments['extraInfo']
          });
        });
        return true;
      default:
        return null;
    }
  }

  void init(MethodCall call) {
    _onRumReady(() {
      dd_rum.init({
        'clientToken': call.arguments['clientToken'],
        'env': call.arguments['environment'],
        'service': call.arguments['service'],
        'site': call.arguments['useEUEndpoints'] ? 'datadoghq.eu' : 'datadoghq.com',
        'trackInteractions': true,
        'applicationId': call.arguments['webRumApplicationId'],
      });
    });
  }

  /// Fires after document is ready and after window.DD_RUM is available
  static void _onRumReady(void Function() callback) {
    html.document.addEventListener('ready', (event) {
      dd_rum.onReady(callback);
    });
  }
}
