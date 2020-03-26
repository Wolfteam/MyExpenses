// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    amount: (json['amount'] as num)?.toDouble(),
    description: json['description'] as String,
    transactionDate: json['transactionDate'] == null
        ? null
        : DateTime.parse(json['transactionDate'] as String),
    repetitionCycle: _$enumDecodeNullable(
        _$RepetitionCycleTypeEnumMap, json['repetitionCycle']),
    parentTransactionCreatedHash:
        json['parentTransactionCreatedHash'] as String,
    isParentTransaction: json['isParentTransaction'] as bool,
    nextRecurringDate: json['nextRecurringDate'] == null
        ? null
        : DateTime.parse(json['nextRecurringDate'] as String),
    imagePath: json['imagePath'] as String,
    categoryCreatedHash: json['categoryCreatedHash'] as String,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    createdBy: json['createdBy'] as String,
    createdHash: json['createdHash'] as String,
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    updatedBy: json['updatedBy'] as String,
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'description': instance.description,
      'transactionDate': instance.transactionDate?.toIso8601String(),
      'repetitionCycle': _$RepetitionCycleTypeEnumMap[instance.repetitionCycle],
      'parentTransactionCreatedHash': instance.parentTransactionCreatedHash,
      'isParentTransaction': instance.isParentTransaction,
      'nextRecurringDate': instance.nextRecurringDate?.toIso8601String(),
      'imagePath': instance.imagePath,
      'categoryCreatedHash': instance.categoryCreatedHash,
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'createdHash': instance.createdHash,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$RepetitionCycleTypeEnumMap = {
  RepetitionCycleType.none: 'none',
  RepetitionCycleType.eachDay: 'eachDay',
  RepetitionCycleType.eachWeek: 'eachWeek',
  RepetitionCycleType.eachMonth: 'eachMonth',
  RepetitionCycleType.biweekly: 'biweekly',
  RepetitionCycleType.eachYear: 'eachYear',
};
