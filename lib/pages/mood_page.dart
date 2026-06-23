import 'package:flutter/material.dart';

import '../services/verse_store.dart';
import 'quran_page.dart';

class MoodPage extends StatefulWidget {
  final String moodLabel;
  const MoodPage({super.key, required this.moodLabel});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  final VerseStore _store = VerseStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreUpdated);
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addVerse() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QuranPage(selectMode: true)),
    );
    if (result != null) {
      _store.addMoodVerse(widget.moodLabel, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : null;
    final activeMoodTextColor = Colors.green.shade900;
    final verseTextStyle = TextStyle(color: activeMoodTextColor, fontSize: 15);
    final emptyTextStyle = TextStyle(color: isDark ? Colors.white70 : Colors.black54);
    final iconColor = isDark ? Colors.green.shade900 : null;
    final verses = _store.getMoodVerses(widget.moodLabel);

    return Scaffold(
      appBar: AppBar(title: Text(widget.moodLabel)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: _addVerse,
                icon: const Icon(Icons.add),
                label: const Text('Add verse from Quran'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: verses.isEmpty
                ? Center(child: Text('No verses added yet.', style: emptyTextStyle))
                  : ListView.separated(
                      itemCount: verses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final verse = verses[i];
                        return Card(
                          color: cardColor,
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                verse,
                                textAlign: TextAlign.right,
                                style: verseTextStyle,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: iconColor),
                              onPressed: () {
                                _store.removeMoodVerse(widget.moodLabel, verse);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Verse removed from mood')),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
