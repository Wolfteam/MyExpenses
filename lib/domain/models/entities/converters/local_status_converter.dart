import 'package:drift/drift.dart';
import 'package:my_expenses/domain/enums/enums.dart';

class LocalStatusConverter extends TypeConverter<LocalStatusType, int> {
  const LocalStatusConverter();

  @override
  LocalStatusType? mapToDart(int? fromDb) {
    return LocalStatusType.values[fromDb!];
  }

  @override
  int? mapToSql(LocalStatusType? value) {
    return value!.index;
  }
}
