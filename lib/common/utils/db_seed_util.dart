import 'package:flutter/material.dart';

import '../../common/enums/repetition_cycle_type.dart';
import '../../common/utils/category_utils.dart';
import '../../models/entities/database.dart';
import '../converters/color_converter.dart';
import '../converters/icon_data_converter.dart';
import '../enums/local_status_type.dart';

const createdBy = 'ebastidas';

List<Category> getDefaultCategories() {
  final categories = [
    //Income
    _buildCategory(
      'Money',
      CategoryUtils.getByName(CategoryUtils.money2).icon.icon,
      Colors.green,
      true,
    ),
    _buildCategory(
      'Bank',
      CategoryUtils.getByName(CategoryUtils.bank).icon.icon,
      Colors.black,
      true,
    ),

    //Food
    _buildCategory(
      'Fast Food',
      CategoryUtils.getByName(CategoryUtils.fastFood).icon.icon,
      Colors.red,
    ),
    _buildCategory(
      'Restaurant',
      CategoryUtils.getByName(CategoryUtils.restaurant).icon.icon,
      Colors.brown,
    ),
    _buildCategory(
      'Cafe',
      CategoryUtils.getByName(CategoryUtils.cafe).icon.icon,
      Colors.orange,
    ),

    //Home
    _buildCategory(
      'Gas',
      CategoryUtils.getByName(CategoryUtils.gas).icon.icon,
      Colors.blueAccent,
    ),
    _buildCategory(
      'Water',
      CategoryUtils.getByName(CategoryUtils.waterDrop).icon.icon,
      Colors.blue,
    ),
    _buildCategory(
      'Light',
      CategoryUtils.getByName(CategoryUtils.battery).icon.icon,
      Colors.yellow,
    ),
    _buildCategory(
      'Phone',
      CategoryUtils.getByName(CategoryUtils.smartphone).icon.icon,
      Colors.green,
    ),
    _buildCategory(
      'TV',
      CategoryUtils.getByName(CategoryUtils.tv).icon.icon,
      Colors.brown,
    ),
    _buildCategory(
      'Internet',
      CategoryUtils.getByName(CategoryUtils.web).icon.icon,
      Colors.blueAccent,
    ),

    //life
    _buildCategory(
      'Games',
      CategoryUtils.getByName(CategoryUtils.gamepad).icon.icon,
      Colors.indigo,
    ),
    _buildCategory(
      'Movies',
      CategoryUtils.getByName(CategoryUtils.movies).icon.icon,
      Colors.grey,
    ),
    _buildCategory(
      'Sports',
      CategoryUtils.getByName(CategoryUtils.soccerBall).icon.icon,
      Colors.black,
    ),
    _buildCategory(
      'Health',
      CategoryUtils.getByName(CategoryUtils.healing).icon.icon,
      Colors.red,
    ),
    _buildCategory(
      'Pharmacy',
      CategoryUtils.getByName(CategoryUtils.pharmacy).icon.icon,
      Colors.red,
    ),
    _buildCategory(
      'Education',
      CategoryUtils.getByName(CategoryUtils.school).icon.icon,
      Colors.grey,
    ),

    //Shopping
    _buildCategory(
      'Shopping',
      CategoryUtils.getByName(CategoryUtils.shop).icon.icon,
      Colors.cyan,
    ),
    _buildCategory(
      'Offer',
      CategoryUtils.getByName(CategoryUtils.offer).icon.icon,
      Colors.green,
    ),

    //Transport
    _buildCategory(
      'Taxi',
      CategoryUtils.getByName(CategoryUtils.taxi).icon.icon,
      Colors.yellow,
    ),
    _buildCategory(
      'Bus',
      CategoryUtils.getByName(CategoryUtils.bus).icon.icon,
      Colors.black,
    ),
    _buildCategory(
      'Car',
      CategoryUtils.getByName(CategoryUtils.car).icon.icon,
      Colors.red,
    ),
    _buildCategory(
      'Subway',
      CategoryUtils.getByName(CategoryUtils.subway).icon.icon,
      Colors.grey,
    ),
  ];

  return categories;
}

//TODO: DELETE THIS ONCE THE APP IS COMPLETED
List<Transaction> getDefaultTransactions() {
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

List<Transaction> getDefaultRecurringTransactions() {
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

Category _buildCategory(
  String name,
  IconData icon,
  Color color, [
  bool isAnIncome = false,
]) {
  final now = DateTime.now();
  return Category(
    id: null,
    localStatus: LocalStatusType.nothing,
    name: name,
    isAnIncome: isAnIncome,
    icon: icon,
    iconColor: color,
    createdBy: createdBy,
    createdAt: now,
    createdHash: createdHash([
      name,
      isAnIncome,
      const IconDataConverter().mapToSql(icon),
      const ColorConverter().mapToSql(color),
      createdBy,
      now,
      LocalStatusType.nothing
    ]),
  );
}

Transaction _buildTransaction(
  int categoryId,
  String description,
  double amount,
  DateTime date, {
  int repetitions = 0,
  RepetitionCycleType cycle = RepetitionCycleType.none,
  DateTime nextRecurringDate,
}) {
  final now = DateTime.now();
  return Transaction(
    id: null,
    localStatus: LocalStatusType.nothing,
    amount: amount,
    categoryId: categoryId,
    description: description,
    transactionDate: date,
    repetitionCycle: cycle,
    createdBy: createdBy,
    isParentTransaction: cycle != RepetitionCycleType.none,
    nextRecurringDate: nextRecurringDate,
    createdAt: now,
    createdHash: createdHash([
      amount,
      categoryId,
      description,
      date,
      cycle,
      createdBy,
      cycle != RepetitionCycleType.none,
      nextRecurringDate,
      now,
      LocalStatusType.nothing,
    ]),
  );
}
