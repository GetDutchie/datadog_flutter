import 'package:datadog_flutter/datadog_logger.dart';
import 'package:datadog_flutter/src/channel.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'method_channel_helpers.dart';

void main() {
  group('DatadogLogger', () {
    late DatadogLogger subject;
    late List<MethodCall> calls;

    setUp(() {
      calls = [];
      overrideMethodChannel(
        channelName: channel.name,
        onCall: (call) async {
          calls.add(call);
        },
      );
      subject = DatadogLogger(
        loggerName: 'test_logger',
        bindOnRecord: false,
      );
    });
    group('log', () {
      String logCallLevel() {
        final logCalls = calls.logCalls();

        return logCalls.single.arguments['level'] as String;
      }

      test('it maps Level.ALL to debug', () async {
        await subject.log('test', Level.ALL);

        expect(logCallLevel(), 'debug');
      });

      test('it maps Level.FINEST to debug', () async {
        await subject.log('test', Level.FINEST);

        expect(logCallLevel(), 'debug');
      });
      test('it maps Level.FINER to debug', () async {
        await subject.log('test', Level.FINER);

        expect(logCallLevel(), 'debug');
      });

      test('it maps Level.FINE to debug', () async {
        await subject.log('test', Level.FINE);

        expect(logCallLevel(), 'debug');
      });

      test('it maps Level.SHOUT to debug', () async {
        await subject.log('test', Level.SHOUT);

        expect(logCallLevel(), 'debug');
      });

      test('it maps Level.CONFIG to notice', () async {
        await subject.log('test', Level.CONFIG);

        expect(logCallLevel(), 'notice');
      });

      test('it maps Level.INFO to info', () async {
        await subject.log('test', Level.INFO);

        expect(logCallLevel(), 'info');
      });

      test('it maps Level.WARNING to warn', () async {
        await subject.log('test', Level.WARNING);

        expect(logCallLevel(), 'warn');
      });

      test('it maps Level.SEVERE to error', () async {
        await subject.log('test', Level.SEVERE);

        expect(logCallLevel(), 'error');
      });

      test('it does not log Level.OFF logs', () async {
        await subject.log('test', Level.OFF);

        expect(calls.nothingLogged(), isTrue);
      });
    });
  });
}

extension on List<MethodCall> {
  List<MethodCall> logCalls() {
    return where((element) => element.method == 'loggerLog').toList();
  }

  bool nothingLogged() {
    return logCalls().isEmpty;
  }
}
