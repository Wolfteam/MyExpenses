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
import '../widgets/nothing_found.dart';
import '../widgets/search/search_amount_filter_bottom_sheet_dialog.dart';
import '../widgets/search/search_date_filter_bottom_sheet_dialog.dart';
import '../widgets/sort_direction_popupmenu_filter.dart';
import '../widgets/transactions/transaction_item_card_container.dart';
import '../widgets/transactions/transaction_popupmenu_filter.dart';
import '../widgets/transactions/transaction_popupmenu_type_filter.dart';
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
  bool _isLoadingMore = false;

  bool get _isBottom {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchBoxTextController = TextEditingController(text: '');
    _hideFabAnimController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: 0);
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
    _scrollController.addListener(_onScroll);
    _searchBoxTextController.addListener(_onSearchTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (c, s) => CustomScrollView(controller: _scrollController, slivers: _buildPage(s)),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchBoxTextController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  List<Widget> _buildPage(SearchState state) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final i18n = I18n.of(context);
    return state.map(
      loading: (_) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()],
          ),
        )
      ],
      initial: (s) => [
        SliverAppBar(
          title: Text(i18n.search),
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: EdgeInsets.only(top: statusBarHeight, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSearchBox(!s.description.isNullEmptyOrWhitespace, i18n),
                  _buildFilterBar(
                    s.amount,
                    s.category,
                    s.transactionFilterType,
                    s.sortDirectionType,
                    s.transactionType,
                  ),
                ],
              ),
            ),
          ),
          expandedHeight: 170,
          pinned: true,
          snap: true,
        ),
        if (s.transactions.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: Styles.edgeInsetAll10,
              child: Text(i18n.transactions, textAlign: TextAlign.start, style: Theme.of(context).textTheme.headline6),
            ),
          ),
        if (s.transactions.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => index >= s.transactions.length
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    )
                  : TransactionItemCardContainer(
                      key: Key('transaction_item_${s.transactions[index].id}'),
                      item: s.transactions[index],
                    ),
              childCount: s.hasReachedMax ? s.transactions.length : s.transactions.length + 1,
            ),
          ),
        if (s.transactions.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [NothingFound(msg: i18n.noTransactionsForThisPeriod)],
            ),
          )
      ],
    );
  }

  Widget _buildSearchBox(bool showCleanButton, I18n i18n) {
    final theme = Theme.of(context);

    return Card(
      elevation: Styles.cardElevation,
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
        TransactionPopupMenuTypeFilter(
          selectedValue: transactionType,
          onSelectedValue: _transactionTypeChanged,
          showNa: true,
        ),
      ],
    );
  }

  Widget _buildFab() {
    return FadeTransition(
      opacity: _hideFabAnimController,
      child: ScaleTransition(
        scale: _hideFabAnimController,
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => _scrollController.goToTheTop(),
          child: const Icon(Icons.arrow_upward),
        ),
      ),
    );
  }

  Future<void> _onScroll() async {
    if (_isBottom && !_isLoadingMore) {
      _isLoadingMore = true;
      await context.read<SearchBloc>().loadMore();
      _isLoadingMore = false;
    }
    return Future.value();
  }

  Future<void> _onSearchTextChanged() => context.read<SearchBloc>().descriptionChanged(_searchBoxTextController.text);

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
    context.read<SearchBloc>().resetTempDates();
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
    context.read<SearchBloc>().resetTempDates();
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
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(context, listen: false);

    if (category != null && category.id > 0) {
      selectedCatProvider.currentSelectedItem = category;
    }

    final route = MaterialPageRoute<CategoryItem>(
      builder: (ctx) => CategoriesPage(isInSelectionMode: true, showDeselectButton: true, selectedCategory: category),
    );
    await Navigator.of(context).push(route);

    await context.read<SearchBloc>().categoryChanged(selectedCatProvider.currentSelectedItem);
  }

  Future<void> _transactionFilterTypeChanged(TransactionFilterType newValue) {
    _removeSearchFocus();
    return context.read<SearchBloc>().transactionFilterChanged(newValue);
  }

  Future<void> _transactionTypeChanged(int newValue) {
    _removeSearchFocus();
    return context.read<SearchBloc>().transactionTypeChanged(newValue);
  }

  Future<void> _sortDirectionChanged(SortDirectionType newValue) {
    _removeSearchFocus();
    return context.read<SearchBloc>().sortDirectionchanged(newValue);
  }
}
