// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class User extends DataClass implements Insertable<User> {
  final int id;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;
  final String googleUserId;
  final String name;
  final String email;
  final String pictureUrl;
  final bool isActive;
  User(
      {@required this.id,
      @required this.createdAt,
      @required this.createdBy,
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
      createdAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_at']),
      createdBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
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
  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'googleUserId': serializer.toJson<String>(googleUserId),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'pictureUrl': serializer.toJson<String>(pictureUrl),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  @override
  UsersCompanion createCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
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

  User copyWith(
          {int id,
          DateTime createdAt,
          String createdBy,
          DateTime updatedAt,
          String updatedBy,
          String googleUserId,
          String name,
          String email,
          String pictureUrl,
          bool isActive}) =>
      User(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
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
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
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
          createdAt.hashCode,
          $mrjc(
              createdBy.hashCode,
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
                                      isActive.hashCode))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
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
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<String> googleUserId;
  final Value<String> name;
  final Value<String> email;
  final Value<String> pictureUrl;
  final Value<bool> isActive;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
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
    this.createdAt = const Value.absent(),
    @required String createdBy,
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    @required String googleUserId,
    @required String name,
    @required String email,
    this.pictureUrl = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : createdBy = Value(createdBy),
        googleUserId = Value(googleUserId),
        name = Value(name),
        email = Value(email);
  UsersCompanion copyWith(
      {Value<int> id,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<String> googleUserId,
      Value<String> name,
      Value<String> email,
      Value<String> pictureUrl,
      Value<bool> isActive}) {
    return UsersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      googleUserId: googleUserId ?? this.googleUserId,
      name: name ?? this.name,
      email: email ?? this.email,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      isActive: isActive ?? this.isActive,
    );
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

  final VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  GeneratedDateTimeColumn _createdAt;
  @override
  GeneratedDateTimeColumn get createdAt => _createdAt ??= _constructCreatedAt();
  GeneratedDateTimeColumn _constructCreatedAt() {
    return GeneratedDateTimeColumn(
      'created_at',
      $tableName,
      false,
    )..clientDefault = () => DateTime.now();
  }

  final VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  GeneratedTextColumn _createdBy;
  @override
  GeneratedTextColumn get createdBy => _createdBy ??= _constructCreatedBy();
  GeneratedTextColumn _constructCreatedBy() {
    return GeneratedTextColumn('created_by', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
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
        defaultValue: Constant(true));
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        createdBy,
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
  VerificationContext validateIntegrity(UsersCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.createdAt.present) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableValue(d.createdAt.value, _createdAtMeta));
    }
    if (d.createdBy.present) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableValue(d.createdBy.value, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (d.updatedAt.present) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableValue(d.updatedAt.value, _updatedAtMeta));
    }
    if (d.updatedBy.present) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableValue(d.updatedBy.value, _updatedByMeta));
    }
    if (d.googleUserId.present) {
      context.handle(
          _googleUserIdMeta,
          googleUserId.isAcceptableValue(
              d.googleUserId.value, _googleUserIdMeta));
    } else if (isInserting) {
      context.missing(_googleUserIdMeta);
    }
    if (d.name.present) {
      context.handle(
          _nameMeta, name.isAcceptableValue(d.name.value, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (d.email.present) {
      context.handle(
          _emailMeta, email.isAcceptableValue(d.email.value, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (d.pictureUrl.present) {
      context.handle(_pictureUrlMeta,
          pictureUrl.isAcceptableValue(d.pictureUrl.value, _pictureUrlMeta));
    }
    if (d.isActive.present) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableValue(d.isActive.value, _isActiveMeta));
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
  Map<String, Variable> entityToSql(UsersCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.createdAt.present) {
      map['created_at'] = Variable<DateTime, DateTimeType>(d.createdAt.value);
    }
    if (d.createdBy.present) {
      map['created_by'] = Variable<String, StringType>(d.createdBy.value);
    }
    if (d.updatedAt.present) {
      map['updated_at'] = Variable<DateTime, DateTimeType>(d.updatedAt.value);
    }
    if (d.updatedBy.present) {
      map['updated_by'] = Variable<String, StringType>(d.updatedBy.value);
    }
    if (d.googleUserId.present) {
      map['google_user_id'] =
          Variable<String, StringType>(d.googleUserId.value);
    }
    if (d.name.present) {
      map['name'] = Variable<String, StringType>(d.name.value);
    }
    if (d.email.present) {
      map['email'] = Variable<String, StringType>(d.email.value);
    }
    if (d.pictureUrl.present) {
      map['picture_url'] = Variable<String, StringType>(d.pictureUrl.value);
    }
    if (d.isActive.present) {
      map['is_active'] = Variable<bool, BoolType>(d.isActive.value);
    }
    return map;
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(_db, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final int repetitions;
  final RepetitionCycleType repetitionCycle;
  final int categoryId;
  Transaction(
      {@required this.id,
      @required this.createdAt,
      @required this.createdBy,
      this.updatedAt,
      this.updatedBy,
      @required this.amount,
      @required this.description,
      @required this.transactionDate,
      @required this.repetitions,
      @required this.repetitionCycle,
      @required this.categoryId});
  factory Transaction.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    return Transaction(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      createdAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_at']),
      createdBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
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
      repetitions: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}repetitions']),
      repetitionCycle: $TransactionsTable.$converter0.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}repetition_cycle'])),
      categoryId: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}category_id']),
    );
  }
  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      repetitionCycle:
          serializer.fromJson<RepetitionCycleType>(json['repetitionCycle']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'repetitions': serializer.toJson<int>(repetitions),
      'repetitionCycle':
          serializer.toJson<RepetitionCycleType>(repetitionCycle),
      'categoryId': serializer.toJson<int>(categoryId),
    };
  }

  @override
  TransactionsCompanion createCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
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
      repetitions: repetitions == null && nullToAbsent
          ? const Value.absent()
          : Value(repetitions),
      repetitionCycle: repetitionCycle == null && nullToAbsent
          ? const Value.absent()
          : Value(repetitionCycle),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
    );
  }

  Transaction copyWith(
          {int id,
          DateTime createdAt,
          String createdBy,
          DateTime updatedAt,
          String updatedBy,
          double amount,
          String description,
          DateTime transactionDate,
          int repetitions,
          RepetitionCycleType repetitionCycle,
          int categoryId}) =>
      Transaction(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        transactionDate: transactionDate ?? this.transactionDate,
        repetitions: repetitions ?? this.repetitions,
        repetitionCycle: repetitionCycle ?? this.repetitionCycle,
        categoryId: categoryId ?? this.categoryId,
      );
  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('repetitions: $repetitions, ')
          ..write('repetitionCycle: $repetitionCycle, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          createdAt.hashCode,
          $mrjc(
              createdBy.hashCode,
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
                                      repetitions.hashCode,
                                      $mrjc(repetitionCycle.hashCode,
                                          categoryId.hashCode)))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.transactionDate == this.transactionDate &&
          other.repetitions == this.repetitions &&
          other.repetitionCycle == this.repetitionCycle &&
          other.categoryId == this.categoryId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<double> amount;
  final Value<String> description;
  final Value<DateTime> transactionDate;
  final Value<int> repetitions;
  final Value<RepetitionCycleType> repetitionCycle;
  final Value<int> categoryId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.repetitionCycle = const Value.absent(),
    this.categoryId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    @required String createdBy,
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    @required double amount,
    @required String description,
    @required DateTime transactionDate,
    @required int repetitions,
    @required RepetitionCycleType repetitionCycle,
    @required int categoryId,
  })  : createdBy = Value(createdBy),
        amount = Value(amount),
        description = Value(description),
        transactionDate = Value(transactionDate),
        repetitions = Value(repetitions),
        repetitionCycle = Value(repetitionCycle),
        categoryId = Value(categoryId);
  TransactionsCompanion copyWith(
      {Value<int> id,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<double> amount,
      Value<String> description,
      Value<DateTime> transactionDate,
      Value<int> repetitions,
      Value<RepetitionCycleType> repetitionCycle,
      Value<int> categoryId}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      repetitions: repetitions ?? this.repetitions,
      repetitionCycle: repetitionCycle ?? this.repetitionCycle,
      categoryId: categoryId ?? this.categoryId,
    );
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

  final VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  GeneratedDateTimeColumn _createdAt;
  @override
  GeneratedDateTimeColumn get createdAt => _createdAt ??= _constructCreatedAt();
  GeneratedDateTimeColumn _constructCreatedAt() {
    return GeneratedDateTimeColumn(
      'created_at',
      $tableName,
      false,
    )..clientDefault = () => DateTime.now();
  }

  final VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  GeneratedTextColumn _createdBy;
  @override
  GeneratedTextColumn get createdBy => _createdBy ??= _constructCreatedBy();
  GeneratedTextColumn _constructCreatedBy() {
    return GeneratedTextColumn('created_by', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
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

  final VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  GeneratedIntColumn _repetitions;
  @override
  GeneratedIntColumn get repetitions =>
      _repetitions ??= _constructRepetitions();
  GeneratedIntColumn _constructRepetitions() {
    return GeneratedIntColumn(
      'repetitions',
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
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        amount,
        description,
        transactionDate,
        repetitions,
        repetitionCycle,
        categoryId
      ];
  @override
  $TransactionsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'transactions';
  @override
  final String actualTableName = 'transactions';
  @override
  VerificationContext validateIntegrity(TransactionsCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.createdAt.present) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableValue(d.createdAt.value, _createdAtMeta));
    }
    if (d.createdBy.present) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableValue(d.createdBy.value, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (d.updatedAt.present) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableValue(d.updatedAt.value, _updatedAtMeta));
    }
    if (d.updatedBy.present) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableValue(d.updatedBy.value, _updatedByMeta));
    }
    if (d.amount.present) {
      context.handle(
          _amountMeta, amount.isAcceptableValue(d.amount.value, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (d.description.present) {
      context.handle(_descriptionMeta,
          description.isAcceptableValue(d.description.value, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (d.transactionDate.present) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableValue(
              d.transactionDate.value, _transactionDateMeta));
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (d.repetitions.present) {
      context.handle(_repetitionsMeta,
          repetitions.isAcceptableValue(d.repetitions.value, _repetitionsMeta));
    } else if (isInserting) {
      context.missing(_repetitionsMeta);
    }
    context.handle(_repetitionCycleMeta, const VerificationResult.success());
    if (d.categoryId.present) {
      context.handle(_categoryIdMeta,
          categoryId.isAcceptableValue(d.categoryId.value, _categoryIdMeta));
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
  Map<String, Variable> entityToSql(TransactionsCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.createdAt.present) {
      map['created_at'] = Variable<DateTime, DateTimeType>(d.createdAt.value);
    }
    if (d.createdBy.present) {
      map['created_by'] = Variable<String, StringType>(d.createdBy.value);
    }
    if (d.updatedAt.present) {
      map['updated_at'] = Variable<DateTime, DateTimeType>(d.updatedAt.value);
    }
    if (d.updatedBy.present) {
      map['updated_by'] = Variable<String, StringType>(d.updatedBy.value);
    }
    if (d.amount.present) {
      map['amount'] = Variable<double, RealType>(d.amount.value);
    }
    if (d.description.present) {
      map['description'] = Variable<String, StringType>(d.description.value);
    }
    if (d.transactionDate.present) {
      map['transaction_date'] =
          Variable<DateTime, DateTimeType>(d.transactionDate.value);
    }
    if (d.repetitions.present) {
      map['repetitions'] = Variable<int, IntType>(d.repetitions.value);
    }
    if (d.repetitionCycle.present) {
      final converter = $TransactionsTable.$converter0;
      map['repetition_cycle'] =
          Variable<int, IntType>(converter.mapToSql(d.repetitionCycle.value));
    }
    if (d.categoryId.present) {
      map['category_id'] = Variable<int, IntType>(d.categoryId.value);
    }
    return map;
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(_db, alias);
  }

  static TypeConverter<RepetitionCycleType, int> $converter0 =
      const RepetitionCycleConverter();
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;
  final String name;
  final bool isAnIncome;
  final IconData icon;
  final Color iconColor;
  Category(
      {@required this.id,
      @required this.createdAt,
      @required this.createdBy,
      this.updatedAt,
      this.updatedBy,
      @required this.name,
      @required this.isAnIncome,
      @required this.icon,
      @required this.iconColor});
  factory Category.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Category(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      createdAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_at']),
      createdBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
      updatedAt: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_at']),
      updatedBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}updated_by']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      isAnIncome: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}is_an_income']),
      icon: $CategoriesTable.$converter0.mapToDart(
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}icon'])),
      iconColor: $CategoriesTable.$converter1.mapToDart(intType
          .mapFromDatabaseResponse(data['${effectivePrefix}icon_color'])),
    );
  }
  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      name: serializer.fromJson<String>(json['name']),
      isAnIncome: serializer.fromJson<bool>(json['isAnIncome']),
      icon: serializer.fromJson<IconData>(json['icon']),
      iconColor: serializer.fromJson<Color>(json['iconColor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'name': serializer.toJson<String>(name),
      'isAnIncome': serializer.toJson<bool>(isAnIncome),
      'icon': serializer.toJson<IconData>(icon),
      'iconColor': serializer.toJson<Color>(iconColor),
    };
  }

  @override
  CategoriesCompanion createCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
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
    );
  }

  Category copyWith(
          {int id,
          DateTime createdAt,
          String createdBy,
          DateTime updatedAt,
          String updatedBy,
          String name,
          bool isAnIncome,
          IconData icon,
          Color iconColor}) =>
      Category(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        name: name ?? this.name,
        isAnIncome: isAnIncome ?? this.isAnIncome,
        icon: icon ?? this.icon,
        iconColor: iconColor ?? this.iconColor,
      );
  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('isAnIncome: $isAnIncome, ')
          ..write('icon: $icon, ')
          ..write('iconColor: $iconColor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          createdAt.hashCode,
          $mrjc(
              createdBy.hashCode,
              $mrjc(
                  updatedAt.hashCode,
                  $mrjc(
                      updatedBy.hashCode,
                      $mrjc(
                          name.hashCode,
                          $mrjc(isAnIncome.hashCode,
                              $mrjc(icon.hashCode, iconColor.hashCode)))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.name == this.name &&
          other.isAnIncome == this.isAnIncome &&
          other.icon == this.icon &&
          other.iconColor == this.iconColor);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<DateTime> updatedAt;
  final Value<String> updatedBy;
  final Value<String> name;
  final Value<bool> isAnIncome;
  final Value<IconData> icon;
  final Value<Color> iconColor;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.isAnIncome = const Value.absent(),
    this.icon = const Value.absent(),
    this.iconColor = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    @required String createdBy,
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    @required String name,
    @required bool isAnIncome,
    @required IconData icon,
    @required Color iconColor,
  })  : createdBy = Value(createdBy),
        name = Value(name),
        isAnIncome = Value(isAnIncome),
        icon = Value(icon),
        iconColor = Value(iconColor);
  CategoriesCompanion copyWith(
      {Value<int> id,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<DateTime> updatedAt,
      Value<String> updatedBy,
      Value<String> name,
      Value<bool> isAnIncome,
      Value<IconData> icon,
      Value<Color> iconColor}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      name: name ?? this.name,
      isAnIncome: isAnIncome ?? this.isAnIncome,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
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

  final VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  GeneratedDateTimeColumn _createdAt;
  @override
  GeneratedDateTimeColumn get createdAt => _createdAt ??= _constructCreatedAt();
  GeneratedDateTimeColumn _constructCreatedAt() {
    return GeneratedDateTimeColumn(
      'created_at',
      $tableName,
      false,
    )..clientDefault = () => DateTime.now();
  }

  final VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  GeneratedTextColumn _createdBy;
  @override
  GeneratedTextColumn get createdBy => _createdBy ??= _constructCreatedBy();
  GeneratedTextColumn _constructCreatedBy() {
    return GeneratedTextColumn('created_by', $tableName, false,
        minTextLength: 0, maxTextLength: 255);
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

  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        name,
        isAnIncome,
        icon,
        iconColor
      ];
  @override
  $CategoriesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'categories';
  @override
  final String actualTableName = 'categories';
  @override
  VerificationContext validateIntegrity(CategoriesCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.id.present) {
      context.handle(_idMeta, id.isAcceptableValue(d.id.value, _idMeta));
    }
    if (d.createdAt.present) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableValue(d.createdAt.value, _createdAtMeta));
    }
    if (d.createdBy.present) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableValue(d.createdBy.value, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (d.updatedAt.present) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableValue(d.updatedAt.value, _updatedAtMeta));
    }
    if (d.updatedBy.present) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableValue(d.updatedBy.value, _updatedByMeta));
    }
    if (d.name.present) {
      context.handle(
          _nameMeta, name.isAcceptableValue(d.name.value, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (d.isAnIncome.present) {
      context.handle(_isAnIncomeMeta,
          isAnIncome.isAcceptableValue(d.isAnIncome.value, _isAnIncomeMeta));
    } else if (isInserting) {
      context.missing(_isAnIncomeMeta);
    }
    context.handle(_iconMeta, const VerificationResult.success());
    context.handle(_iconColorMeta, const VerificationResult.success());
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
  Map<String, Variable> entityToSql(CategoriesCompanion d) {
    final map = <String, Variable>{};
    if (d.id.present) {
      map['id'] = Variable<int, IntType>(d.id.value);
    }
    if (d.createdAt.present) {
      map['created_at'] = Variable<DateTime, DateTimeType>(d.createdAt.value);
    }
    if (d.createdBy.present) {
      map['created_by'] = Variable<String, StringType>(d.createdBy.value);
    }
    if (d.updatedAt.present) {
      map['updated_at'] = Variable<DateTime, DateTimeType>(d.updatedAt.value);
    }
    if (d.updatedBy.present) {
      map['updated_by'] = Variable<String, StringType>(d.updatedBy.value);
    }
    if (d.name.present) {
      map['name'] = Variable<String, StringType>(d.name.value);
    }
    if (d.isAnIncome.present) {
      map['is_an_income'] = Variable<bool, BoolType>(d.isAnIncome.value);
    }
    if (d.icon.present) {
      final converter = $CategoriesTable.$converter0;
      map['icon'] =
          Variable<String, StringType>(converter.mapToSql(d.icon.value));
    }
    if (d.iconColor.present) {
      final converter = $CategoriesTable.$converter1;
      map['icon_color'] =
          Variable<int, IntType>(converter.mapToSql(d.iconColor.value));
    }
    return map;
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(_db, alias);
  }

  static TypeConverter<IconData, String> $converter0 =
      const IconDataConverter();
  static TypeConverter<Color, int> $converter1 = const ColorConverter();
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
      [users, transactions, categories];
}

// **************************************************************************
// DaoGenerator
// **************************************************************************

mixin _$UsersDaoImplMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => db.users;
}
mixin _$CategoriesDaoImplMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => db.categories;
}
mixin _$TransactionsDaoImplMixin on DatabaseAccessor<AppDatabase> {
  $TransactionsTable get transactions => db.transactions;
  $CategoriesTable get categories => db.categories;
}
