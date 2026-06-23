import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          const Text('Your Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Email: user@example.com'),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
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
