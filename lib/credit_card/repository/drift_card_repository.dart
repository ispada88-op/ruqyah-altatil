import 'package:drift/drift.dart' show Value;

import '../db/app_database.dart';
import '../models/card_profile.dart';
import 'card_repository.dart';
import 'card_limit_exception.dart';

/// Drift-backed implementation of [CardRepository].
/// Maps Drift [Card] (cents, bps) to domain [CardProfile].
/// [maxCardsForFreeTier] when set (e.g. 3), enforces Freemium limit before insert.
class DriftCardRepository implements CardRepository {
  DriftCardRepository(this._db, {this.maxCardsForFreeTier});

  final AppDatabase _db;
  /// Free tier limit. Null = no limit (premium). Set to 3 for free tier.
  final int? maxCardsForFreeTier;

  @override
  Future<List<CardProfile>> listCards() async {
    final rows = await _db.select(_db.cards).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<CardProfile?> getCard(String cardId) async {
    final row = await _db.cardsDao.getCard(cardId);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<void> addCard(CardProfile card) async {
    if (maxCardsForFreeTier != null) {
      final count = await getCardCount();
      if (count >= maxCardsForFreeTier!) {
        throw CardLimitReachedException(maxCardsForFreeTier!, count);
      }
    }
    await _db.cardsDao.insertCard(_toCompanion(card));
  }

  @override
  Future<void> updateCard(CardProfile card) async {
    await _db.update(_db.cards).replace(_toDriftRow(card));
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await (_db.delete(_db.cards)..where((t) => t.id.equals(cardId))).go();
  }

  @override
  Future<int> getCardCount() async {
    final rows = await _db.select(_db.cards).get();
    return rows.length;
  }

  static CardProfile _toDomain(Card row) {
    return CardProfile(
      id: row.id,
      name: row.name,
      totalLimitCents: row.totalLimit,
      annualFeeCents: row.annualFeeAmount,
      annualFeeIssueDate: row.annualFeeIssueDate,
      currency: row.currency,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      fxMarkupBps: row.fxMarkupBps,
    );
  }

  static Card _toDriftRow(CardProfile p) {
    return Card(
      id: p.id,
      name: p.name,
      totalLimit: p.totalLimitCents,
      annualFeeAmount: p.annualFeeCents,
      annualFeeIssueDate: p.annualFeeIssueDate,
      fxMarkupBps: p.fxMarkupBps,
      currency: p.currency,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );
  }

  static CardsCompanion _toCompanion(CardProfile p) {
    return CardsCompanion.insert(
      id: p.id,
      name: p.name,
      totalLimit: p.totalLimitCents,
      annualFeeAmount: p.annualFeeCents,
      annualFeeIssueDate: p.annualFeeIssueDate,
      currency: p.currency,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
      fxMarkupBps: p.fxMarkupBps == null ? const Value.absent() : Value(p.fxMarkupBps),
    );
  }
}
