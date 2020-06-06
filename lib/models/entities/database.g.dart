// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class User extends DataClass implements Insertable<User> {
  final int id;
  final LocalStatusType localStatus;
  final DateTime createdAt;
  final String createdBy;
  final String createdHash;
  final DateTime updatedAt;
  final String updatedBy;
  final String googleUserId;
  final String name;
  final String email;
  final String pictureUrl;
  final bool isActive;
  User(
      {@required this.id,
      @required this.localStatus,
      @required this.createdAt,
      @required this.createdBy,
      @required this.createdHash,
      this.updatedAt,
      this.updatedBy,
      @required this.googleUserId,
      @required this.name,
      @required this.email,
      this.pictureUrl,
      @required this.isActive});
  factory User.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return User(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      localStatus: $UsersTable.$converter0.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}local_status'])),
      createdAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_at']),
      createdBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
      createdHash: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_hash']),
      updatedAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_at']),
      updatedBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_by']),
      googleUserId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}google_user_id']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      email:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}email']),
      pictureUrl: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}picture_url']),
      isActive:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}is_active']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || localStatus != null) {
      final converter = $UsersTable.$converter0;
      map['local_status'] = Variable<int>(converter.mapToSql(localStatus));
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdHash != null) {
      map['created_hash'] = Variable<String>(createdHash);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || googleUserId != null) {
      map['google_user_id'] = Variable<String>(googleUserId);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || pictureUrl != null) {
      map['picture_url'] = Variable<String>(pictureUrl);
    }
    if (!nullToAbsent || isActive != null) {
      map['is_active'] = Variable<bool>(isActive);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      localStatus: localStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(localStatus),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdHash: createdHash == null && nullToAbsent
          ? const Value.absent()
          : Value(createdHash),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      googleUserId: googleUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(googleUserId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      pictureUrl: pictureUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pictureUrl),
      isActive: isActive == null && nullToAbsent
          ? const Value.absent()
          : Value(isActive),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      localStatus: serializer.fromJson<LocalStatusType>(json['localStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdHash: serializer.fromJson<String>(json['createdHash']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      googleUserId: serializer.fromJson<String>(json['googleUserId']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      pictureUrl: serializer.fromJson<String>(json['pictureUrl']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localStatus': serializer.toJson<LocalStatusType>(localStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdHash': serializer.toJson<String>(createdHash),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'googleUserId': serializer.toJson<String>(googleUserId),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'pictureUrl': serializer.toJson<String>(pictureUrl),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  User copyWith(
          {int id,
          LocalStatusType localStatus,
          DateTime createdAt,
          String createdBy,
          String createdHash,
          DateTime updatedAt,
          String updatedBy,
          String googleUserId,
          String name,
          String email,
          String pictureUrl,
          bool isActive}) =>
      User(
        id: id ?? this.id,
        localStatus: localStatus ?? this.localStatus,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        createdHash: createdHash ?? this.createdHash,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        googleUserId: googleUserId ?? this.googleUserId,
        name: name ?? this.name,
        email: email ?? this.email,
        pictureUrl: pictureUrl ?? this.pictureUrl,
        isActive: isActive ?? this.isActive,
      );
  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('localStatus: $localStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdHash: $createdHash, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('googleUserId: $googleUserId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('pictureUrl: $pictureUrl, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          localStatus.hashCode,
          $mrjc(
              createdAt.hashCode,
              $mrjc(
                  createdBy.hashCode,
                  $mrjc(
                      createdHash.hashCode,
                      $mrjc(
                          updatedAt.hashCode,
                          $mrjc(
                              updatedBy.hashCode,
                              $mrjc(
                                  googleUserId.hashCode,
                                  $mrjc(
                                      name.hashCode,
                                      $mrjc(
                                          email.hashCode,
                                          $mrjc(pictureUrl.hashCode,
                                              isActive.hashCode))))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.localStatus == this.localStatus &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.createdHash == this.createdHash &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.googleUserId == this.googleUserId &&
          other.name == this.name &&
          other.email == this.email &&
          other.pictureUrl == this.pictureUrl &&
          other.isActive == this.isActive);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<LocalStatusType> localStatus;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<String> createdHash;
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<String> googleUserId;
  final Value<String> name;
  final Value<String> email;
  final Value<String> pictureUrl;
  final Value<bool> isActive;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.localStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdHash = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.googleUserId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.pictureUrl = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    @required LocalStatusType localStatus,
    @required DateTime createdAt,
    @required String createdBy,
    @required String createdHash,
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    @required String googleUserId,
    @required String name,
    @required String email,
    this.pictureUrl = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : localStatus = Value(localStatus),
        createdAt = Value(createdAt),
        createdBy = Value(createdBy),
        createdHash = Value(createdHash),
        googleUserId = Value(googleUserId),
        name = Value(name),
        email = Value(email);
  static Insertable<User> custom({
    Expression<int> id,
    Expression<int> localStatus,
    Expression<DateTime> createdAt,
    Expression<String> createdBy,
    Expression<String> createdHash,
    Expression<DateTime> updatedAt,
    Expression<String> updatedBy,
    Expression<String> googleUserId,
    Expression<String> name,
    Expression<String> email,
    Expression<String> pictureUrl,
    Expression<bool> isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localStatus != null) 'local_status': localStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdHash != null) 'created_hash': createdHash,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (googleUserId != null) 'google_user_id': googleUserId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (pictureUrl != null) 'picture_url': pictureUrl,
      if (isActive != null) 'is_active': isActive,
    });
  }

  UsersCompanion copyWith(
      {Value<int> id,
      Value<LocalStatusType> localStatus,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<String> createdHash,
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<String> googleUserId,
      Value<String> name,
      Value<String> email,
      Value<String> pictureUrl,
      Value<bool> isActive}) {
    return UsersCompanion(
      id: id ?? this.id,
      localStatus: localStatus ?? this.localStatus,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      createdHash: createdHash ?? this.createdHash,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      googleUserId: googleUserId ?? this.googleUserId,
      name: name ?? this.name,
      email: email ?? this.email,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localStatus.present) {
      final converter = $UsersTable.$converter0;
      map['local_status'] =
          Variable<int>(converter.mapToSql(localStatus.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdHash.present) {
      map['created_hash'] = Variable<String>(createdHash.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (googleUserId.present) {
      map['google_user_id'] = Variable<String>(googleUserId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (pictureUrl.present) {
      map['picture_url'] = Variable<String>(pictureUrl.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  final GeneratedDatabase _db;
  final String _alias;
  $UsersTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _localStatusMeta =
      const VerificationMeta('localStatus');
  GeneratedIntColumn _localStatus;
  @override
  GeneratedIntColumn get localStatus =>
      _localStatus ??= _constructLocalStatus();
  GeneratedIntColumn _constructLocalStatus() {
    return GeneratedIntColumn(
      'local_status',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  GeneratedDateTimeColumn _createdAt;
  @override
  GeneratedDateTimeColumn get createdAt => _createdAt ??= _constructCreatedAt();
  GeneratedDateTimeColumn _constructCreatedAt() {
    return GeneratedDateTimeColumn(
      'created_at',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  GeneratedTextColumn _createdBy;
  @override
  GeneratedTextColumn get createdBy => _createdBy ??= _constructCreatedBy();
  GeneratedTextColumn _constructCreatedBy() {
    return GeneratedTextColumn('created_by', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _createdHashMeta =
      const VerificationMeta('createdHash');
  GeneratedTextColumn _createdHash;
  @override
  GeneratedTextColumn get createdHash =>
      _createdHash ??= _constructCreatedHash();
  GeneratedTextColumn _constructCreatedHash() {
    return GeneratedTextColumn(
      'created_hash',
      $tableName,
      false,
    );
  }

  final VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  GeneratedDateTimeColumn _updatedAt;
  @override
  GeneratedDateTimeColumn get updatedAt => _updatedAt ??= _constructUpdatedAt();
  GeneratedDateTimeColumn _constructUpdatedAt() {
    return GeneratedDateTimeColumn(
      'updated_at',
      $tableName,
      true,
    );
  }

  final VerificationMeta _updatedByMeta = const VerificationMeta('updatedBy');
  GeneratedTextColumn _updatedBy;
  @override
  GeneratedTextColumn get updatedBy => _updatedBy ??= _constructUpdatedBy();
  GeneratedTextColumn _constructUpdatedBy() {
    return GeneratedTextColumn('updated_by', $tableName, true,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _googleUserIdMeta =
      const VerificationMeta('googleUserId');
  GeneratedTextColumn _googleUserId;
  @override
  GeneratedTextColumn get googleUserId =>
      _googleUserId ??= _constructGoogleUserId();
  GeneratedTextColumn _constructGoogleUserId() {
    return GeneratedTextColumn(
      'google_user_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  GeneratedTextColumn _name;
  @override
  GeneratedTextColumn get name => _name ??= _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false,
        minTextLength: 1, maxTextLength: 255);
  }

  final VerificationMeta _emailMeta = const VerificationMeta('email');
  GeneratedTextColumn _email;
  @override
  GeneratedTextColumn get email => _email ??= _constructEmail();
  GeneratedTextColumn _constructEmail() {
    return GeneratedTextColumn('email', $tableName, false,
        minTextLength: 1, maxTextLength: 255);
  }

  final VerificationMeta _pictureUrlMeta = const VerificationMeta('pictureUrl');
  GeneratedTextColumn _pictureUrl;
  @override
  GeneratedTextColumn get pictureUrl => _pictureUrl ??= _constructPictureUrl();
  GeneratedTextColumn _constructPictureUrl() {
    return GeneratedTextColumn(
      'picture_url',
      $tableName,
      true,
    );
  }

  final VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  GeneratedBoolColumn _isActive;
  @override
  GeneratedBoolColumn get isActive => _isActive ??= _constructIsActive();
  GeneratedBoolColumn _constructIsActive() {
    return GeneratedBoolColumn('is_active', $tableName, false,
        defaultValue: const Constant(true));
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        localStatus,
        createdAt,
        createdBy,
        createdHash,
        updatedAt,
        updatedBy,
        googleUserId,
        name,
        email,
        pictureUrl,
        isActive
      ];
  @override
  $UsersTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'users';
  @override
  final String actualTableName = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    context.handle(_localStatusMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at'], _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by'], _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_hash')) {
      context.handle(
          _createdHashMeta,
          createdHash.isAcceptableOrUnknown(
              data['created_hash'], _createdHashMeta));
    } else if (isInserting) {
      context.missing(_createdHashMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at'], _updatedAtMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by'], _updatedByMeta));
    }
    if (data.containsKey('google_user_id')) {
      context.handle(
          _googleUserIdMeta,
          googleUserId.isAcceptableOrUnknown(
              data['google_user_id'], _googleUserIdMeta));
    } else if (isInserting) {
      context.missing(_googleUserIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email'], _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('picture_url')) {
      context.handle(
          _pictureUrlMeta,
          pictureUrl.isAcceptableOrUnknown(
              data['picture_url'], _pictureUrlMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active'], _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return User.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(_db, alias);
  }

  static TypeConverter<LocalStatusType, int> $converter0 =
      const LocalStatusConverter();
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final LocalStatusType localStatus;
  final DateTime createdAt;
  final String createdBy;
  final String createdHash;
  final DateTime updatedAt;
  final String updatedBy;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final RepetitionCycleType repetitionCycle;
  final int parentTransactionId;
  final bool isParentTransaction;
  final DateTime nextRecurringDate;
  final String imagePath;
  final int categoryId;
  Transaction(
      {@required this.id,
      @required this.localStatus,
      @required this.createdAt,
      @required this.createdBy,
      @required this.createdHash,
      this.updatedAt,
      this.updatedBy,
      @required this.amount,
      @required this.description,
      @required this.transactionDate,
      @required this.repetitionCycle,
      this.parentTransactionId,
      @required this.isParentTransaction,
      this.nextRecurringDate,
      this.imagePath,
      @required this.categoryId});
  factory Transaction.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Transaction(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      localStatus: $TransactionsTable.$converter0.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}local_status'])),
      createdAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_at']),
      createdBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
      createdHash: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_hash']),
      updatedAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_at']),
      updatedBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_by']),
      amount:
          doubleType.mapFromDatabaseResponse(data['${effectivePrefix}amount']),
      description: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}description']),
      transactionDate: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}transaction_date']),
      repetitionCycle: $TransactionsTable.$converter1.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}repetition_cycle'])),
      parentTransactionId: intType.mapFromDatabaseResponse(
          data['${effectivePrefix}parent_transaction_id']),
      isParentTransaction: boolType.mapFromDatabaseResponse(
          data['${effectivePrefix}is_parent_transaction']),
      nextRecurringDate: dateTimeType.mapFromDatabaseResponse(
          data['${effectivePrefix}next_recurring_date']),
      imagePath: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}image_path']),
      categoryId: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}category_id']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || localStatus != null) {
      final converter = $TransactionsTable.$converter0;
      map['local_status'] = Variable<int>(converter.mapToSql(localStatus));
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdHash != null) {
      map['created_hash'] = Variable<String>(createdHash);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || transactionDate != null) {
      map['transaction_date'] = Variable<DateTime>(transactionDate);
    }
    if (!nullToAbsent || repetitionCycle != null) {
      final converter = $TransactionsTable.$converter1;
      map['repetition_cycle'] =
          Variable<int>(converter.mapToSql(repetitionCycle));
    }
    if (!nullToAbsent || parentTransactionId != null) {
      map['parent_transaction_id'] = Variable<int>(parentTransactionId);
    }
    if (!nullToAbsent || isParentTransaction != null) {
      map['is_parent_transaction'] = Variable<bool>(isParentTransaction);
    }
    if (!nullToAbsent || nextRecurringDate != null) {
      map['next_recurring_date'] = Variable<DateTime>(nextRecurringDate);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      localStatus: localStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(localStatus),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdHash: createdHash == null && nullToAbsent
          ? const Value.absent()
          : Value(createdHash),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      transactionDate: transactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDate),
      repetitionCycle: repetitionCycle == null && nullToAbsent
          ? const Value.absent()
          : Value(repetitionCycle),
      parentTransactionId: parentTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTransactionId),
      isParentTransaction: isParentTransaction == null && nullToAbsent
          ? const Value.absent()
          : Value(isParentTransaction),
      nextRecurringDate: nextRecurringDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRecurringDate),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      localStatus: serializer.fromJson<LocalStatusType>(json['localStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdHash: serializer.fromJson<String>(json['createdHash']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      repetitionCycle:
          serializer.fromJson<RepetitionCycleType>(json['repetitionCycle']),
      parentTransactionId:
          serializer.fromJson<int>(json['parentTransactionId']),
      isParentTransaction:
          serializer.fromJson<bool>(json['isParentTransaction']),
      nextRecurringDate:
          serializer.fromJson<DateTime>(json['nextRecurringDate']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localStatus': serializer.toJson<LocalStatusType>(localStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdHash': serializer.toJson<String>(createdHash),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'repetitionCycle':
          serializer.toJson<RepetitionCycleType>(repetitionCycle),
      'parentTransactionId': serializer.toJson<int>(parentTransactionId),
      'isParentTransaction': serializer.toJson<bool>(isParentTransaction),
      'nextRecurringDate': serializer.toJson<DateTime>(nextRecurringDate),
      'imagePath': serializer.toJson<String>(imagePath),
      'categoryId': serializer.toJson<int>(categoryId),
    };
  }

  Transaction copyWith(
          {int id,
          LocalStatusType localStatus,
          DateTime createdAt,
          String createdBy,
          String createdHash,
          DateTime updatedAt,
          String updatedBy,
          double amount,
          String description,
          DateTime transactionDate,
          RepetitionCycleType repetitionCycle,
          int parentTransactionId,
          bool isParentTransaction,
          DateTime nextRecurringDate,
          String imagePath,
          int categoryId}) =>
      Transaction(
        id: id ?? this.id,
        localStatus: localStatus ?? this.localStatus,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        createdHash: createdHash ?? this.createdHash,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        transactionDate: transactionDate ?? this.transactionDate,
        repetitionCycle: repetitionCycle ?? this.repetitionCycle,
        parentTransactionId: parentTransactionId ?? this.parentTransactionId,
        isParentTransaction: isParentTransaction ?? this.isParentTransaction,
        nextRecurringDate: nextRecurringDate ?? this.nextRecurringDate,
        imagePath: imagePath ?? this.imagePath,
        categoryId: categoryId ?? this.categoryId,
      );
  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('localStatus: $localStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdHash: $createdHash, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('repetitionCycle: $repetitionCycle, ')
          ..write('parentTransactionId: $parentTransactionId, ')
          ..write('isParentTransaction: $isParentTransaction, ')
          ..write('nextRecurringDate: $nextRecurringDate, ')
          ..write('imagePath: $imagePath, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          localStatus.hashCode,
          $mrjc(
              createdAt.hashCode,
              $mrjc(
                  createdBy.hashCode,
                  $mrjc(
                      createdHash.hashCode,
                      $mrjc(
                          updatedAt.hashCode,
                          $mrjc(
                              updatedBy.hashCode,
                              $mrjc(
                                  amount.hashCode,
                                  $mrjc(
                                      description.hashCode,
                                      $mrjc(
                                          transactionDate.hashCode,
                                          $mrjc(
                                              repetitionCycle.hashCode,
                                              $mrjc(
                                                  parentTransactionId.hashCode,
                                                  $mrjc(
                                                      isParentTransaction
                                                          .hashCode,
                                                      $mrjc(
                                                          nextRecurringDate
                                                              .hashCode,
                                                          $mrjc(
                                                              imagePath
                                                                  .hashCode,
                                                              categoryId
                                                                  .hashCode))))))))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.localStatus == this.localStatus &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.createdHash == this.createdHash &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.transactionDate == this.transactionDate &&
          other.repetitionCycle == this.repetitionCycle &&
          other.parentTransactionId == this.parentTransactionId &&
          other.isParentTransaction == this.isParentTransaction &&
          other.nextRecurringDate == this.nextRecurringDate &&
          other.imagePath == this.imagePath &&
          other.categoryId == this.categoryId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<LocalStatusType> localStatus;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<String> createdHash;
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<double> amount;
  final Value<String> description;
  final Value<DateTime> transactionDate;
  final Value<RepetitionCycleType> repetitionCycle;
  final Value<int> parentTransactionId;
  final Value<bool> isParentTransaction;
  final Value<DateTime> nextRecurringDate;
  final Value<String> imagePath;
  final Value<int> categoryId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.localStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdHash = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.repetitionCycle = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
    this.isParentTransaction = const Value.absent(),
    this.nextRecurringDate = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.categoryId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    @required LocalStatusType localStatus,
    @required DateTime createdAt,
    @required String createdBy,
    @required String createdHash,
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    @required double amount,
    @required String description,
    @required DateTime transactionDate,
    @required RepetitionCycleType repetitionCycle,
    this.parentTransactionId = const Value.absent(),
    @required bool isParentTransaction,
    this.nextRecurringDate = const Value.absent(),
    this.imagePath = const Value.absent(),
    @required int categoryId,
  })  : localStatus = Value(localStatus),
        createdAt = Value(createdAt),
        createdBy = Value(createdBy),
        createdHash = Value(createdHash),
        amount = Value(amount),
        description = Value(description),
        transactionDate = Value(transactionDate),
        repetitionCycle = Value(repetitionCycle),
        isParentTransaction = Value(isParentTransaction),
        categoryId = Value(categoryId);
  static Insertable<Transaction> custom({
    Expression<int> id,
    Expression<int> localStatus,
    Expression<DateTime> createdAt,
    Expression<String> createdBy,
    Expression<String> createdHash,
    Expression<DateTime> updatedAt,
    Expression<String> updatedBy,
    Expression<double> amount,
    Expression<String> description,
    Expression<DateTime> transactionDate,
    Expression<int> repetitionCycle,
    Expression<int> parentTransactionId,
    Expression<bool> isParentTransaction,
    Expression<DateTime> nextRecurringDate,
    Expression<String> imagePath,
    Expression<int> categoryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localStatus != null) 'local_status': localStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdHash != null) 'created_hash': createdHash,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (repetitionCycle != null) 'repetition_cycle': repetitionCycle,
      if (parentTransactionId != null)
        'parent_transaction_id': parentTransactionId,
      if (isParentTransaction != null)
        'is_parent_transaction': isParentTransaction,
      if (nextRecurringDate != null) 'next_recurring_date': nextRecurringDate,
      if (imagePath != null) 'image_path': imagePath,
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int> id,
      Value<LocalStatusType> localStatus,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<String> createdHash,
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<double> amount,
      Value<String> description,
      Value<DateTime> transactionDate,
      Value<RepetitionCycleType> repetitionCycle,
      Value<int> parentTransactionId,
      Value<bool> isParentTransaction,
      Value<DateTime> nextRecurringDate,
      Value<String> imagePath,
      Value<int> categoryId}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      localStatus: localStatus ?? this.localStatus,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      createdHash: createdHash ?? this.createdHash,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      repetitionCycle: repetitionCycle ?? this.repetitionCycle,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      isParentTransaction: isParentTransaction ?? this.isParentTransaction,
      nextRecurringDate: nextRecurringDate ?? this.nextRecurringDate,
      imagePath: imagePath ?? this.imagePath,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localStatus.present) {
      final converter = $TransactionsTable.$converter0;
      map['local_status'] =
          Variable<int>(converter.mapToSql(localStatus.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdHash.present) {
      map['created_hash'] = Variable<String>(createdHash.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (repetitionCycle.present) {
      final converter = $TransactionsTable.$converter1;
      map['repetition_cycle'] =
          Variable<int>(converter.mapToSql(repetitionCycle.value));
    }
    if (parentTransactionId.present) {
      map['parent_transaction_id'] = Variable<int>(parentTransactionId.value);
    }
    if (isParentTransaction.present) {
      map['is_parent_transaction'] = Variable<bool>(isParentTransaction.value);
    }
    if (nextRecurringDate.present) {
      map['next_recurring_date'] = Variable<DateTime>(nextRecurringDate.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    return map;
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  final GeneratedDatabase _db;
  final String _alias;
  $TransactionsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _localStatusMeta =
      const VerificationMeta('localStatus');
  GeneratedIntColumn _localStatus;
  @override
  GeneratedIntColumn get localStatus =>
      _localStatus ??= _constructLocalStatus();
  GeneratedIntColumn _constructLocalStatus() {
    return GeneratedIntColumn(
      'local_status',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  GeneratedDateTimeColumn _createdAt;
  @override
  GeneratedDateTimeColumn get createdAt => _createdAt ??= _constructCreatedAt();
  GeneratedDateTimeColumn _constructCreatedAt() {
    return GeneratedDateTimeColumn(
      'created_at',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  GeneratedTextColumn _createdBy;
  @override
  GeneratedTextColumn get createdBy => _createdBy ??= _constructCreatedBy();
  GeneratedTextColumn _constructCreatedBy() {
    return GeneratedTextColumn('created_by', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _createdHashMeta =
      const VerificationMeta('createdHash');
  GeneratedTextColumn _createdHash;
  @override
  GeneratedTextColumn get createdHash =>
      _createdHash ??= _constructCreatedHash();
  GeneratedTextColumn _constructCreatedHash() {
    return GeneratedTextColumn(
      'created_hash',
      $tableName,
      false,
    );
  }

  final VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  GeneratedDateTimeColumn _updatedAt;
  @override
  GeneratedDateTimeColumn get updatedAt => _updatedAt ??= _constructUpdatedAt();
  GeneratedDateTimeColumn _constructUpdatedAt() {
    return GeneratedDateTimeColumn(
      'updated_at',
      $tableName,
      true,
    );
  }

  final VerificationMeta _updatedByMeta = const VerificationMeta('updatedBy');
  GeneratedTextColumn _updatedBy;
  @override
  GeneratedTextColumn get updatedBy => _updatedBy ??= _constructUpdatedBy();
  GeneratedTextColumn _constructUpdatedBy() {
    return GeneratedTextColumn('updated_by', $tableName, true,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _amountMeta = const VerificationMeta('amount');
  GeneratedRealColumn _amount;
  @override
  GeneratedRealColumn get amount => _amount ??= _constructAmount();
  GeneratedRealColumn _constructAmount() {
    return GeneratedRealColumn(
      'amount',
      $tableName,
      false,
    );
  }

  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  GeneratedTextColumn _description;
  @override
  GeneratedTextColumn get description =>
      _description ??= _constructDescription();
  GeneratedTextColumn _constructDescription() {
    return GeneratedTextColumn('description', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  GeneratedDateTimeColumn _transactionDate;
  @override
  GeneratedDateTimeColumn get transactionDate =>
      _transactionDate ??= _constructTransactionDate();
  GeneratedDateTimeColumn _constructTransactionDate() {
    return GeneratedDateTimeColumn(
      'transaction_date',
      $tableName,
      false,
    );
  }

  final VerificationMeta _repetitionCycleMeta =
      const VerificationMeta('repetitionCycle');
  GeneratedIntColumn _repetitionCycle;
  @override
  GeneratedIntColumn get repetitionCycle =>
      _repetitionCycle ??= _constructRepetitionCycle();
  GeneratedIntColumn _constructRepetitionCycle() {
    return GeneratedIntColumn(
      'repetition_cycle',
      $tableName,
      false,
    );
  }

  final VerificationMeta _parentTransactionIdMeta =
      const VerificationMeta('parentTransactionId');
  GeneratedIntColumn _parentTransactionId;
  @override
  GeneratedIntColumn get parentTransactionId =>
      _parentTransactionId ??= _constructParentTransactionId();
  GeneratedIntColumn _constructParentTransactionId() {
    return GeneratedIntColumn(
      'parent_transaction_id',
      $tableName,
      true,
    );
  }

  final VerificationMeta _isParentTransactionMeta =
      const VerificationMeta('isParentTransaction');
  GeneratedBoolColumn _isParentTransaction;
  @override
  GeneratedBoolColumn get isParentTransaction =>
      _isParentTransaction ??= _constructIsParentTransaction();
  GeneratedBoolColumn _constructIsParentTransaction() {
    return GeneratedBoolColumn(
      'is_parent_transaction',
      $tableName,
      false,
    );
  }

  final VerificationMeta _nextRecurringDateMeta =
      const VerificationMeta('nextRecurringDate');
  GeneratedDateTimeColumn _nextRecurringDate;
  @override
  GeneratedDateTimeColumn get nextRecurringDate =>
      _nextRecurringDate ??= _constructNextRecurringDate();
  GeneratedDateTimeColumn _constructNextRecurringDate() {
    return GeneratedDateTimeColumn(
      'next_recurring_date',
      $tableName,
      true,
    );
  }

  final VerificationMeta _imagePathMeta = const VerificationMeta('imagePath');
  GeneratedTextColumn _imagePath;
  @override
  GeneratedTextColumn get imagePath => _imagePath ??= _constructImagePath();
  GeneratedTextColumn _constructImagePath() {
    return GeneratedTextColumn(
      'image_path',
      $tableName,
      true,
    );
  }

  final VerificationMeta _categoryIdMeta = const VerificationMeta('categoryId');
  GeneratedIntColumn _categoryId;
  @override
  GeneratedIntColumn get categoryId => _categoryId ??= _constructCategoryId();
  GeneratedIntColumn _constructCategoryId() {
    return GeneratedIntColumn('category_id', $tableName, false,
        $customConstraints: 'REFERENCES categories(id)');
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        localStatus,
        createdAt,
        createdBy,
        createdHash,
        updatedAt,
        updatedBy,
        amount,
        description,
        transactionDate,
        repetitionCycle,
        parentTransactionId,
        isParentTransaction,
        nextRecurringDate,
        imagePath,
        categoryId
      ];
  @override
  $TransactionsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'transactions';
  @override
  final String actualTableName = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    context.handle(_localStatusMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at'], _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by'], _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_hash')) {
      context.handle(
          _createdHashMeta,
          createdHash.isAcceptableOrUnknown(
              data['created_hash'], _createdHashMeta));
    } else if (isInserting) {
      context.missing(_createdHashMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at'], _updatedAtMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by'], _updatedByMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount'], _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description'], _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date'], _transactionDateMeta));
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    context.handle(_repetitionCycleMeta, const VerificationResult.success());
    if (data.containsKey('parent_transaction_id')) {
      context.handle(
          _parentTransactionIdMeta,
          parentTransactionId.isAcceptableOrUnknown(
              data['parent_transaction_id'], _parentTransactionIdMeta));
    }
    if (data.containsKey('is_parent_transaction')) {
      context.handle(
          _isParentTransactionMeta,
          isParentTransaction.isAcceptableOrUnknown(
              data['is_parent_transaction'], _isParentTransactionMeta));
    } else if (isInserting) {
      context.missing(_isParentTransactionMeta);
    }
    if (data.containsKey('next_recurring_date')) {
      context.handle(
          _nextRecurringDateMeta,
          nextRecurringDate.isAcceptableOrUnknown(
              data['next_recurring_date'], _nextRecurringDateMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path'], _imagePathMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id'], _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Transaction.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(_db, alias);
  }

  static TypeConverter<LocalStatusType, int> $converter0 =
      const LocalStatusConverter();
  static TypeConverter<RepetitionCycleType, int> $converter1 =
      const RepetitionCycleConverter();
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final LocalStatusType localStatus;
  final DateTime createdAt;
  final String createdBy;
  final String createdHash;
  final DateTime updatedAt;
  final String updatedBy;
  final String name;
  final bool isAnIncome;
  final IconData icon;
  final Color iconColor;
  final int userId;
  Category(
      {@required this.id,
      @required this.localStatus,
      @required this.createdAt,
      @required this.createdBy,
      @required this.createdHash,
      this.updatedAt,
      this.updatedBy,
      @required this.name,
      @required this.isAnIncome,
      @required this.icon,
      @required this.iconColor,
      this.userId});
  factory Category.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Category(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      localStatus: $CategoriesTable.$converter0.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}local_status'])),
      createdAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_at']),
      createdBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
      createdHash: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_hash']),
      updatedAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_at']),
      updatedBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_by']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      isAnIncome: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}is_an_income']),
      icon: $CategoriesTable.$converter1.mapToDart(
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}icon'])),
      iconColor: $CategoriesTable.$converter2.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}icon_color'])),
      userId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}user_id']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || localStatus != null) {
      final converter = $CategoriesTable.$converter0;
      map['local_status'] = Variable<int>(converter.mapToSql(localStatus));
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdHash != null) {
      map['created_hash'] = Variable<String>(createdHash);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || isAnIncome != null) {
      map['is_an_income'] = Variable<bool>(isAnIncome);
    }
    if (!nullToAbsent || icon != null) {
      final converter = $CategoriesTable.$converter1;
      map['icon'] = Variable<String>(converter.mapToSql(icon));
    }
    if (!nullToAbsent || iconColor != null) {
      final converter = $CategoriesTable.$converter2;
      map['icon_color'] = Variable<int>(converter.mapToSql(iconColor));
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      localStatus: localStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(localStatus),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdHash: createdHash == null && nullToAbsent
          ? const Value.absent()
          : Value(createdHash),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      isAnIncome: isAnIncome == null && nullToAbsent
          ? const Value.absent()
          : Value(isAnIncome),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      iconColor: iconColor == null && nullToAbsent
          ? const Value.absent()
          : Value(iconColor),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      localStatus: serializer.fromJson<LocalStatusType>(json['localStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdHash: serializer.fromJson<String>(json['createdHash']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      name: serializer.fromJson<String>(json['name']),
      isAnIncome: serializer.fromJson<bool>(json['isAnIncome']),
      icon: serializer.fromJson<IconData>(json['icon']),
      iconColor: serializer.fromJson<Color>(json['iconColor']),
      userId: serializer.fromJson<int>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localStatus': serializer.toJson<LocalStatusType>(localStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdHash': serializer.toJson<String>(createdHash),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'name': serializer.toJson<String>(name),
      'isAnIncome': serializer.toJson<bool>(isAnIncome),
      'icon': serializer.toJson<IconData>(icon),
      'iconColor': serializer.toJson<Color>(iconColor),
      'userId': serializer.toJson<int>(userId),
    };
  }

  Category copyWith(
          {int id,
          LocalStatusType localStatus,
          DateTime createdAt,
          String createdBy,
          String createdHash,
          DateTime updatedAt,
          String updatedBy,
          String name,
          bool isAnIncome,
          IconData icon,
          Color iconColor,
          int userId}) =>
      Category(
        id: id ?? this.id,
        localStatus: localStatus ?? this.localStatus,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        createdHash: createdHash ?? this.createdHash,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        name: name ?? this.name,
        isAnIncome: isAnIncome ?? this.isAnIncome,
        icon: icon ?? this.icon,
        iconColor: iconColor ?? this.iconColor,
        userId: userId ?? this.userId,
      );
  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('localStatus: $localStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdHash: $createdHash, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('isAnIncome: $isAnIncome, ')
          ..write('icon: $icon, ')
          ..write('iconColor: $iconColor, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          localStatus.hashCode,
          $mrjc(
              createdAt.hashCode,
              $mrjc(
                  createdBy.hashCode,
                  $mrjc(
                      createdHash.hashCode,
                      $mrjc(
                          updatedAt.hashCode,
                          $mrjc(
                              updatedBy.hashCode,
                              $mrjc(
                                  name.hashCode,
                                  $mrjc(
                                      isAnIncome.hashCode,
                                      $mrjc(
                                          icon.hashCode,
                                          $mrjc(iconColor.hashCode,
                                              userId.hashCode))))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.localStatus == this.localStatus &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.createdHash == this.createdHash &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.name == this.name &&
          other.isAnIncome == this.isAnIncome &&
          other.icon == this.icon &&
          other.iconColor == this.iconColor &&
          other.userId == this.userId);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<LocalStatusType> localStatus;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<String> createdHash;
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<String> name;
  final Value<bool> isAnIncome;
  final Value<IconData> icon;
  final Value<Color> iconColor;
  final Value<int> userId;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.localStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdHash = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.isAnIncome = const Value.absent(),
    this.icon = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.userId = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    @required LocalStatusType localStatus,
    @required DateTime createdAt,
    @required String createdBy,
    @required String createdHash,
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    @required String name,
    @required bool isAnIncome,
    @required IconData icon,
    @required Color iconColor,
    this.userId = const Value.absent(),
  })  : localStatus = Value(localStatus),
        createdAt = Value(createdAt),
        createdBy = Value(createdBy),
        createdHash = Value(createdHash),
        name = Value(name),
        isAnIncome = Value(isAnIncome),
        icon = Value(icon),
        iconColor = Value(iconColor);
  static Insertable<Category> custom({
    Expression<int> id,
    Expression<int> localStatus,
    Expression<DateTime> createdAt,
    Expression<String> createdBy,
    Expression<String> createdHash,
    Expression<DateTime> updatedAt,
    Expression<String> updatedBy,
    Expression<String> name,
    Expression<bool> isAnIncome,
    Expression<String> icon,
    Expression<int> iconColor,
    Expression<int> userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localStatus != null) 'local_status': localStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdHash != null) 'created_hash': createdHash,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (name != null) 'name': name,
      if (isAnIncome != null) 'is_an_income': isAnIncome,
      if (icon != null) 'icon': icon,
      if (iconColor != null) 'icon_color': iconColor,
      if (userId != null) 'user_id': userId,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int> id,
      Value<LocalStatusType> localStatus,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<String> createdHash,
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<String> name,
      Value<bool> isAnIncome,
      Value<IconData> icon,
      Value<Color> iconColor,
      Value<int> userId}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      localStatus: localStatus ?? this.localStatus,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      createdHash: createdHash ?? this.createdHash,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      name: name ?? this.name,
      isAnIncome: isAnIncome ?? this.isAnIncome,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      userId: userId ?? this.userId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localStatus.present) {
      final converter = $CategoriesTable.$converter0;
      map['local_status'] =
          Variable<int>(converter.mapToSql(localStatus.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdHash.present) {
      map['created_hash'] = Variable<String>(createdHash.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isAnIncome.present) {
      map['is_an_income'] = Variable<bool>(isAnIncome.value);
    }
    if (icon.present) {
      final converter = $CategoriesTable.$converter1;
      map['icon'] = Variable<String>(converter.mapToSql(icon.value));
    }
    if (iconColor.present) {
      final converter = $CategoriesTable.$converter2;
      map['icon_color'] = Variable<int>(converter.mapToSql(iconColor.value));
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    return map;
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  final GeneratedDatabase _db;
  final String _alias;
  $CategoriesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _localStatusMeta =
      const VerificationMeta('localStatus');
  GeneratedIntColumn _localStatus;
  @override
  GeneratedIntColumn get localStatus =>
      _localStatus ??= _constructLocalStatus();
  GeneratedIntColumn _constructLocalStatus() {
    return GeneratedIntColumn(
      'local_status',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  GeneratedDateTimeColumn _createdAt;
  @override
  GeneratedDateTimeColumn get createdAt => _createdAt ??= _constructCreatedAt();
  GeneratedDateTimeColumn _constructCreatedAt() {
    return GeneratedDateTimeColumn(
      'created_at',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  GeneratedTextColumn _createdBy;
  @override
  GeneratedTextColumn get createdBy => _createdBy ??= _constructCreatedBy();
  GeneratedTextColumn _constructCreatedBy() {
    return GeneratedTextColumn('created_by', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _createdHashMeta =
      const VerificationMeta('createdHash');
  GeneratedTextColumn _createdHash;
  @override
  GeneratedTextColumn get createdHash =>
      _createdHash ??= _constructCreatedHash();
  GeneratedTextColumn _constructCreatedHash() {
    return GeneratedTextColumn(
      'created_hash',
      $tableName,
      false,
    );
  }

  final VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  GeneratedDateTimeColumn _updatedAt;
  @override
  GeneratedDateTimeColumn get updatedAt => _updatedAt ??= _constructUpdatedAt();
  GeneratedDateTimeColumn _constructUpdatedAt() {
    return GeneratedDateTimeColumn(
      'updated_at',
      $tableName,
      true,
    );
  }

  final VerificationMeta _updatedByMeta = const VerificationMeta('updatedBy');
  GeneratedTextColumn _updatedBy;
  @override
  GeneratedTextColumn get updatedBy => _updatedBy ??= _constructUpdatedBy();
  GeneratedTextColumn _constructUpdatedBy() {
    return GeneratedTextColumn('updated_by', $tableName, true,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  GeneratedTextColumn _name;
  @override
  GeneratedTextColumn get name => _name ??= _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _isAnIncomeMeta = const VerificationMeta('isAnIncome');
  GeneratedBoolColumn _isAnIncome;
  @override
  GeneratedBoolColumn get isAnIncome => _isAnIncome ??= _constructIsAnIncome();
  GeneratedBoolColumn _constructIsAnIncome() {
    return GeneratedBoolColumn(
      'is_an_income',
      $tableName,
      false,
    );
  }

  final VerificationMeta _iconMeta = const VerificationMeta('icon');
  GeneratedTextColumn _icon;
  @override
  GeneratedTextColumn get icon => _icon ??= _constructIcon();
  GeneratedTextColumn _constructIcon() {
    return GeneratedTextColumn(
      'icon',
      $tableName,
      false,
    );
  }

  final VerificationMeta _iconColorMeta = const VerificationMeta('iconColor');
  GeneratedIntColumn _iconColor;
  @override
  GeneratedIntColumn get iconColor => _iconColor ??= _constructIconColor();
  GeneratedIntColumn _constructIconColor() {
    return GeneratedIntColumn(
      'icon_color',
      $tableName,
      false,
    );
  }

  final VerificationMeta _userIdMeta = const VerificationMeta('userId');
  GeneratedIntColumn _userId;
  @override
  GeneratedIntColumn get userId => _userId ??= _constructUserId();
  GeneratedIntColumn _constructUserId() {
    return GeneratedIntColumn('user_id', $tableName, true,
        $customConstraints: 'REFERENCES users(id)');
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        localStatus,
        createdAt,
        createdBy,
        createdHash,
        updatedAt,
        updatedBy,
        name,
        isAnIncome,
        icon,
        iconColor,
        userId
      ];
  @override
  $CategoriesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'categories';
  @override
  final String actualTableName = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    context.handle(_localStatusMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at'], _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by'], _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_hash')) {
      context.handle(
          _createdHashMeta,
          createdHash.isAcceptableOrUnknown(
              data['created_hash'], _createdHashMeta));
    } else if (isInserting) {
      context.missing(_createdHashMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at'], _updatedAtMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by'], _updatedByMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_an_income')) {
      context.handle(
          _isAnIncomeMeta,
          isAnIncome.isAcceptableOrUnknown(
              data['is_an_income'], _isAnIncomeMeta));
    } else if (isInserting) {
      context.missing(_isAnIncomeMeta);
    }
    context.handle(_iconMeta, const VerificationResult.success());
    context.handle(_iconColorMeta, const VerificationResult.success());
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id'], _userIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Category.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(_db, alias);
  }

  static TypeConverter<LocalStatusType, int> $converter0 =
      const LocalStatusConverter();
  static TypeConverter<IconData, String> $converter1 =
      const IconDataConverter();
  static TypeConverter<Color, int> $converter2 = const ColorConverter();
}

class RunningTask extends DataClass implements Insertable<RunningTask> {
  final int id;
  final LocalStatusType localStatus;
  final DateTime createdAt;
  final String createdBy;
  final String createdHash;
  final DateTime updatedAt;
  final String updatedBy;
  final String name;
  final bool isRunning;
  RunningTask(
      {@required this.id,
      @required this.localStatus,
      @required this.createdAt,
      @required this.createdBy,
      @required this.createdHash,
      this.updatedAt,
      this.updatedBy,
      @required this.name,
      @required this.isRunning});
  factory RunningTask.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return RunningTask(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      localStatus: $RunningTasksTable.$converter0.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}local_status'])),
      createdAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_at']),
      createdBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
      createdHash: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_hash']),
      updatedAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_at']),
      updatedBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_by']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      isRunning: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}is_running']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || localStatus != null) {
      final converter = $RunningTasksTable.$converter0;
      map['local_status'] = Variable<int>(converter.mapToSql(localStatus));
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdHash != null) {
      map['created_hash'] = Variable<String>(createdHash);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || isRunning != null) {
      map['is_running'] = Variable<bool>(isRunning);
    }
    return map;
  }

  RunningTasksCompanion toCompanion(bool nullToAbsent) {
    return RunningTasksCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      localStatus: localStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(localStatus),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdHash: createdHash == null && nullToAbsent
          ? const Value.absent()
          : Value(createdHash),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      isRunning: isRunning == null && nullToAbsent
          ? const Value.absent()
          : Value(isRunning),
    );
  }

  factory RunningTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return RunningTask(
      id: serializer.fromJson<int>(json['id']),
      localStatus: serializer.fromJson<LocalStatusType>(json['localStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdHash: serializer.fromJson<String>(json['createdHash']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      name: serializer.fromJson<String>(json['name']),
      isRunning: serializer.fromJson<bool>(json['isRunning']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localStatus': serializer.toJson<LocalStatusType>(localStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdHash': serializer.toJson<String>(createdHash),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'name': serializer.toJson<String>(name),
      'isRunning': serializer.toJson<bool>(isRunning),
    };
  }

  RunningTask copyWith(
          {int id,
          LocalStatusType localStatus,
          DateTime createdAt,
          String createdBy,
          String createdHash,
          DateTime updatedAt,
          String updatedBy,
          String name,
          bool isRunning}) =>
      RunningTask(
        id: id ?? this.id,
        localStatus: localStatus ?? this.localStatus,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        createdHash: createdHash ?? this.createdHash,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        name: name ?? this.name,
        isRunning: isRunning ?? this.isRunning,
      );
  @override
  String toString() {
    return (StringBuffer('RunningTask(')
          ..write('id: $id, ')
          ..write('localStatus: $localStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdHash: $createdHash, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('isRunning: $isRunning')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          localStatus.hashCode,
          $mrjc(
              createdAt.hashCode,
              $mrjc(
                  createdBy.hashCode,
                  $mrjc(
                      createdHash.hashCode,
                      $mrjc(
                          updatedAt.hashCode,
                          $mrjc(updatedBy.hashCode,
                              $mrjc(name.hashCode, isRunning.hashCode)))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is RunningTask &&
          other.id == this.id &&
          other.localStatus == this.localStatus &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.createdHash == this.createdHash &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.name == this.name &&
          other.isRunning == this.isRunning);
}

class RunningTasksCompanion extends UpdateCompanion<RunningTask> {
  final Value<int> id;
  final Value<LocalStatusType> localStatus;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<String> createdHash;
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<String> name;
  final Value<bool> isRunning;
  const RunningTasksCompanion({
    this.id = const Value.absent(),
    this.localStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdHash = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.isRunning = const Value.absent(),
  });
  RunningTasksCompanion.insert({
    this.id = const Value.absent(),
    @required LocalStatusType localStatus,
    @required DateTime createdAt,
    @required String createdBy,
    @required String createdHash,
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    @required String name,
    @required bool isRunning,
  })  : localStatus = Value(localStatus),
        createdAt = Value(createdAt),
        createdBy = Value(createdBy),
        createdHash = Value(createdHash),
        name = Value(name),
        isRunning = Value(isRunning);
  static Insertable<RunningTask> custom({
    Expression<int> id,
    Expression<int> localStatus,
    Expression<DateTime> createdAt,
    Expression<String> createdBy,
    Expression<String> createdHash,
    Expression<DateTime> updatedAt,
    Expression<String> updatedBy,
    Expression<String> name,
    Expression<bool> isRunning,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localStatus != null) 'local_status': localStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdHash != null) 'created_hash': createdHash,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (name != null) 'name': name,
      if (isRunning != null) 'is_running': isRunning,
    });
  }

  RunningTasksCompanion copyWith(
      {Value<int> id,
      Value<LocalStatusType> localStatus,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<String> createdHash,
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<String> name,
      Value<bool> isRunning}) {
    return RunningTasksCompanion(
      id: id ?? this.id,
      localStatus: localStatus ?? this.localStatus,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      createdHash: createdHash ?? this.createdHash,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      name: name ?? this.name,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localStatus.present) {
      final converter = $RunningTasksTable.$converter0;
      map['local_status'] =
          Variable<int>(converter.mapToSql(localStatus.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdHash.present) {
      map['created_hash'] = Variable<String>(createdHash.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isRunning.present) {
      map['is_running'] = Variable<bool>(isRunning.value);
    }
    return map;
  }
}

class $RunningTasksTable extends RunningTasks
    with TableInfo<$RunningTasksTable, RunningTask> {
  final GeneratedDatabase _db;
  final String _alias;
  $RunningTasksTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _localStatusMeta =
      const VerificationMeta('localStatus');
  GeneratedIntColumn _localStatus;
  @override
  GeneratedIntColumn get localStatus =>
      _localStatus ??= _constructLocalStatus();
  GeneratedIntColumn _constructLocalStatus() {
    return GeneratedIntColumn(
      'local_status',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  GeneratedDateTimeColumn _createdAt;
  @override
  GeneratedDateTimeColumn get createdAt => _createdAt ??= _constructCreatedAt();
  GeneratedDateTimeColumn _constructCreatedAt() {
    return GeneratedDateTimeColumn(
      'created_at',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  GeneratedTextColumn _createdBy;
  @override
  GeneratedTextColumn get createdBy => _createdBy ??= _constructCreatedBy();
  GeneratedTextColumn _constructCreatedBy() {
    return GeneratedTextColumn('created_by', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _createdHashMeta =
      const VerificationMeta('createdHash');
  GeneratedTextColumn _createdHash;
  @override
  GeneratedTextColumn get createdHash =>
      _createdHash ??= _constructCreatedHash();
  GeneratedTextColumn _constructCreatedHash() {
    return GeneratedTextColumn(
      'created_hash',
      $tableName,
      false,
    );
  }

  final VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  GeneratedDateTimeColumn _updatedAt;
  @override
  GeneratedDateTimeColumn get updatedAt => _updatedAt ??= _constructUpdatedAt();
  GeneratedDateTimeColumn _constructUpdatedAt() {
    return GeneratedDateTimeColumn(
      'updated_at',
      $tableName,
      true,
    );
  }

  final VerificationMeta _updatedByMeta = const VerificationMeta('updatedBy');
  GeneratedTextColumn _updatedBy;
  @override
  GeneratedTextColumn get updatedBy => _updatedBy ??= _constructUpdatedBy();
  GeneratedTextColumn _constructUpdatedBy() {
    return GeneratedTextColumn('updated_by', $tableName, true,
        minTextLength: 0, maxTextLength: 255);
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  GeneratedTextColumn _name;
  @override
  GeneratedTextColumn get name => _name ??= _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn(
      'name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isRunningMeta = const VerificationMeta('isRunning');
  GeneratedBoolColumn _isRunning;
  @override
  GeneratedBoolColumn get isRunning => _isRunning ??= _constructIsRunning();
  GeneratedBoolColumn _constructIsRunning() {
    return GeneratedBoolColumn(
      'is_running',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        localStatus,
        createdAt,
        createdBy,
        createdHash,
        updatedAt,
        updatedBy,
        name,
        isRunning
      ];
  @override
  $RunningTasksTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'running_tasks';
  @override
  final String actualTableName = 'running_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<RunningTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    context.handle(_localStatusMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at'], _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by'], _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_hash')) {
      context.handle(
          _createdHashMeta,
          createdHash.isAcceptableOrUnknown(
              data['created_hash'], _createdHashMeta));
    } else if (isInserting) {
      context.missing(_createdHashMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at'], _updatedAtMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by'], _updatedByMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_running')) {
      context.handle(_isRunningMeta,
          isRunning.isAcceptableOrUnknown(data['is_running'], _isRunningMeta));
    } else if (isInserting) {
      context.missing(_isRunningMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunningTask map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return RunningTask.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $RunningTasksTable createAlias(String alias) {
    return $RunningTasksTable(_db, alias);
  }

  static TypeConverter<LocalStatusType, int> $converter0 =
      const LocalStatusConverter();
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $UsersTable _users;
  $UsersTable get users => _users ??= $UsersTable(this);
  $TransactionsTable _transactions;
  $TransactionsTable get transactions =>
      _transactions ??= $TransactionsTable(this);
  $CategoriesTable _categories;
  $CategoriesTable get categories => _categories ??= $CategoriesTable(this);
  $RunningTasksTable _runningTasks;
  $RunningTasksTable get runningTasks =>
      _runningTasks ??= $RunningTasksTable(this);
  UsersDaoImpl _usersDaoImpl;
  UsersDaoImpl get usersDaoImpl =>
      _usersDaoImpl ??= UsersDaoImpl(this as AppDatabase);
  TransactionsDaoImpl _transactionsDaoImpl;
  TransactionsDaoImpl get transactionsDaoImpl =>
      _transactionsDaoImpl ??= TransactionsDaoImpl(this as AppDatabase);
  CategoriesDaoImpl _categoriesDaoImpl;
  CategoriesDaoImpl get categoriesDaoImpl =>
      _categoriesDaoImpl ??= CategoriesDaoImpl(this as AppDatabase);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, transactions, categories, runningTasks];
}

// **************************************************************************
// DaoGenerator
// **************************************************************************

mixin _$CategoriesDaoImplMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $TransactionsTable get transactions => attachedDatabase.transactions;
}
mixin _$TransactionsDaoImplMixin on DatabaseAccessor<AppDatabase> {
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $CategoriesTable get categories => attachedDatabase.categories;
}
mixin _$UsersDaoImplMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
}
