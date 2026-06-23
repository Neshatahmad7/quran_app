import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/app_settings.dart';

import 'package:flutter/material.dart';

import '../services/verse_store.dart';

String _formatEnglishNumber(int number) => number.toString();

String _formatAyahLabel(int ayah) => '⟪ ${_formatEnglishNumber(ayah)} ⟫';

class QuranVerse {
  final int ayah;
  final String arabic;
  final String translation;
  final bool isBismillah;

  QuranVerse({
    required this.ayah,
    required this.arabic,
    required this.translation,
    this.isBismillah = false,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    return QuranVerse(
      ayah: json['ayah'] as int,
      arabic: json['arabic'] as String,
      translation: json['translation'] as String? ?? '',
      isBismillah: json['isBismillah'] as bool? ?? false,
    );
  }
}

// cache translation maps per language
final Map<String, Map<int, Map<int, String>>> _translationCache = {};

Future<void> _ensureTranslationsLoaded(String lang) async {
  if (lang == 'English' || _translationCache.containsKey(lang)) return;

  final fileName = lang == 'Dari/Persian' ? 'assets/dari_translation.txt' : 'assets/pashto_translation.txt';
  final content = await rootBundle.loadString(fileName);
  final map = <int, Map<int, String>>{};
  for (final line in content.split('\n')) {
    if (line.trim().isEmpty) continue;
    final parts = line.split('|');
    if (parts.length < 3) continue;
    final s = int.tryParse(parts[0]);
    final a = int.tryParse(parts[1]);
    final text = parts.sublist(2).join('|').trim();
    if (s == null || a == null) continue;
    map.putIfAbsent(s, () => {})[a] = text;
  }
  _translationCache[lang] = map;
}

Future<List<QuranVerse>> _loadQuranVerses(int surahNumber) async {
  final jsonString = await rootBundle.loadString('assets/quran.json');
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final verses = data['$surahNumber'] as List<dynamic>?;
  if (verses == null) return [];

  final lang = AppSettings.instance.languageLabel;
  await _ensureTranslationsLoaded(lang);
  final translationsForSurah = _translationCache[lang]?[surahNumber];

  return verses.map((dynamic item) {
    final json = item as Map<String, dynamic>;
    final base = QuranVerse.fromJson(json);
    final override = translationsForSurah != null ? translationsForSurah[base.ayah] : null;
    if (override != null && override.isNotEmpty) {
      return QuranVerse(
        ayah: base.ayah,
        arabic: base.arabic,
        translation: override,
        isBismillah: base.isBismillah,
      );
    }
    return base;
  }).toList();
}

Future<void> _showAddToMoodSheet(BuildContext context, QuranVerse verse, String surahName, String englishName) async {
  final selectedMood = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final height = MediaQuery.of(context).size.height * 0.55;
      return SafeArea(
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18.0),
                child: Center(
                  child: Text('Add verse to mood', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: VerseStore.moods.length,
                  itemBuilder: (context, index) {
                    final mood = VerseStore.moods[index];
                    return ListTile(
                      title: Text(mood),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context, mood);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (selectedMood != null) {
    VerseStore.instance.addMoodVerse(selectedMood, verse.arabic);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verse added to "$selectedMood" mood')),
    );
  }
}

Future<void> _showAddNoteDialog(BuildContext context, QuranVerse verse, String surahName, String englishName) async {
  final controller = TextEditingController();
  final note = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add note'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Write your note here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(context, text.isEmpty ? null : text);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  if (note != null && note.isNotEmpty) {
    VerseStore.instance.addNote(
      VerseNote(
        surahName: surahName,
        englishName: englishName,
        ayah: verse.ayah,
        arabic: verse.arabic,
        translation: verse.translation,
        note: note,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note added to My Notes')),
    );
  }
}

void _addToFavorites(BuildContext context, QuranVerse verse) {
  VerseStore.instance.addFavorite(verse.arabic);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Verse added to favorites')),
  );
}

class QuranPage extends StatelessWidget {
  final bool selectMode;
  const QuranPage({super.key, this.selectMode = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahCardColor = isDark ? Colors.grey[850]! : Colors.green.shade50;
    final surahBorderColor = isDark ? Colors.grey[700]! : Colors.green.shade100;
    final surahTitleColor = isDark ? Colors.white : null;
    final surahSubtitleColor = isDark ? Colors.grey[300] : null;

    final surahs = [
      {'arabic': 'الفاتحة', 'english': 'The Opening'},
      {'arabic': 'البقرة', 'english': 'The Cow'},
      {'arabic': 'آل عمران', 'english': 'Family of Imran'},
      {'arabic': 'النساء', 'english': 'The Women'},
      {'arabic': 'المائدة', 'english': 'The Table Spread'},
      {'arabic': 'الأنعام', 'english': 'The Cattle'},
      {'arabic': 'الأعراف', 'english': 'The Heights'},
      {'arabic': 'الأنفال', 'english': 'The Spoils of War'},
      {'arabic': 'التوبة', 'english': 'Repentance'},
      {'arabic': 'يونس', 'english': 'Jonah'},
      {'arabic': 'هود', 'english': 'Hud'},
      {'arabic': 'يوسف', 'english': 'Joseph'},
      {'arabic': 'الرعد', 'english': 'The Thunder'},
      {'arabic': 'ابراهيم', 'english': 'Abraham'},
      {'arabic': 'الحجر', 'english': 'The Rocky Tract'},
      {'arabic': 'النحل', 'english': 'The Bee'},
      {'arabic': 'الإسراء', 'english': 'The Night Journey'},
      {'arabic': 'الكهف', 'english': 'The Cave'},
      {'arabic': 'مريم', 'english': 'Mary'},
      {'arabic': 'طه', 'english': 'Ta-Ha'},
      {'arabic': 'الأنبياء', 'english': 'The Prophets'},
      {'arabic': 'الحج', 'english': 'The Pilgrimage'},
      {'arabic': 'المؤمنون', 'english': 'The Believers'},
      {'arabic': 'النور', 'english': 'The Light'},
      {'arabic': 'الفرقان', 'english': 'The Criterion'},
      {'arabic': 'الشعراء', 'english': 'The Poets'},
      {'arabic': 'النمل', 'english': 'The Ant'},
      {'arabic': 'القصص', 'english': 'The Stories'},
      {'arabic': 'العنكبوت', 'english': 'The Spider'},
      {'arabic': 'الروم', 'english': 'The Romans'},
      {'arabic': 'لقمان', 'english': 'Luqman'},
      {'arabic': 'السجدة', 'english': 'The Prostration'},
      {'arabic': 'الأحزاب', 'english': 'The Combined Forces'},
      {'arabic': 'سبأ', 'english': 'Sheba'},
      {'arabic': 'فاطر', 'english': 'The Originator'},
      {'arabic': 'يس', 'english': 'Yaseen'},
      {'arabic': 'الصافات', 'english': 'Those Who Set The Ranks'},
      {'arabic': 'ص', 'english': 'Sad'},
      {'arabic': 'الزمر', 'english': 'The Troops'},
      {'arabic': 'غافر', 'english': 'The Forgiver'},
      {'arabic': 'فصلت', 'english': 'Explained in Detail'},
      {'arabic': 'الشورى', 'english': 'The Consultation'},
      {'arabic': 'الزخرف', 'english': 'Ornaments of Gold'},
      {'arabic': 'الدخان', 'english': 'The Smoke'},
      {'arabic': 'الجاثية', 'english': 'The Crouching'},
      {'arabic': 'الأحقاف', 'english': 'The Wind-Curved Sandhills'},
      {'arabic': 'محمد', 'english': 'Muhammad'},
      {'arabic': 'الفتح', 'english': 'The Victory'},
      {'arabic': 'الحجرات', 'english': 'The Rooms'},
      {'arabic': 'ق', 'english': 'Qaf'},
      {'arabic': 'الذاريات', 'english': 'The Winnowing Winds'},
      {'arabic': 'الطور', 'english': 'The Mount'},
      {'arabic': 'النجم', 'english': 'The Star'},
      {'arabic': 'القمر', 'english': 'The Moon'},
      {'arabic': 'الرحمن', 'english': 'The Beneficent'},
      {'arabic': 'الواقعة', 'english': 'The Inevitable'},
      {'arabic': 'الحديد', 'english': 'The Iron'},
      {'arabic': 'المجادلة', 'english': 'The Pleading Woman'},
      {'arabic': 'الحشر', 'english': 'The Exile'},
      {'arabic': 'الممتحنة', 'english': 'She that is to be examined'},
      {'arabic': 'الصف', 'english': 'The Ranks'},
      {'arabic': 'الجمعة', 'english': 'Friday'},
      {'arabic': 'المنافقون', 'english': 'The Hypocrites'},
      {'arabic': 'التغابن', 'english': 'Mutual Disillusion'},
      {'arabic': 'الطلاق', 'english': 'Divorce'},
      {'arabic': 'التحريم', 'english': 'Prohibition'},
      {'arabic': 'الملك', 'english': 'The Sovereignty'},
      {'arabic': 'القلم', 'english': 'The Pen'},
      {'arabic': 'الحاقة', 'english': 'The Reality'},
      {'arabic': 'المعارج', 'english': 'The Ascending Stairways'},
      {'arabic': 'نوح', 'english': 'Noah'},
      {'arabic': 'الجن', 'english': 'The Jinn'},
      {'arabic': 'المزمل', 'english': 'The Enshrouded One'},
      {'arabic': 'المدثر', 'english': 'The Cloaked One'},
      {'arabic': 'القيامة', 'english': 'The Resurrection'},
      {'arabic': 'الإنسان', 'english': 'Man'},
      {'arabic': 'المرسلات', 'english': 'The Emissaries'},
      {'arabic': 'النبأ', 'english': 'The Tidings'},
      {'arabic': 'النازعات', 'english': 'Those Who Drag Forth'},
      {'arabic': 'عبس', 'english': 'He Frowned'},
      {'arabic': 'التكوير', 'english': 'The Overthrowing'},
      {'arabic': 'الانفطار', 'english': 'The Cleaving'},
      {'arabic': 'المطففين', 'english': 'Defrauding'},
      {'arabic': 'الانشقاق', 'english': 'The Splitting Open'},
      {'arabic': 'البروج', 'english': 'The Constellations'},
      {'arabic': 'الطارق', 'english': 'The Nightcomer'},
      {'arabic': 'الأعلى', 'english': 'The Most High'},
      {'arabic': 'الغاشية', 'english': 'The Overwhelming'},
      {'arabic': 'الفجر', 'english': 'The Dawn'},
      {'arabic': 'البلد', 'english': 'The City'},
      {'arabic': 'الشمس', 'english': 'The Sun'},
      {'arabic': 'الليل', 'english': 'The Night'},
      {'arabic': 'الضحى', 'english': 'The Morning Hours'},
      {'arabic': 'الشرح', 'english': 'The Relief'},
      {'arabic': 'التين', 'english': 'The Fig'},
      {'arabic': 'العلق', 'english': 'The Clot'},
      {'arabic': 'القدر', 'english': 'The Power'},
      {'arabic': 'البينة', 'english': 'The Clear Proof'},
      {'arabic': 'الزلزلة', 'english': 'The Earthquake'},
      {'arabic': 'العاديات', 'english': 'The Courser'},
      {'arabic': 'القارعة', 'english': 'The Calamity'},
      {'arabic': 'التكاثر', 'english': 'The Rivalry in world increase'},
      {'arabic': 'العصر', 'english': 'The Declining Day'},
      {'arabic': 'الهمزة', 'english': 'The Slanderer'},
      {'arabic': 'الفيل', 'english': 'The Elephant'},
      {'arabic': 'قريش', 'english': 'Quraysh'},
      {'arabic': 'الماعون', 'english': 'Small Kindnesses'},
      {'arabic': 'الكوثر', 'english': 'Abundance'},
      {'arabic': 'الكافرون', 'english': 'The Disbelievers'},
      {'arabic': 'النصر', 'english': 'Divine Support'},
      {'arabic': 'المسد', 'english': 'The Palm Fiber'},
      {'arabic': 'الإخلاص', 'english': 'Sincerity'},
      {'arabic': 'الفلق', 'english': 'The Daybreak'},
      {'arabic': 'الناس', 'english': 'Mankind'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final arabic = surah['arabic'] as String;
        final english = surah['english'] as String;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: surahBorderColor),
          ),
          color: surahCardColor,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade800,
              child: Text(
                _formatEnglishNumber(index + 1),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(arabic, style: TextStyle(fontWeight: FontWeight.w600, color: surahTitleColor)),
            subtitle: Text(english, style: TextStyle(color: surahSubtitleColor)),
            onTap: () async {
              final navigator = Navigator.of(context);
              final verse = await navigator.push<String>(
                MaterialPageRoute(
                  builder: (_) => SurahPage(
                    surahIndex: index + 1,
                    arabicName: arabic,
                    englishName: english,
                  ),
                ),
              );
              if (verse != null && selectMode) {
                navigator.pop(verse);
              }
            },
          ),
        );
      },
    );
  }
}

class SurahPage extends StatefulWidget {
  final int surahIndex;
  final String arabicName;
  final String englishName;
  const SurahPage({
    super.key,
    required this.surahIndex,
    required this.arabicName,
    required this.englishName,
  });

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  late Future<List<QuranVerse>> _versesFuture;

  void _reloadVerses() {
    setState(() {
      _versesFuture = _loadQuranVerses(widget.surahIndex);
    });
  }

  @override
  void initState() {
    super.initState();
    _versesFuture = _loadQuranVerses(widget.surahIndex);
    AppSettings.instance.addListener(_reloadVerses);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_reloadVerses);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verseCardColor = isDark ? Colors.grey[850]! : Colors.green.shade50;
    final verseBorderColor = isDark ? Colors.grey[700]! : Colors.green.shade100;
    final translationTextColor = isDark ? Colors.grey[300]! : Colors.black54;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.arabicName} — ${widget.englishName}')),
      body: FutureBuilder<List<QuranVerse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load verses: ${snapshot.error}'));
          }

          final verses = snapshot.data ?? [];
          if (verses.isEmpty) {
            return const Center(child: Text('No verses found for this surah.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, i) {
              final verse = verses[i];
              final translationLabel = verse.translation.isNotEmpty
                  ? verse.translation
                  : 'Translation not available yet.';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: verseBorderColor),
                ),
                color: verseCardColor,
                child: ListTile(
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'favorite':
                          _addToFavorites(context, verse);
                          break;
                        case 'mood':
                          _showAddToMoodSheet(context, verse, widget.arabicName, widget.englishName);
                          break;
                        case 'note':
                          _showAddNoteDialog(context, verse, widget.arabicName, widget.englishName);
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'favorite', child: Text('Add to Favorites')),
                      PopupMenuItem(value: 'mood', child: Text('Add to Mood')),
                      PopupMenuItem(value: 'note', child: Text('Add Note')),
                    ],
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verse.arabic,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: VerseStore.instance.quranArabicFontSize, fontWeight: FontWeight.w700),
                      ),
                      if (!verse.isBismillah) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 134, 190, 137),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              _formatAyahLabel(verse.ayah),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        translationLabel,
                        style: TextStyle(color: translationTextColor, fontSize: VerseStore.instance.quranTranslationFontSize),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context, verse.arabic);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
