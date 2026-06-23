import 'dart:async';

import 'package:flutter/material.dart';

import '../services/prayer_time_service.dart';
import 'mood_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  Map<String, String> _times = const {
    'Fajr': '04:12',
    'Dhuhr': '12:20',
    'Asr': '15:34',
    'Maghrib': '18:47',
    'Isha': '20:05',
  };

  String _sunriseTime = '05:45';
  bool _loadingPrayerTimes = true;

  final List<Map<String, Object>> _moodOptions = const [
    {'label': 'Happy', 'icon': Icons.sentiment_satisfied},
    {'label': 'Sad', 'icon': Icons.sentiment_dissatisfied},
    {'label': 'Angry', 'icon': Icons.mood_bad},
    {'label': 'Nervous', 'icon': Icons.sentiment_neutral},
    {'label': 'Depressed', 'icon': Icons.sentiment_very_dissatisfied},
    {'label': 'Exhausted', 'icon': Icons.bedtime},
    {'label': 'Alone', 'icon': Icons.person_outline},
    {'label': 'Weak', 'icon': Icons.remove_circle_outline},
    {'label': 'Strong', 'icon': Icons.fitness_center},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final prayerTimes = await PrayerTimeService.getPrayerTimes();
      if (!mounted) return;
      setState(() {
        _times = prayerTimes;
        _sunriseTime = prayerTimes['Sunrise']!;
        _loadingPrayerTimes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingPrayerTimes = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime _toToday(String time) {
    final parts = time.split(':');
    return DateTime(_now.year, _now.month, _now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _currentPrayer() {
    final now = _now;
    final entries = _times.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final start = _toToday(entries[i].value);
      final end = _toToday(entries[(i + 1) % entries.length].value);
      final adjustedEnd = (i + 1 == entries.length) ? end.add(const Duration(days: 1)) : end;
      if (now.isAtSameMomentAs(start) || (now.isAfter(start) && now.isBefore(adjustedEnd))) {
        return entries[i].key;
      }
    }
    return entries.last.key;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatTime(DateTime value) {
    return '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}:${_twoDigits(value.second)}';
  }

  Duration _timeUntil(String time) {
    DateTime target = _toToday(time);
    if (target.isBefore(_now) || target.isAtSameMomentAs(_now)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(_now);
  }

  String _formatDurationHMS(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${_twoDigits(h)}:${_twoDigits(m)}:${_twoDigits(s)}';
  }

  List<Map<String, Object>> get _scheduleItems {
    return [
      {'label': 'Fajr', 'time': _times['Fajr']!, 'icon': Icons.nights_stay},
      {'label': 'Sunrise', 'time': _sunriseTime, 'icon': Icons.wb_sunny},
      {'label': 'Dhuhr', 'time': _times['Dhuhr']!, 'icon': Icons.wb_sunny},
      {'label': 'Asr', 'time': _times['Asr']!, 'icon': Icons.wb_cloudy},
      {'label': 'Maghrib', 'time': _times['Maghrib']!, 'icon': Icons.wb_twilight},
      {'label': 'Isha', 'time': _times['Isha']!, 'icon': Icons.bedtime},
    ];
  }

  Widget _buildMoodRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodTextColor = isDark ? Colors.green.shade900 : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My mood', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _moodOptions.map((option) {
              final label = option['label'] as String;
              final iconData = option['icon'] as IconData;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MoodPage(moodLabel: label)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(iconData, size: 18, color: Colors.green.shade800),
                      const SizedBox(width: 6),
                      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: moodTextColor)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPrayer = _currentPrayer();
    final nextPrayer = _getNextPrayer();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMoodRow(context),
          const SizedBox(height: 8),
          if (_loadingPrayerTimes) ...[
            Card(
              margin: EdgeInsets.zero,
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Calculating prayer times locally...', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Prayer', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(currentPrayer, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Time', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(_formatTime(_now), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Next Prayer', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12)),
                          const SizedBox(height: 2),
                          // show remaining time then the next prayer label
                          Text('${_formatDurationHMS(_timeUntil(_times[nextPrayer]!))} remaining', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(nextPrayer, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Prayer Schedule', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          ..._scheduleItems.map((item) {
            final label = item['label'] as String;
            final time = item['time'] as String;
            final iconData = item['icon'] as IconData;
            final isCurrent = label == currentPrayer;
            final isNext = label == nextPrayer;
            return Card(
              margin: const EdgeInsets.only(bottom: 5),
              color: isCurrent ? Colors.green.shade50 : null,
              child: ListTile(
                dense: true,
                minVerticalPadding: 4,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                leading: Icon(
                  iconData,
                  color: isCurrent ? Colors.green : isNext ? Colors.green.shade700 : Colors.grey,
                  size: 18,
                ),
                title: Text(label, style: TextStyle(fontSize: 13, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500, color: isCurrent ? Colors.green.shade900 : null)),
                trailing: isNext
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isCurrent ? Colors.green.shade900 : null)),
                          const SizedBox(height: 2),
                          Text(_formatDurationHMS(_timeUntil(label == 'Sunrise' ? _sunriseTime : time)), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    : Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isCurrent ? Colors.green.shade900 : null)),
              ),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  String _getNextPrayer() {
    final now = _now;
    final entries = _times.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final prayerTime = _toToday(entries[i].value);
      if (now.isBefore(prayerTime)) {
        return entries[i].key;
      }
    }
    return entries.first.key;
  }
}
