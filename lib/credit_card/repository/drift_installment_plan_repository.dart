import 'package:drift/drift.dart';

import '../db/app_database.dart' as drift;
import '../models/installment_plan.dart';
import 'installment_plan_repository.dart';

/// Drift-backed implementation of [InstallmentPlanRepository].
/// Maps Drift row (integer cents) to domain [InstallmentPlan].
class DriftInstallmentPlanRepository implements InstallmentPlanRepository {
  DriftInstallmentPlanRepository(this._db);

  final drift.AppDatabase _db;

  @override
  Future<List<InstallmentPlan>> listPlansForCard(String cardId) async {
    final rows = await (_db.select(_db.installmentPlans)
          ..where((t) => t.cardId.equals(cardId))
          ..orderBy([(t) => OrderingTerm.desc(t.nextDueDate)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<InstallmentPlan>> listActivePlansForCard(String cardId) async {
    final rows = await (_db.select(_db.installmentPlans)
          ..where((t) =>
              t.cardId.equals(cardId) & t.status.isValue('active'))
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<InstallmentPlan?> getPlan(String planId) async {
    final row = await (_db.select(_db.installmentPlans)
          ..where((t) => t.id.equals(planId)))
        .getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<void> addPlan(InstallmentPlan plan) async {
    await _db.into(_db.installmentPlans).insert(_toCompanion(plan));
  }

  @override
  Future<void> updatePlan(InstallmentPlan plan) async {
    await _db.update(_db.installmentPlans).replace(_toDriftRow(plan));
  }

  @override
  Future<void> deletePlan(String planId) async {
    await (_db.delete(_db.installmentPlans)..where((t) => t.id.equals(planId))).go();
  }

  static InstallmentPlan _toDomain(drift.InstallmentPlan row) {
    return InstallmentPlan(
      id: row.id,
      cardId: row.cardId,
      totalAmountCents: row.totalAmount,
      monthlyPaymentCents: row.monthlyPayment,
      remainingAmountCents: row.remainingAmount,
      numInstallments: row.numInstallments,
      remainingInstallments: row.remainingInstallments,
      startDate: row.startDate,
      nextDueDate: row.nextDueDate,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static drift.InstallmentPlan _toDriftRow(InstallmentPlan d) {
    return drift.InstallmentPlan(
      id: d.id,
      cardId: d.cardId,
      totalAmount: d.totalAmountCents,
      monthlyPayment: d.monthlyPaymentCents,
      remainingAmount: d.remainingAmountCents,
      numInstallments: d.numInstallments,
      remainingInstallments: d.remainingInstallments,
      startDate: d.startDate,
      nextDueDate: d.nextDueDate,
      status: d.status,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }

  static drift.InstallmentPlansCompanion _toCompanion(InstallmentPlan d) {
    return drift.InstallmentPlansCompanion.insert(
      id: d.id,
      cardId: d.cardId,
      totalAmount: d.totalAmountCents,
      monthlyPayment: d.monthlyPaymentCents,
      remainingAmount: d.remainingAmountCents,
      numInstallments: d.numInstallments,
      remainingInstallments: d.remainingInstallments,
      startDate: d.startDate,
      nextDueDate: d.nextDueDate,
      status: d.status,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }
}
