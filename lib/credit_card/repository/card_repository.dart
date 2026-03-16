import '../models/card_profile.dart';

/// Contract for card persistence.
/// Implement with drift (SQLite) or Firebase; enforce freemium (max 3 cards for free) in implementation.
abstract class CardRepository {
  Future<List<CardProfile>> listCards();
  Future<CardProfile?> getCard(String cardId);
  Future<void> addCard(CardProfile card);
  Future<void> updateCard(CardProfile card);
  Future<void> deleteCard(String cardId);
  Future<int> getCardCount();
}
