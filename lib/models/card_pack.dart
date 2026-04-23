/// Card model representing a single AAC card
class Card {
  final String id;
  final String label;
  final String? imagePath;
  final String? category;
  final String? color;

  const Card({
    required this.id,
    required this.label,
    this.imagePath,
    this.category,
    this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'imagePath': imagePath,
        'category': category,
        'color': color,
      };

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        id: json['id'] as String,
        label: json['label'] as String,
        imagePath: json['imagePath'] as String?,
        category: json['category'] as String?,
        color: json['color'] as String?,
      );
}

/// CardPack model representing a collection of cards
class CardPack {
  final String id;
  final String name;
  final String description;
  final List<Card> cards;
  final double price;
  final bool isPremium;

  const CardPack({
    required this.id,
    required this.name,
    required this.description,
    required this.cards,
    this.price = 0.0,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cards': cards.map((c) => c.toJson()).toList(),
        'price': price,
        'isPremium': isPremium,
      };

  factory CardPack.fromJson(Map<String, dynamic> json) => CardPack(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        cards: (json['cards'] as List)
            .map((c) => Card.fromJson(c as Map<String, dynamic>))
            .toList(),
        price: (json['price'] as num).toDouble(),
        isPremium: json['isPremium'] as bool,
      );
}