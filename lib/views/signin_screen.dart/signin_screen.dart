// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:n_back/constants/colors.dart';
import 'package:n_back/viewmodel/signin_viewmodel.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final h = mediaQuery.size.height;
    final w = mediaQuery.size.width;
    final isMobile = w < 600;
    final isTablet = w >= 600 && w < 1200;

    return Scaffold(
      backgroundColor: blue,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        foregroundColor: blue,
        title: Text(
          'N-Back Game',
          style: TextStyle(
            fontSize: isMobile
                ? h * 0.03
                : isTablet
                ? h * 0.05
                : h * 0.07,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<SignInViewModel>(
            builder: (context, viewModel, _) {
              final _signinFormKey = GlobalKey<FormState>();
              final emailController = TextEditingController();
              final passController = TextEditingController();

              return Form(
                key: _signinFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.05,
                        ),
                      ),
                      SizedBox(
                        width: w * 0.7,
                        child: TextFormField(
                          controller: emailController,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            icon: Icon(Icons.email_outlined),
                            iconColor: Colors.white,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            hintText: 'Enter Email',
                            hintStyle: TextStyle(
                              fontSize: isMobile
                                  ? h * 0.02
                                  : isTablet
                                  ? h * 0.04
                                  : h * 0.06,
                              color: Colors.grey,
                            ),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontSize: isMobile
                                  ? h * 0.02
                                  : isTablet
                                  ? h * 0.04
                                  : h * 0.06,
                              color: Colors.white,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email cannot be empty';
                            } else if (!value.contains('@') ||
                                !value.contains('.')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(
                        width: w * 0.7,
                        child: TextFormField(
                          controller: passController,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            icon: Icon(Icons.password_outlined),
                            iconColor: Colors.white,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            hintText: 'Enter Password',
                            hintStyle: TextStyle(
                              fontSize: isMobile
                                  ? h * 0.02
                                  : isTablet
                                  ? h * 0.04
                                  : h * 0.06,
                              color: Colors.grey,
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: isMobile
                                  ? h * 0.02
                                  : isTablet
                                  ? h * 0.04
                                  : h * 0.06,
                              color: Colors.white,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password cannot be empty';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(blue),
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                if (!_signinFormKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fix the errors'),
                                    ),
                                  );
                                  return;
                                }
                                final email = emailController.text.trim();
                                final password = passController.text;
                                final result = await viewModel.signIn(
                                  email: email,
                                  password: password,
                                );
                                if (result == 'Successful') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sign In Success!'),
                                    ),
                                  );
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/play',
                                    );
                                  }
                                } else if (result == 'No User Exists') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User Not Found'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Sign in error: $result'),
                                    ),
                                  );
                                }
                              },
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: TextStyle(
                                  color: blue,
                                  fontSize: h * 0.02,
                                ),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account yet? ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: h * 0.02,
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(blue),
                              foregroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: h * 0.02,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
