import 'package:flutter/material.dart';

class WorkoutPage extends StatefulWidget {
  final Map<String, dynamic> token;

  const WorkoutPage({super.key, required this.token});

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  Map<String, dynamic> target = {};
  Map<String, dynamic> progress = {};
  Map<String, dynamic> tracker = {};
  bool isFinished = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutData();
  }

  // Function to fetch workout data from Supabase
  Future<void> _fetchWorkoutData() async {
    if (widget.token.isNotEmpty) {
      // Assuming the first row contains the user's current workout data
      setState(() {
        target = widget.token['target'] ?? {};
        progress = widget.token['progress'] ?? {};
        tracker = widget.token['tracker'] ?? {};
        isFinished = widget.token['is_finished'] ?? false;
        _isLoading = false;
      });
    } else {
      // print('Error fetching workout data: ${response.error?.message}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading Indicator if Data is Loading
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else ...[
              // Run Tracker Section
              Text(
                'Target',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.directions_run, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'Target Distance: ${target['distance']} meter',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.directions_run, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    'Distance Progress: ${progress['distance'].toInt()} meter',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    'Calories Burned: ${progress['calorie']} kcal',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.directions_run, color: Colors.lightGreen),
                  SizedBox(width: 10),
                  Text(
                    'Average Cadance: ${tracker['cadence']} spm',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Overall Progress Section
              Text(
                'Overall Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress['distance'].toInt() / target['distance'],
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
                minHeight: 10,
              ),
              SizedBox(height: 20),

              isFinished
                  ? Container()
                  : Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/tracker',
                            arguments: {'workout_id': widget.token['id']},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Start Workout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {'workout_id': widget.token['id']},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Talk to Personal Coach',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
