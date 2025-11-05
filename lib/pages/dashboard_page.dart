import 'package:flutter/material.dart';
import 'package:nexstep/components/button.dart';
import 'package:nexstep/theme/main_theme.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: MainTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, User!",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ready for today's training?",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    // CircleAvatar(
                    //   radius: 20,
                    //   backgroundColor: MainTheme.primaryColor,
                    //   child: Text(
                    //     "U",
                    //     style: theme.textTheme.titleMedium?.copyWith(
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 80),

                // Weekly Progress Circle
                Center(
                  child: CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 15.0,
                    percent: 0.75,
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: Colors.white12,
                    progressColor: MainTheme.primaryColor,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Weekly Progress",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "75%",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),

                // Start Workout Button
                NexStepButton(
                  text: "Start Workout",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Workout started!")),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Activity Cards
                _buildActivityCard(
                  title: "Activity Today",
                  subtitle: "Calories Burned 559 kcal",
                  detail: "Distance: 7.2 km",
                  icon: Icons.directions_run,
                ),
                const SizedBox(height: 16),
                _buildActivityCard(
                  title: "Latest Workout",
                  subtitle: "AI-Guided Run",
                  detail: "Progress: 660 kcal / 7.2 km",
                  icon: Icons.auto_graph,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: MainTheme.primaryColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1C1C1C),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: MainTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: MainTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    color: MainTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
