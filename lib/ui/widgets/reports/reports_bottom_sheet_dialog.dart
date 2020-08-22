import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/reports/reports_bloc.dart';
import '../../../common/enums/report_file_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/utils/notification_utils.dart';
import '../../../common/utils/toast_utils.dart';
import '../../../generated/i18n.dart';
import '../../../models/app_notification.dart';
import '../modal_sheet_separator.dart';
import '../modal_sheet_title.dart';

class ReportsBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: BlocConsumer<ReportsBloc, ReportState>(
          listener: (ctx, state) async {
            final i18n = I18n.of(context);
            if (state is ReportSheetState) {
              await requestIOSPermissions();

              if (state.errorOccurred) {
                showErrorToast(i18n.unknownErrorOcurred);
              }
            }

            if (state is ReportGeneratedState) {
              showNotification(
                i18n.transactionsReport,
                '${i18n.reportWasSuccessfullyGenerated(state.fileName)}.\n${i18n.tapToOpen}',
                jsonEncode(AppNotification.openPdf(state.filePath)),
              );
              Navigator.pop(context);
            }
          },
          builder: (ctx, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildPage(context, state),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPage(
    BuildContext context,
    ReportState state,
  ) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);

    if (state is ReportSheetState) {
      if (state.generatingReport) {
        return [
          Container(
            height: 300,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ];
      }

      return [
        ModalSheetSeparator(),
        ModalSheetTitle(title: i18n.exportFrom),
        Text('${i18n.startDate}:'),
        FlatButton(
            onPressed: () => _showDatePicker(context, state.from, true),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(state.fromDateString),
            )),
        Text('${i18n.endDate}:'),
        FlatButton(
          onPressed: () => _showDatePicker(context, state.to, false),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(state.toDateString),
          ),
        ),
        Text(i18n.reportFormat),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          child: DropdownButton<ReportFileType>(
            isExpanded: true,
            hint: Text(i18n.selectFormat),
            underline: Container(height: 0, color: Colors.transparent),
            value: state.selectedFileType,
            items: _buildDropdownItems(context),
            onChanged: (newValue) => _reportFileTypeChanged(context, newValue),
          ),
        ),
        ButtonBar(
          buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
          children: <Widget>[
            OutlineButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                i18n.cancel,
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
            RaisedButton(
              color: theme.primaryColor,
              onPressed: () => _generateReport(context),
              child: Text(i18n.generate),
            ),
          ],
        )
      ];
    }

    return [];
  }

  List<DropdownMenuItem<ReportFileType>> _buildDropdownItems(
    BuildContext context,
  ) {
    final i18n = I18n.of(context);
    return ReportFileType.values.map((item) {
      return DropdownMenuItem<ReportFileType>(
        value: item,
        child: Text(i18n.getReportFileTypeName(item)),
      );
    }).toList();
  }

  Future _showDatePicker(
    BuildContext context,
    DateTime initialDate,
    bool isFromDate,
  ) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    if (selectedDate == null) return;

    if (isFromDate) {
      context.bloc<ReportsBloc>().add(FromDateChanged(selectedDate));
    } else {
      context.bloc<ReportsBloc>().add(ToDateChanged(selectedDate));
    }
  }

  void _reportFileTypeChanged(
    BuildContext context,
    ReportFileType newValue,
  ) =>
      context.bloc<ReportsBloc>().add(FileTypeChanged(newValue));

  void _generateReport(BuildContext context) {
    final i18n = I18n.of(context);
    context.bloc<ReportsBloc>().add(GenerateReport(i18n));
  }
}
