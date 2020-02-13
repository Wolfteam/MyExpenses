import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../models/category_item.dart';
import 'add_edit_category_page.dart';

class CategoriesListPage extends StatefulWidget {
  final bool loadIncomes;

  CategoriesListPage({
    Key key,
    this.loadIncomes,
  }) : super(key: key);

  @override
  _CategoriesListPageState createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> {
  Widget _buildCategoryItem(CategoryItem category) {
    var icon = IconTheme(
      data: new IconThemeData(color: category.iconColor),
      child: new Icon(category.icon),
    );
    return ListTile(
      leading: icon,
      title: Text(category.name),
      onTap: () {},
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context
        .bloc<CategoriesListBloc>()
        .add(GetCategories(loadIncomes: widget.loadIncomes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CategoriesListBloc, CategoriesListState>(
          builder: (ctx, state) {
        if (state is CategoriesLoadedState) {
          return ListView.builder(
            itemCount: state.categories.length,
            itemBuilder: (ctx, index) =>
                _buildCategoryItem(state.categories[index]),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: () {
          var route =
              MaterialPageRoute(builder: (ctx) => AddEditCategoryPage());
          Navigator.push(context, route);
        },
      ),
    );
  }
}
