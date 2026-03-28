import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';

class ChartsPeriodFilter extends StatelessWidget {
  const ChartsPeriodFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is! ChartsStateLoaded) return const SizedBox.shrink();
        final selected = state.selectedPeriod;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PeriodChip(label: i18n.last30Days, period: ChartPeriodType.last30days, selected: selected),
              _PeriodChip(label: i18n.last3Months, period: ChartPeriodType.last3months, selected: selected),
              _PeriodChip(label: i18n.last12Months, period: ChartPeriodType.last12months, selected: selected),
              _PeriodChip(label: i18n.allTime, period: ChartPeriodType.allTime, selected: selected),
              _CustomRangeChip(selected: selected),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final ChartPeriodType period;
  final ChartPeriodType selected;

  const _PeriodChip({required this.label, required this.period, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected == period,
        onSelected: (_) => context.read<ChartsBloc>().add(ChartsEvent.periodChanged(period: period)),
      ),
    );
  }
}

class _CustomRangeChip extends StatelessWidget {
  final ChartPeriodType selected;

  const _CustomRangeChip({required this.selected});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return FilterChip(
      label: Text(i18n.customRange),
      selected: selected == ChartPeriodType.custom,
      onSelected: (_) => _pickCustomRange(context),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
    );
    if (result == null || !context.mounted) {
      return;
    }
    context.read<ChartsBloc>().add(
      ChartsEvent.customRangeSelected(start: result.start, end: result.end),
    );
  }
}
