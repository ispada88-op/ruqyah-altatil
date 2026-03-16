import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Opens the SQLite database on the device using [path_provider].
/// Enables foreign keys for strict referential integrity.
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'credit_card.db'));
    return NativeDatabase.createInBackground(
      file,
      setup: (raw) {
        raw.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}

@DriftDatabase(tables: [Cards, StatementCycles, InstallmentPlans], daos: [CardsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );
}

/// DAO: insert a card and retrieve a card with its active statement cycles.
@DriftAccessor(tables: [Cards, StatementCycles])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  /// Inserts a card. Fails if id already exists (PK).
  Future<int> insertCard(CardsCompanion companion) =>
      into(db.cards).insert(companion);

  /// Retrieves a card by id, or null if not found.
  Future<Card?> getCard(String id) =>
      (select(db.cards)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Retrieves a card and its active (non-paid) statement cycles in one query.
  Future<CardWithActiveCycles?> getCardWithActiveStatementCycles(String cardId) async {
    final card = await getCard(cardId);
    if (card == null) return null;
    final cycles = await (select(db.statementCycles)
          ..where((t) =>
              t.cardId.equals(cardId) & t.status.isNotValue('paid'))
          ..orderBy([(t) => OrderingTerm.desc(t.statementDate)]))
        .get();
    return CardWithActiveCycles(card: card, cycles: cycles);
  }
}

/// Simple holder for card + its active statement cycles.
class CardWithActiveCycles {
  CardWithActiveCycles({required this.card, required this.cycles});
  final Card card;
  final List<StatementCycle> cycles;
}
