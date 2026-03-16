/// Result of the Minimum Payment Trap simulation.
/// All monetary values in integer cents.
class MinimumPaymentTrapResult {
  const MinimumPaymentTrapResult({
    required this.totalInterestCents,
    required this.monthsToPayOff,
    required this.totalPaymentsCents,
    this.monthlyBreakdown,
  });

  final int totalInterestCents;
  final int monthsToPayOff;
  final int totalPaymentsCents;
  final List<MinPaymentMonth>? monthlyBreakdown;

  int get principalCents => totalPaymentsCents - totalInterestCents;
}

/// Single month in the minimum-payment simulation.
class MinPaymentMonth {
  const MinPaymentMonth({
    required this.monthIndex,
    required this.balanceStartCents,
    required this.paymentCents,
    required this.interestCents,
    required this.principalCents,
    required this.balanceEndCents,
  });

  final int monthIndex;
  final int balanceStartCents;
  final int paymentCents;
  final int interestCents;
  final int principalCents;
  final int balanceEndCents;
}
