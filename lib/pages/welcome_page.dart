import 'package:flutter/material.dart';
import 'package:nexstep/components/button.dart';
import 'package:nexstep/theme/main_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: MainTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/imgs/logo.png', height: 200),
              Text(
                'NextStep',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),

              const SizedBox(height: 60),

              // Button using theme
              SizedBox(
                width: double.infinity,
                height: 50,
                child: NexStepButton(
                  text: 'Get Started',
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
