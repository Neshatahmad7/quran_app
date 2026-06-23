import 'package:flutter/foundation.dart';

class VerseNote {
  final String surahName;
  final String englishName;
  final int ayah;
  final String arabic;
  final String translation;
  final String note;

  const VerseNote({
    required this.surahName,
    required this.englishName,
    required this.ayah,
    required this.arabic,
    required this.translation,
    required this.note,
  });
}

class VerseStore extends ChangeNotifier {
  VerseStore._internal() {
    for (final mood in moods) {
      _moodVerses[mood] = [];
    }
  }

  static final VerseStore instance = VerseStore._internal();

  static const List<String> moods = [
    'Happy',
    'Sad',
    'Angry',
    'Nervous',
    'Depressed',
    'Exhausted',
    'Alone',
    'Weak',
    'Strong',
  ];

  final Map<String, List<String>> _moodVerses = {};
  final List<String> _favorites = [];
  final List<VerseNote> _notes = [];

  List<String> getMoodVerses(String mood) {
    return List.unmodifiable(_moodVerses[mood] ?? []);
  }

  List<String> get favorites => List.unmodifiable(_favorites);
  List<VerseNote> get notes => List.unmodifiable(_notes);

  void addMoodVerse(String mood, String verse) {
    final moodList = _moodVerses[mood];
    if (moodList == null) return;
    if (!moodList.contains(verse)) {
      moodList.insert(0, verse);
      notifyListeners();
    }
  }

  void removeMoodVerse(String mood, String verse) {
    final moodList = _moodVerses[mood];
    if (moodList == null) return;
    if (moodList.remove(verse)) {
      notifyListeners();
    }
  }

  void addFavorite(String verse) {
    if (!_favorites.contains(verse)) {
      _favorites.insert(0, verse);
      notifyListeners();
    }
  }

  void removeFavorite(String verse) {
    if (_favorites.remove(verse)) {
      notifyListeners();
    }
  }

  void addNote(VerseNote note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void removeNoteAt(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
      notifyListeners();
    }
  }
}
