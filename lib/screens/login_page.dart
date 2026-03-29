import 'package:eccomerce_app/controllers/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _loginKey = GlobalKey<FormState>();
  bool _isPasswordToggled = true;
  bool _isLoading = false; // Add loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,

      body: SingleChildScrollView(
        child: Form(
          key: _loginKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                //  mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                // spacing: 10,
                children: [
                  Placeholder(
                    fallbackHeight: MediaQuery.sizeOf(context).height * 0.35,
                  ),
                  Text(
                    'Login',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Get started with your account',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading, // Disable when loading
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email cannot be empty';
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
                    obscureText: _isPasswordToggled,
                    controller: _passwordController,
                    enabled: !_isLoading, // Disable when loading
                    validator: (value) {
                      if (value!.isEmpty || value.length < 8) {
                        return 'Password should have atleast 8 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // Disable when loading
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
                  //forget password
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              // Disable when loading
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Forget password'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Enter your email'),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            controller: _emailController,
                                            decoration: InputDecoration(
                                                labelText: 'Email',
                                                border: OutlineInputBorder()),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (_emailController.text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Email cannot be empty')));
                                              return;
                                            }
                                            await AuthService()
                                                .resetPassword(_emailController
                                                    .text
                                                    .trim())
                                                .then((value) {
                                              if (value == 'Mail sent') {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'A password link have been sent to your email!!')));
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        backgroundColor:
                                                            Colors.red,
                                                        content: Text(
                                                          value.toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )));
                                              }
                                            });
                                          },
                                          child: Text('Submit'),
                                        ),
                                      ],
                                    );
                                  });
                            },
                      child: Text(
                        'forget password',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              // Disable when loading and make async
                              if (_loginKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true; // Start loading
                                });

                                try {
                                  final result = await AuthService()
                                      .loginInWithEmail(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim());

                                  print('Login result: $result'); // Debug line

                                  if (result == 'login successfully') {
                                    // Make sure this matches your AuthService
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Logged in successfully!!')),
                                    );
                                    if (mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/home', (route) => false);
                                    }
                                  } else {
                                    // Handle non-success responses
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Login failed: $result')),
                                    );
                                  }
                                } catch (error) {
                                  print('Login error: $error'); // Debug line
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $error')),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false; // Stop loading
                                    });
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                        backgroundColor: Theme.of(context).primaryColor,
                        //shape: RoundedRectangleBorder(),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Login',
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
                      Text('Don\'t have an account?'),
                      TextButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  // Disable when loading
                                  Navigator.pushNamed(context, '/signup');
                                },
                          child: Text('Sign up'))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
