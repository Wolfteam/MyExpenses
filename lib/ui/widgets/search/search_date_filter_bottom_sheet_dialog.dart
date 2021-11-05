import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../../bloc/search/search_bloc.dart';
import '../../../common/enums/app_language_type.dart';
import '../../../common/extensions/string_extensions.dart';
import '../../../common/styles.dart';
import '../../../common/utils/i18n_utils.dart';
import '../modal_sheet_separator.dart';
import '../modal_sheet_title.dart';

class SearchDateFilterBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (ctx, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[..._buildPage(ctx, state)],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPage(BuildContext context, SearchState state) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final now = DateTime.now();
    return state.map(
      loading: (_) => [],
      initial: (s) {
        final startText = s.fromString.isNullEmptyOrWhitespace ? i18n.na : s.fromString;
        final untilText = s.untilString.isNullEmptyOrWhitespace ? i18n.na : s.untilString;
        return [
          ModalSheetSeparator(),
          ModalSheetTitle(title: i18n.filterByX(i18n.date.toLowerCase())),
          Text('${i18n.startDate}:'),
          TextButton(
            style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: () => _changeDate(context, s.tempFrom ?? now, s.currentLanguage, true),
            child: Align(alignment: Alignment.centerLeft, child: Text(startText!)),
          ),
          Text('${i18n.untilDate}:'),
          TextButton(
            style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: () => _changeDate(context, s.tempUntil ?? now, s.currentLanguage, false),
            child: Align(alignment: Alignment.centerLeft, child: Text(untilText!)),
          ),
          Divider(color: theme.colorScheme.secondary),
          _buildBottomButtonBar(context),
        ];
      },
    );
  }

  Widget _buildBottomButtonBar(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return ButtonBar(
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
    );
  }

  Future<void> _changeDate(
    BuildContext context,
    DateTime initialDate,
    AppLanguageType language,
    bool isFromDate,
  ) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      locale: currentLocale(language),
      firstDate: DateTime(now.year - 1),
      initialDate: initialDate,
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate == null) {
      return;
    }
    if (isFromDate) {
      context.read<SearchBloc>().add(SearchEvent.tempFromDateChanged(newValue: selectedDate));
    } else {
      context.read<SearchBloc>().add(SearchEvent.tempToDateChanged(newValue: selectedDate));
    }
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
