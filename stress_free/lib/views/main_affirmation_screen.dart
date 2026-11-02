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
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: _affirmations.length,
    itemBuilder: (BuildContext context, int index) {
      return SizedBox(
        height: 50,
        child: Center(child: Text('Entry ${_affirmations[index].text}')),
      );
    }
  );
}
 
}
