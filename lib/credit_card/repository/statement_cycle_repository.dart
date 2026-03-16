import '../models/statement_cycle.dart';

/// Contract for statement cycle persistence.
abstract class StatementCycleRepository {
  Future<List<StatementCycle>> listCyclesForCard(String cardId);
  Future<StatementCycle?> getCycle(String cycleId);
  Future<StatementCycle?> getCurrentOpenCycle(String cardId);
  Future<void> addCycle(StatementCycle cycle);
  Future<void> updateCycle(StatementCycle cycle);
}
