import 'package:flutter/material.dart';
import '../presenters/affirmation_presenter.dart';
import '../models/affirmation_model.dart';

class MainAffirmationScreen extends StatefulWidget {
  const MainAffirmationScreen({super.key});
  @override
  State<MainAffirmationScreen> createState() => _MainAffirmationScreenState();
  
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
    child: Scaffold(
      appBar: AppBar(
        title: const Text("Affirmations"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
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
                    fontWeight: affirmation.isFavorite ? FontWeight.bold : FontWeight.normal,
                    color: affirmation.isFavorite ? Colors.purple : Colors.black,
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
    ),
  );
}
 
}
