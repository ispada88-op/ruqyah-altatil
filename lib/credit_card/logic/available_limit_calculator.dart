// Dynamic available limit: no reliance on a static card_balances table.
// Single source of truth: Total Limit - Outstanding Statement Balances - Active Installment Holds.
// All amounts in integer cents.

/// Computes available limit on-the-fly from statement and installment data.
class AvailableLimitCalculator {
  AvailableLimitCalculator._();

  /// Computes available limit on-the-fly from authoritative sources.
  ///
  /// [totalLimitCents] Card's total credit limit.
  /// [outstandingStatementBalanceCents] Sum of unpaid statement balances (from statement_cycles, not a cache).
  /// [activeInstallmentHoldCents] Sum of active installment amounts reserving credit (e.g. total or remaining).
  static int availableLimit({
    required int totalLimitCents,
    required int outstandingStatementBalanceCents,
    required int activeInstallmentHoldCents,
  }) {
    final used = outstandingStatementBalanceCents + activeInstallmentHoldCents;
    if (used > totalLimitCents) return 0;
    return totalLimitCents - used;
  }
}
