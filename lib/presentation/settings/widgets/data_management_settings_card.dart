import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/settings/widgets/restart_warning.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';

class DataManagementSettingsCard extends StatelessWidget {
  const DataManagementSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Injection.dataTransferBloc,
      child: const _DataManagementCardContent(),
    );
  }
}

class _DataManagementCardContent extends StatelessWidget {
  const _DataManagementCardContent();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocListener<DataTransferBloc, DataTransferState>(
      listener: (context, state) {
        switch (state) {
          case DataTransferStateSuccess():
            final msg = switch (state.operation) {
              DataTransferOperation.export => i18n.exportSuccess,
              DataTransferOperation.import => i18n.importSuccess,
              DataTransferOperation.clearAll => i18n.clearSuccess,
            };
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          case DataTransferStateError():
            final msg = switch (state.operation) {
              DataTransferOperation.export => i18n.exportError,
              DataTransferOperation.import => i18n.importError(''),
              DataTransferOperation.clearAll => i18n.clearError,
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            );
          case DataTransferStateImportValidationError():
            final msg = switch (state.validationError) {
              ImportValidationErrorInvalidFormat() => i18n.invalidImportFile,
              ImportValidationErrorMissingField(:final field) => i18n.invalidImportFileMissingFields(field),
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            );
          default:
            break;
        }
      },
      child: BlocBuilder<DataTransferBloc, DataTransferState>(
        builder: (context, state) {
          final isLoading = state is DataTransferStateLoading;
          return SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsCardTitleText(
                  text: i18n.dataManagement,
                  icon: const Icon(Icons.storage),
                ),
                SettingsCardSubtitleText(text: i18n.dataManagementSubtitle),
                const SizedBox(height: 4),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.upload),
                          onPressed: () => _onExportPressed(context),
                          label: Text(i18n.exportData, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.download),
                          onPressed: () => _onImport(context),
                          label: Text(i18n.importData, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      icon: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                      onPressed: () => _onClearAll(context),
                      label: Text(
                        i18n.clearAllData,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ],
                const RestartWarning(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onExportPressed(BuildContext context) async {
    final i18n = S.of(context);
    final isCsv = await showDialog<bool>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(i18n.selectExportFormat),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, false),
            child: const ListTile(
              leading: Icon(Icons.code),
              title: Text('JSON'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, true),
            child: ListTile(
              leading: const Icon(Icons.table_chart),
              title: Text(i18n.csv),
            ),
          ),
        ],
      ),
    );
    if (isCsv == null || !context.mounted) return;
    _onExport(context, isCsv: isCsv);
  }

  void _onExport(BuildContext context, {required bool isCsv}) {
    final i18n = S.of(context);
    context.read<DataTransferBloc>().add(
      DataTransferEvent.export(
        isCsv: isCsv,
        csvLabels: isCsv
            ? (
                date: i18n.date,
                description: i18n.description,
                amount: i18n.amount,
                category: i18n.category,
                type: i18n.type,
                paymentMethod: i18n.paymentMethodFieldTitle,
                income: i18n.income,
                expense: i18n.expenses,
                longDescription: i18n.longDescription,
                repetitionCycle: i18n.repetitionCycle,
                isRecurring: i18n.isRecurring,
                yes: i18n.yes,
                no: i18n.no,
                auto: i18n.auto,
                repetitionCycleNone: i18n.none,
                repetitionCycleEachDay: i18n.eachDay,
                repetitionCycleEachWeek: i18n.eachWeek,
                repetitionCycleEachMonth: i18n.eachMonth,
                repetitionCycleBiweekly: i18n.biweekly,
                repetitionCycleEachYear: i18n.eachYear,
              )
            : null,
      ),
    );
  }

  Future<void> _onImport(BuildContext context) async {
    final i18n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(i18n.importConfirmTitle),
        content: Text(i18n.importConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(i18n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(i18n.yes),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;

    context.read<DataTransferBloc>().add(
      DataTransferEvent.import(filePath: result.files.single.path!),
    );
  }

  Future<void> _onClearAll(BuildContext context) async {
    final i18n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(i18n.clearConfirmTitle),
        content: Text(i18n.clearConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(i18n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(i18n.yes),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.read<DataTransferBloc>().add(const DataTransferEvent.clearAll());
  }
}
