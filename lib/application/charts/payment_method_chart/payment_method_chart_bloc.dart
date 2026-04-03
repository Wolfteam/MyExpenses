import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/entities/daos/payment_methods_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:my_expenses/presentation/charts/widgets/chart_colors.dart';

part 'payment_method_chart_bloc.freezed.dart';
part 'payment_method_chart_event.dart';
part 'payment_method_chart_state.dart';

class PaymentMethodChartBloc extends Bloc<PaymentMethodChartEvent, PaymentMethodChartState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final PaymentMethodsDao _paymentMethodsDao;

  PaymentMethodChartBloc(this._logger, this._transactionsDao, this._usersDao, this._paymentMethodsDao)
    : super(const PaymentMethodChartState.loaded(loaded: false, methods: [])) {
    on<PaymentMethodChartEventLoad>((event, emit) async {
      final user = await _usersDao.getActiveUser();
      _logger.info(runtimeType, 'load: from=${event.from} to=${event.to}');
      final transactions = await _transactionsDao.getAllTransactions(user?.id, event.from, event.to);
      final paymentMethods = await _paymentMethodsDao.getAll(
        user?.id,
        includeArchived: true,
      );
      emit(PaymentMethodChartState.loaded(
        loaded: true,
        methods: _buildMethods(transactions, paymentMethods),
      ));
    });
  }

  List<PaymentMethodChartItem> _buildMethods(
    List<TransactionItem> transactions,
    List<PaymentMethodItem> paymentMethods,
  ) {
    final expenseTransactions = transactions.where((t) => !t.category.isAnIncome).toList();
    final grouped = <String, double>{};

    for (final t in expenseTransactions) {
      final key = t.paymentMethodName ?? '';
      grouped[key] = TransactionUtils.roundDouble((grouped[key] ?? 0) + t.amount.abs());
    }

    final total = grouped.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return [];
    }

    return grouped.entries
        .sortedByCompare((e) => e.value, (a, b) => b.compareTo(a))
        .mapIndexed((index, e) {
      final method = paymentMethods.firstWhereOrNull(
        (m) => m.name == e.key,
      );
      return PaymentMethodChartItem(
        methodName: e.key,
        icon: method?.icon ??
            ChartColors.defaultPaymentMethodIcon(method?.type),
        iconColor: method?.iconColor ??
            ChartColors.fromIndex(index),
        total: e.value,
        percentage: TransactionUtils.roundDouble(
          (e.value / total) * 100,
        ),
        type: method?.type,
      );
    }).toList();
  }
}
