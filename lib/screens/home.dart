import 'package:eccomerce_app/controllers/auth_service.dart';
import 'package:eccomerce_app/widgets/home_button.dart';
import 'package:eccomerce_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton.outlined(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Want to logout out?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Close the dialog first
                              Navigator.pop(context);

                              // Perform logout
                              await AuthService().logout();

                              // Navigate to login screen and clear navigation stack
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login', // Replace with your login route name
                                (route) => false,
                              );
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      );
                    });
              },
              icon: Icon(
                color: Colors.white,
                Icons.logout,
              ))
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                color: Colors.deepPurple.shade100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardText(keyy: 'Total products', value: '100'),
                  DashboardText(keyy: 'Total products', value: '100'),
                  DashboardText(keyy: 'Total products', value: '100'),
                  DashboardText(keyy: 'Total products', value: '100'),
                  DashboardText(keyy: 'Total products', value: '100'),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                HomeButton(
                  name: 'Orders',
                  ontap: () {
                    Navigator.pushNamed(
                      context,
                      '/orders',
                    );
                  },
                ),
                HomeButton(
                  name: 'Products',
                  ontap: () {
                    Navigator.pushNamed(context, '/products');
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                HomeButton(
                  name: 'Promos',
                  ontap: () {
                    Navigator.pushNamed(context, '/promos',
                        arguments: {"promo": true});
                  },
                ),
                HomeButton(
                  name: 'Banners',
                  ontap: () {
                    Navigator.pushNamed(context, '/promos',
                        arguments: {"promo": false});
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                HomeButton(
                  name: 'Categories',
                  ontap: () {
                    Navigator.pushNamed(context, '/category');
                  },
                ),
                HomeButton(
                  name: 'Coupons',
                  ontap: () {
                    Navigator.pushNamed(context, '/coupon');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
