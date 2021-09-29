import 'package:flutter/material.dart';
import 'package:datadog_flutter/datadog_logger.dart';
import 'package:logging/logging.dart';
import 'shared_widgets.dart';

class Logs extends StatelessWidget {
  static final controller = TextEditingController(text: 'Hello from Flutter');

  // Instantiation will bind to root Logger
  static final ddLogger = DatadogLogger();

  /// This can be instantiated anywhere. It can be regularly disposed and recreated
  /// (such as in a build method) becuase DatadogLogger was instantiated
  /// with `bindOnRecord: true`. Any `Logger` instance will forward to DD.
  static final internalLoggger = Logger('MyLoggerName');

  const Logs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      controller: controller,
      fieldLabel: 'Log Text',
      child: ListView(
        shrinkWrap: true,
        children: [
          // This could be refactored to a map using internalLogger.log
          // however, the purpose of an example is to be illustrative so
          // this should remain verbose
          ExampleButton(
            onPressed: () => internalLoggger.finest('FINEST ${controller.text}'),
            text: 'FINEST',
          ),
          ExampleButton(
            onPressed: () => internalLoggger.finer('FINER ${controller.text}'),
            text: 'FINER',
          ),
          ExampleButton(
            onPressed: () => internalLoggger.fine('FINE ${controller.text}'),
            text: 'FINE',
          ),
          ExampleButton(
            onPressed: () => internalLoggger.config('CONFIG ${controller.text}'),
            text: 'CONFIG',
          ),
          ExampleButton(
            onPressed: () => internalLoggger.info('INFO ${controller.text}'),
            text: 'INFO',
          ),
          ExampleButton(
            onPressed: () => internalLoggger.warning('WARNING ${controller.text}'),
            text: 'WARNING',
          ),
          ExampleButton(
            onPressed: () => internalLoggger.severe('SEVERE ${controller.text}'),
            text: 'SEVERE',
          ),
          ExampleButton(
            onPressed: () => internalLoggger.severe('SHOUT ${controller.text}'),
            text: 'SHOUT',
          ),
          const Divider(),
          ExampleButton(
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
            text: 'Custom Attributes',
          ),
        ],
      ),
    );
  }
}
