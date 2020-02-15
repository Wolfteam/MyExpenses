import 'package:moor/moor.dart';
import 'package:my_expenses/common/enums/repetition_cycle_type.dart';

class RepetitionCycleConverter extends TypeConverter<RepetitionCycleType, int> {
  const RepetitionCycleConverter();

  @override
  RepetitionCycleType mapToDart(int fromDb) {
    return RepetitionCycleType.values[fromDb];
  }

  @override
  int mapToSql(RepetitionCycleType value) {
    return value.index;
  }
}
