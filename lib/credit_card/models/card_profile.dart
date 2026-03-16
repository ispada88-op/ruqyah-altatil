/// Immutable model for a credit card profile.
/// All monetary values in integer cents (smallest currency unit).
class CardProfile {
  const CardProfile({
    required this.id,
    required this.name,
    required this.totalLimitCents,
    required this.annualFeeCents,
    required this.annualFeeIssueDate,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.fxMarkupBps,
  });

  final String id;
  final String name;
  final int totalLimitCents;
  final int annualFeeCents;
  final String annualFeeIssueDate;
  final String currency;
  final String createdAt;
  final String updatedAt;
  /// FX markup in basis points (e.g. 200 = 2%). Null when unknown.
  final int? fxMarkupBps;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalLimitCents': totalLimitCents,
        'annualFeeCents': annualFeeCents,
        'annualFeeIssueDate': annualFeeIssueDate,
        'currency': currency,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        if (fxMarkupBps != null) 'fxMarkupBps': fxMarkupBps,
      };

  factory CardProfile.fromJson(Map<String, dynamic> json) {
    return CardProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      totalLimitCents: json['totalLimitCents'] as int,
      annualFeeCents: json['annualFeeCents'] as int,
      annualFeeIssueDate: json['annualFeeIssueDate'] as String,
      currency: json['currency'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      fxMarkupBps: json['fxMarkupBps'] as int?,
    );
  }

  CardProfile copyWith({
    String? id,
    String? name,
    int? totalLimitCents,
    int? annualFeeCents,
    String? annualFeeIssueDate,
    String? currency,
    String? createdAt,
    String? updatedAt,
    int? fxMarkupBps,
  }) {
    return CardProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      totalLimitCents: totalLimitCents ?? this.totalLimitCents,
      annualFeeCents: annualFeeCents ?? this.annualFeeCents,
      annualFeeIssueDate: annualFeeIssueDate ?? this.annualFeeIssueDate,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fxMarkupBps: fxMarkupBps ?? this.fxMarkupBps,
    );
  }
}
