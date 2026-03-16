import 'package:flutter_test/flutter_test.dart';

import 'package:roqia_altatil/credit_card/logic/installment_tracker.dart';
import 'package:roqia_altatil/credit_card/models/installment_plan.dart';
import 'package:roqia_altatil/credit_card/models/statement_cycle.dart';

void main() {
  group('InstallmentTracker', () {
    test('reservedCreditFromTotal sums active plans only', () {
      final plans = [
        _plan(id: '1', total: 10000, status: 'active'),
        _plan(id: '2', total: 5000, status: 'completed'),
        _plan(id: '3', total: 3000, status: 'active'),
      ];
      expect(InstallmentTracker.reservedCreditFromTotal(plans), 13000);
    });

    test('reservedCreditFromRemaining uses remaining amount', () {
      final plans = [
        _plan(id: '1', total: 10000, remaining: 7000, status: 'active'),
      ];
      expect(InstallmentTracker.reservedCreditFromRemaining(plans), 7000);
    });

    test('dueAmountForCycle adds installment when nextDue in range', () {
      final cycle = StatementCycle(
        id: 'c1',
        cardId: 'card1',
        statementDate: '2025-01-01',
        dueDate: '2025-01-25',
        graceDays: 25,
        closingBalanceCents: 5000,
        minPaymentPercent: 5,
        aprBps: 1899,
        status: 'open',
        createdAt: '',
        updatedAt: '',
      );
      final plans = [
        _plan(id: '1', monthly: 500, nextDue: '2025-01-15', status: 'active'),
      ];
      final due = InstallmentTracker.dueAmountForCycle(
        cycle: cycle,
        activePlans: plans,
        nextStatementDate: '2025-02-01',
      );
      expect(due, 5500); // 5000 + 500
    });

    test('availableLimit returns correct value', () {
      expect(
        InstallmentTracker.availableLimit(
          totalLimitCents: 10000,
          currentBalanceCents: 3000,
          reservedCents: 2000,
        ),
        5000,
      );
    });

    test('availableLimit returns 0 when used exceeds limit', () {
      expect(
        InstallmentTracker.availableLimit(
          totalLimitCents: 5000,
          currentBalanceCents: 4000,
          reservedCents: 2000,
        ),
        0,
      );
    });
  });
}

InstallmentPlan _plan({
  required String id,
  int total = 10000,
  int remaining = 10000,
  int monthly = 500,
  String nextDue = '2025-01-15',
  required String status,
}) {
  return InstallmentPlan(
    id: id,
    cardId: 'card1',
    totalAmountCents: total,
    monthlyPaymentCents: monthly,
    remainingAmountCents: remaining,
    numInstallments: 20,
    remainingInstallments: 20,
    startDate: '2024-01-01',
    nextDueDate: nextDue,
    status: status,
    createdAt: '',
    updatedAt: '',
  );
}
