import 'package:drift/drift.dart';

import '../db/app_database.dart' as drift;
import '../models/statement_cycle.dart';
import 'statement_cycle_repository.dart';

/// Drift-backed implementation of [StatementCycleRepository].
/// Maps Drift row (cents, bps) to domain [StatementCycle].
/// Domain uses [minPaymentPercent]; Drift table uses minPaymentPct (same value).
class DriftStatementCycleRepository implements StatementCycleRepository {
  DriftStatementCycleRepository(this._db);

  final drift.AppDatabase _db;

  @override
  Future<List<StatementCycle>> listCyclesForCard(String cardId) async {
    final rows = await (_db.select(_db.statementCycles)
          ..where((t) => t.cardId.equals(cardId))
          ..orderBy([(t) => OrderingTerm.desc(t.statementDate)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<StatementCycle?> getCycle(String cycleId) async {
    final row = await (_db.select(_db.statementCycles)
          ..where((t) => t.id.equals(cycleId)))
        .getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<StatementCycle?> getCurrentOpenCycle(String cardId) async {
    final rows = await (_db.select(_db.statementCycles)
          ..where((t) =>
              t.cardId.equals(cardId) & t.status.isNotValue('paid'))
          ..orderBy([(t) => OrderingTerm.desc(t.statementDate)])
          ..limit(1))
        .get();
    final row = rows.isNotEmpty ? rows.single : null;
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<void> addCycle(StatementCycle cycle) async {
    await _db.into(_db.statementCycles).insert(_toCompanion(cycle));
  }

  @override
  Future<void> updateCycle(StatementCycle cycle) async {
    await _db.update(_db.statementCycles).replace(_toDriftRow(cycle));
  }

  static StatementCycle _toDomain(drift.StatementCycle row) {
    return StatementCycle(
      id: row.id,
      cardId: row.cardId,
      statementDate: row.statementDate,
      dueDate: row.dueDate,
      graceDays: row.graceDays,
      closingBalanceCents: row.closingBalanceCents,
      minPaymentPercent: row.minPaymentPct,
      aprBps: row.aprBps,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static drift.StatementCycle _toDriftRow(StatementCycle d) {
    return drift.StatementCycle(
      id: d.id,
      cardId: d.cardId,
      statementDate: d.statementDate,
      dueDate: d.dueDate,
      graceDays: d.graceDays,
      closingBalanceCents: d.closingBalanceCents,
      minPaymentPct: d.minPaymentPercent,
      aprBps: d.aprBps,
      status: d.status,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }

  static drift.StatementCyclesCompanion _toCompanion(StatementCycle d) {
    return drift.StatementCyclesCompanion.insert(
      id: d.id,
      cardId: d.cardId,
      statementDate: d.statementDate,
      dueDate: d.dueDate,
      graceDays: d.graceDays,
      closingBalanceCents: d.closingBalanceCents,
      minPaymentPct: d.minPaymentPercent,
      aprBps: d.aprBps,
      status: d.status,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }
}
