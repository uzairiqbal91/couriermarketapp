import 'package:flutter/material.dart';

class DisplayError extends StatelessWidget {
  final Widget icon;
  final String? message;
  final error;

  const DisplayError({
    this.icon = const Icon(Icons.error_outline, color: Colors.grey, size: 96),
    this.message,
    this.error,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: this.icon),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            this.message ?? this.error.toString(), // ?? "Something went wrong",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
