/// Immutable model for a statement cycle.
/// All monetary values in integer cents.
class StatementCycle {
  const StatementCycle({
    required this.id,
    required this.cardId,
    required this.statementDate,
    required this.dueDate,
    required this.graceDays,
    required this.closingBalanceCents,
    required this.minPaymentPercent,
    required this.aprBps,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String cardId;
  final String statementDate;
  final String dueDate;
  final int graceDays;
  final int closingBalanceCents;
  final int minPaymentPercent;
  final int aprBps;
  final String status;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardId': cardId,
        'statementDate': statementDate,
        'dueDate': dueDate,
        'graceDays': graceDays,
        'closingBalanceCents': closingBalanceCents,
        'minPaymentPercent': minPaymentPercent,
        'aprBps': aprBps,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory StatementCycle.fromJson(Map<String, dynamic> json) {
    return StatementCycle(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      statementDate: json['statementDate'] as String,
      dueDate: json['dueDate'] as String,
      graceDays: json['graceDays'] as int,
      closingBalanceCents: json['closingBalanceCents'] as int,
      minPaymentPercent: json['minPaymentPercent'] as int,
      aprBps: json['aprBps'] as int,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
