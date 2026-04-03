import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/shared/common_dropdown_button.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_title.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/enum_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';

class ReportsBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocProvider<ReportsBloc>(
          create: (ctx) => Injection.getReportsBloc(ctx.read<CurrencyBloc>()),
          child: const _Body(),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocConsumer<ReportsBloc, ReportState>(
      listener: (ctx, state) {
        switch (state) {
          case ReportStateInitialState():
            if (state.errorOccurred) {
              ToastUtils.showErrorToast(ctx, i18n.unknownErrorOcurred);
            }
          case ReportStateGeneratedState():
            Navigator.pop(context);
        }
      },
      builder: (ctx, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: switch (state) {
          final ReportStateInitialState state when state.generatingReport => [
            const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
          ],
          ReportStateInitialState() => [
            ModalSheetSeparator(),
            ModalSheetTitle(title: i18n.exportFrom),
            Text('${i18n.startDate} - ${i18n.endDate}:'),
            TextButton.icon(
              icon: const Icon(Icons.date_range),
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _pickDateRange(context, state),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${utils.DateUtils.formatDateWithoutLocale(
                    state.from,
                    utils.DateUtils.monthDayAndYearFormat,
                  )}'
                  ' - '
                  '${utils.DateUtils.formatDateWithoutLocale(
                    state.to,
                    utils.DateUtils.monthDayAndYearFormat,
                  )}',
                ),
              ),
            ),
            Text(i18n.reportFormat),
            CommonDropdownButton<ReportFileType>(
              hint: i18n.selectFormat,
              currentValue: state.selectedFileType,
              values: ReportFileType.values.map((el) => TranslatedEnum(el, i18n.getReportFileTypeName(el))).toList(),
              onChanged: (newValue, _) => _reportFileTypeChanged(context, newValue),
            ),
            Text(i18n.paymentMethods),
            BlocProvider<PaymentMethodPickerBloc>(
              create: (_) =>
                  Injection.paymentMethodPickerBloc
                    ..add(PaymentMethodPickerEvent.load(initialSelectedId: state.selectedPaymentMethodId)),
              child: BlocBuilder<PaymentMethodPickerBloc, PaymentMethodPickerState>(
                builder: (ctx, pmState) => switch (pmState) {
                  final PaymentMethodPickerStateLoadedState s => CommonDropdownButton<int?>(
                    hint: i18n.paymentMethods,
                    currentValue: state.selectedPaymentMethodId,
                    values: [
                      TranslatedEnum(null, i18n.all),
                      TranslatedEnum(
                        0,
                        i18n.paymentMethodUnknownNone,
                      ),
                      ...s.items.map(
                        (m) => TranslatedEnum(m.id, m.name),
                      ),
                    ],
                    onChanged: (newValue, _) => context.read<ReportsBloc>().add(
                      ReportsEvent.paymentMethodChanged(
                        selectedPaymentMethodId: newValue,
                      ),
                    ),
                  ),
                  _ => const SizedBox(
                    height: 48,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                },
              ),
            ),
            SwitchListTile(
              value: state.groupByPaymentMethod,
              onChanged: (v) => context.read<ReportsBloc>().add(ReportsEvent.groupByPaymentMethodChanged(value: v)),
              title: Text(i18n.groupByPaymentMethod, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 8),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(i18n.cancel),
                ),
                FilledButton(onPressed: () => _generateReport(context), child: Text(i18n.generate)),
              ],
            ),
          ],
          ReportStateGeneratedState() => [],
        },
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    ReportStateInitialState state,
  ) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      initialDateRange: DateTimeRange(
        start: state.from,
        end: state.to,
      ),
    );
    if (result == null || !context.mounted) return;
    context.read<ReportsBloc>().add(
      ReportsEvent.fromDateChanged(selectedDate: result.start),
    );
    context.read<ReportsBloc>().add(
      ReportsEvent.toDateChanged(selectedDate: result.end),
    );
  }

  void _reportFileTypeChanged(BuildContext context, ReportFileType newValue) =>
      context.read<ReportsBloc>().add(ReportsEvent.fileTypeChanged(selectedFileType: newValue));

  void _generateReport(BuildContext context) {
    final translations = S.of(context).getReportTranslations();
    context.read<ReportsBloc>().add(ReportsEvent.generateReport(translations: translations));
  }
}
