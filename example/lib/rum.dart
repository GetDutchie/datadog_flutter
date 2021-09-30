import 'package:datadog_flutter/datadog_rum.dart';
import 'package:flutter/material.dart';

import 'shared_widgets.dart';

class Rum extends StatelessWidget {
  static final controller = TextEditingController(text: 'Event from Flutter');

  const Rum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      controller: controller,
      fieldLabel: 'Event Text',
      child: ListView(
        shrinkWrap: true,
        children: [
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
          const Divider(),
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
          const Divider(),
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
          const Divider(),
          ExampleButton(
            onPressed: () => DatadogRum.instance.startResourceLoading(
              '${controller.text}1',
              url: controller.text,
            ),
            text: 'Start Resource Loading',
          ),
          ExampleButton(
            onPressed: () => DatadogRum.instance.stopResourceLoading(
              '${controller.text}1',
            ),
            text: 'Stop Resource Loading',
          ),
          ExampleButton(
            onPressed: () =>
                DatadogRum.instance.startUserAction('${controller.text}1'),
            text: 'Start User Action',
          ),
          ExampleButton(
            onPressed: () =>
                DatadogRum.instance.stopUserAction('${controller.text}1'),
            text: 'Stop User Action',
          ),
        ],
      ),
    );
  }
}
