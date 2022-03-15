import 'dart:io';

import 'package:datadog_flutter/src/platform/runtime_platform.dart';

class IOPlatform implements RuntimePlatform {
  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isIOS => Platform.isIOS;

  @override
  final isWeb = false;

  IOPlatform();
}

final platform = IOPlatform();
