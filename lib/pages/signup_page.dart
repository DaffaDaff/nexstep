import 'package:flutter/material.dart';
import 'package:nexstep/components/button.dart';
import 'package:nexstep/components/text_field.dart';
import 'package:nexstep/theme/main_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: MainTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Signup",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // Username
                NextStepTextField(
                  hintText: 'Username',
                  prefixIcon: Icons.person_outline,
                  controller: _usernameController,
                ),
                const SizedBox(height: 20),

                // Email
                NextStepTextField(
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password
                NextStepTextField(
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Repeat Password
                NextStepTextField(
                  hintText: 'Repeat Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureRepeatPassword,
                  controller: _repeatPasswordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRepeatPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureRepeatPassword = !_obscureRepeatPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Next Button
                NexStepButton(
                  text: 'Next',
                  onPressed: () {
                    // Navigate to target info screen
                    Navigator.pushNamed(context, '/target-info');
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Have an Account? ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        "Login",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: MainTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
