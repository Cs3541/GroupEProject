import 'package:flutter/material.dart';

import '../presenters/affirmations_presenter.dart';

class MainAffirmationScreen extends StatelessWidget {
  const MainAffirmationScreen({super.key, this.presenter});

  final AffirmationsPresenter? presenter;

  @override
  Widget build(BuildContext context) {
    final categories = (presenter ?? AffirmationsPresenter()).categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Affirmations'),
        actions: [
          // Navigation belongs to later stories.
          IconButton(
            tooltip: 'Favorite affirmations',
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Affirmation settings',
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choose a category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(onPressed: () {}, child: Text(category)),
            ),
        ],
      ),
    );
  }
}
