import 'package:flutter/material.dart';
import 'package:nexstep/components/button.dart';
import 'package:nexstep/components/text_field.dart';
import 'package:nexstep/supabase.dart';
import 'package:nexstep/theme/main_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _isSaving = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _workoutLevels = ['Beginner', 'Intermediate', 'Advanced'];

  Future<void> _saveTargetInfo() async {
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);
    final height = double.tryParse(_heightController.text);
    final targetHeight = double.tryParse(_targetHeightController.text);

    if (age == null ||
        weight == null ||
        targetWeight == null ||
        height == null ||
        targetHeight == null ||
        _selectedGender == null ||
        _selectedWorkoutLevel == null) {
      _showMessage('Please fill in all fields correctly.');
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      _showMessage('You must be logged in to continue.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await supabase.from('details').insert({
        'user_id': user.id,
        'age': age,
        'gender': _selectedGender,
        'weight': weight,
        'target_weight': targetWeight,
        'height': height,
        'target_height': targetHeight,
        'workout_level': _selectedWorkoutLevel,
      });

      _showMessage('Target info saved successfully!');
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (Route<dynamic> route) => false,
      );
    } on PostgrestException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Unexpected error: $e');
    } finally {
      setState(() => _isSaving = false);
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
                  text: _isSaving ? 'Saving...' : 'Signup',
                  onPressed: () async {
                    if (!_isSaving) await _saveTargetInfo();
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
