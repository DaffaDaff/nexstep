import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  late Position _currentPosition;
  late StreamSubscription<Position> _positionStream;
  late Timer _timer;
  bool _isRunning = false;
  double _distance = 0.0; // in meters
  DateTime? _startTime;
  String _elapsedTime = '00:00:00';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _startRun(); // Auto-start the run as soon as the page is loaded
  }

  // Check for location permission
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.deniedForever) {
      // Handle permissions error
      print("Location service not enabled or permission denied");
      return;
    }
  }

  // Auto-start the run
  void _startRun() {
    setState(() {
      _isRunning = true;
      _startTime = DateTime.now();
      _distance = 0.0;
      _startLocationTracking();
      _startTimer(); // Start the timer to update the time every second
    });
  }

  // Start location tracking
  void _startLocationTracking() {
    _positionStream = Geolocator.getPositionStream().listen((
      Position position,
    ) {
      if (_startTime != null) {
        setState(() {
          _currentPosition = position;
          _distance += _calculateDistance(
            _currentPosition.latitude,
            _currentPosition.longitude,
          );
        });
      }
    });
  }

  // Calculate the distance between two points (in meters)
  double _calculateDistance(double lat1, double lon1) {
    if (_currentPosition == null) return 0.0;

    double lat2 = _currentPosition.latitude;
    double lon2 = _currentPosition.longitude;

    double distanceInMeters = Geolocator.distanceBetween(
      lat1,
      lon1,
      lat2,
      lon2,
    );
    return distanceInMeters;
  }

  // Start the timer to update time every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (_startTime != null) {
          _elapsedTime = _formatDuration(
            DateTime.now().difference(_startTime!),
          );
        }
      });
    });
  }

  // Format the elapsed time (HH:mm:ss)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final seconds = twoDigits(duration.inSeconds % 60);
    final minutes = twoDigits(duration.inMinutes % 60);
    final hours = twoDigits(duration.inHours);
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _positionStream
        .cancel(); // Cancel the location stream when the page is disposed
    _timer.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Running Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
            ],
          ),
        ),
      ),
    );
  }
}
