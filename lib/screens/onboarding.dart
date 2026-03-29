import 'package:eccomerce_app/data/onboarding_widget.dart';
import 'package:eccomerce_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool isLastPage = false;
  var value = OnboardingItem();
  final PageController _controller = PageController();
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'onboarding_completed', true); // Changed key name for clarity

    if (mounted) {
      // Navigate to login page using named route
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _controller.page != null && _controller.page! > 0) {
          _controller.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: PageView.builder(
            onPageChanged: (val) {
              setState(() {
                isLastPage = value.items.length - 1 == val;
              });
            },
            controller: _controller,
            itemCount: value.items.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Text(
                    value.items[index].title,
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  Icon(
                    value.items[index].iconData,
                    size: 80,
                    color: Colors.amber,
                  ),
                  Text(
                    value.items[index].description,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              );
            },
          ),
        ),
        bottomSheet: isLastPage
            ? getStarted()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _controller.jumpToPage(value.items.length - 1);
                    },
                    child: Text('Skip'),
                  ),
                  SmoothPageIndicator(
                      effect: WormEffect(
                        dotWidth: 12,
                        type: WormType.normal,
                      ),
                      controller: _controller,
                      count: value.items.length),
                  TextButton(
                    onPressed: () {
                      _controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeIn);
                    },
                    child: Text('Next'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget getStarted() {
    return Padding(
      padding: const EdgeInsets.all(8.0).copyWith(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.deepPurple,
        ),
        width: MediaQuery.sizeOf(context).width * 0.9,
        child: TextButton(
            onPressed: () {
              _completeOnboarding();
            },
            child: Text('Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ))),
      ),
    );
  }
}
