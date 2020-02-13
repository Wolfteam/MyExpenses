import 'package:flutter/material.dart';

import '../../common/utils/category_utils.dart';
import '../../models/entities/database.dart';

const createdBy = "ebastidas";

List<Category> getDefaultCategories() {
  var categories = [
    //Income
    Category(
      name: 'Money',
      isAnIncome: true,
      icon: CategoryUtils.getByName(CategoryUtils.money2).icon.icon,
      iconColor: Colors.green.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Bank',
      isAnIncome: true,
      icon: CategoryUtils.getByName(CategoryUtils.bank).icon.icon,
      iconColor: Colors.black.value,
      createdBy: createdBy,
    ),

    //Food
    Category(
      name: 'Fast Food',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.fastFood).icon.icon,
      iconColor: Colors.red.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Restaurant',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.restaurant).icon.icon,
      iconColor: Colors.brown.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Cafe',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.cafe).icon.icon,
      iconColor: Colors.orange.value,
      createdBy: createdBy,
    ),

    //Home
    Category(
      name: 'Gas',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.gas).icon.icon,
      iconColor: Colors.blueAccent.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Water',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.waterDrop).icon.icon,
      iconColor: Colors.blue.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Light',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.battery).icon.icon,
      iconColor: Colors.yellow.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Phone',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.smartphone).icon.icon,
      iconColor: Colors.green.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'TV',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.tv).icon.icon,
      iconColor: Colors.brown.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Internet',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.web).icon.icon,
      iconColor: Colors.blueAccent.value,
      createdBy: createdBy,
    ),

    //life
    Category(
      name: 'Games',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.gamepad).icon.icon,
      iconColor: Colors.indigo.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Movies',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.movies).icon.icon,
      iconColor: Colors.grey.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Sports',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.soccerBall).icon.icon,
      iconColor: Colors.black.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Health',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.healing).icon.icon,
      iconColor: Colors.red.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Pharmacy',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.pharmacy).icon.icon,
      iconColor: Colors.red.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Education',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.school).icon.icon,
      iconColor: Colors.grey.value,
      createdBy: createdBy,
    ),

    //Shopping
    Category(
      name: 'Shopping',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.shop).icon.icon,
      iconColor: Colors.cyan.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Offer',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.offer).icon.icon,
      iconColor: Colors.green.value,
      createdBy: createdBy,
    ),

    //Transport
    Category(
      name: 'Taxi',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.taxi).icon.icon,
      iconColor: Colors.yellow.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Bus',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.bus).icon.icon,
      iconColor: Colors.black.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Car',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.car).icon.icon,
      iconColor: Colors.red.value,
      createdBy: createdBy,
    ),
    Category(
      name: 'Subway',
      isAnIncome: false,
      icon: CategoryUtils.getByName(CategoryUtils.subway).icon.icon,
      iconColor: Colors.grey.value,
      createdBy: createdBy,
    ),
  ];

  return categories;
}

List<Transaction> getDefaultTransactions() {
  var transactions = [
    Transaction(
      amount: -10,
      categoryId: 4,
      description: "SuperMaxi",
      transactionDate: DateTime.now(),
      repetitions: 0,
      createdBy: createdBy,
    ),
    Transaction(
      amount: -50,
      categoryId: 5,
      description: "Almuerzos",
      transactionDate: DateTime.now(),
      repetitions: 0,
      createdBy: createdBy,
    ),
    Transaction(
      amount: -400,
      categoryId: 7,
      description: "PS4",
      transactionDate: DateTime.now().add(Duration(days: -2)),
      repetitions: 0,
      createdBy: createdBy,
    ),
    Transaction(
      amount: -59,
      categoryId: 8,
      description: "Reparaciones",
      transactionDate: DateTime.now().add(Duration(days: -3)),
      repetitions: 0,
      createdBy: createdBy,
    ),
  ];

  return transactions;
}
