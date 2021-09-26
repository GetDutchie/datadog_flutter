import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
