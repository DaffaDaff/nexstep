import 'package:flutter/material.dart';
import 'package:nexstep/theme/main_theme.dart';

class TrainingPlansPage extends StatefulWidget {
  const TrainingPlansPage({super.key});

  @override
  State<TrainingPlansPage> createState() => _TrainingPlansPageState();
}

class _TrainingPlansPageState extends State<TrainingPlansPage> {
  int _selectedIndex = 1;

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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Training Plans",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    // CircleAvatar(
                    //   radius: 20,
                    //   backgroundColor: MainTheme.primaryColor,
                    //   child: Text(
                    //     "R",
                    //     style: theme.textTheme.titleMedium?.copyWith(
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 30),

                // Workouts Recommendation
                Text(
                  "Workouts Recommendation",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWorkoutCard(
                      icon: Icons.directions_run,
                      color: Colors.blueAccent,
                      title: "AI-Guided Run",
                      duration: "30 min",
                      category: "Endurance",
                    ),
                    _buildWorkoutCard(
                      icon: Icons.fitness_center,
                      color: Colors.orangeAccent,
                      title: "HIIT Fusion",
                      duration: "25 min",
                      category: "Strength",
                    ),
                    _buildWorkoutCard(
                      icon: Icons.self_improvement,
                      color: Colors.greenAccent,
                      title: "Yoga Flow",
                      duration: "20 min",
                      category: "Flexibility",
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Workouts History
                Text(
                  "Workouts History",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                _buildHistoryCard(
                  title: "AI-Guided Run",
                  time: "Yesterday, 6:30 AM",
                  calories: "550 kcal",
                  distance: "7.2 km",
                  icon: Icons.directions_run,
                ),
                const SizedBox(height: 12),
                _buildHistoryCard(
                  title: "Morning Jog",
                  time: "2 days ago",
                  calories: "400 kcal",
                  distance: "5 km",
                  icon: Icons.directions_walk,
                ),
                const SizedBox(height: 12),
                _buildHistoryCard(
                  title: "Cycling",
                  time: "Last Week",
                  calories: "1,000 kcal",
                  distance: "",
                  icon: Icons.pedal_bike,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Helper Widgets ===

  Widget _buildWorkoutCard({
    required IconData icon,
    required Color color,
    required String title,
    required String duration,
    required String category,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$duration\n$category",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String time,
    required String calories,
    required String distance,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1C1C1C),
        border: Border.all(color: MainTheme.primaryColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MainTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: MainTheme.primaryColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  "Calories Burned: $calories",
                  style: TextStyle(
                    color: MainTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (distance.isNotEmpty)
                  Text(
                    "Distance: $distance",
                    style: TextStyle(
                      color: MainTheme.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.star_border, color: Colors.white70, size: 22),
        ],
      ),
    );
  }
}
