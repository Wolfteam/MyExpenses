import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/converters/db_converters.dart';
import 'package:my_expenses/infrastructure/db/database.dart';
import 'package:my_expenses/presentation/shared/utils/category_utils.dart';

const createdBy = 'ebastidas';

//TODO: MOVE THIS OUT OF HERE ?

List<CategoriesCompanion> getDefaultCategories() {
  final categories = [
    //Income
    _buildCategory(
      'Money',
      CategoryUtils.getByName(CategoryUtils.money2).icon.icon!,
      Colors.green,
      true,
    ),
    _buildCategory(
      'Bank',
      CategoryUtils.getByName(CategoryUtils.bank).icon.icon!,
      Colors.black,
      true,
    ),

    //Food
    _buildCategory(
      'Fast Food',
      CategoryUtils.getByName(CategoryUtils.fastFood).icon.icon!,
      Colors.red,
    ),
    _buildCategory(
      'Restaurant',
      CategoryUtils.getByName(CategoryUtils.restaurant).icon.icon!,
      Colors.brown,
    ),
    _buildCategory(
      'Cafe',
      CategoryUtils.getByName(CategoryUtils.cafe).icon.icon!,
      Colors.orange,
    ),

    //Home
    _buildCategory(
      'Gas',
      CategoryUtils.getByName(CategoryUtils.gas).icon.icon!,
      Colors.blueAccent,
    ),
    _buildCategory(
      'Water',
      CategoryUtils.getByName(CategoryUtils.waterDrop).icon.icon!,
      Colors.blue,
    ),
    _buildCategory(
      'Light',
      CategoryUtils.getByName(CategoryUtils.battery).icon.icon!,
      Colors.yellow,
    ),
    _buildCategory(
      'Phone',
      CategoryUtils.getByName(CategoryUtils.smartphone).icon.icon!,
      Colors.green,
    ),
    _buildCategory(
      'TV',
      CategoryUtils.getByName(CategoryUtils.tv).icon.icon!,
      Colors.brown,
    ),
    _buildCategory(
      'Internet',
      CategoryUtils.getByName(CategoryUtils.web).icon.icon!,
      Colors.blueAccent,
    ),

    //life
    _buildCategory(
      'Games',
      CategoryUtils.getByName(CategoryUtils.gamepad).icon.icon!,
      Colors.indigo,
    ),
    _buildCategory(
      'Movies',
      CategoryUtils.getByName(CategoryUtils.movies).icon.icon!,
      Colors.grey,
    ),
    _buildCategory(
      'Sports',
      CategoryUtils.getByName(CategoryUtils.soccerBall).icon.icon!,
      Colors.black,
    ),
    _buildCategory(
      'Health',
      CategoryUtils.getByName(CategoryUtils.healing).icon.icon!,
      Colors.red,
    ),
    _buildCategory(
      'Pharmacy',
      CategoryUtils.getByName(CategoryUtils.pharmacy).icon.icon!,
      Colors.red,
    ),
    _buildCategory(
      'Education',
      CategoryUtils.getByName(CategoryUtils.school).icon.icon!,
      Colors.grey,
    ),

    //Shopping
    _buildCategory(
      'Shopping',
      CategoryUtils.getByName(CategoryUtils.shop).icon.icon!,
      Colors.cyan,
    ),
    _buildCategory(
      'Offer',
      CategoryUtils.getByName(CategoryUtils.offer).icon.icon!,
      Colors.green,
    ),

    //Transport
    _buildCategory(
      'Taxi',
      CategoryUtils.getByName(CategoryUtils.taxi).icon.icon!,
      Colors.yellow,
    ),
    _buildCategory(
      'Bus',
      CategoryUtils.getByName(CategoryUtils.bus).icon.icon!,
      Colors.black,
    ),
    _buildCategory(
      'Car',
      CategoryUtils.getByName(CategoryUtils.car).icon.icon!,
      Colors.red,
    ),
    _buildCategory(
      'Subway',
      CategoryUtils.getByName(CategoryUtils.subway).icon.icon!,
      Colors.grey,
    ),
  ];

  return categories;
}

//TODO: DELETE THIS ONCE THE APP IS COMPLETED
List<TransactionsCompanion> getDefaultTransactions() {
  final transactions = [
    _buildTransaction(
      4,
      'SuperMaxi',
      -10,
      DateTime.now(),
    ),
    _buildTransaction(
      5,
      'Almuerzo',
      -50,
      DateTime.now(),
    ),
    _buildTransaction(
      7,
      'PS4',
      -400,
      DateTime.now().add(const Duration(days: -2)),
    ),
    _buildTransaction(
      8,
      'Reparaciones',
      -59,
      DateTime.now().add(const Duration(days: -3)),
    ),
    _buildTransaction(
      8,
      'Putas',
      -20,
      DateTime.now().add(const Duration(days: -4)),
    ),
    _buildTransaction(
      3,
      'Hamburguesas',
      -19,
      DateTime.now().add(const Duration(days: -5)),
    ),
    _buildTransaction(
      6,
      'Pilas',
      -29,
      DateTime.now().add(const Duration(days: -6)),
    ),
    _buildTransaction(
      5,
      'Camas',
      -109,
      DateTime.now().add(const Duration(days: -7)),
    ),
    _buildTransaction(
      8,
      'Sabanas',
      -23,
      DateTime.now().add(const Duration(days: -30)),
    ),
    _buildTransaction(
      1,
      'Cheques',
      350,
      DateTime.now().add(const Duration(days: -1)),
    ),
    _buildTransaction(
      2,
      'Salario',
      700,
      DateTime.now().add(const Duration(days: -30)),
    ),
  ];

  return transactions;
}

List<TransactionsCompanion> getDefaultRecurringTransactions() {
  final now = DateTime.now();
  final transDate = now.subtract(const Duration(days: 60));
  return [
    _buildTransaction(
      5,
      'Recurrente A',
      -100,
      transDate,
      repetitions: 1,
      cycle: RepetitionCycleType.eachDay,
      nextRecurringDate: transDate,
    )
  ];
}

CategoriesCompanion _buildCategory(
  String name,
  IconData icon,
  Color color, [
  bool isAnIncome = false,
]) {
  final now = DateTime.now();
  return CategoriesCompanion.insert(
    localStatus: LocalStatusType.nothing,
    name: name,
    isAnIncome: isAnIncome,
    icon: Value(icon),
    iconColor: color,
    createdBy: createdBy,
    createdAt: now,
    createdHash: createdHash(
      [name, isAnIncome, const IconDataConverter().toSql(icon)!, const ColorConverter().toSql(color), createdBy, now, LocalStatusType.nothing],
    ),
  );
}

TransactionsCompanion _buildTransaction(
  int categoryId,
  String description,
  double amount,
  DateTime date, {
  int repetitions = 0,
  RepetitionCycleType cycle = RepetitionCycleType.none,
  DateTime? nextRecurringDate,
}) {
  final now = DateTime.now();
  return TransactionsCompanion.insert(
    localStatus: LocalStatusType.nothing,
    amount: amount,
    categoryId: categoryId,
    description: description,
    transactionDate: date,
    repetitionCycle: cycle,
    createdBy: createdBy,
    isParentTransaction: cycle != RepetitionCycleType.none,
    nextRecurringDate: Value(nextRecurringDate),
    createdAt: now,
    createdHash: createdHash([
      amount,
      categoryId,
      description,
      date,
      cycle,
      createdBy,
      cycle != RepetitionCycleType.none,
      nextRecurringDate ?? -1,
      now,
      LocalStatusType.nothing,
    ]),
  );
}
