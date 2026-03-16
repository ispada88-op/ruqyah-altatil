// Credit Card Optimizer MVP — public API.
// Data models, business logic, repository contracts, and provider strategy.
// No UI. Add flutter_riverpod (and optionally drift) when implementing.

export 'models/card_profile.dart';
export 'models/statement_cycle.dart';
export 'models/installment_plan.dart';
export 'models/minimum_payment_trap_result.dart';
export 'logic/minimum_payment_trap.dart';
export 'logic/installment_tracker.dart';
export 'logic/fx_calculator.dart';
export 'logic/available_limit_calculator.dart';
export 'repository/card_repository.dart';
export 'repository/statement_cycle_repository.dart';
export 'repository/installment_plan_repository.dart';
export 'repository/card_balance_repository.dart';
export 'repository/card_limit_exception.dart';
export 'repository/drift_card_repository.dart';
export 'repository/drift_statement_cycle_repository.dart';
export 'repository/drift_installment_plan_repository.dart';
