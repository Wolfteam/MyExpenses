import 'package:drift/drift.dart';
import 'package:my_expenses/domain/enums/enums.dart';

class PaymentTypeConverter extends TypeConverter<PaymentMethodType, int> {
  const PaymentTypeConverter();

  @override
  PaymentMethodType fromSql(int fromDb) {
    return PaymentMethodType.values[fromDb];
  }

  @override
  int toSql(PaymentMethodType value) {
    return value.index;
  }
}
