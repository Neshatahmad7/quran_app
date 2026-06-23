import 'package:flutter/material.dart';

import '../services/verse_store.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VerseStore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, child) {
          final favorites = store.favorites;
          if (favorites.isEmpty) {
            return const Center(child: Text('No favorite verses yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final verse = favorites[index];
              return Card(
                child: ListTile(
                  title: Text(
                    verse,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      store.removeFavorite(verse);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favorite removed')),
                      );
                    },
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
