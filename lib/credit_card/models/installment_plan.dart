/// Immutable model for a 0% installment plan.
/// All monetary values in integer cents.
class InstallmentPlan {
  const InstallmentPlan({
    required this.id,
    required this.cardId,
    required this.totalAmountCents,
    required this.monthlyPaymentCents,
    required this.remainingAmountCents,
    required this.numInstallments,
    required this.remainingInstallments,
    required this.startDate,
    required this.nextDueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String cardId;
  final int totalAmountCents;
  final int monthlyPaymentCents;
  final int remainingAmountCents;
  final int numInstallments;
  final int remainingInstallments;
  final String startDate;
  final String nextDueDate;
  final String status;
  final String createdAt;
  final String updatedAt;

  bool get isActive => status == 'active';

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardId': cardId,
        'totalAmountCents': totalAmountCents,
        'monthlyPaymentCents': monthlyPaymentCents,
        'remainingAmountCents': remainingAmountCents,
        'numInstallments': numInstallments,
        'remainingInstallments': remainingInstallments,
        'startDate': startDate,
        'nextDueDate': nextDueDate,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) {
    return InstallmentPlan(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      totalAmountCents: json['totalAmountCents'] as int,
      monthlyPaymentCents: json['monthlyPaymentCents'] as int,
      remainingAmountCents: json['remainingAmountCents'] as int,
      numInstallments: json['numInstallments'] as int,
      remainingInstallments: json['remainingInstallments'] as int,
      startDate: json['startDate'] as String,
      nextDueDate: json['nextDueDate'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
