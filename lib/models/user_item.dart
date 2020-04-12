import 'package:equatable/equatable.dart';

class UserItem extends Equatable {
  final int id;
  final String googleUserId;
  final String name;
  final String email;
  final String pictureUrl;
  final bool isActive;

  @override
  List<Object> get props => [
        id,
        googleUserId,
        name,
        email,
        pictureUrl,
        isActive,
      ];

  const UserItem({
    this.id,
    this.googleUserId,
    this.name,
    this.email,
    this.pictureUrl,
    this.isActive,
  });

  UserItem copyWith({
    int id,
    String googleUserId,
    String name,
    String email,
    String pictureUrl,
    bool isActive,
  }) {
    return UserItem(
      id: id ?? this.id,
      email: email ?? this.email,
      googleUserId: googleUserId ?? this.googleUserId,
      isActive: isActive ?? this.isActive,
      name: name ?? this.name,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }
}
