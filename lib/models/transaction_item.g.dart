// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionItem _$TransactionItemFromJson(Map<String, dynamic> json) {
  return TransactionItem(
    id: json['id'] as int,
    amount: (json['amount'] as num)?.toDouble(),
    description: json['description'] as String,
    transactionDate: json['transactionDate'] == null
        ? null
        : DateTime.parse(json['transactionDate'] as String),
    repetitionCycle: _$enumDecodeNullable(
        _$RepetitionCycleTypeEnumMap, json['repetitionCycle']),
    parentTransactionId: json['parentTransactionId'] as int,
    isParentTransaction: json['isParentTransaction'] as bool,
    nextRecurringDate: json['nextRecurringDate'] == null
        ? null
        : DateTime.parse(json['nextRecurringDate'] as String),
    imagePath: json['imagePath'] as String,
    category: json['category'] == null
        ? null
        : CategoryItem.fromJson(json['category'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TransactionItemToJson(TransactionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'description': instance.description,
      'transactionDate': instance.transactionDate?.toIso8601String(),
      'repetitionCycle': _$RepetitionCycleTypeEnumMap[instance.repetitionCycle],
      'parentTransactionId': instance.parentTransactionId,
      'isParentTransaction': instance.isParentTransaction,
      'nextRecurringDate': instance.nextRecurringDate?.toIso8601String(),
      'imagePath': instance.imagePath,
      'category': instance.category,
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
