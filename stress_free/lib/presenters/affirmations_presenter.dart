import '../models/affirmation_model.dart';

/// Consumes the existing model without changing favorites or entry content.
class AffirmationsPresenter {
  AffirmationsPresenter({Iterable<Affirmation> affirmations = const []})
    : categories = List.unmodifiable({
        'Life',
        'Gym',
        'Work',
        ...affirmations
            .map((entry) => entry.category)
            .where((c) => c.isNotEmpty),
      });

  final List<String> categories;
}
