import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_item.freezed.dart';

@freezed
class UserItem with _$UserItem {
  const factory UserItem({
    required int id,
    required String googleUserId,
    required String name,
    required String email,
    String? pictureUrl,
    required bool isActive,
  }) = _UserItem;
}
