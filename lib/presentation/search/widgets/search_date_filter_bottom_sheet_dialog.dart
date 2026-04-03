import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_title.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class SearchDateFilterBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return SingleChildScrollView(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocBuilder<SearchBloc, SearchState>(
          builder:
              (ctx, state) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: switch (state) {
                  SearchStateLoadingState() => [],
                  SearchStateInitialState() => [
                    ModalSheetSeparator(),
                    ModalSheetTitle(title: i18n.filterByX(i18n.date.toLowerCase())),
                    TextButton.icon(
                      icon: const Icon(Icons.date_range),
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _pickDateRange(context, state),
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatDateRange(i18n, state),
                        ),
                      ),
                    ),
                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => _closeModal(context),
                          child: Text(i18n.close),
                        ),
                        TextButton(
                          onPressed: () => _clearFilters(context),
                          child: Text(i18n.clear),
                        ),
                        FilledButton(
                          onPressed: () => _applyDates(context),
                          child: Text(i18n.apply),
                        ),
                      ],
                    ),
                  ],
                },
              ),
        ),
      ),
    );
  }

  String _formatDateRange(S i18n, SearchStateInitialState state) {
    final from = state.fromString;
    final until = state.untilString;
    if (from.isNullEmptyOrWhitespace && until.isNullEmptyOrWhitespace) {
      return i18n.selectDateRange;
    }
    return '${from.isNullEmptyOrWhitespace ? i18n.na : from!}'
        ' - '
        '${until.isNullEmptyOrWhitespace ? i18n.na : until!}';
  }

  Future<void> _pickDateRange(
    BuildContext context,
    SearchStateInitialState state,
  ) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: state.tempFrom != null && state.tempUntil != null
          ? DateTimeRange(start: state.tempFrom!, end: state.tempUntil!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
    );
    if (result == null || !context.mounted) return;
    context.read<SearchBloc>().add(
      SearchEvent.tempFromDateChanged(newValue: result.start),
    );
    context.read<SearchBloc>().add(
      SearchEvent.tempToDateChanged(newValue: result.end),
    );
  }

  void _closeModal(BuildContext context) {
    Navigator.pop(context);
  }

  void _clearFilters(BuildContext context) {
    context.read<SearchBloc>().add(const SearchEvent.tempFromDateChanged());
    context.read<SearchBloc>().add(const SearchEvent.tempToDateChanged());
  }

  void _applyDates(BuildContext context) {
    _closeModal(context);
    context.read<SearchBloc>().add(const SearchEvent.applyTempDates());
  }
}
