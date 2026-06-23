import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeService {
  static final Coordinates _fallbackCoordinates = Coordinates(21.3891, 39.8579);

  static Future<Map<String, String>> getPrayerTimes() async {
    final coordinates = await _getCoordinates();
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    final now = DateTime.now();
    final prayerTimes = PrayerTimes(coordinates, DateComponents.from(now), params);

    return {
      'Fajr': _formatTime(prayerTimes.fajr),
      'Sunrise': _formatTime(prayerTimes.sunrise),
      'Dhuhr': _formatTime(prayerTimes.dhuhr),
      'Asr': _formatTime(prayerTimes.asr),
      'Maghrib': _formatTime(prayerTimes.maghrib),
      'Isha': _formatTime(prayerTimes.isha),
    };
  }

  static Future<Coordinates> _getCoordinates() async {
    try {
      final position = await _getDeviceLocation();
      return position != null
          ? Coordinates(position.latitude, position.longitude)
          : _fallbackCoordinates;
    } catch (_) {
      return _fallbackCoordinates;
    }
  }

  static Future<Position?> _getDeviceLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }

    final settings = const LocationSettings(accuracy: LocationAccuracy.high);
    return await Geolocator.getCurrentPosition(locationSettings: settings);
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
