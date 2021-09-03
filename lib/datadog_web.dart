import 'dart:async';
import 'dart:html' as html;

import 'package:datadog_flutter/src/interop/dd_log.dart' as dd_logs;
import 'package:datadog_flutter/src/interop/dd_rum.dart' as dd_rum;

import 'package:flutter/services.dart';
import 'package:datadog_flutter/src/channel.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class DatadogFlutterPlugin {
  static void registerWith(Registrar registrar) {
    final _channel = MethodChannel(
      channel.name,
      const StandardMethodCodec(),
      registrar,
    );
    final instance = DatadogFlutterPlugin();
    _channel.setMethodCallHandler(instance.handleMethodCall);
    html.document.addEventListener('ready', (event) {
      _writeJavascriptToDOM(LOGGER_SCRIPT);
      _writeJavascriptToDOM(RUM_SCRIPT);
    });
  }

  final Map<String, dd_logs.Logger> loggers = {};
  final Map<String, Map<String, dynamic>> logAttributes = {};
  final Map<String, dynamic> rumAttributes = {};

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'initWithClientToken':
        dd_logs.onReady(() {
          dd_logs.init({
            'clientToken': call.arguments['clientToken'],
            'env': call.arguments['environment'],
            'service': call.arguments['service'],
            'site': call.arguments['useEUEndpoints'] ? 'datadoghq.eu' : 'datadoghq.com',
          });
          dd_rum.onReady(() {
            dd_rum.init({
              'clientToken': call.arguments['clientToken'],
              'env': call.arguments['environment'],
              'service': call.arguments['service'],
              'site': call.arguments['useEUEndpoints'] ? 'datadoghq.eu' : 'datadoghq.com',
              'trackInteractions': true,
              'applicationId': call.arguments['webRumApplicationId'],
            });
          });
        });
        return true;
      case 'loggerCreateLogger':
        final logger = dd_logs.createLogger(call.arguments['loggerName'], 'debug', 'http');
        loggers[call.arguments['identifier']] = logger;
        return true;
      case 'loggerAddAttribute':
        logAttributes[call.arguments['identifier']] ??= {};
        logAttributes[call.arguments['identifier']]?[call.arguments['key']] =
            call.arguments['value'];
        dd_logs.onReady(() {
          dd_logs.setLoggerGlobalContext(logAttributes[call.arguments['identifier']] ?? {});
        });
        return true;
      case 'loggerAddTag':
        return false;
      case 'loggerRemoveAttribute':
        logAttributes[call.arguments['identifier']]?.remove(call.arguments['key']);
        dd_logs.setLoggerGlobalContext(logAttributes[call.arguments['identifier']] ?? {});
        return true;
      case 'loggerRemoveTag':
        return false;
      case 'log':
        loggers[call.arguments['identifier']]?.log(
          call.arguments['message'],
          call.arguments['attributes'],
          call.arguments['level'],
        );
        return true;
      case 'resourceStartLoading':
      case 'resourceStopLoading':
        return false;
      case 'rumAddAttribute':
        rumAttributes[call.arguments['key']] = call.arguments['value'];
        dd_rum.setRumGlobalContext(rumAttributes);
        return true;
      case 'rumAddError':
        dd_rum.addError(call.arguments['message']);
        return true;
      case 'rumAddTiming':
        dd_rum.addTiming(call.arguments['name']);
        return false;
      case 'rumAddUserAction':
        dd_rum.addAction(call.arguments['name'], call.arguments['attributes']);
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
        dd_rum.setUser({
          'email': call.arguments['email'],
          'id': call.arguments['id'],
          'name': call.arguments['name'],
          ...?call.arguments['extraInfo']
        });
        return true;
      case 'tracingCreateHeadersForRequest':
        // this is handled natively on the browser
        return {};
      case 'tracingFinishSpan':
        // this is handled natively on the browser
        return true;
      case 'updateTrackingConsent':
        return false;

      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The datadog_flutter plugin for web doesn't implement '${call.method}'",
        );
    }
  }

  static final LOGGER_SCRIPT =
      _generateScript('https://www.datadoghq-browser-agent.com/datadog-logs-v3.js', 'DD_LOGS');
  static final RUM_SCRIPT =
      _generateScript('https://www.datadoghq-browser-agent.com/datadog-rum-v3.js', 'DD_RUM');

  static String _generateScript(String jsURL, String windowProperty) => '''
    (function(h,o,u,n,d) {
    h=h[d]=h[d]||{q:[],onReady:function(c){h.q.push(c)}}
    d=o.createElement(u);d.async=1;d.src=n
    n=o.getElementsByTagName(u)[0];n.parentNode.insertBefore(d,n)
  })(window,document,'script','$jsURL','$windowProperty')
  ''';

  static void _writeJavascriptToDOM(String javascript) {
    final element = html.document.createElement('script');
    element.text = javascript;
    final scriptTag = html.document.getElementsByTagName('script').first;
    html.window.console.log(scriptTag.parentNode);
    scriptTag.parentNode?.insertBefore(element, scriptTag);
  }
}
