part of '../add_edit_transaction_page.dart';

typedef OnCategoryChanged = void Function(CategoryItem);

class AddEditTransactionHeader extends StatelessWidget {
  final bool isParentTransaction;
  final DateTime? nextRecurringDate;
  final bool isRecurringTransactionRunning;
  final String transactionDateString;
  final double amount;
  final RepetitionCycleType repetitionCycle;
  final String description;
  final bool isChildTransaction;
  final CategoryItem category;
  final OnCategoryChanged onCategoryChanged;

  const AddEditTransactionHeader({
    super.key,
    required this.isParentTransaction,
    this.nextRecurringDate,
    required this.isRecurringTransactionRunning,
    required this.transactionDateString,
    required this.amount,
    required this.repetitionCycle,
    required this.description,
    required this.isChildTransaction,
    required this.category,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    const cornerRadius = Radius.circular(20);
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final dateString = isParentTransaction && nextRecurringDate != null && isRecurringTransactionRunning
        ? i18n.nextDateOn(
            utils.DateUtils.formatDateWithoutLocale(nextRecurringDate, utils.DateUtils.monthDayAndYearFormat),
          )
        : '${i18n.date}: $transactionDateString';

    final formattedAmount = context.watch<CurrencyBloc>().format(amount);
    final repetitionCycleType = i18n.translateRepetitionCycleType(repetitionCycle);
    final Color? transactionColor = category.id <= 0
        ? null
        : category.isAnIncome
        ? Colors.green
        : Colors.red;

    return SizedBox(
      height: 260.0,
      child: Stack(
        children: <Widget>[
          Container(height: 150, color: theme.colorScheme.primary),
          Container(
            padding: const EdgeInsets.only(top: 60.0, left: 10.0, right: 10.0, bottom: 10.0),
            child: Material(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: cornerRadius,
                  bottomRight: cornerRadius,
                  topLeft: cornerRadius,
                  topRight: cornerRadius,
                ),
              ),
              elevation: 5.0,
              child: Container(
                margin: Styles.edgeInsetHorizontal16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 40.0),
                    Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(dateString, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Tooltip(
                              message: formattedAmount,
                              child: Text(
                                formattedAmount,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge!.copyWith(color: transactionColor),
                              ),
                            ),
                            subtitle: Text(
                              i18n.amount.toUpperCase(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Tooltip(
                              message: repetitionCycleType,
                              child: Text(
                                repetitionCycleType,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            subtitle: Text(
                              i18n.repetitions.toUpperCase(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 10,
              color: theme.cardColor.withValues(alpha: 0.8),
              type: MaterialType.circle,
              child: IconButton(
                iconSize: 80,
                icon: FaIcon(category.icon),
                color: category.iconColor,
                onPressed: !isChildTransaction ? () => _changeCategory(context) : null,
                disabledColor: category.iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeCategory(BuildContext context) async {
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(context, listen: false);

    if (category.id > 0) {
      selectedCatProvider.currentSelectedItem = category;
    }

    final route = MaterialPageRoute<CategoryItem>(
      builder: (ctx) => CategoriesPage(isInSelectionMode: true, selectedCategory: category),
    );
    final selectedCat = await Navigator.of(context).push(route);

    selectedCatProvider.currentSelectedItem = null;

    if (selectedCat != null) {
      onCategoryChanged(selectedCat);
    }
  }
}
