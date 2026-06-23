import 'package:flutter/material.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.explore, size: 96),
          SizedBox(height: 16),
          Text('Qibla Direction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Compass placeholder — needs device sensors or a package.'),
        ],
      ),
    );
  }
}
