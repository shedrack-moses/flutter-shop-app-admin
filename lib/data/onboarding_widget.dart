import 'package:flutter/material.dart';

class OnboardingWidget {
  final IconData iconData;
  final String title, description;

  OnboardingWidget(
      {required this.iconData, required this.title, required this.description});
}

class OnboardingItem {
  List<OnboardingWidget> items = [
    OnboardingWidget(
        iconData: Icons.person_3_outlined,
        title: 'Welcome',
        description: 'this is the first page'),
    OnboardingWidget(
        iconData: Icons.person_3_outlined,
        title: 'Welcome',
        description: 'this is the second page'),
    OnboardingWidget(
        iconData: Icons.person_3_outlined,
        title: 'Welcome',
        description: 'this is the third page'),
  ];
}
