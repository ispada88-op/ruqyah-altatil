// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalLimitMeta =
      const VerificationMeta('totalLimit');
  @override
  late final GeneratedColumn<int> totalLimit = GeneratedColumn<int>(
      'total_limit', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _annualFeeAmountMeta =
      const VerificationMeta('annualFeeAmount');
  @override
  late final GeneratedColumn<int> annualFeeAmount = GeneratedColumn<int>(
      'annual_fee_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _annualFeeIssueDateMeta =
      const VerificationMeta('annualFeeIssueDate');
  @override
  late final GeneratedColumn<String> annualFeeIssueDate =
      GeneratedColumn<String>('annual_fee_issue_date', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fxMarkupBpsMeta =
      const VerificationMeta('fxMarkupBps');
  @override
  late final GeneratedColumn<int> fxMarkupBps = GeneratedColumn<int>(
      'fx_markup_bps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        totalLimit,
        annualFeeAmount,
        annualFeeIssueDate,
        fxMarkupBps,
        currency,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(Insertable<Card> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('total_limit')) {
      context.handle(
          _totalLimitMeta,
          totalLimit.isAcceptableOrUnknown(
              data['total_limit']!, _totalLimitMeta));
    } else if (isInserting) {
      context.missing(_totalLimitMeta);
    }
    if (data.containsKey('annual_fee_amount')) {
      context.handle(
          _annualFeeAmountMeta,
          annualFeeAmount.isAcceptableOrUnknown(
              data['annual_fee_amount']!, _annualFeeAmountMeta));
    } else if (isInserting) {
      context.missing(_annualFeeAmountMeta);
    }
    if (data.containsKey('annual_fee_issue_date')) {
      context.handle(
          _annualFeeIssueDateMeta,
          annualFeeIssueDate.isAcceptableOrUnknown(
              data['annual_fee_issue_date']!, _annualFeeIssueDateMeta));
    } else if (isInserting) {
      context.missing(_annualFeeIssueDateMeta);
    }
    if (data.containsKey('fx_markup_bps')) {
      context.handle(
          _fxMarkupBpsMeta,
          fxMarkupBps.isAcceptableOrUnknown(
              data['fx_markup_bps']!, _fxMarkupBpsMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      totalLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_limit'])!,
      annualFeeAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}annual_fee_amount'])!,
      annualFeeIssueDate: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}annual_fee_issue_date'])!,
      fxMarkupBps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fx_markup_bps']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final String id;
  final String name;
  final int totalLimit;
  final int annualFeeAmount;
  final String annualFeeIssueDate;
  final int? fxMarkupBps;
  final String currency;
  final String createdAt;
  final String updatedAt;
  const Card(
      {required this.id,
      required this.name,
      required this.totalLimit,
      required this.annualFeeAmount,
      required this.annualFeeIssueDate,
      this.fxMarkupBps,
      required this.currency,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['total_limit'] = Variable<int>(totalLimit);
    map['annual_fee_amount'] = Variable<int>(annualFeeAmount);
    map['annual_fee_issue_date'] = Variable<String>(annualFeeIssueDate);
    if (!nullToAbsent || fxMarkupBps != null) {
      map['fx_markup_bps'] = Variable<int>(fxMarkupBps);
    }
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      name: Value(name),
      totalLimit: Value(totalLimit),
      annualFeeAmount: Value(annualFeeAmount),
      annualFeeIssueDate: Value(annualFeeIssueDate),
      fxMarkupBps: fxMarkupBps == null && nullToAbsent
          ? const Value.absent()
          : Value(fxMarkupBps),
      currency: Value(currency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Card.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      totalLimit: serializer.fromJson<int>(json['totalLimit']),
      annualFeeAmount: serializer.fromJson<int>(json['annualFeeAmount']),
      annualFeeIssueDate:
          serializer.fromJson<String>(json['annualFeeIssueDate']),
      fxMarkupBps: serializer.fromJson<int?>(json['fxMarkupBps']),
      currency: serializer.fromJson<String>(json['currency']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'totalLimit': serializer.toJson<int>(totalLimit),
      'annualFeeAmount': serializer.toJson<int>(annualFeeAmount),
      'annualFeeIssueDate': serializer.toJson<String>(annualFeeIssueDate),
      'fxMarkupBps': serializer.toJson<int?>(fxMarkupBps),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Card copyWith(
          {String? id,
          String? name,
          int? totalLimit,
          int? annualFeeAmount,
          String? annualFeeIssueDate,
          Value<int?> fxMarkupBps = const Value.absent(),
          String? currency,
          String? createdAt,
          String? updatedAt}) =>
      Card(
        id: id ?? this.id,
        name: name ?? this.name,
        totalLimit: totalLimit ?? this.totalLimit,
        annualFeeAmount: annualFeeAmount ?? this.annualFeeAmount,
        annualFeeIssueDate: annualFeeIssueDate ?? this.annualFeeIssueDate,
        fxMarkupBps: fxMarkupBps.present ? fxMarkupBps.value : this.fxMarkupBps,
        currency: currency ?? this.currency,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      totalLimit:
          data.totalLimit.present ? data.totalLimit.value : this.totalLimit,
      annualFeeAmount: data.annualFeeAmount.present
          ? data.annualFeeAmount.value
          : this.annualFeeAmount,
      annualFeeIssueDate: data.annualFeeIssueDate.present
          ? data.annualFeeIssueDate.value
          : this.annualFeeIssueDate,
      fxMarkupBps:
          data.fxMarkupBps.present ? data.fxMarkupBps.value : this.fxMarkupBps,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalLimit: $totalLimit, ')
          ..write('annualFeeAmount: $annualFeeAmount, ')
          ..write('annualFeeIssueDate: $annualFeeIssueDate, ')
          ..write('fxMarkupBps: $fxMarkupBps, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, totalLimit, annualFeeAmount,
      annualFeeIssueDate, fxMarkupBps, currency, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.name == this.name &&
          other.totalLimit == this.totalLimit &&
          other.annualFeeAmount == this.annualFeeAmount &&
          other.annualFeeIssueDate == this.annualFeeIssueDate &&
          other.fxMarkupBps == this.fxMarkupBps &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> totalLimit;
  final Value<int> annualFeeAmount;
  final Value<String> annualFeeIssueDate;
  final Value<int?> fxMarkupBps;
  final Value<String> currency;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.totalLimit = const Value.absent(),
    this.annualFeeAmount = const Value.absent(),
    this.annualFeeIssueDate = const Value.absent(),
    this.fxMarkupBps = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String name,
    required int totalLimit,
    required int annualFeeAmount,
    required String annualFeeIssueDate,
    this.fxMarkupBps = const Value.absent(),
    required String currency,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        totalLimit = Value(totalLimit),
        annualFeeAmount = Value(annualFeeAmount),
        annualFeeIssueDate = Value(annualFeeIssueDate),
        currency = Value(currency),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Card> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? totalLimit,
    Expression<int>? annualFeeAmount,
    Expression<String>? annualFeeIssueDate,
    Expression<int>? fxMarkupBps,
    Expression<String>? currency,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (totalLimit != null) 'total_limit': totalLimit,
      if (annualFeeAmount != null) 'annual_fee_amount': annualFeeAmount,
      if (annualFeeIssueDate != null)
        'annual_fee_issue_date': annualFeeIssueDate,
      if (fxMarkupBps != null) 'fx_markup_bps': fxMarkupBps,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? totalLimit,
      Value<int>? annualFeeAmount,
      Value<String>? annualFeeIssueDate,
      Value<int?>? fxMarkupBps,
      Value<String>? currency,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return CardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      totalLimit: totalLimit ?? this.totalLimit,
      annualFeeAmount: annualFeeAmount ?? this.annualFeeAmount,
      annualFeeIssueDate: annualFeeIssueDate ?? this.annualFeeIssueDate,
      fxMarkupBps: fxMarkupBps ?? this.fxMarkupBps,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (totalLimit.present) {
      map['total_limit'] = Variable<int>(totalLimit.value);
    }
    if (annualFeeAmount.present) {
      map['annual_fee_amount'] = Variable<int>(annualFeeAmount.value);
    }
    if (annualFeeIssueDate.present) {
      map['annual_fee_issue_date'] = Variable<String>(annualFeeIssueDate.value);
    }
    if (fxMarkupBps.present) {
      map['fx_markup_bps'] = Variable<int>(fxMarkupBps.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalLimit: $totalLimit, ')
          ..write('annualFeeAmount: $annualFeeAmount, ')
          ..write('annualFeeIssueDate: $annualFeeIssueDate, ')
          ..write('fxMarkupBps: $fxMarkupBps, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatementCyclesTable extends StatementCycles
    with TableInfo<$StatementCyclesTable, StatementCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatementCyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES cards (id) ON DELETE CASCADE'));
  static const VerificationMeta _statementDateMeta =
      const VerificationMeta('statementDate');
  @override
  late final GeneratedColumn<String> statementDate = GeneratedColumn<String>(
      'statement_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _graceDaysMeta =
      const VerificationMeta('graceDays');
  @override
  late final GeneratedColumn<int> graceDays = GeneratedColumn<int>(
      'grace_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _closingBalanceCentsMeta =
      const VerificationMeta('closingBalanceCents');
  @override
  late final GeneratedColumn<int> closingBalanceCents = GeneratedColumn<int>(
      'closing_balance_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _minPaymentPctMeta =
      const VerificationMeta('minPaymentPct');
  @override
  late final GeneratedColumn<int> minPaymentPct = GeneratedColumn<int>(
      'min_payment_pct', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _aprBpsMeta = const VerificationMeta('aprBps');
  @override
  late final GeneratedColumn<int> aprBps = GeneratedColumn<int>(
      'apr_bps', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cardId,
        statementDate,
        dueDate,
        graceDays,
        closingBalanceCents,
        minPaymentPct,
        aprBps,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statement_cycles';
  @override
  VerificationContext validateIntegrity(Insertable<StatementCycle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('statement_date')) {
      context.handle(
          _statementDateMeta,
          statementDate.isAcceptableOrUnknown(
              data['statement_date']!, _statementDateMeta));
    } else if (isInserting) {
      context.missing(_statementDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('grace_days')) {
      context.handle(_graceDaysMeta,
          graceDays.isAcceptableOrUnknown(data['grace_days']!, _graceDaysMeta));
    } else if (isInserting) {
      context.missing(_graceDaysMeta);
    }
    if (data.containsKey('closing_balance_cents')) {
      context.handle(
          _closingBalanceCentsMeta,
          closingBalanceCents.isAcceptableOrUnknown(
              data['closing_balance_cents']!, _closingBalanceCentsMeta));
    } else if (isInserting) {
      context.missing(_closingBalanceCentsMeta);
    }
    if (data.containsKey('min_payment_pct')) {
      context.handle(
          _minPaymentPctMeta,
          minPaymentPct.isAcceptableOrUnknown(
              data['min_payment_pct']!, _minPaymentPctMeta));
    } else if (isInserting) {
      context.missing(_minPaymentPctMeta);
    }
    if (data.containsKey('apr_bps')) {
      context.handle(_aprBpsMeta,
          aprBps.isAcceptableOrUnknown(data['apr_bps']!, _aprBpsMeta));
    } else if (isInserting) {
      context.missing(_aprBpsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatementCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatementCycle(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      statementDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statement_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date'])!,
      graceDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grace_days'])!,
      closingBalanceCents: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}closing_balance_cents'])!,
      minPaymentPct: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_payment_pct'])!,
      aprBps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}apr_bps'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StatementCyclesTable createAlias(String alias) {
    return $StatementCyclesTable(attachedDatabase, alias);
  }
}

class StatementCycle extends DataClass implements Insertable<StatementCycle> {
  final String id;
  final String cardId;
  final String statementDate;
  final String dueDate;
  final int graceDays;
  final int closingBalanceCents;
  final int minPaymentPct;
  final int aprBps;
  final String status;
  final String createdAt;
  final String updatedAt;
  const StatementCycle(
      {required this.id,
      required this.cardId,
      required this.statementDate,
      required this.dueDate,
      required this.graceDays,
      required this.closingBalanceCents,
      required this.minPaymentPct,
      required this.aprBps,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['statement_date'] = Variable<String>(statementDate);
    map['due_date'] = Variable<String>(dueDate);
    map['grace_days'] = Variable<int>(graceDays);
    map['closing_balance_cents'] = Variable<int>(closingBalanceCents);
    map['min_payment_pct'] = Variable<int>(minPaymentPct);
    map['apr_bps'] = Variable<int>(aprBps);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  StatementCyclesCompanion toCompanion(bool nullToAbsent) {
    return StatementCyclesCompanion(
      id: Value(id),
      cardId: Value(cardId),
      statementDate: Value(statementDate),
      dueDate: Value(dueDate),
      graceDays: Value(graceDays),
      closingBalanceCents: Value(closingBalanceCents),
      minPaymentPct: Value(minPaymentPct),
      aprBps: Value(aprBps),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StatementCycle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatementCycle(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      statementDate: serializer.fromJson<String>(json['statementDate']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      graceDays: serializer.fromJson<int>(json['graceDays']),
      closingBalanceCents:
          serializer.fromJson<int>(json['closingBalanceCents']),
      minPaymentPct: serializer.fromJson<int>(json['minPaymentPct']),
      aprBps: serializer.fromJson<int>(json['aprBps']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'statementDate': serializer.toJson<String>(statementDate),
      'dueDate': serializer.toJson<String>(dueDate),
      'graceDays': serializer.toJson<int>(graceDays),
      'closingBalanceCents': serializer.toJson<int>(closingBalanceCents),
      'minPaymentPct': serializer.toJson<int>(minPaymentPct),
      'aprBps': serializer.toJson<int>(aprBps),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  StatementCycle copyWith(
          {String? id,
          String? cardId,
          String? statementDate,
          String? dueDate,
          int? graceDays,
          int? closingBalanceCents,
          int? minPaymentPct,
          int? aprBps,
          String? status,
          String? createdAt,
          String? updatedAt}) =>
      StatementCycle(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        statementDate: statementDate ?? this.statementDate,
        dueDate: dueDate ?? this.dueDate,
        graceDays: graceDays ?? this.graceDays,
        closingBalanceCents: closingBalanceCents ?? this.closingBalanceCents,
        minPaymentPct: minPaymentPct ?? this.minPaymentPct,
        aprBps: aprBps ?? this.aprBps,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StatementCycle copyWithCompanion(StatementCyclesCompanion data) {
    return StatementCycle(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      statementDate: data.statementDate.present
          ? data.statementDate.value
          : this.statementDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      graceDays: data.graceDays.present ? data.graceDays.value : this.graceDays,
      closingBalanceCents: data.closingBalanceCents.present
          ? data.closingBalanceCents.value
          : this.closingBalanceCents,
      minPaymentPct: data.minPaymentPct.present
          ? data.minPaymentPct.value
          : this.minPaymentPct,
      aprBps: data.aprBps.present ? data.aprBps.value : this.aprBps,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatementCycle(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('statementDate: $statementDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('graceDays: $graceDays, ')
          ..write('closingBalanceCents: $closingBalanceCents, ')
          ..write('minPaymentPct: $minPaymentPct, ')
          ..write('aprBps: $aprBps, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cardId, statementDate, dueDate, graceDays,
      closingBalanceCents, minPaymentPct, aprBps, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatementCycle &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.statementDate == this.statementDate &&
          other.dueDate == this.dueDate &&
          other.graceDays == this.graceDays &&
          other.closingBalanceCents == this.closingBalanceCents &&
          other.minPaymentPct == this.minPaymentPct &&
          other.aprBps == this.aprBps &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StatementCyclesCompanion extends UpdateCompanion<StatementCycle> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<String> statementDate;
  final Value<String> dueDate;
  final Value<int> graceDays;
  final Value<int> closingBalanceCents;
  final Value<int> minPaymentPct;
  final Value<int> aprBps;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const StatementCyclesCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.statementDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.graceDays = const Value.absent(),
    this.closingBalanceCents = const Value.absent(),
    this.minPaymentPct = const Value.absent(),
    this.aprBps = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatementCyclesCompanion.insert({
    required String id,
    required String cardId,
    required String statementDate,
    required String dueDate,
    required int graceDays,
    required int closingBalanceCents,
    required int minPaymentPct,
    required int aprBps,
    required String status,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cardId = Value(cardId),
        statementDate = Value(statementDate),
        dueDate = Value(dueDate),
        graceDays = Value(graceDays),
        closingBalanceCents = Value(closingBalanceCents),
        minPaymentPct = Value(minPaymentPct),
        aprBps = Value(aprBps),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<StatementCycle> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<String>? statementDate,
    Expression<String>? dueDate,
    Expression<int>? graceDays,
    Expression<int>? closingBalanceCents,
    Expression<int>? minPaymentPct,
    Expression<int>? aprBps,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (statementDate != null) 'statement_date': statementDate,
      if (dueDate != null) 'due_date': dueDate,
      if (graceDays != null) 'grace_days': graceDays,
      if (closingBalanceCents != null)
        'closing_balance_cents': closingBalanceCents,
      if (minPaymentPct != null) 'min_payment_pct': minPaymentPct,
      if (aprBps != null) 'apr_bps': aprBps,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatementCyclesCompanion copyWith(
      {Value<String>? id,
      Value<String>? cardId,
      Value<String>? statementDate,
      Value<String>? dueDate,
      Value<int>? graceDays,
      Value<int>? closingBalanceCents,
      Value<int>? minPaymentPct,
      Value<int>? aprBps,
      Value<String>? status,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return StatementCyclesCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      statementDate: statementDate ?? this.statementDate,
      dueDate: dueDate ?? this.dueDate,
      graceDays: graceDays ?? this.graceDays,
      closingBalanceCents: closingBalanceCents ?? this.closingBalanceCents,
      minPaymentPct: minPaymentPct ?? this.minPaymentPct,
      aprBps: aprBps ?? this.aprBps,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (statementDate.present) {
      map['statement_date'] = Variable<String>(statementDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (graceDays.present) {
      map['grace_days'] = Variable<int>(graceDays.value);
    }
    if (closingBalanceCents.present) {
      map['closing_balance_cents'] = Variable<int>(closingBalanceCents.value);
    }
    if (minPaymentPct.present) {
      map['min_payment_pct'] = Variable<int>(minPaymentPct.value);
    }
    if (aprBps.present) {
      map['apr_bps'] = Variable<int>(aprBps.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatementCyclesCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('statementDate: $statementDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('graceDays: $graceDays, ')
          ..write('closingBalanceCents: $closingBalanceCents, ')
          ..write('minPaymentPct: $minPaymentPct, ')
          ..write('aprBps: $aprBps, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentPlansTable extends InstallmentPlans
    with TableInfo<$InstallmentPlansTable, InstallmentPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES cards (id) ON DELETE CASCADE'));
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<int> totalAmount = GeneratedColumn<int>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthlyPaymentMeta =
      const VerificationMeta('monthlyPayment');
  @override
  late final GeneratedColumn<int> monthlyPayment = GeneratedColumn<int>(
      'monthly_payment', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _remainingAmountMeta =
      const VerificationMeta('remainingAmount');
  @override
  late final GeneratedColumn<int> remainingAmount = GeneratedColumn<int>(
      'remaining_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _numInstallmentsMeta =
      const VerificationMeta('numInstallments');
  @override
  late final GeneratedColumn<int> numInstallments = GeneratedColumn<int>(
      'num_installments', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _remainingInstallmentsMeta =
      const VerificationMeta('remainingInstallments');
  @override
  late final GeneratedColumn<int> remainingInstallments = GeneratedColumn<int>(
      'remaining_installments', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<String> nextDueDate = GeneratedColumn<String>(
      'next_due_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cardId,
        totalAmount,
        monthlyPayment,
        remainingAmount,
        numInstallments,
        remainingInstallments,
        startDate,
        nextDueDate,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installment_plans';
  @override
  VerificationContext validateIntegrity(Insertable<InstallmentPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('monthly_payment')) {
      context.handle(
          _monthlyPaymentMeta,
          monthlyPayment.isAcceptableOrUnknown(
              data['monthly_payment']!, _monthlyPaymentMeta));
    } else if (isInserting) {
      context.missing(_monthlyPaymentMeta);
    }
    if (data.containsKey('remaining_amount')) {
      context.handle(
          _remainingAmountMeta,
          remainingAmount.isAcceptableOrUnknown(
              data['remaining_amount']!, _remainingAmountMeta));
    } else if (isInserting) {
      context.missing(_remainingAmountMeta);
    }
    if (data.containsKey('num_installments')) {
      context.handle(
          _numInstallmentsMeta,
          numInstallments.isAcceptableOrUnknown(
              data['num_installments']!, _numInstallmentsMeta));
    } else if (isInserting) {
      context.missing(_numInstallmentsMeta);
    }
    if (data.containsKey('remaining_installments')) {
      context.handle(
          _remainingInstallmentsMeta,
          remainingInstallments.isAcceptableOrUnknown(
              data['remaining_installments']!, _remainingInstallmentsMeta));
    } else if (isInserting) {
      context.missing(_remainingInstallmentsMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallmentPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallmentPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_amount'])!,
      monthlyPayment: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}monthly_payment'])!,
      remainingAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remaining_amount'])!,
      numInstallments: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}num_installments'])!,
      remainingInstallments: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}remaining_installments'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      nextDueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}next_due_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InstallmentPlansTable createAlias(String alias) {
    return $InstallmentPlansTable(attachedDatabase, alias);
  }
}

class InstallmentPlan extends DataClass implements Insertable<InstallmentPlan> {
  final String id;
  final String cardId;
  final int totalAmount;
  final int monthlyPayment;
  final int remainingAmount;
  final int numInstallments;
  final int remainingInstallments;
  final String startDate;
  final String nextDueDate;
  final String status;
  final String createdAt;
  final String updatedAt;
  const InstallmentPlan(
      {required this.id,
      required this.cardId,
      required this.totalAmount,
      required this.monthlyPayment,
      required this.remainingAmount,
      required this.numInstallments,
      required this.remainingInstallments,
      required this.startDate,
      required this.nextDueDate,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['total_amount'] = Variable<int>(totalAmount);
    map['monthly_payment'] = Variable<int>(monthlyPayment);
    map['remaining_amount'] = Variable<int>(remainingAmount);
    map['num_installments'] = Variable<int>(numInstallments);
    map['remaining_installments'] = Variable<int>(remainingInstallments);
    map['start_date'] = Variable<String>(startDate);
    map['next_due_date'] = Variable<String>(nextDueDate);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  InstallmentPlansCompanion toCompanion(bool nullToAbsent) {
    return InstallmentPlansCompanion(
      id: Value(id),
      cardId: Value(cardId),
      totalAmount: Value(totalAmount),
      monthlyPayment: Value(monthlyPayment),
      remainingAmount: Value(remainingAmount),
      numInstallments: Value(numInstallments),
      remainingInstallments: Value(remainingInstallments),
      startDate: Value(startDate),
      nextDueDate: Value(nextDueDate),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InstallmentPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallmentPlan(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      totalAmount: serializer.fromJson<int>(json['totalAmount']),
      monthlyPayment: serializer.fromJson<int>(json['monthlyPayment']),
      remainingAmount: serializer.fromJson<int>(json['remainingAmount']),
      numInstallments: serializer.fromJson<int>(json['numInstallments']),
      remainingInstallments:
          serializer.fromJson<int>(json['remainingInstallments']),
      startDate: serializer.fromJson<String>(json['startDate']),
      nextDueDate: serializer.fromJson<String>(json['nextDueDate']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'totalAmount': serializer.toJson<int>(totalAmount),
      'monthlyPayment': serializer.toJson<int>(monthlyPayment),
      'remainingAmount': serializer.toJson<int>(remainingAmount),
      'numInstallments': serializer.toJson<int>(numInstallments),
      'remainingInstallments': serializer.toJson<int>(remainingInstallments),
      'startDate': serializer.toJson<String>(startDate),
      'nextDueDate': serializer.toJson<String>(nextDueDate),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  InstallmentPlan copyWith(
          {String? id,
          String? cardId,
          int? totalAmount,
          int? monthlyPayment,
          int? remainingAmount,
          int? numInstallments,
          int? remainingInstallments,
          String? startDate,
          String? nextDueDate,
          String? status,
          String? createdAt,
          String? updatedAt}) =>
      InstallmentPlan(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        totalAmount: totalAmount ?? this.totalAmount,
        monthlyPayment: monthlyPayment ?? this.monthlyPayment,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        numInstallments: numInstallments ?? this.numInstallments,
        remainingInstallments:
            remainingInstallments ?? this.remainingInstallments,
        startDate: startDate ?? this.startDate,
        nextDueDate: nextDueDate ?? this.nextDueDate,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InstallmentPlan copyWithCompanion(InstallmentPlansCompanion data) {
    return InstallmentPlan(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      monthlyPayment: data.monthlyPayment.present
          ? data.monthlyPayment.value
          : this.monthlyPayment,
      remainingAmount: data.remainingAmount.present
          ? data.remainingAmount.value
          : this.remainingAmount,
      numInstallments: data.numInstallments.present
          ? data.numInstallments.value
          : this.numInstallments,
      remainingInstallments: data.remainingInstallments.present
          ? data.remainingInstallments.value
          : this.remainingInstallments,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentPlan(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('monthlyPayment: $monthlyPayment, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('numInstallments: $numInstallments, ')
          ..write('remainingInstallments: $remainingInstallments, ')
          ..write('startDate: $startDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cardId,
      totalAmount,
      monthlyPayment,
      remainingAmount,
      numInstallments,
      remainingInstallments,
      startDate,
      nextDueDate,
      status,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallmentPlan &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.totalAmount == this.totalAmount &&
          other.monthlyPayment == this.monthlyPayment &&
          other.remainingAmount == this.remainingAmount &&
          other.numInstallments == this.numInstallments &&
          other.remainingInstallments == this.remainingInstallments &&
          other.startDate == this.startDate &&
          other.nextDueDate == this.nextDueDate &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InstallmentPlansCompanion extends UpdateCompanion<InstallmentPlan> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<int> totalAmount;
  final Value<int> monthlyPayment;
  final Value<int> remainingAmount;
  final Value<int> numInstallments;
  final Value<int> remainingInstallments;
  final Value<String> startDate;
  final Value<String> nextDueDate;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const InstallmentPlansCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.monthlyPayment = const Value.absent(),
    this.remainingAmount = const Value.absent(),
    this.numInstallments = const Value.absent(),
    this.remainingInstallments = const Value.absent(),
    this.startDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentPlansCompanion.insert({
    required String id,
    required String cardId,
    required int totalAmount,
    required int monthlyPayment,
    required int remainingAmount,
    required int numInstallments,
    required int remainingInstallments,
    required String startDate,
    required String nextDueDate,
    required String status,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cardId = Value(cardId),
        totalAmount = Value(totalAmount),
        monthlyPayment = Value(monthlyPayment),
        remainingAmount = Value(remainingAmount),
        numInstallments = Value(numInstallments),
        remainingInstallments = Value(remainingInstallments),
        startDate = Value(startDate),
        nextDueDate = Value(nextDueDate),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<InstallmentPlan> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<int>? totalAmount,
    Expression<int>? monthlyPayment,
    Expression<int>? remainingAmount,
    Expression<int>? numInstallments,
    Expression<int>? remainingInstallments,
    Expression<String>? startDate,
    Expression<String>? nextDueDate,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (monthlyPayment != null) 'monthly_payment': monthlyPayment,
      if (remainingAmount != null) 'remaining_amount': remainingAmount,
      if (numInstallments != null) 'num_installments': numInstallments,
      if (remainingInstallments != null)
        'remaining_installments': remainingInstallments,
      if (startDate != null) 'start_date': startDate,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentPlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? cardId,
      Value<int>? totalAmount,
      Value<int>? monthlyPayment,
      Value<int>? remainingAmount,
      Value<int>? numInstallments,
      Value<int>? remainingInstallments,
      Value<String>? startDate,
      Value<String>? nextDueDate,
      Value<String>? status,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return InstallmentPlansCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      numInstallments: numInstallments ?? this.numInstallments,
      remainingInstallments:
          remainingInstallments ?? this.remainingInstallments,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<int>(totalAmount.value);
    }
    if (monthlyPayment.present) {
      map['monthly_payment'] = Variable<int>(monthlyPayment.value);
    }
    if (remainingAmount.present) {
      map['remaining_amount'] = Variable<int>(remainingAmount.value);
    }
    if (numInstallments.present) {
      map['num_installments'] = Variable<int>(numInstallments.value);
    }
    if (remainingInstallments.present) {
      map['remaining_installments'] =
          Variable<int>(remainingInstallments.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<String>(nextDueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentPlansCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('monthlyPayment: $monthlyPayment, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('numInstallments: $numInstallments, ')
          ..write('remainingInstallments: $remainingInstallments, ')
          ..write('startDate: $startDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $StatementCyclesTable statementCycles =
      $StatementCyclesTable(this);
  late final $InstallmentPlansTable installmentPlans =
      $InstallmentPlansTable(this);
  late final CardsDao cardsDao = CardsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cards, statementCycles, installmentPlans];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('cards',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('statement_cycles', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('cards',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('installment_plans', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  required String id,
  required String name,
  required int totalLimit,
  required int annualFeeAmount,
  required String annualFeeIssueDate,
  Value<int?> fxMarkupBps,
  required String currency,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> totalLimit,
  Value<int> annualFeeAmount,
  Value<String> annualFeeIssueDate,
  Value<int?> fxMarkupBps,
  Value<String> currency,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, Card> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StatementCyclesTable, List<StatementCycle>>
      _statementCyclesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.statementCycles,
              aliasName:
                  $_aliasNameGenerator(db.cards.id, db.statementCycles.cardId));

  $$StatementCyclesTableProcessedTableManager get statementCyclesRefs {
    final manager =
        $$StatementCyclesTableTableManager($_db, $_db.statementCycles)
            .filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_statementCyclesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InstallmentPlansTable, List<InstallmentPlan>>
      _installmentPlansRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.installmentPlans,
              aliasName: $_aliasNameGenerator(
                  db.cards.id, db.installmentPlans.cardId));

  $$InstallmentPlansTableProcessedTableManager get installmentPlansRefs {
    final manager =
        $$InstallmentPlansTableTableManager($_db, $_db.installmentPlans)
            .filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_installmentPlansRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalLimit => $composableBuilder(
      column: $table.totalLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get annualFeeAmount => $composableBuilder(
      column: $table.annualFeeAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get annualFeeIssueDate => $composableBuilder(
      column: $table.annualFeeIssueDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fxMarkupBps => $composableBuilder(
      column: $table.fxMarkupBps, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> statementCyclesRefs(
      Expression<bool> Function($$StatementCyclesTableFilterComposer f) f) {
    final $$StatementCyclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.statementCycles,
        getReferencedColumn: (t) => t.cardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StatementCyclesTableFilterComposer(
              $db: $db,
              $table: $db.statementCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> installmentPlansRefs(
      Expression<bool> Function($$InstallmentPlansTableFilterComposer f) f) {
    final $$InstallmentPlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.installmentPlans,
        getReferencedColumn: (t) => t.cardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstallmentPlansTableFilterComposer(
              $db: $db,
              $table: $db.installmentPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalLimit => $composableBuilder(
      column: $table.totalLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get annualFeeAmount => $composableBuilder(
      column: $table.annualFeeAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get annualFeeIssueDate => $composableBuilder(
      column: $table.annualFeeIssueDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fxMarkupBps => $composableBuilder(
      column: $table.fxMarkupBps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get totalLimit => $composableBuilder(
      column: $table.totalLimit, builder: (column) => column);

  GeneratedColumn<int> get annualFeeAmount => $composableBuilder(
      column: $table.annualFeeAmount, builder: (column) => column);

  GeneratedColumn<String> get annualFeeIssueDate => $composableBuilder(
      column: $table.annualFeeIssueDate, builder: (column) => column);

  GeneratedColumn<int> get fxMarkupBps => $composableBuilder(
      column: $table.fxMarkupBps, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> statementCyclesRefs<T extends Object>(
      Expression<T> Function($$StatementCyclesTableAnnotationComposer a) f) {
    final $$StatementCyclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.statementCycles,
        getReferencedColumn: (t) => t.cardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StatementCyclesTableAnnotationComposer(
              $db: $db,
              $table: $db.statementCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> installmentPlansRefs<T extends Object>(
      Expression<T> Function($$InstallmentPlansTableAnnotationComposer a) f) {
    final $$InstallmentPlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.installmentPlans,
        getReferencedColumn: (t) => t.cardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstallmentPlansTableAnnotationComposer(
              $db: $db,
              $table: $db.installmentPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardsTable,
    Card,
    $$CardsTableFilterComposer,
    $$CardsTableOrderingComposer,
    $$CardsTableAnnotationComposer,
    $$CardsTableCreateCompanionBuilder,
    $$CardsTableUpdateCompanionBuilder,
    (Card, $$CardsTableReferences),
    Card,
    PrefetchHooks Function(
        {bool statementCyclesRefs, bool installmentPlansRefs})> {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> totalLimit = const Value.absent(),
            Value<int> annualFeeAmount = const Value.absent(),
            Value<String> annualFeeIssueDate = const Value.absent(),
            Value<int?> fxMarkupBps = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardsCompanion(
            id: id,
            name: name,
            totalLimit: totalLimit,
            annualFeeAmount: annualFeeAmount,
            annualFeeIssueDate: annualFeeIssueDate,
            fxMarkupBps: fxMarkupBps,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int totalLimit,
            required int annualFeeAmount,
            required String annualFeeIssueDate,
            Value<int?> fxMarkupBps = const Value.absent(),
            required String currency,
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CardsCompanion.insert(
            id: id,
            name: name,
            totalLimit: totalLimit,
            annualFeeAmount: annualFeeAmount,
            annualFeeIssueDate: annualFeeIssueDate,
            fxMarkupBps: fxMarkupBps,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CardsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {statementCyclesRefs = false, installmentPlansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (statementCyclesRefs) db.statementCycles,
                if (installmentPlansRefs) db.installmentPlans
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (statementCyclesRefs)
                    await $_getPrefetchedData<Card, $CardsTable,
                            StatementCycle>(
                        currentTable: table,
                        referencedTable: $$CardsTableReferences
                            ._statementCyclesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CardsTableReferences(db, table, p0)
                                .statementCyclesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cardId == item.id),
                        typedResults: items),
                  if (installmentPlansRefs)
                    await $_getPrefetchedData<Card, $CardsTable,
                            InstallmentPlan>(
                        currentTable: table,
                        referencedTable: $$CardsTableReferences
                            ._installmentPlansRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CardsTableReferences(db, table, p0)
                                .installmentPlansRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cardId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardsTable,
    Card,
    $$CardsTableFilterComposer,
    $$CardsTableOrderingComposer,
    $$CardsTableAnnotationComposer,
    $$CardsTableCreateCompanionBuilder,
    $$CardsTableUpdateCompanionBuilder,
    (Card, $$CardsTableReferences),
    Card,
    PrefetchHooks Function(
        {bool statementCyclesRefs, bool installmentPlansRefs})>;
typedef $$StatementCyclesTableCreateCompanionBuilder = StatementCyclesCompanion
    Function({
  required String id,
  required String cardId,
  required String statementDate,
  required String dueDate,
  required int graceDays,
  required int closingBalanceCents,
  required int minPaymentPct,
  required int aprBps,
  required String status,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$StatementCyclesTableUpdateCompanionBuilder = StatementCyclesCompanion
    Function({
  Value<String> id,
  Value<String> cardId,
  Value<String> statementDate,
  Value<String> dueDate,
  Value<int> graceDays,
  Value<int> closingBalanceCents,
  Value<int> minPaymentPct,
  Value<int> aprBps,
  Value<String> status,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

final class $$StatementCyclesTableReferences extends BaseReferences<
    _$AppDatabase, $StatementCyclesTable, StatementCycle> {
  $$StatementCyclesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) => db.cards.createAlias(
      $_aliasNameGenerator(db.statementCycles.cardId, db.cards.id));

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardsTableTableManager($_db, $_db.cards)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StatementCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $StatementCyclesTable> {
  $$StatementCyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statementDate => $composableBuilder(
      column: $table.statementDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get graceDays => $composableBuilder(
      column: $table.graceDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get closingBalanceCents => $composableBuilder(
      column: $table.closingBalanceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minPaymentPct => $composableBuilder(
      column: $table.minPaymentPct, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aprBps => $composableBuilder(
      column: $table.aprBps, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableFilterComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StatementCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $StatementCyclesTable> {
  $$StatementCyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statementDate => $composableBuilder(
      column: $table.statementDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get graceDays => $composableBuilder(
      column: $table.graceDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get closingBalanceCents => $composableBuilder(
      column: $table.closingBalanceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minPaymentPct => $composableBuilder(
      column: $table.minPaymentPct,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aprBps => $composableBuilder(
      column: $table.aprBps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableOrderingComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StatementCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatementCyclesTable> {
  $$StatementCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get statementDate => $composableBuilder(
      column: $table.statementDate, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get graceDays =>
      $composableBuilder(column: $table.graceDays, builder: (column) => column);

  GeneratedColumn<int> get closingBalanceCents => $composableBuilder(
      column: $table.closingBalanceCents, builder: (column) => column);

  GeneratedColumn<int> get minPaymentPct => $composableBuilder(
      column: $table.minPaymentPct, builder: (column) => column);

  GeneratedColumn<int> get aprBps =>
      $composableBuilder(column: $table.aprBps, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableAnnotationComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StatementCyclesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StatementCyclesTable,
    StatementCycle,
    $$StatementCyclesTableFilterComposer,
    $$StatementCyclesTableOrderingComposer,
    $$StatementCyclesTableAnnotationComposer,
    $$StatementCyclesTableCreateCompanionBuilder,
    $$StatementCyclesTableUpdateCompanionBuilder,
    (StatementCycle, $$StatementCyclesTableReferences),
    StatementCycle,
    PrefetchHooks Function({bool cardId})> {
  $$StatementCyclesTableTableManager(
      _$AppDatabase db, $StatementCyclesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatementCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatementCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatementCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cardId = const Value.absent(),
            Value<String> statementDate = const Value.absent(),
            Value<String> dueDate = const Value.absent(),
            Value<int> graceDays = const Value.absent(),
            Value<int> closingBalanceCents = const Value.absent(),
            Value<int> minPaymentPct = const Value.absent(),
            Value<int> aprBps = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StatementCyclesCompanion(
            id: id,
            cardId: cardId,
            statementDate: statementDate,
            dueDate: dueDate,
            graceDays: graceDays,
            closingBalanceCents: closingBalanceCents,
            minPaymentPct: minPaymentPct,
            aprBps: aprBps,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cardId,
            required String statementDate,
            required String dueDate,
            required int graceDays,
            required int closingBalanceCents,
            required int minPaymentPct,
            required int aprBps,
            required String status,
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StatementCyclesCompanion.insert(
            id: id,
            cardId: cardId,
            statementDate: statementDate,
            dueDate: dueDate,
            graceDays: graceDays,
            closingBalanceCents: closingBalanceCents,
            minPaymentPct: minPaymentPct,
            aprBps: aprBps,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StatementCyclesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (cardId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cardId,
                    referencedTable:
                        $$StatementCyclesTableReferences._cardIdTable(db),
                    referencedColumn:
                        $$StatementCyclesTableReferences._cardIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StatementCyclesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StatementCyclesTable,
    StatementCycle,
    $$StatementCyclesTableFilterComposer,
    $$StatementCyclesTableOrderingComposer,
    $$StatementCyclesTableAnnotationComposer,
    $$StatementCyclesTableCreateCompanionBuilder,
    $$StatementCyclesTableUpdateCompanionBuilder,
    (StatementCycle, $$StatementCyclesTableReferences),
    StatementCycle,
    PrefetchHooks Function({bool cardId})>;
typedef $$InstallmentPlansTableCreateCompanionBuilder
    = InstallmentPlansCompanion Function({
  required String id,
  required String cardId,
  required int totalAmount,
  required int monthlyPayment,
  required int remainingAmount,
  required int numInstallments,
  required int remainingInstallments,
  required String startDate,
  required String nextDueDate,
  required String status,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$InstallmentPlansTableUpdateCompanionBuilder
    = InstallmentPlansCompanion Function({
  Value<String> id,
  Value<String> cardId,
  Value<int> totalAmount,
  Value<int> monthlyPayment,
  Value<int> remainingAmount,
  Value<int> numInstallments,
  Value<int> remainingInstallments,
  Value<String> startDate,
  Value<String> nextDueDate,
  Value<String> status,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

final class $$InstallmentPlansTableReferences extends BaseReferences<
    _$AppDatabase, $InstallmentPlansTable, InstallmentPlan> {
  $$InstallmentPlansTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) => db.cards.createAlias(
      $_aliasNameGenerator(db.installmentPlans.cardId, db.cards.id));

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardsTableTableManager($_db, $_db.cards)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InstallmentPlansTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTable> {
  $$InstallmentPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlyPayment => $composableBuilder(
      column: $table.monthlyPayment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numInstallments => $composableBuilder(
      column: $table.numInstallments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remainingInstallments => $composableBuilder(
      column: $table.remainingInstallments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableFilterComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstallmentPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTable> {
  $$InstallmentPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlyPayment => $composableBuilder(
      column: $table.monthlyPayment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numInstallments => $composableBuilder(
      column: $table.numInstallments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remainingInstallments => $composableBuilder(
      column: $table.remainingInstallments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableOrderingComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstallmentPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentPlansTable> {
  $$InstallmentPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<int> get monthlyPayment => $composableBuilder(
      column: $table.monthlyPayment, builder: (column) => column);

  GeneratedColumn<int> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount, builder: (column) => column);

  GeneratedColumn<int> get numInstallments => $composableBuilder(
      column: $table.numInstallments, builder: (column) => column);

  GeneratedColumn<int> get remainingInstallments => $composableBuilder(
      column: $table.remainingInstallments, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableAnnotationComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstallmentPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstallmentPlansTable,
    InstallmentPlan,
    $$InstallmentPlansTableFilterComposer,
    $$InstallmentPlansTableOrderingComposer,
    $$InstallmentPlansTableAnnotationComposer,
    $$InstallmentPlansTableCreateCompanionBuilder,
    $$InstallmentPlansTableUpdateCompanionBuilder,
    (InstallmentPlan, $$InstallmentPlansTableReferences),
    InstallmentPlan,
    PrefetchHooks Function({bool cardId})> {
  $$InstallmentPlansTableTableManager(
      _$AppDatabase db, $InstallmentPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallmentPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstallmentPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cardId = const Value.absent(),
            Value<int> totalAmount = const Value.absent(),
            Value<int> monthlyPayment = const Value.absent(),
            Value<int> remainingAmount = const Value.absent(),
            Value<int> numInstallments = const Value.absent(),
            Value<int> remainingInstallments = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<String> nextDueDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentPlansCompanion(
            id: id,
            cardId: cardId,
            totalAmount: totalAmount,
            monthlyPayment: monthlyPayment,
            remainingAmount: remainingAmount,
            numInstallments: numInstallments,
            remainingInstallments: remainingInstallments,
            startDate: startDate,
            nextDueDate: nextDueDate,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cardId,
            required int totalAmount,
            required int monthlyPayment,
            required int remainingAmount,
            required int numInstallments,
            required int remainingInstallments,
            required String startDate,
            required String nextDueDate,
            required String status,
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InstallmentPlansCompanion.insert(
            id: id,
            cardId: cardId,
            totalAmount: totalAmount,
            monthlyPayment: monthlyPayment,
            remainingAmount: remainingAmount,
            numInstallments: numInstallments,
            remainingInstallments: remainingInstallments,
            startDate: startDate,
            nextDueDate: nextDueDate,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InstallmentPlansTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (cardId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cardId,
                    referencedTable:
                        $$InstallmentPlansTableReferences._cardIdTable(db),
                    referencedColumn:
                        $$InstallmentPlansTableReferences._cardIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InstallmentPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InstallmentPlansTable,
    InstallmentPlan,
    $$InstallmentPlansTableFilterComposer,
    $$InstallmentPlansTableOrderingComposer,
    $$InstallmentPlansTableAnnotationComposer,
    $$InstallmentPlansTableCreateCompanionBuilder,
    $$InstallmentPlansTableUpdateCompanionBuilder,
    (InstallmentPlan, $$InstallmentPlansTableReferences),
    InstallmentPlan,
    PrefetchHooks Function({bool cardId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$StatementCyclesTableTableManager get statementCycles =>
      $$StatementCyclesTableTableManager(_db, _db.statementCycles);
  $$InstallmentPlansTableTableManager get installmentPlans =>
      $$InstallmentPlansTableTableManager(_db, _db.installmentPlans);
}

mixin _$CardsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardsTable get cards => attachedDatabase.cards;
  $StatementCyclesTable get statementCycles => attachedDatabase.statementCycles;
  CardsDaoManager get managers => CardsDaoManager(this);
}

class CardsDaoManager {
  final _$CardsDaoMixin _db;
  CardsDaoManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
  $$StatementCyclesTableTableManager get statementCycles =>
      $$StatementCyclesTableTableManager(
          _db.attachedDatabase, _db.statementCycles);
}
