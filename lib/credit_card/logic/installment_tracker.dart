import '../models/installment_plan.dart';
import '../models/statement_cycle.dart';

/// Pure business logic for installment plans:
/// - Reserved credit (reduces available limit)
/// - Installment slice to add to a statement's due amount
/// All amounts in integer cents. Dates as ISO date strings (YYYY-MM-DD).
class InstallmentTracker {
  InstallmentTracker._();

  /// Reserved credit for a card: sum of total amounts of active plans.
  /// Use this to subtract from available limit (full reserve).
  /// For a more conservative reserve, use [reservedCreditFromRemaining] instead.
  static int reservedCreditFromTotal(Iterable<InstallmentPlan> activePlans) {
    int sum = 0;
    for (final p in activePlans) {
      if (p.isActive) sum += p.totalAmountCents;
    }
    return sum;
  }

  /// Reserved credit using remaining amount (conservative: only unpaid portion).
  static int reservedCreditFromRemaining(Iterable<InstallmentPlan> activePlans) {
    int sum = 0;
    for (final p in activePlans) {
      if (p.isActive) sum += p.remainingAmountCents;
    }
    return sum;
  }

  /// Due amount for a statement cycle: closing balance + installment portions
  /// whose [next_due_date] falls within the cycle window.
  ///
  /// [cycle] The statement cycle (statement date and next cycle's statement date define the window).
  /// [nextStatementDate] The *next* statement's closing date (exclusive end of window).
  ///   If null, we consider only plans whose nextDueDate <= cycle.dueDate (simplified).
  /// [activePlans] All active installment plans for this card.
  static int dueAmountForCycle({
    required StatementCycle cycle,
    required Iterable<InstallmentPlan> activePlans,
    String? nextStatementDate,
  }) {
    int due = cycle.closingBalanceCents;
    final cycleStart = cycle.statementDate;
    final cycleEnd = nextStatementDate ?? cycle.dueDate;

    for (final plan in activePlans) {
      if (!plan.isActive) continue;
      final nextDue = plan.nextDueDate;
      if (_dateInRange(nextDue, cycleStart, cycleEnd)) {
        due += plan.monthlyPaymentCents;
      }
    }
    return due;
  }

  static bool _dateInRange(String date, String start, String end) {
    return date.compareTo(start) >= 0 && date.compareTo(end) <= 0;
  }

  /// Computes available limit for a card (pure function).
  /// [totalLimitCents] Card's total limit.
  /// [currentBalanceCents] Current balance (from card_balances or latest statement).
  /// [reservedCents] Sum from [reservedCreditFromTotal] or [reservedCreditFromRemaining].
  static int availableLimit({
    required int totalLimitCents,
    required int currentBalanceCents,
    required int reservedCents,
  }) {
    int used = currentBalanceCents + reservedCents;
    if (used > totalLimitCents) return 0;
    return totalLimitCents - used;
  }
}
