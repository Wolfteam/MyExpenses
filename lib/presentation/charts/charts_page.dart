import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/presentation/charts/widgets/monthly_bar_chart.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

//TODO: MAYBE IMPROVE THIS BLOC AND THE DETAILS ONE
class _ChartsPageState extends State<ChartsPage> with AutomaticKeepAliveClientMixin<ChartsPage>, TransactionMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: Styles.edgeInsetHorizontal10,
      child: BlocBuilder<ChartsBloc, ChartsState>(
        builder: (ctx, state) => CustomScrollView(
          controller: ScrollController(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 10),
              sliver: SliverToBoxAdapter(
                child: MonthlyBarChart(
                  currentMonthDate: state.currentMonthDate,
                  currentMonthDateString: state.currentMonthDateString,
                  currentYear: state.currentYear,
                  language: state.language,
                  totalIncomeAmount: state.totalIncomeAmount,
                  totalExpenseAmount: state.totalExpenseAmount,
                  transactions: state.transactions,
                  transactionsPerMonth: state.transactionsPerMonth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
