import 'package:datadog_flutter/datadog_tracing.dart';
import 'package:flutter/material.dart';

class Tracing extends StatelessWidget {
  static final client = DatadogTracingHttpClient();
  static final API_ROOT = Uri.parse('https://google.com');

  const Tracing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        MaterialButton(
          onPressed: () => client.get(API_ROOT),
          child: Text('GET'),
        ),
        MaterialButton(
          onPressed: () => client.put(API_ROOT),
          child: Text('PUT'),
        ),
        MaterialButton(
          onPressed: () => client.post(API_ROOT),
          child: Text('POST'),
        ),
        MaterialButton(
          onPressed: () => client.patch(API_ROOT),
          child: Text('PATCH'),
        ),
        MaterialButton(
          onPressed: () => client.delete(API_ROOT),
          child: Text('DELETE'),
        ),
      ],
    );
  }
}
