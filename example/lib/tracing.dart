import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:flutter/material.dart';

import 'example_button.dart';
import 'config.dart';

class Tracing extends StatelessWidget {
  static final client = DatadogTracingHttpClient();
  static final ENDPOINT = Uri.parse(API_ROOT);

  const Tracing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExampleButton(
          onPressed: () => client.get(ENDPOINT),
          text: 'GET',
        ),
        ExampleButton(
          onPressed: () => client.put(ENDPOINT),
          text: 'PUT',
        ),
        ExampleButton(
          onPressed: () => client.post(ENDPOINT),
          text: 'POST',
        ),
        ExampleButton(
          onPressed: () => client.patch(ENDPOINT),
          text: 'PATCH',
        ),
        ExampleButton(
          onPressed: () => client.delete(ENDPOINT),
          text: 'DELETE',
        ),
      ],
    );
  }
}
