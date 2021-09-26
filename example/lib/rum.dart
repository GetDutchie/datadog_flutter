import 'package:datadog_flutter/datadog_rum.dart';
import 'package:flutter/material.dart';

import 'example_button.dart';

class Rum extends StatelessWidget {
  static final controller = TextEditingController(text: 'Event from Flutter');

  const Rum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExampleButton(
          onPressed: () {
            final route = MaterialPageRoute(
              fullscreenDialog: true,
              settings: RouteSettings(name: 'RumModalRoute'),
              builder: (BuildContext _) => _ModalRoute(),
            );
            Navigator.of(context).push(route);
          },
          text: 'Change Route',
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Event Text'),
            autofocus: true,
          ),
        ),
        ExampleButton(
          onPressed: () =>
              DatadogRum.instance.addUserAction('TAP ${controller.text}'),
          text: 'Tap Event',
        ),
        ExampleButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'Scroll ${controller.text}',
            action: RUMAction.scroll,
          ),
          text: 'Scroll Event',
        ),
        ExampleButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'SWIPE ${controller.text}',
            action: RUMAction.swipe,
          ),
          text: 'Swipe Event',
        ),
        ExampleButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'CLICK ${controller.text}',
            action: RUMAction.click,
          ),
          text: 'Click Event',
        ),
        ExampleButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'CUSTOM ${controller.text}',
            action: RUMAction.custom,
          ),
          text: 'Custom Event',
        ),
        Divider(),
        ExampleButton(
          onPressed: () => throw StateError('State Error from Flutter'),
          text: 'Report Zoned Error To RUM',
        ),
        ExampleButton(
          onPressed: () async {
            try {
              throw StateError('Custom Add Error from Flutter');
            } catch (e, st) {
              await DatadogRum.instance.addError(e, st);
            }
          },
          text: 'Add Error To RUM',
        ),
        Divider(),
        ExampleButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'Custom Attributes',
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
    );
  }
}

class _ModalRoute extends StatelessWidget {
  const _ModalRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ExampleButton(
          onPressed: Navigator.of(context).pop,
          text: 'Go Back',
        ),
      ),
    );
  }
}
