import 'dart:async';

import 'package:flutter/material.dart';

class PrayerTimes extends StatefulWidget {
  final Map<String, String> times;
  final String sunriseTime;

  const PrayerTimes({super.key, Map<String, String>? times, this.sunriseTime = '05:45'})
      : times = times ?? const {
          'Fajr': '04:12',
          'Dhuhr': '12:20',
          'Asr': '15:34',
          'Maghrib': '18:47',
          'Isha': '20:05',
        };

  @override
  State<PrayerTimes> createState() => _PrayerTimesState();
}

enum _EventType { prayer, sunrise }

class _TimelineEvent {
  final String label;
  final String timeLabel;
  final DateTime start;
  final _EventType type;

  const _TimelineEvent({
    required this.label,
    required this.timeLabel,
    required this.start,
    required this.type,
  });
}

class _PrayerTimesState extends State<PrayerTimes> {
  late final List<MapEntry<String, String>> _schedule;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _schedule = widget.times.entries.toList(growable: false);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime _toToday(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  int _currentPrayerIndex(DateTime now) {
    for (var i = 0; i < _schedule.length; i++) {
      final start = _toToday(_schedule[i].value);
      final end = _toToday(_schedule[(i + 1) % _schedule.length].value);
      final adjustedEnd = (i + 1 == _schedule.length) ? end.add(const Duration(days: 1)) : end;
      if (now.isAtSameMomentAs(start) || (now.isAfter(start) && now.isBefore(adjustedEnd))) {
        return i;
      }
    }

    if (now.isBefore(_toToday(_schedule.first.value))) {
      return _schedule.length - 1;
    }

    return _schedule.length - 1;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  List<_TimelineEvent> get _timeline {
    final fajr = _toToday(widget.times['Fajr']!);
    final sunrise = _toToday(widget.sunriseTime);
    final dhuhr = _toToday(widget.times['Dhuhr']!);
    final asr = _toToday(widget.times['Asr']!);
    final maghrib = _toToday(widget.times['Maghrib']!);
    final isha = _toToday(widget.times['Isha']!);

    return [
      _TimelineEvent(
        label: 'Fajr',
        timeLabel: widget.times['Fajr']!,
        start: fajr,
        type: _EventType.prayer,
      ),
      _TimelineEvent(
        label: 'Sunrise',
        timeLabel: widget.sunriseTime,
        start: sunrise,
        type: _EventType.sunrise,
      ),
      _TimelineEvent(
        label: 'Dhuhr',
        timeLabel: widget.times['Dhuhr']!,
        start: dhuhr,
        type: _EventType.prayer,
      ),
      _TimelineEvent(
        label: 'Asr',
        timeLabel: widget.times['Asr']!,
        start: asr,
        type: _EventType.prayer,
      ),
      _TimelineEvent(
        label: 'Maghrib',
        timeLabel: widget.times['Maghrib']!,
        start: maghrib,
        type: _EventType.prayer,
      ),
      _TimelineEvent(
        label: 'Isha',
        timeLabel: widget.times['Isha']!,
        start: isha,
        type: _EventType.prayer,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentPrayerIndex = _currentPrayerIndex(now);
    final nextPrayerIndex = (currentPrayerIndex + 1) % _schedule.length;
    final nextPrayerTime = _toToday(_schedule[nextPrayerIndex].value);
    final nextPrayerDateTime = nextPrayerIndex == 0 && nextPrayerTime.isBefore(now)
        ? nextPrayerTime.add(const Duration(days: 1))
        : nextPrayerTime;
    final nextCountdown = nextPrayerDateTime.difference(now);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          color: Colors.green.shade50,
          child: ListTile(
            leading: const Icon(Icons.access_time, color: Colors.green),
            title: Text('Prayer Times', style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        const SizedBox(height: 8),
        ..._timeline.map((event) {
          final isPrayer = event.type == _EventType.prayer;
          final prayerIndex = isPrayer ? _schedule.indexWhere((e) => e.key == event.label) : -1;
          final isCurrentPrayer = isPrayer && prayerIndex == currentPrayerIndex;
          final isNextPrayer = isPrayer && prayerIndex == nextPrayerIndex;

          Color? rowColor;
          if (isCurrentPrayer) {
            rowColor = Colors.green.shade100;
          }

          final icon = event.type == _EventType.prayer ? Icons.bedtime : Icons.wb_sunny;
          final iconColor = isCurrentPrayer ? Colors.green : Colors.grey;

          final subtitle = isNextPrayer
              ? Text('in ${_formatDuration(nextCountdown)}', style: TextStyle(color: Colors.green.shade700))
              : null;

          final titleTextStyle = TextStyle(
            color: isCurrentPrayer ? Colors.green.shade900 : null,
            fontWeight: isCurrentPrayer ? FontWeight.w700 : null,
          );

          final trailingTextStyle = TextStyle(
            fontWeight: FontWeight.w600,
            color: isCurrentPrayer ? Colors.green.shade900 : null,
          );

          return Card(
            color: rowColor,
            child: ListTile(
              leading: Icon(icon, color: iconColor),
              title: Text(event.label, style: titleTextStyle),
              subtitle: subtitle,
              trailing: Text(event.timeLabel, style: trailingTextStyle),
            ),
          );
        }),
      ],
    );
  }
}
