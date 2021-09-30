import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:flutter/material.dart';

import 'shared_widgets.dart';
import 'config.dart';

class Tracing extends StatelessWidget {
  final controller = TextEditingController(text: API_ROOT);
  static final client = DatadogTracingHttpClient();

  Uri get endpoint => Uri.parse(controller.text);

  Tracing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      controller: controller,
      fieldLabel: 'URL',
      child: ListView(
        shrinkWrap: true,
        children: [
          ExampleButton(
            onPressed: () => client.get(endpoint),
            text: 'GET',
          ),
          ExampleButton(
            onPressed: () => client.put(endpoint),
            text: 'PUT',
          ),
          ExampleButton(
            onPressed: () => client.post(endpoint),
            text: 'POST',
          ),
          ExampleButton(
            onPressed: () => client.patch(endpoint),
            text: 'PATCH',
          ),
          ExampleButton(
            onPressed: () => client.delete(endpoint),
            text: 'DELETE',
          ),
        ],
      ),
    );
  }
}
