import '../models/card_pack.dart';

/// Mock card pack service with hardcoded data
/// In production, this would fetch from a real backend
class CardPackService {
  /// Get all available card packs
  static List<CardPack> getCardPacks() {
    return [_starterPack, _essentialsPack, _foodPack, _familyPack];
  }

  /// Get pack by ID
  static CardPack? getPackById(String id) {
    try {
      return getCardPacks().firstWhere((pack) => pack.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get only free packs
  static List<CardPack> getFreePacks() {
    return getCardPacks().where((pack) => !pack.isPremium).toList();
  }

  /// Get only premium packs
  static List<CardPack> getPremiumPacks() {
    return getCardPacks().where((pack) => pack.isPremium).toList();
  }

  // Starter pack: 9 basic communication cards
  static final _starterPack = CardPack(
    id: 'starter',
    name: 'Starter Pack',
    description: 'Essential communication cards for everyday needs',
    isPremium: false,
    price: 0.0,
    cards: [
      const Card(id: 'yes', label: 'Yes', category: 'basic', color: '#4CAF50'),
      const Card(id: 'no', label: 'No', category: 'basic', color: '#F44336'),
      const Card(id: 'please', label: 'Please', category: 'basic', color: '#2196F3'),
      const Card(id: 'thankyou', label: 'Thank You', category: 'basic', color: '#9C27B0'),
      const Card(id: 'help', label: 'Help', category: 'basic', color: '#FF9800'),
      const Card(id: 'water', label: 'Water', category: 'needs', color: '#03A9F4'),
      const Card(id: 'food', label: 'Food', category: 'needs', color: '#8BC34A'),
      const Card(id: 'toilet', label: 'Toilet', category: 'needs', color: '#607D8B'),
      const Card(id: 'pain', label: 'Pain', category: 'needs', color: '#E91E63'),
    ],
  );

  // Essentials pack: 20 cards for common needs
  static final _essentialsPack = CardPack(
    id: 'essentials',
    name: 'Essentials Pack',
    description: 'Expanded vocabulary for daily communication',
    isPremium: true,
    price: 4.99,
    cards: [
      const Card(id: 'hello', label: 'Hello', category: 'greetings', color: '#4CAF50'),
      const Card(id: 'goodbye', label: 'Goodbye', category: 'greetings', color: '#4CAF50'),
      const Card(id: 'goodmorning', label: 'Good Morning', category: 'greetings', color: '#4CAF50'),
      const Card(id: 'goodnight', label: 'Good Night', category: 'greetings', color: '#4CAF50'),
      const Card(id: 'howareyou', label: 'How are you?', category: 'greetings', color: '#4CAF50'),
      const Card(id: 'sorry', label: 'Sorry', category: 'basic', color: '#2196F3'),
      const Card(id: 'excuse', label: 'Excuse me', category: 'basic', color: '#2196F3'),
      const Card(id: 'happy', label: 'Happy', category: 'emotions', color: '#FFEB3B'),
      const Card(id: 'sad', label: 'Sad', category: 'emotions', color: '#3F51B5'),
      const Card(id: 'tired', label: 'Tired', category: 'emotions', color: '#9E9E9E'),
      const Card(id: 'hungry', label: 'Hungry', category: 'needs', color: '#8BC34A'),
      const Card(id: 'thirsty', label: 'Thirsty', category: 'needs', color: '#03A9F4'),
      const Card(id: 'bathroom', label: 'Bathroom', category: 'needs', color: '#607D8B'),
      const Card(id: 'doctor', label: 'Doctor', category: 'people', color: '#F44336'),
      const Card(id: 'nurse', label: 'Nurse', category: 'people', color: '#F44336'),
      const Card(id: 'family', label: 'Family', category: 'people', color: '#E91E63'),
      const Card(id: 'friend', label: 'Friend', category: 'people', color: '#E91E63'),
      const Card(id: 'yesplease', label: 'Yes, please', category: 'phrases', color: '#4CAF50'),
      const Card(id: 'nothanks', label: 'No, thanks', category: 'phrases', color: '#F44336'),
      const Card(id: 'ineed', label: 'I need...', category: 'phrases', color: '#FF9800'),
    ],
  );

  // Food & Drink pack
  static final _foodPack = CardPack(
    id: 'food',
    name: 'Food & Drink',
    description: 'Common food and drink items',
    isPremium: true,
    price: 2.99,
    cards: [
      const Card(id: 'bread', label: 'Bread', category: 'food', color: '#8D6E63'),
      const Card(id: 'meat', label: 'Meat', category: 'food', color: '#8D6E63'),
      const Card(id: 'vegetables', label: 'Vegetables', category: 'food', color: '#4CAF50'),
      const Card(id: 'fruit', label: 'Fruit', category: 'food', color: '#FF9800'),
      const Card(id: 'milk', label: 'Milk', category: 'drinks', color: '#FFFFFF'),
      const Card(id: 'coffee', label: 'Coffee', category: 'drinks', color: '#6D4C41'),
      const Card(id: 'tea', label: 'Tea', category: 'drinks', color: '#8BC34A'),
      const Card(id: 'juice', label: 'Juice', category: 'drinks', color: '#FF9800'),
    ],
  );

  // Family pack
  static final _familyPack = CardPack(
    id: 'family',
    name: 'Family',
    description: 'Family members and relationships',
    isPremium: true,
    price: 2.99,
    cards: [
      const Card(id: 'mother', label: 'Mother', category: 'family', color: '#E91E63'),
      const Card(id: 'father', label: 'Father', category: 'family', color: '#2196F3'),
      const Card(id: 'wife', label: 'Wife', category: 'family', color: '#E91E63'),
      const Card(id: 'husband', label: 'Husband', category: 'family', color: '#2196F3'),
      const Card(id: 'son', label: 'Son', category: 'family', color: '#9C27B0'),
      const Card(id: 'daughter', label: 'Daughter', category: 'family', color: '#9C27B0'),
      const Card(id: 'brother', label: 'Brother', category: 'family', color: '#673AB7'),
      const Card(id: 'sister', label: 'Sister', category: 'family', color: '#673AB7'),
      const Card(id: 'grandmother', label: 'Grandmother', category: 'family', color: '#E91E63'),
      const Card(id: 'grandfather', label: 'Grandfather', category: 'family', color: '#2196F3'),
    ],
  );
}