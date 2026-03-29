import 'package:flutter/material.dart';

import '../controllers/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  void showCircularProgressIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final _signInKey = GlobalKey<FormState>();
  bool _isPasswordToggled = true;
  bool _isConfirmPasswordToggled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Form(
        key: _signInKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              //   mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              // spacing: 10,
              children: [
                Placeholder(
                  fallbackHeight: MediaQuery.sizeOf(context).height * 0.35,
                ),
                Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Create a new account and get started',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  enabled: !isLoading,
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  enabled: !isLoading,
                  obscureText: _isPasswordToggled,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 8) {
                      return 'Password should have atleast 8 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordToggled = !_isPasswordToggled;
                            });
                          },
                          icon: Icon(_isPasswordToggled
                              ? Icons.visibility_sharp
                              : Icons.visibility_off_sharp)),
                      hintText: 'password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  enabled: !isLoading,
                  obscureText: _isConfirmPasswordToggled,
                  controller: _confirmpasswordController,
                  // Add this validation to your confirm password TextFormField
                  validator: (value) {
                    if (value!.isEmpty || value.length < 8) {
                      return 'Password should have atleast 8 characters';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordToggled =
                                  !_isConfirmPasswordToggled;
                            });
                          },
                          icon: Icon(_isConfirmPasswordToggled
                              ? Icons.visibility_sharp
                              : Icons.visibility_off_sharp)),
                      hintText: ' confirm password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_signInKey.currentState!.validate()) {
                              // Check if passwords match
                              if (_passwordController.text !=
                                  _confirmpasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Passwords do not match!')),
                                );
                                return;
                              }
                              setState(() {
                                isLoading = true;
                              });
                              await AuthService()
                                  .createAccountWithEmail(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim())
                                  .then((value) {
                                print('Auth result: $value');
                                if (value == 'success') {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Logged in successfully!!'),
                                    ),
                                  );
                                  if (mounted) {
                                    Navigator.restorablePushNamedAndRemoveUntil(
                                        context, '/home', (route) => false);
                                  }
                                }
                              }).catchError((onError) {
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('Error!! $onError'),
                                ));
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(15),
                      backgroundColor: Theme.of(context).primaryColor,
                      //shape: RoundedRectangleBorder(),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Sign Up',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    TextButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
