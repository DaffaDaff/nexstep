import 'package:flutter/material.dart';
import 'package:nexstep/components/button.dart';
import 'package:nexstep/components/text_field.dart';
import 'package:nexstep/theme/main_theme.dart';

class TargetInfoPage extends StatefulWidget {
  const TargetInfoPage({super.key});

  @override
  State<TargetInfoPage> createState() => _TargetInfoPageState();
}

class _TargetInfoPageState extends State<TargetInfoPage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _targetHeightController = TextEditingController();

  String? _selectedGender;
  String? _selectedWorkoutLevel;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _workoutLevels = ['Beginner', 'Intermediate', 'Advanced'];

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
                  "",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // Age
                NexStepTextField(
                  hintText: 'Age',
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  controller: _ageController,
                ),
                const SizedBox(height: 20),

                // Gender Dropdown
                _buildDropdownField(
                  label: "Gender",
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 20),

                // Weight and Target Weight (side by side)
                Row(
                  children: [
                    Expanded(
                      child: NexStepTextField(
                        hintText: 'Weight',
                        prefixIcon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                        controller: _weightController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NexStepTextField(
                        hintText: 'Target Weight',
                        prefixIcon: Icons.flag_outlined,
                        keyboardType: TextInputType.number,
                        controller: _targetWeightController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Height and Target Height (side by side)
                Row(
                  children: [
                    Expanded(
                      child: NexStepTextField(
                        hintText: 'Height',
                        prefixIcon: Icons.height_outlined,
                        keyboardType: TextInputType.number,
                        controller: _heightController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NexStepTextField(
                        hintText: 'Target Height',
                        prefixIcon: Icons.flag_circle_outlined,
                        keyboardType: TextInputType.number,
                        controller: _targetHeightController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Workout Level Dropdown
                _buildDropdownField(
                  label: "Workout Level",
                  value: _selectedWorkoutLevel,
                  items: _workoutLevels,
                  onChanged: (value) =>
                      setState(() => _selectedWorkoutLevel = value),
                ),
                const SizedBox(height: 40),

                // Signup Button
                NexStepButton(
                  text: 'Signup',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard',
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      dropdownColor: const Color(0xFF1E1E1E),
      initialValue: value,
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
