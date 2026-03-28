part of '../payment_methods_page.dart';

class _List extends StatelessWidget {
  final List<PaymentMethodItem> items;
  final bool includeArchived;

  const _List({required this.items, required this.includeArchived});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final active = items.where((e) => !e.isArchived).toList();
    final archived = items.where((e) => e.isArchived).toList();
    return Column(
      children: [
        SwitchListTile(
          title: Text(i18n.showArchived),
          value: includeArchived,
          onChanged: (v) => context.read<PaymentMethodsBloc>().add(PaymentMethodsEvent.load(includeArchived: v)),
        ),
        Expanded(
          child: includeArchived
              ? ListView(
                  children: [
                    if (active.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(i18n.active, style: Theme.of(context).textTheme.titleMedium),
                      ),
                    if (active.isNotEmpty)
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: active.length,
                        onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, active, context),
                        itemBuilder: (context, index) =>
                            _ListItem(key: ValueKey(active[index].id), item: active[index]),
                      ),
                    if (archived.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(i18n.archived, style: Theme.of(context).textTheme.titleMedium),
                      ),
                    for (final a in archived) _ListItem(item: a, draggable: false),
                  ],
                )
              : ReorderableListView.builder(
                  itemCount: active.length,
                  onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, active, context),
                  itemBuilder: (context, index) =>
                      _ListItem(key: ValueKey(active[index].id), item: active[index]),
                ),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex, List<PaymentMethodItem> active, BuildContext context) {
    int nIndex = newIndex;
    final ids = List<int>.from(active.map((e) => e.id));
    if (nIndex > oldIndex) {
      nIndex -= 1;
    }
    final moved = ids.removeAt(oldIndex);
    ids.insert(nIndex, moved);
    context.read<PaymentMethodsBloc>().add(PaymentMethodsEvent.reorder(orderedIds: ids));
  }
}
