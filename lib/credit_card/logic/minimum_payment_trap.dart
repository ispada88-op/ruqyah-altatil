import '../models/minimum_payment_trap_result.dart';

/// Pure business logic for the Minimum Payment Trap.
/// All amounts in integer cents; APR in basis points (e.g. 1899 = 18.99%).
/// Efficient single-pass simulation; no floating-point for money.
class MinimumPaymentTrap {
  MinimumPaymentTrap._();

  /// Runs the minimum-payment simulation until payoff.
  ///
  /// [balanceCents] Current balance (cents).
  /// [aprBps] APR in basis points (e.g. 1899 for 18.99%).
  /// [minPaymentPercent] Minimum payment as percent of balance (e.g. 5 for 5%).
  /// [flatMinimumCents] Optional floor for min payment (e.g. 2500 = $25). Default 0.
  /// [fixedExtraCents] Optional fixed extra payment each month. Default 0.
  /// [includeBreakdown] If true, [result.monthlyBreakdown] is populated (use for UI).
  static MinimumPaymentTrapResult run({
    required int balanceCents,
    required int aprBps,
    required int minPaymentPercent,
    int flatMinimumCents = 0,
    int fixedExtraCents = 0,
    bool includeBreakdown = false,
  }) {
    if (balanceCents <= 0) {
      return const MinimumPaymentTrapResult(
        totalInterestCents: 0,
        monthsToPayOff: 0,
        totalPaymentsCents: 0,
      );
    }

    int totalInterest = 0;
    int totalPayments = 0;
    int balance = balanceCents;
    int month = 0;
    List<MinPaymentMonth>? breakdown = includeBreakdown ? [] : null;

    // Monthly rate = APR/12 in basis points, then / 10000
    // Use integer math: interest = balance * aprBps / 10000 / 12
    const int bpsPerYear = 10000;
    const int monthsPerYear = 12;

    while (balance > 0 && month < 360) {
      month++;
      int balanceStart = balance;

      // Interest for the month (integer division; small rounding error acceptable for simulation)
      int interestCents = (balance * aprBps ~/ bpsPerYear) ~/ monthsPerYear;
      totalInterest += interestCents;

      // Minimum payment: max(flat minimum, minPaymentPercent% of balance)
      int minPctCents = (balance * minPaymentPercent) ~/ 100;
      int minPayment = minPctCents > flatMinimumCents ? minPctCents : flatMinimumCents;
      int payment = minPayment + fixedExtraCents;

      // Cap payment at balance + interest so we don't overpay
      int amountDue = balance + interestCents;
      if (payment > amountDue) payment = amountDue;

      totalPayments += payment;
      int principalCents = payment - interestCents;
      balance = balanceStart + interestCents - payment;
      if (balance < 0) balance = 0;

      if (includeBreakdown && breakdown != null) {
        breakdown.add(MinPaymentMonth(
          monthIndex: month,
          balanceStartCents: balanceStart,
          paymentCents: payment,
          interestCents: interestCents,
          principalCents: principalCents,
          balanceEndCents: balance,
        ));
      }
    }

    return MinimumPaymentTrapResult(
      totalInterestCents: totalInterest,
      monthsToPayOff: month,
      totalPaymentsCents: totalPayments,
      monthlyBreakdown: breakdown,
    );
  }
}
