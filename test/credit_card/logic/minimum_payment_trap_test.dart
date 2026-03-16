import 'package:flutter_test/flutter_test.dart';

import 'package:roqia_altatil/credit_card/logic/minimum_payment_trap.dart';

void main() {
  group('MinimumPaymentTrap', () {
    test('returns zero when balance is zero', () {
      final r = MinimumPaymentTrap.run(
        balanceCents: 0,
        aprBps: 1899,
        minPaymentPercent: 5,
      );
      expect(r.totalInterestCents, 0);
      expect(r.monthsToPayOff, 0);
      expect(r.totalPaymentsCents, 0);
    });

    test('returns zero when balance is negative', () {
      final r = MinimumPaymentTrap.run(
        balanceCents: -100,
        aprBps: 1899,
        minPaymentPercent: 5,
      );
      expect(r.totalInterestCents, 0);
      expect(r.monthsToPayOff, 0);
    });

    test('calculates interest and months for typical balance', () {
      // $5000 balance, 18.99% APR, 5% min payment
      final r = MinimumPaymentTrap.run(
        balanceCents: 500000,
        aprBps: 1899,
        minPaymentPercent: 5,
      );
      expect(r.totalInterestCents, greaterThan(0));
      expect(r.monthsToPayOff, greaterThan(1));
      expect(r.totalPaymentsCents, greaterThan(500000));
      expect(r.totalPaymentsCents, greaterThan(r.totalInterestCents));
    });

    test('fixed extra payment reduces months', () {
      final rMin = MinimumPaymentTrap.run(
        balanceCents: 100000,
        aprBps: 1899,
        minPaymentPercent: 5,
      );
      final rExtra = MinimumPaymentTrap.run(
        balanceCents: 100000,
        aprBps: 1899,
        minPaymentPercent: 5,
        fixedExtraCents: 5000,
      );
      expect(rExtra.monthsToPayOff, lessThan(rMin.monthsToPayOff));
      expect(rExtra.totalInterestCents, lessThan(rMin.totalInterestCents));
    });

    test('includeBreakdown populates monthlyBreakdown', () {
      final r = MinimumPaymentTrap.run(
        balanceCents: 10000,
        aprBps: 1200,
        minPaymentPercent: 5,
        includeBreakdown: true,
      );
      expect(r.monthlyBreakdown, isNotNull);
      expect(r.monthlyBreakdown!.length, r.monthsToPayOff);
      expect(r.monthlyBreakdown!.first.balanceStartCents, 10000);
    });
  });
}
