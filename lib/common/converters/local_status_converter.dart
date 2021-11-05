import 'package:drift/drift.dart';

import '../enums/local_status_type.dart';

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
