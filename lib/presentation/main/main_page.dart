import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/mobile_scaffold.dart';
import 'package:my_expenses/presentation/shared/dialogs/info_dialog.dart';
import 'package:my_expenses/presentation/shared/utils/i18n_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';
import 'package:my_expenses/presentation/transaction/add_edit_transaction_page.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rate_my_app/rate_my_app.dart';

class MainPage extends StatefulWidget {
  final bool showGoogleLoginChangesExplanation;

  const MainPage({
    Key? key,
    required this.showGoogleLoginChangesExplanation,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.showGoogleLoginChangesExplanation) {
        final s = S.of(context);
        showDialog(context: context, builder: (_) => InfoDialog(explanations: [s.googleLoginChangesExplanation]));
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.read<MainTabBloc>().add(const MainTabEvent.init());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainTabBloc, MainTabState>(
      listener: (ctx, state) async {
        final notificationService = getIt<NotificationService>();
        if (Platform.isIOS) {
          await notificationService.requestIOSPermissions();
        }
        if (!mounted) {
          return;
        }

        await notificationService.registerCallBacks(
          onIosReceiveLocalNotification: _onDidReceiveLocalNotification,
          onSelectNotification: _onSelectNotification,
        );
      },
      //TODO: DESKTOP SCAFFOLD
      child: Platform.isWindows
          ? MobileScaffold(
              defaultIndex: 0,
              tabController: _tabController,
            )
          : RateMyAppBuilder(
              rateMyApp: RateMyApp(minDays: 7, minLaunches: 10, remindDays: 7, remindLaunches: 10),
              onInitialized: (ctx, rateMyApp) async {
                if (!rateMyApp.shouldOpenDialog) {
                  return;
                }
                final s = S.of(ctx);
                await rateMyApp.showRateDialog(
                  ctx,
                  title: s.rateThisApp,
                  message: s.rateMsg,
                  rateButton: s.rate,
                  laterButton: s.maybeLater,
                  noButton: s.noThanks,
                );
              },
              builder: (context) => MobileScaffold(
                defaultIndex: 0,
                tabController: _tabController,
              ),
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<dynamic> _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    final i18n = S.of(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(i18n.ok),
          )
        ],
      ),
    );
  }

  Future<void> _onSelectNotification(String? json) async {
    if (json.isNullEmptyOrWhitespace) {
      return;
    }

    final settingsService = getIt<SettingsService>();
    final logger = getIt<LoggingService>();
//TODO: IF YOU OPEN THE NOTIFICATION WHILE THE APP IS CLOSED, NOTHING HAPPENS
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final notification = AppNotification.fromJson(jsonDecode(json!) as Map<String, dynamic>);

      final i18n = await getI18n(settingsService.language);
      switch (notification.type) {
        case NotificationType.openCsv:
        case NotificationType.openPdf:
          //open_file crashes while asking for permissions...
          //that's why whe ask for them before opening the file
          final granted = await Permission.storage.isGranted;
          if (!granted) {
            final result = await Permission.storage.request();
            if (!result.isGranted) {
              if (!mounted) {
                return;
              }
              ToastUtils.showWarningToast(context, i18n.openFilePermissionRequestFailedMsg);
              return;
            }
          }
          final file = File(notification.payload!);
          final fileExists = await file.exists();
          if (fileExists) {
            final openResult = await OpenFilex.open(file.path);
            if (!mounted) {
              return;
            }
            switch (openResult.type) {
              case ResultType.done:
                break;
              case ResultType.fileNotFound:
                ToastUtils.showInfoToast(context, i18n.fileNotFound(notification.payload!));
                break;
              case ResultType.noAppToOpen:
                ToastUtils.showInfoToast(context, i18n.noAppToOpenFile);
                break;
              case ResultType.permissionDenied:
                ToastUtils.showWarningToast(context, i18n.openFilePermissionRequestFailedMsg);
                break;
              case ResultType.error:
                ToastUtils.showErrorToast(context, i18n.unknownErrorOcurred);
                break;
            }
          }
          break;
        case NotificationType.openTransactionDetails:
          final transDao = getIt<TransactionsDao>();
          final transaction = await transDao.getTransaction(int.parse(notification.payload!));
          if (!mounted) {
            return;
          }
          final route = AddEditTransactionPage.editRoute(transaction, context);
          await Navigator.push(context, route);
          await route.completed;
          break;
        case NotificationType.msg:
          break;
      }
    } catch (e, s) {
      logger.error(runtimeType, 'Unknown error', e, s);
    }
  }
}
