import 'package:flutter_test/flutter_test.dart';

import 'package:roqia_altatil/credit_card/logic/available_limit_calculator.dart';

void main() {
  group('AvailableLimitCalculator', () {
    test('availableLimit = total - outstanding - installmentHold', () {
      expect(
        AvailableLimitCalculator.availableLimit(
          totalLimitCents: 10000,
          outstandingStatementBalanceCents: 3000,
          activeInstallmentHoldCents: 2000,
        ),
        5000,
      );
    });

    test('availableLimit returns 0 when used exceeds total', () {
      expect(
        AvailableLimitCalculator.availableLimit(
          totalLimitCents: 5000,
          outstandingStatementBalanceCents: 4000,
          activeInstallmentHoldCents: 2000,
        ),
        0,
      );
    });

    test('availableLimit with zero outstanding', () {
      expect(
        AvailableLimitCalculator.availableLimit(
          totalLimitCents: 10000,
          outstandingStatementBalanceCents: 0,
          activeInstallmentHoldCents: 1000,
        ),
        9000,
      );
    });
  });
}
