class Affirmation {
  final String text;
  bool isFavorite;
  final String category;

  Affirmation(
    {
     required this.text,
     this.isFavorite = false,
     required this.category
    });

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      text: json['text'] as String,
      isFavorite: json['isFavorite'] as bool,
      category: json['category'] as String,
    );
  }
} 

