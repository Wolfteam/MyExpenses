import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../bloc/search/search_bloc.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/enums/transaction_filter_type.dart';
import '../../common/enums/transaction_type.dart';
import '../../common/extensions/scroll_controller_extensions.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/styles.dart';
import '../../generated/i18n.dart';
import '../../models/category_item.dart';
import '../../models/current_selected_category.dart';
import '../../models/transaction_item.dart';
import '../widgets/nothing_found.dart';
import '../widgets/search/search_amount_filter_bottom_sheet_dialog.dart';
import '../widgets/search/search_date_filter_bottom_sheet_dialog.dart';
import '../widgets/sort_direction_popupmenu_filter.dart';
import '../widgets/transactions/transaction_item_card_container.dart';
import '../widgets/transactions/transaction_popupmenu_filter.dart';
import 'categories_page.dart';

class SearchPage extends StatefulWidget {
  static MaterialPageRoute route() {
    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => SearchPage(),
    );
    return route;
  }

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final _searchFocusNode = FocusNode();

  ScrollController _scrollController;
  TextEditingController _searchBoxTextController;
  AnimationController _hideFabAnimController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchBoxTextController = TextEditingController(text: '');
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
    _searchBoxTextController.addListener(_onSearchTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    final scaffold = Scaffold(
      appBar: AppBar(title: Text(i18n.search)),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [..._buildPage(state)],
          ),
        ),
      ),
      floatingActionButton: _buildFab(),
    );

    return scaffold;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchBoxTextController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  List<Widget> _buildPage(SearchState state) {
    final i18n = I18n.of(context);
    return state.map(
      loading: (_) => [const Center(child: CircularProgressIndicator())],
      initial: (s) => [
        _buildSearchBox(!s.description.isNullEmptyOrWhitespace, i18n),
        _buildFilterBar(s.amount, s.category, s.transactionFilterType, s.sortDirectionType, s.transactionType),
        Padding(
          padding: Styles.edgeInsetAll10,
          child: Text(i18n.transactions, textAlign: TextAlign.start, style: Theme.of(context).textTheme.headline6),
        ),
        _buildTransactionCards(s.transactions, i18n)
      ],
    );
  }

  Widget _buildSearchBox(bool showCleanButton, I18n i18n) {
    final theme = Theme.of(context);

    return Card(
      elevation: 10,
      margin: Styles.edgeInsetAll10,
      shape: Styles.floatingCardShape,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Icon(Icons.search, size: 30),
          ),
          Expanded(
            child: TextField(
              controller: _searchBoxTextController,
              focusNode: _searchFocusNode,
              cursorColor: theme.accentColor,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                hintText: '${i18n.search}...',
              ),
            ),
          ),
          if (showCleanButton)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cleanSearchText,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    double currentAmountFilter,
    CategoryItem category,
    TransactionFilterType transactionFilterType,
    SortDirectionType sortDirectionType,
    TransactionType transactionType,
  ) {
    final i18n = I18n.of(context);
    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      overflowDirection: VerticalDirection.down,
      buttonPadding: Styles.edgeInsetAll0,
      children: [
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _showDateFilterBottomSheet,
          tooltip: i18n.transactionDate,
        ),
        IconButton(
          icon: const Icon(Icons.attach_money),
          onPressed: () => _showAmountFilterBottomSheet(currentAmountFilter),
          tooltip: i18n.amount,
        ),
        IconButton(
          icon: const Icon(Icons.category),
          onPressed: () => _showCategoriesPage(category),
          tooltip: i18n.category,
        ),
        TransactionPoupMenuFilter(
          selectedValue: transactionFilterType,
          onSelected: _transactionFilterTypeChanged,
          exclude: const [TransactionFilterType.category],
        ),
        SortDirectionPopupMenuFilter(
          selectedSortDirection: sortDirectionType,
          onSelected: _sortDirectionChanged,
        ),
        _buildTransactionTypePopupNenu(transactionType),
      ],
    );
  }

  Widget _buildTransactionTypePopupNenu(TransactionType transactionType) {
    final i18n = I18n.of(context);
    const nothingSelected = -1;
    return PopupMenuButton<int>(
      padding: Styles.edgeInsetAll0,
      tooltip: i18n.transactionType,
      initialValue: transactionType == null ? nothingSelected : transactionType.index,
      onSelected: _transactionTypeChanged,
      itemBuilder: (context) => <PopupMenuEntry<int>>[
        CheckedPopupMenuItem<int>(
          checked: transactionType == null,
          value: nothingSelected,
          child: Text(i18n.na),
        ),
        CheckedPopupMenuItem<int>(
          checked: transactionType == TransactionType.incomes,
          value: TransactionType.incomes.index,
          child: Text(i18n.incomes),
        ),
        CheckedPopupMenuItem<int>(
          checked: transactionType == TransactionType.expenses,
          value: TransactionType.expenses.index,
          child: Text(i18n.expenses),
        )
      ],
    );
  }

  Widget _buildTransactionCards(
    List<TransactionItem> transactions,
    I18n i18n,
  ) {
    if (transactions.isNotEmpty) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: transactions.length,
        itemBuilder: (context, index) => TransactionItemCardContainer(item: transactions[index]),
      );
    }
//TODO: CHANGE THE MSG
    return NothingFound(
      msg: i18n.noTransactionsForThisPeriod,
    );
  }

  Widget _buildFab() {
    return FadeTransition(
      opacity: _hideFabAnimController,
      child: ScaleTransition(
        scale: _hideFabAnimController,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: _goToTheTop,
          child: const Icon(Icons.arrow_upward),
        ),
      ),
    );
  }

  void _goToTheTop() =>
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);

//TODO: I THINK THE CATEGORIES FILTER SHOULD ONLY VE VISIBLE WHEN A USER IS LOGGED IN
  Future<void> _onSearchTextChanged() => context.bloc<SearchBloc>().descriptionChanged(_searchBoxTextController.text);

  void _cleanSearchText() {
    _searchFocusNode.requestFocus();
    if (_searchBoxTextController.text.isEmpty) {
      return;
    }
    _searchBoxTextController.text = '';
  }

  void _removeSearchFocus() => FocusScope.of(context).unfocus();

  void _showDateFilterBottomSheet() {
    _removeSearchFocus();
    context.bloc<SearchBloc>().resetTempDates();
    showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => SearchDateFilterBottomSheetDialog(),
    );
  }

  void _showAmountFilterBottomSheet(double initialAmount) {
    _removeSearchFocus();
    context.bloc<SearchBloc>().resetTempDates();
    showModalBottomSheet(
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => SearchAmountFilterBottomSheetDialog(initialAmount: initialAmount),
    );
  }

  Future<void> _showCategoriesPage(CategoryItem category) async {
    _removeSearchFocus();
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(
      context,
      listen: false,
    );

    if (category != null && category.id > 0) {
      selectedCatProvider.currentSelectedItem = category;
    }

    final route = MaterialPageRoute<CategoryItem>(
      builder: (ctx) => CategoriesPage(isInSelectionMode: true, showDeselectButton: true, selectedCategory: category),
    );
    final selectedCat = await Navigator.of(context).push(route);

    selectedCatProvider.currentSelectedItem = null;

    await context.bloc<SearchBloc>().categoryChanged(selectedCat);
  }

  Future<void> _transactionFilterTypeChanged(TransactionFilterType newValue) {
    _removeSearchFocus();
    return context.bloc<SearchBloc>().transactionFilterChanged(newValue);
  }

  Future<void> _transactionTypeChanged(int newValue) {
    _removeSearchFocus();
    return context.bloc<SearchBloc>().transactionTypeChanged(newValue);
  }

  Future<void> _sortDirectionChanged(SortDirectionType newValue) {
    _removeSearchFocus();
    return context.bloc<SearchBloc>().sortDirectionchanged(newValue);
  }
}
