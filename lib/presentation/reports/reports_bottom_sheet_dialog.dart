import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_title.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';

class ReportsBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: BlocProvider<ReportsBloc>(create: (ctx) => Injection.getReportsBloc(ctx.read<CurrencyBloc>()), child: const _Body()),
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
        state.map(
          initial: (state) {
            if (state.errorOccurred) {
              ToastUtils.showErrorToast(ctx, i18n.unknownErrorOcurred);
            }
          },
          generated: (state) {
            Navigator.pop(context);
          },
        );
      },
      builder:
          (ctx, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: state.map(
              initial: (state) {
                if (state.generatingReport) {
                  return const [SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))];
                }
                final fromDateString = utils.DateUtils.formatDateWithoutLocale(state.from, utils.DateUtils.monthDayAndYearFormat);
                final toDateString = utils.DateUtils.formatDateWithoutLocale(state.to, utils.DateUtils.monthDayAndYearFormat);

                return [
                  ModalSheetSeparator(),
                  ModalSheetTitle(title: i18n.exportFrom),
                  Text('${i18n.startDate}:'),
                  TextButton(
                    onPressed: () => _showDatePicker(context, state.from, true),
                    child: Align(alignment: Alignment.centerLeft, child: Text(fromDateString)),
                  ),
                  Text('${i18n.endDate}:'),
                  TextButton(
                    onPressed: () => _showDatePicker(context, state.to, false),
                    child: Align(alignment: Alignment.centerLeft, child: Text(toDateString)),
                  ),
                  Text(i18n.reportFormat),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: DropdownButton<ReportFileType>(
                      isExpanded: true,
                      hint: Text(i18n.selectFormat),
                      underline: Container(height: 0, color: Colors.transparent),
                      value: state.selectedFileType,
                      items:
                          ReportFileType.values
                              .map((item) => DropdownMenuItem<ReportFileType>(value: item, child: Text(i18n.getReportFileTypeName(item))))
                              .toList(),
                      onChanged: (newValue) => _reportFileTypeChanged(context, newValue!),
                    ),
                  ),
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
                ];
              },
              generated: (_) => [],
            ),
          ),
    );
  }

  Future _showDatePicker(BuildContext context, DateTime initialDate, bool isFromDate) async {
    final now = DateTime.now();
    await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
    ).then((selectedDate) {
      if (selectedDate == null || !context.mounted) {
        return;
      }

      if (isFromDate) {
        context.read<ReportsBloc>().add(ReportsEvent.fromDateChanged(selectedDate: selectedDate));
      } else {
        context.read<ReportsBloc>().add(ReportsEvent.toDateChanged(selectedDate: selectedDate));
      }
    });
  }

  void _reportFileTypeChanged(BuildContext context, ReportFileType newValue) =>
      context.read<ReportsBloc>().add(ReportsEvent.fileTypeChanged(selectedFileType: newValue));

  void _generateReport(BuildContext context) {
    final translations = S.of(context).getReportTranslations();
    context.read<ReportsBloc>().add(ReportsEvent.generateReport(translations: translations));
  }
}
