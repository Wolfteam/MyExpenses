import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/search/widgets/search_box_card.dart';
import 'package:my_expenses/presentation/search/widgets/search_filter_bar.dart';
import 'package:my_expenses/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/transactions/widgets/transaction_item_card_container.dart';

class SearchPage extends StatefulWidget {
  static MaterialPageRoute route() {
    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => BlocProvider<SearchBloc>(
        create: (ctx) => Injection.searchBloc..add(const SearchEvent.init()),
        child: SearchPage(),
      ),
    );
    return route;
  }

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _hideFabAnimController;
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
    _hideFabAnimController = AnimationController(vsync: this, duration: kThemeAnimationDuration, value: 0);
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Body(scrollController: _scrollController),
      floatingActionButton: FadeTransition(
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
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (_isBottom && !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<SearchBloc>().add(const SearchEvent.loadMore());
      await Future.delayed(const Duration(milliseconds: 250));
      _isLoadingMore = false;
    }
  }
}

class _Body extends StatefulWidget {
  final ScrollController scrollController;

  const _Body({required this.scrollController});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _searchFocusNode = FocusNode();
  late TextEditingController _searchBoxTextController;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _searchBoxTextController = TextEditingController(text: '');
    _searchBoxTextController.addListener(_onSearchTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final i18n = S.of(context);
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (ctx, state) => CustomScrollView(
        controller: widget.scrollController,
        slivers: state.map(
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
                      SearchBoxCard(
                        controller: _searchBoxTextController,
                        focusNode: _searchFocusNode,
                        showCleanButton: !s.description.isNullEmptyOrWhitespace,
                      ),
                      SearchFilterBar(
                        currentAmountFilter: s.amount,
                        category: s.category,
                        transactionFilterType: s.transactionFilterType,
                        sortDirectionType: s.sortDirectionType,
                        transactionType: s.transactionType,
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
                  child: Text(i18n.transactions, textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleLarge),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchBoxTextController.removeListener(_onSearchTextChanged);
    _searchBoxTextController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_currentText == _searchBoxTextController.text) {
      return;
    }
    _currentText = _searchBoxTextController.text;
    context.read<SearchBloc>().add(SearchEvent.descriptionChanged(newValue: _searchBoxTextController.text));
  }
}
