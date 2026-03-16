// Riverpod: available limit is computed dynamically (no card_balances table).
// Formula: Available Limit = Total Limit - Outstanding Statement Balances - Active Installment Holds.
//
// Dependency graph:
//   cardListProvider
//   cardProvider(cardId)
//   openStatementCyclesProvider(cardId)  -> list of cycles where status != 'paid'
//   outstandingBalanceProvider(cardId)  -> sum(cycle.closingBalanceCents) for open cycles
//   activeInstallmentPlansProvider(cardId)
//   availableLimitProvider(cardId)       -> AvailableLimitCalculator.availableLimit(
//                                            totalLimit,
//                                            outstandingBalance,
//                                            installmentHold,
//                                          )
//
// Invalidation: On statement or installment changes, invalidate the relevant provider(s);
// availableLimitProvider(cardId) recomputes automatically.

// --- Snippet: dynamic available limit (no static balance table) ---
//
// Outstanding balance from statements (single source of truth):
//
//   final openStatementCyclesProvider = FutureProvider.family<List<StatementCycle>, String>((ref, cardId) async {
//     final repo = ref.watch(statementCycleRepositoryProvider);
//     final cycles = await repo.listCyclesForCard(cardId);
//     return cycles.where((c) => c.status != 'paid').toList();
//   });
//
//   final outstandingBalanceProvider = FutureProvider.family<int, String>((ref, cardId) async {
//     final openCycles = await ref.watch(openStatementCyclesProvider(cardId).future);
//     return openCycles.fold<int>(0, (sum, c) => sum + c.closingBalanceCents);
//   });
//
// Available limit (dynamic, on-the-fly):
//
//   final availableLimitProvider = FutureProvider.family<int, String>((ref, cardId) async {
//     final card = await ref.watch(cardProvider(cardId).future);
//     if (card == null) return 0;
//     final outstanding = await ref.watch(outstandingBalanceProvider(cardId).future);
//     final plans = await ref.watch(activeInstallmentPlansProvider(cardId).future);
//     final hold = InstallmentTracker.reservedCreditFromTotal(plans);
//     return AvailableLimitCalculator.availableLimit(
//       totalLimitCents: card.totalLimitCents,
//       outstandingStatementBalanceCents: outstanding,
//       activeInstallmentHoldCents: hold,
//     );
//   });
