import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import 'category.dart';
import 'transaction.dart';

part 'app_file.g.dart';

@JsonSerializable()
class AppFile extends Equatable {
  final List<Transaction> transactions;

  final List<Category> categories;

  @override
  List<Object> get props => [transactions, categories];

  const AppFile({
    @required this.transactions,
    @required this.categories,
  });

  factory AppFile.fromJson(Map<String, dynamic> json) =>
      _$AppFileFromJson(json);
  Map<String, dynamic> toJson() => _$AppFileToJson(this);
}
