import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../bloc/categories_list/categories_list_bloc.dart';
import '../../bloc/category_form/category_form_bloc.dart';
import '../../bloc/category_icon/category_icon_bloc.dart';
import '../../common/enums/transaction_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/bloc_utils.dart';
import '../../common/utils/category_utils.dart';
import '../../common/utils/toast_utils.dart';
import '../../models/category_icon.dart';
import '../pages/category_icons_page.dart';

class AddEditCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return BlocConsumer<CategoryFormBloc, CategoryState>(
      listener: (ctx, state) {
        state.map(
          initial: (s) {
            if (s.errorOccurred) {
              ToastUtils.showWarningToast(ctx, i18n.unknownErrorOcurred);
            }

            if (s.categoryCantBeDeleted) {
              ToastUtils.showWarningToast(ctx, i18n.categoryCantBeDeleted);
            }
          },
          saved: (_) => _onCategoryAddedOrDeleted(context, false),
          deleted: (_) => _onCategoryAddedOrDeleted(context, true),
        );
      },
      builder: (ctx, state) {
        final appBar = state.maybeMap(
          initial: (s) {
            return AppBar(
              title: Text(
                CategoryState.newCategory(s) ? i18n.addCategory : i18n.editCategory,
              ),
              leading: const BackButton(),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: CategoryState.isFormValid(s) ? () => _saveCategory(context) : null,
                ),
                if (!CategoryState.newCategory(s))
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmationDialog(context, s.name),
                  ),
              ],
            );
          },
          orElse: () => null,
        );

        return Scaffold(
          appBar: appBar,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildPage(context, state),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPage(BuildContext context, CategoryState state) {
    final i18n = S.of(context);
    return state.maybeMap(
      initial: (state) {
        if (state.errorOccurred) {
          ToastUtils.showWarningToast(context, i18n.unknownErrorOcurred);
        }

        return [
          CategoryHeader(name: state.name, type: state.type, iconColor: state.iconColor, iconData: state.icon),
          CategoryForm(
            id: state.id,
            name: state.name,
            type: state.type,
            iconColor: state.iconColor,
            iconData: state.icon,
            isNameDirty: state.isNameDirty,
            isNameValid: state.isNameValid,
          ),
        ];
      },
      orElse: () => [],
    );
  }

  void _saveCategory(BuildContext context) => context.read<CategoryFormBloc>().add(const CategoryFormEvent.formSubmitted());

  void _onCategoryAddedOrDeleted(BuildContext context, bool deleted) {
    final s = S.of(context);
    final msg = deleted ? s.categoryWasSuccessfullyDeleted : s.categoryWasSuccessfullySaved;
    ToastUtils.showSucceedToast(context, msg);
    _notifyCategorySavedOrDeleted(context);
    Navigator.of(context).pop();
  }

  void _showDeleteConfirmationDialog(BuildContext context, String categoryName) {
    final i18n = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.deleteX(categoryName)),
        content: Text(i18n.confirmDeleteCategory),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.close),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryFormBloc>().add(const CategoryFormEvent.deleteCategory());
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  void _notifyCategorySavedOrDeleted(BuildContext context) {
    context.read<IncomesCategoriesBloc>().add(const CategoriesListEvent.getCategories(loadIncomes: true));
    context.read<ExpensesCategoriesBloc>().add(const CategoriesListEvent.getCategories(loadIncomes: false));
    BlocUtils.raiseCommonBlocEvents(context, reloadCategories: true, reloadCharts: true, reloadTransactions: true);
  }
}

class CategoryHeader extends StatelessWidget {
  final String name;
  final TransactionType type;
  final IconData iconData;
  final Color iconColor;

  const CategoryHeader({
    Key? key,
    required this.name,
    required this.type,
    required this.iconData,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return SizedBox(
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
                    name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  SizedBox(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                            title: Text(
                              type == TransactionType.incomes ? i18n.income : i18n.expense,
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
                  clipBehavior: Clip.hardEdge,
                  color: theme.cardColor.withOpacity(0.8),
                  type: MaterialType.circle,
                  child: IconButton(
                    iconSize: 65,
                    icon: Icon(iconData),
                    color: iconColor,
                    onPressed: () => _gotoIconsPage(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gotoIconsPage(BuildContext context) async {
    final route = MaterialPageRoute<CategoryIcon>(
      builder: (ctx) => CategoryIconsPage(),
    );

    final currentIcon = CategoryUtils.getByIconData(iconData);
    context.read<CategoryIconBloc>().add(CategoryIconEvent.selectionChanged(selectedIcon: currentIcon));

    final selectedIcon = await Navigator.of(context).push(route);

    if (selectedIcon == null) {
      return;
    }

    _iconChanged(context, selectedIcon.icon.icon!);
  }

  void _iconChanged(BuildContext context, IconData icon) => context.read<CategoryFormBloc>().add(CategoryFormEvent.iconChanged(selectedIcon: icon));
}

class CategoryForm extends StatefulWidget {
  final int id;
  final String name;
  final TransactionType type;
  final IconData iconData;
  final Color iconColor;
  final bool isNameValid;
  final bool isNameDirty;

  const CategoryForm({
    Key? key,
    required this.id,
    required this.name,
    required this.type,
    required this.iconData,
    required this.iconColor,
    required this.isNameValid,
    required this.isNameDirty,
  }) : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final FocusNode _nameFocus = FocusNode();
  late TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.name);
    _nameController.addListener(_nameChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final suffixIcon = _buildSuffixIconButton(_nameController, _nameFocus);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Form(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: Icon(
                      widget.iconData,
                      size: 30,
                      color: widget.iconColor,
                    ),
                    onPressed: () => _showColorPicker(context),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    minLines: 1,
                    maxLength: 255,
                    validator: (_) => widget.isNameValid ? null : i18n.invalidName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Radio<TransactionType>(
                  value: TransactionType.incomes,
                  groupValue: widget.type,
                  onChanged: widget.id > 0 ? null : (v) => _typeChanged(v!),
                ),
                Text(i18n.income),
                Radio<TransactionType>(
                  value: TransactionType.expenses,
                  groupValue: widget.type,
                  onChanged: widget.id > 0 ? null : (v) => _typeChanged(v!),
                ),
                Text(i18n.expense),
              ],
            ),
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

  Widget? _buildSuffixIconButton(TextEditingController controller, FocusNode focusNode) {
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nameChanged() => context.read<CategoryFormBloc>().add(CategoryFormEvent.nameChanged(name: _nameController.text));

  void _typeChanged(TransactionType type) => context.read<CategoryFormBloc>().add(CategoryFormEvent.typeChanged(selectedType: type));

  void _iconColorChanged(Color color) => context.read<CategoryFormBloc>().add(CategoryFormEvent.iconColorChanged(iconColor: color));

  Future<void> _showColorPicker(BuildContext context) {
    final i18n = S.of(context);
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(i18n.pickColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: widget.iconColor,
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(i18n.ok),
          ),
        ],
      ),
    );
  }
}
