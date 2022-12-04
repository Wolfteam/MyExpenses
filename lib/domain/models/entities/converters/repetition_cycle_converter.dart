import 'package:drift/drift.dart';
import 'package:my_expenses/domain/enums/enums.dart';

class RepetitionCycleConverter extends TypeConverter<RepetitionCycleType, int> {
  const RepetitionCycleConverter();

  @override
  RepetitionCycleType fromSql(int fromDb) {
    return RepetitionCycleType.values[fromDb];
  }

  @override
  int toSql(RepetitionCycleType value) {
    return value.index;
  }
}
