import 'package:flutter/material.dart';

class DashboardText extends StatelessWidget {
  final String keyy, value;
  const DashboardText({super.key, required this.keyy, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          keyy,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
