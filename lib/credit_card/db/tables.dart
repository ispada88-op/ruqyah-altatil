import 'package:drift/drift.dart';

/// Cards table. All monetary amounts stored as integer cents.
class Cards extends Table {
  @override
  String get tableName => 'cards';

  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get totalLimit => integer()();
  IntColumn get annualFeeAmount => integer()();
  TextColumn get annualFeeIssueDate => text()();
  IntColumn get fxMarkupBps => integer().nullable()();
  TextColumn get currency => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Statement cycles per card. Strong FK to Cards. All amounts in cents.
class StatementCycles extends Table {
  @override
  String get tableName => 'statement_cycles';

  TextColumn get id => text()();
  TextColumn get cardId => text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get statementDate => text()();
  TextColumn get dueDate => text()();
  IntColumn get graceDays => integer()();
  IntColumn get closingBalanceCents => integer()();
  IntColumn get minPaymentPct => integer()();
  IntColumn get aprBps => integer()();
  TextColumn get status => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Installment plans (0%). Strong FK to Cards. All amounts in cents.
class InstallmentPlans extends Table {
  @override
  String get tableName => 'installment_plans';

  TextColumn get id => text()();
  TextColumn get cardId => text().references(Cards, #id, onDelete: KeyAction.cascade)();
  IntColumn get totalAmount => integer()();
  IntColumn get monthlyPayment => integer()();
  IntColumn get remainingAmount => integer()();
  IntColumn get numInstallments => integer()();
  IntColumn get remainingInstallments => integer()();
  TextColumn get startDate => text()();
  TextColumn get nextDueDate => text()();
  TextColumn get status => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
