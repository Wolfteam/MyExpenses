import 'package:freezed_annotation/freezed_annotation.dart';

import 'category.dart';
import 'transaction.dart';

part 'app_file.freezed.dart';
part 'app_file.g.dart';

@freezed
class AppFile with _$AppFile {
  const factory AppFile({
    required List<Transaction> transactions,
    required List<Category> categories,
  }) = _AppFile;

  factory AppFile.fromJson(Map<String, dynamic> json) => _$AppFileFromJson(json);
}
