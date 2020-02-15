import 'package:my_expenses/common/enums/repetition_cycle_type.dart';

String getRepetitionCycleTypeName(RepetitionCycleType type) {
  switch (type) {
    case RepetitionCycleType.none:
      return 'None';
    case RepetitionCycleType.eachDay:
      return 'Each Day';
    case RepetitionCycleType.eachWeek:
      return 'Each Week';
    case RepetitionCycleType.eachMonth:
      return 'Each Month';
    case RepetitionCycleType.eachYear:
      return 'Each Year';
    default:
      return 'N/A';
  }
}
