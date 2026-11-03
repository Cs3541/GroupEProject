import 'package:flutter/material.dart';
import '../presenters/affirmation_presenter.dart';
import '../models/affirmation_model.dart';

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
class _MainAffirmationScreenState extends State<MainAffirmationScreen> {
  final AffirmationPresenter _presenter = AffirmationPresenter();
  List<Affirmation> _affirmations = [];
  bool _isLoading = true;
  //List of categories for the dropdown menu
  final List<String> _categories = ["All", 'Favorites', "Motivation", "Self-love", "Confidence", "Peace", "Success",];
  String? _selectedCategory = 'All';

// Load affirmations when the screen is initialized
  @override
  void initState() {
    super.initState();
    _loadAffirmations();
  }
    Future<void> _loadAffirmations() async {
    final affirmations = await _presenter.loadAffirmations();
      setState(() {
        _affirmations = affirmations;
        _isLoading = false;
      });
  }

// Screen build method
@override
Widget build(BuildContext context) {
  //If loading show a loading indicator, otherwise show the affirmations
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  //list of affirmations to display based on the selected category
  final displayedAffirmations = _selectedCategory == 'All'
      ? _affirmations
      : _selectedCategory == 'Favorites'
          ? _affirmations.where((a) => a.isFavorite).toList()
          : _affirmations.where((a) => a.category == _selectedCategory).toList();

  return Center(
    child: Column(
      children: [
        DropdownButton<String>(
          value: _selectedCategory,
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
        ),
        Expanded(
          child: displayedAffirmations.isEmpty
              ? const Center(child: Text("No affirmations available."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedAffirmations.length,
                  itemBuilder: (BuildContext context, int index) {
                    final affirmation = displayedAffirmations[index];
                    if (_selectedCategory == 'All' || affirmation.category == _selectedCategory || (_selectedCategory == 'Favorites' && affirmation.isFavorite)) {
                return SelectableText( // Allows users to select affirmation and select it as a favorite
                  affirmation.text,
                  textAlign: TextAlign.center,
                  onTap: () {
                    setState(() {
                      affirmation.isFavorite = !affirmation.isFavorite;
                    });
                  },
                  style: TextStyle(
                    fontSize: 18,
                    color: affirmation.isFavorite ? Colors.yellow : Colors.black,
                  ),   
                );
              } else {
                return const SizedBox.shrink(); // Return an empty widget for non-matching categories
              }
            },
          ),
        ),
      ],
    ),
  );
}
 
}
