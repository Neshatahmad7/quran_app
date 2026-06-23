import 'package:flutter/material.dart';

import '../services/app_settings.dart';
import '../services/verse_store.dart';
import 'favorites_page.dart';
import 'notes_page.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  final VerseStore _store = VerseStore.instance;
  

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    AppSettings.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    AppSettings.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showFontSizePicker(BuildContext context) async {
    final options = ['Small', 'Medium', 'Large'];
    String choice = _store.quranFontSizeLabel;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          return RadioListTile<String>(
            title: Text(opt),
            value: opt,
            groupValue: choice,
            onChanged: (v) {
              if (v != null) {
                _store.setQuranFontSize(v);
                Navigator.pop(ctx);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final options = ['System', 'Light', 'Dark'];
    String choice = AppSettings.instance.themeModeLabel;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          return RadioListTile<String>(
            title: Text(opt),
            value: opt,
            groupValue: choice,
            onChanged: (v) {
              if (v != null) {
                AppSettings.instance.setThemeMode(v);
                Navigator.pop(ctx);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final options = ['English', 'Dari/Persian', 'Pashto'];
    String choice = AppSettings.instance.languageLabel;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          return RadioListTile<String>(
            title: Text(opt),
            value: opt,
            groupValue: choice,
            onChanged: (v) {
              if (v != null) {
                AppSettings.instance.setLanguage(v);
                Navigator.pop(ctx);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Quran Font Size'),
                  subtitle: Text(_store.quranFontSizeLabel),
                  onTap: () => _showFontSizePicker(context),
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Theme'),
                  subtitle: Text(AppSettings.instance.themeModeLabel),
                  onTap: () => _showThemePicker(context),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(AppSettings.instance.languageLabel),
                  onTap: () => _showLanguagePicker(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text('Favorites'),
              subtitle: Text('${_store.favorites.length} saved verses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.note, color: Colors.blue),
              title: const Text('My Notes'),
              subtitle: Text('${_store.notes.length} saved notes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotesPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
