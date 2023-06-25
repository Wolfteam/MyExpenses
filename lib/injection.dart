import 'package:get_it/get_it.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/entities/daos/categories_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/infrastructure/background_service.dart';
import 'package:my_expenses/infrastructure/db/categories_dao_impl.dart';
import 'package:my_expenses/infrastructure/db/database.dart';
import 'package:my_expenses/infrastructure/db/transactions_dao_impl.dart';
import 'package:my_expenses/infrastructure/db/users_dao_impl.dart';
import 'package:my_expenses/infrastructure/infrastructure.dart';

final GetIt getIt = GetIt.instance;

class Injection {
  static SplashScreenBloc get splashScreenBloc {
    final settingsService = getIt<SettingsService>();
    return SplashScreenBloc(settingsService);
  }

  static PasswordDialogBloc get passwordDialogBloc {
    final logger = getIt<LoggingService>();
    final secureStorage = getIt<SecureStorageService>();
    return PasswordDialogBloc(logger, secureStorage);
  }

  static UserAccountsBloc getUserAccountsBloc(AppBloc appBloc) {
    final logger = getIt<LoggingService>();
    final categoriesDao = getIt<CategoriesDao>();
    final transactionsDao = getIt<TransactionsDao>();
    final usersDao = getIt<UsersDao>();
    final secureStorage = getIt<SecureStorageService>();
    final pathService = getIt<PathService>();
    final googleService = getIt<GoogleService>();
    final imageService = getIt<ImageService>();
    final syncService = getIt<SyncService>();
    final networkService = getIt<NetworkService>();
    return UserAccountsBloc(
      logger,
      categoriesDao,
      transactionsDao,
      usersDao,
      secureStorage,
      pathService,
      googleService,
      imageService,
      syncService,
      networkService,
      appBloc,
    );
  }

  static CategoryFormBloc get categoryFormBloc {
    final logger = getIt<LoggingService>();
    final categoriesDao = getIt<CategoriesDao>();
    final usersDao = getIt<UsersDao>();
    return CategoryFormBloc(logger, categoriesDao, usersDao);
  }

  static EstimatesBloc get estimatesBloc {
    final logger = getIt<LoggingService>();
    final settingsService = getIt<SettingsService>();
    final usersDao = getIt<UsersDao>();
    final transactionsDao = getIt<TransactionsDao>();
    return EstimatesBloc(logger, settingsService, usersDao, transactionsDao);
  }

  static SearchBloc get searchBloc {
    final logger = getIt<LoggingService>();
    final settingsService = getIt<SettingsService>();
    final usersDao = getIt<UsersDao>();
    final transactionsDao = getIt<TransactionsDao>();
    return SearchBloc(logger, transactionsDao, usersDao, settingsService);
  }

  static ReportsBloc getReportsBloc(CurrencyBloc currencyBloc) {
    final logger = getIt<LoggingService>();
    final transactionsDao = getIt<TransactionsDao>();
    final usersDao = getIt<UsersDao>();
    final pathService = getIt<PathService>();
    final notificationService = getIt<NotificationService>();
    final deviceInfoService = getIt<DeviceInfoService>();
    return ReportsBloc(logger, transactionsDao, pathService, notificationService, deviceInfoService, usersDao, currencyBloc);
  }

  static TransactionFormBloc get transactionFormBloc {
    final logger = getIt<LoggingService>();
    final transactionsDao = getIt<TransactionsDao>();
    final settingsService = getIt<SettingsService>();
    final usersDao = getIt<UsersDao>();
    final pathService = getIt<PathService>();
    final syncService = getIt<SyncService>();
    return TransactionFormBloc(logger, transactionsDao, usersDao, settingsService, pathService, syncService);
  }

  static Future<void> init() async {
    if (!getIt.isRegistered<NetworkService>()) {
      getIt.registerSingleton<NetworkService>(NetworkServiceImpl());
    }

    if (!getIt.isRegistered<TelemetryService>()) {
      final impl = TelemetryServiceImpl();
      await impl.init();
      getIt.registerSingleton<TelemetryService>(impl);
    }

    if (!getIt.isRegistered<DeviceInfoService>()) {
      final impl = DeviceInfoServiceImpl();
      await impl.init();
      getIt.registerSingleton<DeviceInfoService>(impl);
    }

    if (!getIt.isRegistered<LoggingService>()) {
      getIt.registerSingleton<LoggingService>(LoggingServiceImpl(getIt<TelemetryService>(), getIt<DeviceInfoService>()));
    }

    if (!getIt.isRegistered<PathService>()) {
      final impl = PathServiceImpl();
      getIt.registerSingleton<PathService>(impl);
    }

    if (!getIt.isRegistered<ImageService>()) {
      final impl = ImageServiceImpl(getIt<PathService>());
      getIt.registerSingleton<ImageService>(impl);
    }

    if (!getIt.isRegistered<NotificationService>()) {
      final impl = NotificationServiceImpl(getIt<LoggingService>());
      await impl.init();
      getIt.registerSingleton<NotificationService>(impl);
    }

    if (!getIt.isRegistered<SettingsService>()) {
      final settings = SettingsServiceImpl(getIt<LoggingService>());
      await settings.init();
      getIt.registerSingleton<SettingsService>(settings);
    }

    if (!getIt.isRegistered<AppDatabase>()) {
      getIt.registerSingleton<AppDatabase>(AppDatabase());
    }

    if (!getIt.isRegistered<CategoriesDao>()) {
      getIt.registerSingleton<CategoriesDao>(CategoriesDaoImpl(getIt<AppDatabase>()));
    }

    if (!getIt.isRegistered<TransactionsDao>()) {
      getIt.registerSingleton<TransactionsDao>(TransactionsDaoImpl(getIt<AppDatabase>()));
    }

    if (!getIt.isRegistered<UsersDao>()) {
      getIt.registerSingleton<UsersDao>(UsersDaoImpl(getIt<AppDatabase>()));
    }

    if (!getIt.isRegistered<SecureStorageService>()) {
      getIt.registerSingleton<SecureStorageService>(SecureStorageServiceImpl());
    }

    if (!getIt.isRegistered<GoogleService>()) {
      getIt.registerSingleton<GoogleService>(GoogleServiceImpl(getIt<LoggingService>(), getIt<SecureStorageService>()));
    }

    if (!getIt.isRegistered<NetworkService>()) {
      getIt.registerSingleton<NetworkService>(NetworkServiceImpl());
    }

    if (!getIt.isRegistered<SyncService>()) {
      getIt.registerSingleton<SyncService>(
        SyncServiceImpl(
          getIt<LoggingService>(),
          getIt<TransactionsDao>(),
          getIt<CategoriesDao>(),
          getIt<UsersDao>(),
          getIt<GoogleService>(),
          getIt<SecureStorageService>(),
          getIt<PathService>(),
        ),
      );
    }

    if (!getIt.isRegistered<BackgroundService>()) {
      final impl = await getBackgroundService();
      await impl.init();
      getIt.registerSingleton<BackgroundService>(impl);
    }
  }

  static Future<BackgroundService> getBackgroundService({bool forBgTask = false}) async {
    if (!forBgTask) {
      return BackgroundServiceImpl(
        getIt<NetworkService>(),
        getIt<SyncService>(),
        getIt<LoggingService>(),
        getIt<SettingsService>(),
        getIt<NotificationService>(),
        getIt<TransactionsDao>(),
        getIt<UsersDao>(),
        getIt<AppDatabase>(),
      );
    }

    //To avoid problems, its better to just get some instances manually
    final telemetryService = TelemetryServiceImpl();
    //For some reason the init does not work here...
    // await telemetryService.init();

    final deviceInfoService = DeviceInfoServiceImpl();
    await deviceInfoService.init();

    final loggingService = LoggingServiceImpl(telemetryService, deviceInfoService);
    final settingsService = SettingsServiceImpl(loggingService);
    await settingsService.init();

    final notificationService = NotificationServiceImpl(loggingService);
    await notificationService.init();

    final pathService = PathServiceImpl();
    final db = getIsolateDatabase();
    final transactionsDao = TransactionsDaoImpl(db);
    final categoriesDao = CategoriesDaoImpl(db);
    final usersDao = UsersDaoImpl(db);
    final secureStorage = SecureStorageServiceImpl();
    final googleService = GoogleServiceImpl(loggingService, secureStorage);
    final syncService = SyncServiceImpl(loggingService, transactionsDao, categoriesDao, usersDao, googleService, secureStorage, pathService);
    final networkService = NetworkServiceImpl();
    return BackgroundServiceImpl(
      networkService,
      syncService,
      loggingService,
      settingsService,
      notificationService,
      transactionsDao,
      usersDao,
      db,
    );
  }
}
