import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

class SensorsPage extends StatefulWidget {
  const SensorsPage({super.key});

  @override
  State<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  // Accelerometer
  double ax = 0, ay = 0, az = 0;

  // Gyroscope
  double gx = 0, gy = 0, gz = 0;

  // GPS
  double? latitude;
  double? longitude;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();

    // Accelerometer stream
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        ax = event.x;
        ay = event.y;
        az = event.z;
      });
    });

    // Gyroscope stream
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gx = event.x;
        gy = event.y;
        gz = event.z;
      });
    });

    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      _gettingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildCard(
              title: 'Accelerometer',
              subtitle: 'Measures acceleration (m/s²)',
              values: [
                'X: ${ax.toStringAsFixed(2)}',
                'Y: ${ay.toStringAsFixed(2)}',
                'Z: ${az.toStringAsFixed(2)}',
              ],
            ),
            _buildCard(
              title: 'Gyroscope',
              subtitle: 'Measures rotation (rad/s)',
              values: [
                'X: ${gx.toStringAsFixed(2)}',
                'Y: ${gy.toStringAsFixed(2)}',
                'Z: ${gz.toStringAsFixed(2)}',
              ],
            ),
            _buildCard(
              title: 'GPS Location',
              subtitle: 'Current coordinates',
              values: [
                if (latitude != null && longitude != null)
                  'Lat: ${latitude!.toStringAsFixed(6)}\nLon: ${longitude!.toStringAsFixed(6)}'
                else if (_gettingLocation)
                  'Getting location...'
                else
                  'Tap below to refresh',
              ],
              button: ElevatedButton(
                onPressed: _getLocation,
                child: const Text('Refresh Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required List<String> values,
    Widget? button,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 16),
            for (var value in values)
              Text(value, style: const TextStyle(fontSize: 16)),
            if (button != null) ...[const SizedBox(height: 12), button],
          ],
        ),
      ),
    );
  }
}
