import 'package:courier_market_mobile/fragments/display_error.dart';
import 'package:courier_market_mobile/fragments/display_loader.dart';
import 'package:flutter/material.dart';

class DisplayResponse extends StatelessWidget {
  final bool isLoading;
  final Widget icon;
  final String? message;
  final Exception? error;

  const DisplayResponse({
    this.isLoading = false,
    this.icon = const Icon(
      Icons.error_outline,
      color: Colors.grey,
      size: 96,
    ),
    this.message,
    this.error,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      isLoading ? DisplayLoader() : DisplayError(error: error, message: message, icon: icon);
}
