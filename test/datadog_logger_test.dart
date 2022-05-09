import 'package:datadog_flutter/datadog_logger.dart';
import 'package:datadog_flutter/src/channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  group('DatadogLogger', () {
    late DatadogLogger subject;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => null);

      subject = DatadogLogger(
        loggerName: 'test_logger',
        bindOnRecord: false,
      );
    });
    group('#levelAsStatus', () {
      test('it maps Level.ALL to debug', () async {
        final status = subject.levelAsStatus(Level.ALL);

        expect(status, 'debug');
      });

      test('it maps Level.FINEST to debug', () async {
        final status = subject.levelAsStatus(Level.FINEST);

        expect(status, 'debug');
      });
      test('it maps Level.FINER to debug', () async {
        final status = subject.levelAsStatus(Level.FINER);

        expect(status, 'debug');
      });

      test('it maps Level.FINE to debug', () async {
        final status = subject.levelAsStatus(Level.FINE);

        expect(status, 'debug');
      });

      test('it maps Level.SHOUT to debug', () async {
        final status = subject.levelAsStatus(Level.SHOUT);

        expect(status, 'debug');
      });

      test('it maps Level.CONFIG to notice', () async {
        final status = subject.levelAsStatus(Level.CONFIG);

        expect(status, 'notice');
      });

      test('it maps Level.INFO to info', () async {
        final status = subject.levelAsStatus(Level.INFO);

        expect(status, 'info');
      });

      test('it maps Level.WARNING to warn', () async {
        final status = subject.levelAsStatus(Level.WARNING);

        expect(status, 'warn');
      });

      test('it maps Level.SEVERE to error', () async {
        final status = subject.levelAsStatus(Level.SEVERE);

        expect(status, 'error');
      });

      test('it does not log Level.OFF logs', () async {
        bool levelAsStatusCalled = false;
        _FakeDatadogLogger(
          // Since this is invoked as a parameter to the `loggerLog`
          // MethodCall, use it as a hook to detect whether logging
          // was performed
          onLevelAsStatusCalled: () => levelAsStatusCalled = true,
        ).log('test', Level.OFF);

        expect(levelAsStatusCalled, isFalse);
      });
    });
  });
}

class _FakeDatadogLogger extends DatadogLogger {
  final VoidCallback onLevelAsStatusCalled;

  _FakeDatadogLogger({
    required this.onLevelAsStatusCalled,
  });

  @override
  String levelAsStatus(Level level) {
    onLevelAsStatusCalled();
    return '';
  }
}
