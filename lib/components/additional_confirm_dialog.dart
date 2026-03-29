import 'package:flutter/material.dart';

class AdditionalConfirmDialog extends StatelessWidget {
  final String contentText;
  final VoidCallback onYes, onNo;
  const AdditionalConfirmDialog(
      {super.key,
      required this.contentText,
      required this.onYes,
      required this.onNo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(contentText),
      title: Text('Are you sure?'),
      actions: [
        TextButton(
          onPressed: onYes,
          child: Text('No'),
        ),
        TextButton(
          onPressed: onNo,
          child: Text('Yes'),
        ),
      ],
    );
  }
}
