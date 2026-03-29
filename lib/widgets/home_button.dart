import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final String name;
  final Function() ontap;
  const HomeButton({super.key, required this.name, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        height: 65,
        width: MediaQuery.sizeOf(context).width * .42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
