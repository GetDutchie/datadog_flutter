import 'dart:async';
import 'dart:html' as html;

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
        html.document.addEventListener('ready', (event) {
          _writeJavascriptToDOM(LOGGER_SCRIPT);
          if (call.arguments['webRumApplicationId'] != null) {
            _writeJavascriptToDOM(RUM_SCRIPT);
          }
        });

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
        final result = logger.handleMethodCall(call) ?? rum.handleMethodCall(call);
        if (result != null) return result;
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

  /// Creates script text to inject into the browser to import DD scripts.
  /// See [_writeJavascriptToDOM].
  static String _generateScript(String jsURL, String windowProperty) => '''
    (function(h,o,u,n,d) {
    h=h[d]=h[d]||{q:[],onReady:function(c){h.q.push(c)}}
    d=o.createElement(u);d.async=1;d.src=n
    n=o.getElementsByTagName(u)[0];n.parentNode.insertBefore(d,n)
  })(window,document,'script','$jsURL','$windowProperty')
  ''';

  /// Append raw text in a script tag to the document's <head>
  /// See [_generateScript],
  static void _writeJavascriptToDOM(String javascript) {
    final element = html.document.createElement('script');
    element.text = javascript;
    final scriptTag = html.document.getElementsByTagName('script').first;
    html.window.console.log(scriptTag.parentNode);
    scriptTag.parentNode?.insertBefore(element, scriptTag);
  }
}
