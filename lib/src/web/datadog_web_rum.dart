import 'package:datadog_flutter/src/web/interop/dd_rum.dart' as dd_rum;
import 'package:datadog_flutter/src/web/interop/utils.dart';

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
        dd_rum.setRumGlobalContext(jsify(rumAttributes));
        return true;
      case 'rumAddError':
        dd_rum.addError(call.arguments['message']);
        return true;
      case 'rumAddTiming':
        dd_rum.addTiming(call.arguments['name']);
        return false;
      case 'rumAddUserAction':
        dd_rum.addAction(
          call.arguments['name'],
          jsify(call.arguments['attributes']),
        );
        return true;
      case 'rumRemoveAttribute':
        rumAttributes.remove(call.arguments['key']);
        dd_rum.setRumGlobalContext(rumAttributes);
        return false;
      case 'rumStartView':
        dd_rum.startView(call.arguments['key']);
        return true;
      case 'rumStartUserAction':
      case 'rumStopUserAction':
      case 'rumStopView':
        return false;
      case 'setUserInfo':
        dd_rum.setUser(jsify({
          'email': call.arguments['email'],
          'id': call.arguments['id'],
          'name': call.arguments['name'],
          ...?call.arguments['extraInfo']
        }));
        return true;
      default:
        return null;
    }
  }

  void init(MethodCall call) {
    dd_rum.init(dd_rum.DatadogOptions(
      applicationId: call.arguments['webRumApplicationId'],
      clientToken: call.arguments['clientToken'],
      env: call.arguments['environment'],
      service: call.arguments['serviceName'],
      site: call.arguments['useEUEndpoints'] ? 'datadoghq.eu' : 'datadoghq.com',
      trackInteractions: true,
    ));
  }
}
