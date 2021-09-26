import 'package:flutter/material.dart';
import 'package:datadog_flutter/datadog_logger.dart';
import 'package:logging/logging.dart';

class Logs extends StatelessWidget {
  static final controller = TextEditingController(text: 'Hello  from Flutter');

  // Instantiation will bind to root Logger
  static final ddLogger = DatadogLogger();

  /// This can be instantiated anywhere. It can be regularly disposed and recreated
  /// (such as in a build method) becuase DatadogLogger was instantiated
  /// with `bindOnRecord: true`. Any `Logger` instance will forward to DD.
  static final internalLoggger = Logger('MyLoggerName');

  Logs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextFormField(controller: controller),
        MaterialButton(
          onPressed: () => internalLoggger.finest('FINEST ${controller.text}'),
          child: Text('FINEST'),
        ),
        MaterialButton(
          onPressed: () => internalLoggger.finer('FINER ${controller.text}'),
          child: Text('FINER'),
        ),
        MaterialButton(
          onPressed: () => internalLoggger.fine('FINE ${controller.text}'),
          child: Text('FINE'),
        ),
        MaterialButton(
          onPressed: () => internalLoggger.config('CONFIG ${controller.text}'),
          child: Text('CONFIG'),
        ),
        MaterialButton(
          onPressed: () => internalLoggger.info('INFO ${controller.text}'),
          child: Text('INFO'),
        ),
        MaterialButton(
          onPressed: () =>
              internalLoggger.warning('WARNING ${controller.text}'),
          child: Text('WARNING'),
        ),
        MaterialButton(
          onPressed: () => internalLoggger.severe('SEVERE ${controller.text}'),
          child: Text('SEVERE'),
        ),
        MaterialButton(
          onPressed: () => internalLoggger.severe('SHOUT ${controller.text}'),
          child: Text('SHOUT'),
        ),
        Divider(),
        MaterialButton(
          onPressed: () => ddLogger.log(
            'Custom Attributes',
            Level.WARNING,
            attributes: {
              'customString': 'a string',
              'customInt': 12345,
              'customFloat': 12345.678,
              'customBool': true,
            },
          ),
          child: Text('SHOUT'),
        ),
      ],
    );
  }
}
