import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';

class EmptyChartPreview extends StatelessWidget {
  final IconData icon;

  const EmptyChartPreview({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.grey),
          const SizedBox(height: 4),
          Text(
            S.of(context).noDataForThisPeriod,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
