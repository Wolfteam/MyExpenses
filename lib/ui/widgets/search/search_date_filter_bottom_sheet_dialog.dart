import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/search/search_bloc.dart';
import '../../../common/enums/app_language_type.dart';
import '../../../common/extensions/string_extensions.dart';
import '../../../common/styles.dart';
import '../../../common/utils/i18n_utils.dart';
import '../../../generated/i18n.dart';
import '../modal_sheet_separator.dart';
import '../modal_sheet_title.dart';

class SearchDateFilterBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
    final i18n = I18n.of(context);
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
          FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () => _changeDate(context, s.tempFrom ?? now, s.currentLanguage, true),
            child: Align(alignment: Alignment.centerLeft, child: Text(startText)),
          ),
          Text('${i18n.untilDate}:'),
          FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () => _changeDate(context, s.tempUntil ?? now, s.currentLanguage, false),
            child: Align(alignment: Alignment.centerLeft, child: Text(untilText)),
          ),
          Divider(color: theme.accentColor),
          _buildBottomButtonBar(context),
        ];
      },
    );
  }

  Widget _buildBottomButtonBar(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    return ButtonBar(
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      children: <Widget>[
        OutlineButton(
          onPressed: () => _closeModal(context),
          child: Text(i18n.close, style: TextStyle(color: theme.primaryColor)),
        ),
        OutlineButton(
          onPressed: () => _clearFilters(context),
          child: Text(i18n.clear, style: TextStyle(color: theme.primaryColor)),
        ),
        RaisedButton(
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
      context.bloc<SearchBloc>().tempFromDateChanged(selectedDate);
    } else {
      context.bloc<SearchBloc>().tempToDateChanged(selectedDate);
    }
  }

  void _closeModal(BuildContext context) {
    Navigator.pop(context);
  }

  void _clearFilters(BuildContext context) {
    context.bloc<SearchBloc>().tempFromDateChanged(null);
    context.bloc<SearchBloc>().tempToDateChanged(null);
  }

  Future<void> _applyDates(BuildContext context) {
    _closeModal(context);
    return context.bloc<SearchBloc>().applyTempDates();
  }
}
