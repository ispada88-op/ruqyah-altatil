import 'package:flutter_test/flutter_test.dart';

import 'package:roqia_altatil/credit_card/logic/fx_calculator.dart';
import 'package:roqia_altatil/credit_card/models/card_profile.dart';

void main() {
  group('FXCalculator', () {
    test('feeCents calculates correctly', () {
      expect(FXCalculator.feeCents(10000, 200), 200); // $100, 2% = $2
      expect(FXCalculator.feeCents(100000, 100), 1000); // $1000, 1% = $10
      expect(FXCalculator.feeCents(5000, 350), 175); // $50, 3.5% = $1.75
    });

    test('cheapestCardForAmount returns null for empty list', () {
      expect(
        FXCalculator.cheapestCardForAmount(
          amountCents: 10000,
          cards: [],
        ),
        isNull,
      );
    });

    test('cheapestCardForAmount skips cards with null fxMarkupBps', () {
      final cards = [
        CardProfile(
          id: '1',
          name: 'A',
          totalLimitCents: 10000,
          annualFeeCents: 0,
          annualFeeIssueDate: '01-01',
          currency: 'USD',
          createdAt: '',
          updatedAt: '',
          fxMarkupBps: null,
        ),
      ];
      expect(
        FXCalculator.cheapestCardForAmount(amountCents: 10000, cards: cards),
        isNull,
      );
    });

    test('cheapestCardForAmount returns card with lowest fee', () {
      final cards = [
        CardProfile(
          id: '1',
          name: 'High',
          totalLimitCents: 10000,
          annualFeeCents: 0,
          annualFeeIssueDate: '01-01',
          currency: 'USD',
          createdAt: '',
          updatedAt: '',
          fxMarkupBps: 300,
        ),
        CardProfile(
          id: '2',
          name: 'Low',
          totalLimitCents: 10000,
          annualFeeCents: 0,
          annualFeeIssueDate: '01-01',
          currency: 'USD',
          createdAt: '',
          updatedAt: '',
          fxMarkupBps: 100,
        ),
      ];
      final best = FXCalculator.cheapestCardForAmount(
        amountCents: 10000,
        cards: cards,
      );
      expect(best, isNotNull);
      expect(best!.id, '2');
      expect(best.fxMarkupBps, 100);
    });
  });
}
