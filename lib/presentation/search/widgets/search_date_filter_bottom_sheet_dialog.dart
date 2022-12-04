import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_title.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/i18n_utils.dart';

class SearchDateFilterBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final now = DateTime.now();
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return SingleChildScrollView(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (ctx, state) => state.map(
            loading: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            initial: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ModalSheetSeparator(),
                ModalSheetTitle(title: i18n.filterByX(i18n.date.toLowerCase())),
                Text('${i18n.startDate}:'),
                TextButton(
                  style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: textColor),
                  onPressed: () => _changeDate(context, state.tempFrom ?? now, state.currentLanguage, true),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text((state.fromString.isNullEmptyOrWhitespace ? i18n.na : state.fromString)!),
                  ),
                ),
                Text('${i18n.untilDate}:'),
                TextButton(
                  style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: textColor),
                  onPressed: () => _changeDate(context, state.tempUntil ?? now, state.currentLanguage, false),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text((state.untilString.isNullEmptyOrWhitespace ? i18n.na : state.untilString)!),
                  ),
                ),
                Divider(color: theme.colorScheme.secondary),
                ButtonBar(
                  layoutBehavior: ButtonBarLayoutBehavior.constrained,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () => _closeModal(context),
                      child: Text(i18n.close, style: TextStyle(color: theme.primaryColor)),
                    ),
                    OutlinedButton(
                      onPressed: () => _clearFilters(context),
                      child: Text(i18n.clear, style: TextStyle(color: theme.primaryColor)),
                    ),
                    ElevatedButton(
                      onPressed: () => _applyDates(context),
                      child: Text(i18n.apply),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeDate(BuildContext context, DateTime initialDate, AppLanguageType language, bool isFromDate) async {
    final now = DateTime.now();
    await showDatePicker(
      context: context,
      locale: currentLocale(language),
      firstDate: DateTime(now.year - 1),
      initialDate: initialDate,
      lastDate: DateTime(now.year + 1),
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      }
      if (isFromDate) {
        context.read<SearchBloc>().add(SearchEvent.tempFromDateChanged(newValue: selectedDate));
      } else {
        context.read<SearchBloc>().add(SearchEvent.tempToDateChanged(newValue: selectedDate));
      }
    });
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
