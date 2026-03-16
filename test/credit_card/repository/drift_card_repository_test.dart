import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roqia_altatil/credit_card/db/app_database.dart';
import 'package:roqia_altatil/credit_card/models/card_profile.dart';
import 'package:roqia_altatil/credit_card/repository/card_limit_exception.dart';
import 'package:roqia_altatil/credit_card/repository/drift_card_repository.dart';

void main() {
  late AppDatabase db;
  late DriftCardRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftCardRepository without limit', () {
    setUp(() {
      repo = DriftCardRepository(db);
    });

    test('addCard and getCard work', () async {
      final card = CardProfile(
        id: 'c1',
        name: 'Test',
        totalLimitCents: 10000,
        annualFeeCents: 0,
        annualFeeIssueDate: '01-01',
        currency: 'USD',
        createdAt: '2025-01-01',
        updatedAt: '2025-01-01',
      );
      await repo.addCard(card);
      final got = await repo.getCard('c1');
      expect(got, isNotNull);
      expect(got!.name, 'Test');
    });

    test('getCardCount returns correct count', () async {
      expect(await repo.getCardCount(), 0);
      await repo.addCard(_card('c1'));
      await repo.addCard(_card('c2'));
      expect(await repo.getCardCount(), 2);
    });
  });

  group('DriftCardRepository with Freemium limit 3', () {
    setUp(() {
      repo = DriftCardRepository(db, maxCardsForFreeTier: 3);
    });

    test('allows adding up to 3 cards', () async {
      await repo.addCard(_card('c1'));
      await repo.addCard(_card('c2'));
      await repo.addCard(_card('c3'));
      expect(await repo.getCardCount(), 3);
    });

    test('throws CardLimitReachedException when adding 4th card', () async {
      await repo.addCard(_card('c1'));
      await repo.addCard(_card('c2'));
      await repo.addCard(_card('c3'));
      expect(
        () => repo.addCard(_card('c4')),
        throwsA(isA<CardLimitReachedException>()),
      );
    });
  });
}

CardProfile _card(String id) {
  return CardProfile(
    id: id,
    name: 'Card $id',
    totalLimitCents: 10000,
    annualFeeCents: 0,
    annualFeeIssueDate: '01-01',
    currency: 'USD',
    createdAt: '2025-01-01',
    updatedAt: '2025-01-01',
  );
}
