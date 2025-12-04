import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nexstep/pages/chatbot_page.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackerPage extends StatefulWidget {
  final String workoutId;

  const TrackerPage({super.key, required this.workoutId});

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  Position? _currentPosition;
  late StreamSubscription<Position> _positionStream;
  late StreamSubscription<AccelerometerEvent> _accelerometerStream;
  late Timer _timer;

  bool _isRunning = false;
  double _distance = 0.0;
  String _elapsedTime = '00:00:00';
  int _stepCount = 0;
  double _cadence = 0.0;
  DateTime? _startTime;
  DateTime? _lastStepTime;
  List<int> _timeDifferences = [];
  final int _cadenceWindow = 10;
  double _lastAcceleration = 0.0;
  final double _stepThreshold = 15.0;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _startAccelerometerTracking();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _accelerometerStream.cancel();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final response = await Supabase.instance.client
        .from('workout_sessions')
        .select()
        .eq('user_id', userId!);

    debugPrint(response.toString());

    if (response.isNotEmpty) {}
  }

  // 1. Location Permission Handling
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.requestPermission();

    if (!serviceEnabled || permission == LocationPermission.deniedForever) {
      print("Location service not enabled or permission denied");
      return;
    }
    _startLocationTracking();
  }

  // 2. Start Location Tracking
  void _startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    ).listen(_onLocationUpdate);
  }

  void _onLocationUpdate(Position position) {
    if (_startTime == null) {
      setState(() {
        _currentPosition = position;
      });
    } else {
      setState(() {
        _distance += _calculateDistance(position.latitude, position.longitude);
        _currentPosition = position;
        _routePoints.add(LatLng(position.latitude, position.longitude));
        _insertUpdatedDistance();
      });

      // Recenter the map to the current position
      _mapController.move(LatLng(position.latitude, position.longitude), 20.0);
    }
  }

  double _calculateDistance(double lat1, double lon1) {
    if (_currentPosition == null) return 0.0;

    double lat2 = _currentPosition!.latitude;
    double lon2 = _currentPosition!.longitude;

    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<void> _insertUpdatedDistance() async {
    final response = await Supabase.instance.client
        .from('workout_sessions')
        .select()
        .eq('id', widget.workoutId)
        .single();

    if (response.isNotEmpty) {
      Map<String, dynamic> progressMap = response["progress"];

      progressMap["distance"] = _distance.toInt();

      await Supabase.instance.client
          .from('workout_sessions')
          .update({'progress': progressMap})
          .eq('id', widget.workoutId)
          .select();
    } else {}
  }

  // 3. Accelerometer Step Detection
  void _startAccelerometerTracking() {
    _accelerometerStream = accelerometerEvents.listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Step detection logic
    if (acceleration > _stepThreshold && _lastAcceleration <= _stepThreshold) {
      _onStepDetected();
    }

    _lastAcceleration = acceleration;
  }

  void _onStepDetected() {
    _stepCount++; // Increment step count
    _updateCadence(); // Update cadence
  }

  void _updateCadence() {
    final now = DateTime.now();

    // If there was a previous step, calculate the time difference
    if (_lastStepTime != null) {
      final elapsedTime = now.difference(_lastStepTime!).inSeconds;

      // Add the time difference to a list
      _timeDifferences.add(elapsedTime);

      // Keep only the last N time differences (for a rolling window)
      if (_timeDifferences.length > _cadenceWindow) {
        _timeDifferences.removeAt(0); // Remove the oldest value
      }

      // Calculate average time between steps
      final averageTimeBetweenSteps =
          _timeDifferences.reduce((a, b) => a + b) / _timeDifferences.length;

      // Calculate cadence (steps per minute)
      if (averageTimeBetweenSteps > 0) {
        _cadence = 60 / averageTimeBetweenSteps; // Store average cadence
        _insertUpdatedCadence();
      }
    }

    // Update the last step time
    _lastStepTime = now;
  }

  Future<void> _insertUpdatedCadence() async {
    final response = await Supabase.instance.client
        .from('workout_sessions')
        .select()
        .eq('id', widget.workoutId)
        .single();

    if (response.isNotEmpty) {
      Map<String, dynamic> trackMap = response["tracker"];

      trackMap["cadence"] = (trackMap["cadence"] + _cadence) / 2;

      await Supabase.instance.client
          .from('workout_sessions')
          .update({'tracker': trackMap})
          .eq('id', widget.workoutId)
          .select();
    } else {}
  }

  // 4. Timer for Elapsed Time
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_startTime != null) {
        setState(() {
          _elapsedTime = _formatDuration(
            DateTime.now().difference(_startTime!),
          );
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final seconds = twoDigits(duration.inSeconds % 60);
    final minutes = twoDigits(duration.inMinutes % 60);
    final hours = twoDigits(duration.inHours);
    return "$hours:$minutes:$seconds";
  }

  // 5. Control Button Actions
  void _startRun() {
    setState(() {
      _isRunning = true;
      _startTime = DateTime.now();
      _distance = 0.0;
      _startTimer();
    });
  }

  void _pauseRun() {
    setState(() {
      _isRunning = false;
      _positionStream.pause();
      _accelerometerStream.pause();
      _timer.cancel();
    });
  }

  void _stopRun() {
    setState(() {
      _isRunning = false;
      _positionStream.cancel();
      _accelerometerStream.cancel();
      _timer.cancel();
    });
  }

  // 6. Map UI
  MapController _mapController = MapController();

  Widget _buildMap() {
    if (_currentPosition == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // 7. Control Buttons UI
  Widget _controlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isRunning ? null : _startRun,
          child: Text('Start'),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: !_isRunning ? null : _stopRun,
          child: Text('Stop'),
        ),
      ],
    );
  }

  Future<void> _endWorkout() async {
    final response = await Supabase.instance.client
        .from('workout_sessions')
        .update({'is_finished': true})
        .eq('id', widget.workoutId)
        .select();

    if (response.isNotEmpty) {
    } else {}
  }

  // 8. Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Tracker'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            // Show the exit confirmation dialog
            showDialog(
              context: context,
              barrierDismissible:
                  false, // Prevent dismissing the dialog by tapping outside
              builder: (context) {
                return AlertDialog(
                  title: const Text('Exit?'),
                  content: const Text(
                    'Are you sure you want to end the workout?',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _endWorkout();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Exit'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRunning ? 'Running' : 'Stopped',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Distance: ${(_distance / 1000).toStringAsFixed(2)} km',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text('Time: $_elapsedTime', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Text(
                'Cadence: ${_cadence.toStringAsFixed(2)} steps/min',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              _controlButtons(),
              const SizedBox(height: 20),
              _buildMap(),
            ],
          ),
        ),
      ),
    );
  }
}
