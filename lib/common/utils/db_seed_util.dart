import 'package:flutter/material.dart';

import '../../common/enums/repetition_cycle_type.dart';
import '../../common/utils/category_utils.dart';
import '../../models/entities/database.dart';

const createdBy = 'ebastidas';

List<Category> getDefaultCategories() {
  final categories = [
    //Income
    Category(
      name: 'Money',
      isAnIncome: true,
      icon: CategoryUtils.getByName(CategoryUtils.money2).icon.icon,
      iconColor: Colors.green,
      createdBy: createdBy,
    ),
    Category(
      name: 'Bank',
      isAnIncome: true,
      icon: CategoryUtils.getByName(CategoryUtils.bank).icon.icon,
      iconColor: Colors.black,
      createdBy: createdBy,
    ),

    //Food
    Category(
      name: 'Fast Food',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.fastFood).icon.icon,
      iconColor: Colors.red,
      createdBy: createdBy,
    ),
    Category(
      name: 'Restaurant',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.restaurant).icon.icon,
      iconColor: Colors.brown,
      createdBy: createdBy,
    ),
    Category(
      name: 'Cafe',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.cafe).icon.icon,
      iconColor: Colors.orange,
      createdBy: createdBy,
    ),

    //Home
    Category(
      name: 'Gas',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.gas).icon.icon,
      iconColor: Colors.blueAccent,
      createdBy: createdBy,
    ),
    Category(
      name: 'Water',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.waterDrop).icon.icon,
      iconColor: Colors.blue,
      createdBy: createdBy,
    ),
    Category(
      name: 'Light',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.battery).icon.icon,
      iconColor: Colors.yellow,
      createdBy: createdBy,
    ),
    Category(
      name: 'Phone',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.smartphone).icon.icon,
      iconColor: Colors.green,
      createdBy: createdBy,
    ),
    Category(
      name: 'TV',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.tv).icon.icon,
      iconColor: Colors.brown,
      createdBy: createdBy,
    ),
    Category(
      name: 'Internet',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.web).icon.icon,
      iconColor: Colors.blueAccent,
      createdBy: createdBy,
    ),

    //life
    Category(
      name: 'Games',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.gamepad).icon.icon,
      iconColor: Colors.indigo,
      createdBy: createdBy,
    ),
    Category(
      name: 'Movies',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.movies).icon.icon,
      iconColor: Colors.grey,
      createdBy: createdBy,
    ),
    Category(
      name: 'Sports',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.soccerBall).icon.icon,
      iconColor: Colors.black,
      createdBy: createdBy,
    ),
    Category(
      name: 'Health',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.healing).icon.icon,
      iconColor: Colors.red,
      createdBy: createdBy,
    ),
    Category(
      name: 'Pharmacy',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.pharmacy).icon.icon,
      iconColor: Colors.red,
      createdBy: createdBy,
    ),
    Category(
      name: 'Education',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.school).icon.icon,
      iconColor: Colors.grey,
      createdBy: createdBy,
    ),

    //Shopping
    Category(
      name: 'Shopping',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.shop).icon.icon,
      iconColor: Colors.cyan,
      createdBy: createdBy,
    ),
    Category(
      name: 'Offer',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.offer).icon.icon,
      iconColor: Colors.green,
      createdBy: createdBy,
    ),

    //Transport
    Category(
      name: 'Taxi',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.taxi).icon.icon,
      iconColor: Colors.yellow,
      createdBy: createdBy,
    ),
    Category(
      name: 'Bus',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.bus).icon.icon,
      iconColor: Colors.black,
      createdBy: createdBy,
    ),
    Category(
      name: 'Car',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.car).icon.icon,
      iconColor: Colors.red,
      createdBy: createdBy,
    ),
    Category(
      name: 'Subway',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.subway).icon.icon,
      iconColor: Colors.grey,
      createdBy: createdBy,
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

Transaction _buildTransaction(
  int categoryId,
  String description,
  double amount,
  DateTime date, {
  int repetitions = 0,
  RepetitionCycleType cycle = RepetitionCycleType.none,
  DateTime nextRecurringDate,
}) {
  return Transaction(
    amount: amount,
    categoryId: categoryId,
    description: description,
    transactionDate: date,
    repetitionCycle: cycle,
    createdBy: createdBy,
    isParentTransaction: cycle != RepetitionCycleType.none,
    nextRecurringDate: nextRecurringDate,
  );
}
