import 'package:flutter/material.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as date_utils;

class HomeWelcome extends StatelessWidget {
  const HomeWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateString = date_utils.DateUtils.formatDateWithoutLocale(now, date_utils.DateUtils.dayNameStringFormat);
    //todo: complete this
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Icon(Icons.menu),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Hello',
                style: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Jan 10, 2024',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: CircleAvatar(
            backgroundColor: Colors.purple,
          ),
        ),
      ],
    );
  }
}
