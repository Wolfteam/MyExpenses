import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
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
                          onPressed: () => _onExport(context),
                          label: Text(i18n.exportData),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.download),
                          onPressed: () => _onImport(context),
                          label: Text(i18n.importData),
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
              ],
            ),
          );
        },
      ),
    );
  }

  void _onExport(BuildContext context) {
    context.read<DataTransferBloc>().add(const DataTransferEvent.export());
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
