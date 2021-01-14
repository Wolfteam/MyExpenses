import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../bloc/categories_list/categories_list_bloc.dart';
import '../../bloc/category_form/category_form_bloc.dart';
import '../../bloc/category_icon/category_icon_bloc.dart';
import '../../common/enums/transaction_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/bloc_utils.dart';
import '../../common/utils/category_utils.dart';
import '../../common/utils/toast_utils.dart';
import '../../generated/i18n.dart';
import '../../models/category_icon.dart';
import '../../models/category_item.dart';
import '../pages/category_icons_page.dart';

class AddEditCategoryPage extends StatefulWidget {
  final CategoryItem category;

  const AddEditCategoryPage(this.category);

  @override
  _AddEditCategoryPageState createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final FocusNode _nameFocus = FocusNode();
  TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _nameController.addListener(_nameChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return BlocConsumer<CategoryFormBloc, CategoryState>(listener: (ctx, state) {
      if (state is CategoryFormState) {
        if (state.errorOccurred) {
          showWarningToast(i18n.unknownErrorOcurred);
        }

        if (state.categoryCantBeDeleted) {
          showWarningToast(i18n.categoryCantBeDeleted);
        }
      }

      if (state is CategorySavedOrDeletedState) {
        final i18n = I18n.of(ctx);
        final msg =
            state is CategorySavedState ? i18n.categoryWasSuccessfullySaved : i18n.categoryWasSuccessfullyDeleted;
        showSucceedToast(msg);

        _notifyCategorySavedOrDeleted();

        Navigator.of(ctx).pop();
      }
    }, builder: (ctx, state) {
      AppBar appBar;
      if (state is CategoryFormState) {
        appBar = AppBar(
          title: Text(
            state.newCategory ? i18n.addCategory : i18n.editCategory,
          ),
          leading: const BackButton(),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: state.isFormValid ? () => _saveCategory() : null,
            ),
            if (!state.newCategory)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmationDialog(state.name),
              ),
          ],
        );
      }

      return Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildPage(state),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<Widget> _buildPage(CategoryState state) {
    final i18n = I18n.of(context);
    if (state is CategoryFormState) {
      if (state.errorOccurred) {
        showWarningToast(i18n.unknownErrorOcurred);
      }

      return [
        _buildHeader(state),
        _buildForm(state),
      ];
    }
    return [];
  }

  Container _buildHeader(
    CategoryFormState state,
  ) {
    final i18n = I18n.of(context);
    final theme = Theme.of(context);
    return Container(
      height: 200.0,
      child: Stack(
        children: <Widget>[
          Container(
            height: 150,
            color: theme.primaryColorDark,
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 40.0,
              left: 20.0,
              right: 20.0,
              bottom: 10.0,
            ),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    state.name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                            title: Text(
                              state.type == TransactionType.incomes ? i18n.income : i18n.expense,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              i18n.category.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              i18n.na,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              i18n.parent.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Material(
                  elevation: 10,
                  color: theme.cardColor.withOpacity(0.8),
                  type: MaterialType.circle,
                  child: IconButton(
                    iconSize: 65,
                    icon: Icon(state.icon),
                    color: state.iconColor,
                    onPressed: () => _gotoIconsPage(state),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    CategoryFormState state,
  ) {
    final i18n = I18n.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Form(
        child: Column(
          children: <Widget>[
            _buildNameInput(state, i18n),
            _buildCategoryTypeRadioButtons(state, i18n),
            // ListTile(
            //   contentPadding: const EdgeInsets.only(left: 10),
            //   leading: Icon(
            //     CustomIcons.flow_split,
            //     size: 30,
            //     color: Colors.blue,
            //   ),
            //   title: Text(i18n.parent),
            //   onTap: () {},
            // )
          ],
        ),
      ),
    );
  }

  Widget _buildSuffixIconButton(
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final suffixIcon = !controller.text.isNullEmptyOrWhitespace && focusNode.hasFocus
        ? IconButton(
            alignment: Alignment.bottomCenter,
            icon: const Icon(Icons.close),
            //For some reason an exception is thrown https://github.com/flutter/flutter/issues/35848
            onPressed: () => Future.microtask(() => controller.clear()),
          )
        : null;

    return suffixIcon;
  }

  Widget _buildNameInput(
    CategoryFormState state,
    I18n i18n,
  ) {
    final suffixIcon = _buildSuffixIconButton(_nameController, _nameFocus);
    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: Icon(
              state.icon,
              size: 30,
              color: state.iconColor,
            ),
            onPressed: () => _showColorPicker(context, state),
          ),
        ),
        Expanded(
          child: TextFormField(
            minLines: 1,
            maxLength: 255,
            validator: (_) => state.isNameValid ? null : i18n.invalidName,
            autovalidate: state.isNameDirty,
            controller: _nameController,
            focusNode: _nameFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              alignLabelWithHint: true,
              hintText: i18n.categoryName,
              labelText: i18n.name,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTypeRadioButtons(
    CategoryFormState state,
    I18n i18n,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio<TransactionType>(
          value: TransactionType.incomes,
          groupValue: state.type,
          onChanged: _typeChanged,
        ),
        Text(i18n.income),
        Radio<TransactionType>(
          value: TransactionType.expenses,
          groupValue: state.type,
          onChanged: _typeChanged,
        ),
        Text(i18n.expense),
      ],
    );
  }

  void _showColorPicker(BuildContext context, CategoryFormState state) {
    final i18n = I18n.of(context);
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text(i18n.pickColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: state.iconColor,
            onColorChanged: _iconColorChanged,
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2.0),
              topRight: Radius.circular(2.0),
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(i18n.ok),
          ),
        ],
      ),
    );
  }

  Future _gotoIconsPage(CategoryFormState state) async {
    final route = MaterialPageRoute<CategoryIcon>(
      builder: (ctx) => CategoryIconsPage(),
    );

    final currentIcon = CategoryUtils.getByIconData(state.icon);
    context.read<CategoryIconBloc>().add(IconSelectionChanged(currentIcon));

    final selectedIcon = await Navigator.of(context).push(route);

    if (selectedIcon == null) return;

    _iconChanged(selectedIcon.icon.icon);
  }

  void _nameChanged() => context.read<CategoryFormBloc>().add(NameChanged(_nameController.text));

  void _typeChanged(TransactionType type) => context.read<CategoryFormBloc>().add(TypeChanged(type));

  void _iconChanged(IconData icon) => context.read<CategoryFormBloc>().add(IconChanged(icon));

  void _iconColorChanged(Color color) => context.read<CategoryFormBloc>().add(IconColorChanged(color));

  void _saveCategory() => context.read<CategoryFormBloc>().add(FormSubmitted());

  void _showDeleteConfirmationDialog(String categoryName) {
    final i18n = I18n.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.deleteX(categoryName)),
        content: Text(i18n.confirmDeleteCategory),
        actions: <Widget>[
          OutlineButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.close),
          ),
          RaisedButton(
            color: Theme.of(ctx).primaryColor,
            onPressed: () {
              context.read<CategoryFormBloc>().add(DeleteCategory());
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  void _notifyCategorySavedOrDeleted() {
    context.read<IncomesCategoriesBloc>().add(const GetCategories(loadIncomes: true));

    context.read<ExpensesCategoriesBloc>().add(const GetCategories(loadIncomes: false));

    BlocUtils.raiseCommonBlocEvents(
      context,
      reloadCategories: true,
      reloadCharts: true,
      reloadTransactions: true,
    );
  }
}
