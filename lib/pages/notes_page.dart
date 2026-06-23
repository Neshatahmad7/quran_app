import 'package:flutter/material.dart';

import '../services/verse_store.dart';

String _formatEnglishNumber(int number) => number.toString();

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VerseStore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, child) {
          final notes = store.notes;
          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet. Add a note from the Quran page.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${note.surahName} ${note.ayah > 0 ? '⟪ ${_formatEnglishNumber(note.ayah)} ⟫' : 'بسملة'}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              store.removeNoteAt(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Note deleted')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(note.arabic, textAlign: TextAlign.right),
                      if (note.translation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(note.translation, style: const TextStyle(color: Colors.black54)),
                      ],
                      const SizedBox(height: 8),
                      const Text('Note:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(note.note),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
