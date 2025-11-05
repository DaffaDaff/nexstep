import 'package:flutter/material.dart';
import 'package:nexstep/components/button.dart';
import 'package:nexstep/components/text_field.dart';
import 'package:nexstep/supabase.dart';
import 'package:nexstep/theme/main_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  Future<void> _signUpUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    if (password != repeatPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        _showMessage("Signup successful!");
        Navigator.pushNamed(context, '/target-info');
      } else {
        _showMessage("Signup failed. Please try again.");
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage("Unexpected error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
                  "Sign Up",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // Username
                NexStepTextField(
                  hintText: 'Username',
                  prefixIcon: Icons.person_outline,
                  controller: _usernameController,
                ),
                const SizedBox(height: 20),

                // Email
                NexStepTextField(
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password
                NexStepTextField(
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
                NexStepTextField(
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
                  text: _isLoading ? 'Creating Account...' : 'Next',
                  onPressed: () async {
                    if (!_isLoading) await _signUpUser();
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
