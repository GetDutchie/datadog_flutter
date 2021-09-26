import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:flutter/material.dart';

import 'example_button.dart';

class Tracing extends StatelessWidget {
  static final client = DatadogTracingHttpClient();
  static final API_ROOT = Uri.parse('https://google.com');

  const Tracing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExampleButton(
          onPressed: () => client.get(API_ROOT),
          text: 'GET',
        ),
        ExampleButton(
          onPressed: () => client.put(API_ROOT),
          text: 'PUT',
        ),
        ExampleButton(
          onPressed: () => client.post(API_ROOT),
          text: 'POST',
        ),
        ExampleButton(
          onPressed: () => client.patch(API_ROOT),
          text: 'PATCH',
        ),
        ExampleButton(
          onPressed: () => client.delete(API_ROOT),
          text: 'DELETE',
        ),
      ],
    );
  }
}
