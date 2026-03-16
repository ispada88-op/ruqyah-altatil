import '../models/installment_plan.dart';

/// Contract for installment plan persistence.
abstract class InstallmentPlanRepository {
  Future<List<InstallmentPlan>> listPlansForCard(String cardId);
  Future<List<InstallmentPlan>> listActivePlansForCard(String cardId);
  Future<InstallmentPlan?> getPlan(String planId);
  Future<void> addPlan(InstallmentPlan plan);
  Future<void> updatePlan(InstallmentPlan plan);
  Future<void> deletePlan(String planId);
}
