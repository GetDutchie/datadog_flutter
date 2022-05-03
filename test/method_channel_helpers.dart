import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Overrides the [MethodChannel] with the provided
/// [channelName] and invokes [onCall] whenever
/// a [MethodCall] is received on the channel.
///
/// This is particularly useful because it
/// eliminates the need to pass [MethodChannel]s
/// in constructors solely to allow for testing
/// overrides. Instead, you can declare a
///
/// ```dart
/// const _channel = MethodChannel(...)
/// ```
///
/// and use this  method in tests to receive
/// the [MethodCall]s that were intended for
/// the declared channel.
void overrideMethodChannel({
  required String channelName,
  required Future Function(MethodCall) onCall,
}) {
  // Since this call is idempotent, we can call it more than once
  // without fear of any issues
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
      .setMockMethodCallHandler(
    MethodChannel(channelName),
    onCall,
  );
}
