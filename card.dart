// models/card.dart
// NOTE: Your file was saved as card.dat — rename it to card.dart

class CommCard {
  final String id;
  final String text;
  final String? imagePath;
  final String category;
  final String language;

  CommCard({
    required this.id,
    required this.text,
    this.imagePath,
    required this.category,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'imagePath': imagePath,
        'category': category,
        'language': language,
      };

  factory CommCard.fromJson(Map<String, dynamic> json) => CommCard(
        id: json['id'] as String,
        text: json['text'] as String,
        imagePath: json['imagePath'] as String?,
        category: json['category'] as String,
        language: (json['language'] as String?) ?? 'en',
      );

  // Added: copyWith for immutable updates
  CommCard copyWith({
    String? id,
    String? text,
    String? imagePath,
    String? category,
    String? language,
  }) {
    return CommCard(
      id: id ?? this.id,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      language: language ?? this.language,
    );
  }
}
