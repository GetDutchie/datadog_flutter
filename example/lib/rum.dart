import 'package:datadog_flutter/datadog_rum.dart';
import 'package:flutter/material.dart';

class Rum extends StatelessWidget {
  static final controller = TextEditingController(text: 'Event from Flutter');

  const Rum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        MaterialButton(
          onPressed: () {
            final route = MaterialPageRoute(
              fullscreenDialog: true,
              settings: RouteSettings(name: 'RumModalRoute'),
              builder: (BuildContext _) => _ModalRoute(),
            );
            Navigator.of(context).push(route);
          },
          child: Text('Tap Event'),
        ),
        Divider(),
        TextFormField(controller: controller),
        MaterialButton(
          onPressed: () => DatadogRum.instance.addUserAction('TAP ${controller.text}'),
          child: Text('Tap Event'),
        ),
        MaterialButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'Scroll ${controller.text}',
            action: RUMAction.scroll,
          ),
          child: Text('Scroll Event'),
        ),
        MaterialButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'SWIPE ${controller.text}',
            action: RUMAction.swipe,
          ),
          child: Text('Swipe Event'),
        ),
        MaterialButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'CLICK ${controller.text}',
            action: RUMAction.click,
          ),
          child: Text('Click Event'),
        ),
        MaterialButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'CUSTOM ${controller.text}',
            action: RUMAction.custom,
          ),
          child: Text('Custom Event'),
        ),
        Divider(),
        MaterialButton(
          onPressed: () => throw StateError('State Error from Flutter'),
          child: Text('Report Zoned Error To RUM'),
        ),
        Divider(),
        MaterialButton(
          onPressed: () => DatadogRum.instance.addUserAction(
            'Custom Attributes',
            attributes: {
              'customString': 'a string',
              'customInt': 12345,
              'customFloat': 12345.678,
              'customBool': true,
            },
          ),
          child: Text('Custom Attributes'),
        ),
      ],
    );
  }
}

class _ModalRoute extends StatelessWidget {
  const _ModalRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialButton(
        onPressed: Navigator.of(context).pop,
        child: Text('Go Back'),
      ),
    );
  }
}
