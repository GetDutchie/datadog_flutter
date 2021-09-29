import 'package:flutter/material.dart';

const _routes = {'Logs': '/logs', 'RUM': '/rum', 'Tracing': '/tracing'};

class Screen extends StatelessWidget {
  final Widget child;
  final TextEditingController controller;
  final String fieldLabel;

  const Screen({
    Key? key,
    required this.child,
    required this.controller,
    required this.fieldLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datadog Flutter Example'),
        automaticallyImplyLeading: false,
        actions: [
          for (final route in _routes.entries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(route.value),
                child: Center(
                  child: Text(
                    route.key,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: fieldLabel),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class ExampleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const ExampleButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(text),
        ),
      ),
    );
  }
}
