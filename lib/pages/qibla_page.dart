import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  static const double _kaabaLat = 21.422487;
  static const double _kaabaLon = 39.826206;

  Position? _position;
  double? _heading;
  StreamSubscription<Position>? _posSub;
  StreamSubscription<CompassEvent>? _compassSub;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        setState(() => _error = 'Location permission denied.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _position = pos);

      _compassSub = FlutterCompass.events?.listen((event) {
        if (event.heading == null) {
          setState(() => _error = 'Device does not provide heading sensor.');
          return;
        }
        setState(() => _heading = event.heading);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  double _toRad(double deg) => deg * pi / 180.0;
  double _toDeg(double rad) => rad * 180.0 / pi;

  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = _toRad(lat1);
    final phi2 = _toRad(lat2);
    final deltaLambda = _toRad(lon2 - lon1);
    final y = sin(deltaLambda) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);
    final theta = atan2(y, x);
    return (_toDeg(theta) + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Qibla: $_error'));
    }

    if (_position == null || _heading == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final qibla = _bearing(_position!.latitude, _position!.longitude, _kaabaLat, _kaabaLon);
    // direction to rotate needle so it points to Qibla relative to device orientation
    final direction = (qibla - (_heading ?? 0) + 360) % 360;

    const double alignmentThreshold = 8.0; // degrees tolerance
    final bool aligned = direction <= alignmentThreshold || direction >= 360 - alignmentThreshold;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Qibla Direction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 8),
                  ),
                ),
                // Rotating needle pointing to Qibla
                Transform.rotate(
                  angle: -_toRad(direction),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation, size: 72, color: Colors.redAccent),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // Qibla icon in the north location
                Positioned(
                  top: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: aligned ? Colors.greenAccent.withValues(alpha: 0.95) : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: aligned
                          ? [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 2)]
                          : null,
                    ),
                    child: Icon(
                      Icons.mosque,
                      color: aligned ? Colors.white : Colors.grey.shade700,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Your heading: ${_heading!.toStringAsFixed(1)}°'),
          Text('Qibla bearing: ${qibla.toStringAsFixed(1)}°'),
          Text('Turn: ${direction.toStringAsFixed(1)}° to face Qibla'),
        ],
      ),
    );
  }
}
