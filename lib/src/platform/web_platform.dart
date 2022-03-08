import 'package:datadog_flutter/src/platform/runtime_platform.dart';

class WebPlatform implements RuntimePlatform {
  @override
  final isAndroid = false;

  @override
  final isIOS = false;

  @override
  final isWeb = true;

  const WebPlatform();
}

const platform = WebPlatform();
