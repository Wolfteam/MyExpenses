import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/category/widgets/color_picker_dialog.dart';

class CategoryForm extends StatelessWidget {
  final int id;
  final String name;
  final TransactionType type;
  final IconData iconData;
  final Color iconColor;

  const CategoryForm.create({
    Key? key,
    required this.type,
    required this.iconData,
    required this.iconColor,
  })  : id = 0,
        name = '',
        super(key: key);

  const CategoryForm.edit({
    Key? key,
    required this.id,
    required this.name,
    required this.type,
    required this.iconData,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
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
                    splashRadius: 28,
                    icon: Icon(iconData, size: 30, color: iconColor),
                    onPressed: () => _showColorPicker(context),
                  ),
                ),
                _NameInput(name: name),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Radio<TransactionType>(
                  value: TransactionType.incomes,
                  activeColor: theme.colorScheme.secondary,
                  groupValue: type,
                  onChanged: id > 0 ? null : (v) => _typeChanged(v!, context),
                ),
                Text(i18n.income),
                Radio<TransactionType>(
                  value: TransactionType.expenses,
                  activeColor: theme.colorScheme.secondary,
                  groupValue: type,
                  onChanged: id > 0 ? null : (v) => _typeChanged(v!, context),
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

  void _typeChanged(TransactionType type, BuildContext context) =>
      context.read<CategoryFormBloc>().add(CategoryFormEvent.typeChanged(selectedType: type));

  Future<void> _showColorPicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => ColorPickerDialog(
        iconColor: iconColor,
        onColorSelected: (ctx, color) => context.read<CategoryFormBloc>().add(CategoryFormEvent.iconColorChanged(iconColor: color)),
      ),
    );
  }
}

class _NameInput extends StatefulWidget {
  final String name;

  const _NameInput({Key? key, required this.name}) : super(key: key);

  @override
  State<_NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<_NameInput> {
  final FocusNode _nameFocus = FocusNode();
  late TextEditingController _nameController;
  late String _currentValue;

  @override
  void initState() {
    _currentValue = widget.name;
    _nameController = TextEditingController(text: widget.name);
    _nameController.addListener(_nameChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return BlocBuilder<CategoryFormBloc, CategoryState>(
      builder: (ctx, state) => Expanded(
        child: TextFormField(
          minLines: 1,
          maxLength: CategoryFormBloc.maxNameLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          validator: (_) => state.maybeMap(
            loaded: (state) => state.isNameValid ? null : i18n.invalidName,
            orElse: () => null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _nameController,
          focusNode: _nameFocus,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            suffixIcon: _buildSuffixIconButton(_nameController, _nameFocus),
            alignLabelWithHint: true,
            hintText: i18n.categoryName,
            labelText: i18n.name,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.removeListener(_nameChanged);
    _nameController.dispose();
    super.dispose();
  }

  Widget? _buildSuffixIconButton(TextEditingController controller, FocusNode focusNode) {
    final suffixIcon = !controller.text.isNullEmptyOrWhitespace && focusNode.hasFocus
        ? IconButton(
            alignment: Alignment.bottomCenter,
            icon: const Icon(Icons.close),
            splashRadius: 20,
            //For some reason an exception is thrown https://github.com/flutter/flutter/issues/35848
            onPressed: () => Future.microtask(() => controller.clear()),
          )
        : null;

    return suffixIcon;
  }

  void _nameChanged() {
    if (_currentValue == _nameController.text) {
      return;
    }
    _currentValue = _nameController.text;
    context.read<CategoryFormBloc>().add(CategoryFormEvent.nameChanged(name: _nameController.text));
  }
}
