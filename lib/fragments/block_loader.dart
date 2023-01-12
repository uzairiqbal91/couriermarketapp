import 'package:flutter/material.dart';

Future<void> showBlockLoader({
  required BuildContext context,
  String text = "Please Wait",
}) =>
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(
          children: [
            Center(
              child: Column(children: [
                CircularProgressIndicator(),
                Divider(),
                Text("Please Wait"),
              ]),
            ),
          ],
        ),
      ),
    );
