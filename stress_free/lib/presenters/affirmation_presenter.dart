import '../models/affirmation_model.dart';

class AffirmationPresenter {

  Future<List<Affirmation>> loadAffirmations(String userId) async {
    return await Affirmation.loadAffirmations(userId);
  }

  Future<void> toggleFavorite(String userId, Affirmation affirmation) async {
    await affirmation.saveFavorite(userId);
  }
}