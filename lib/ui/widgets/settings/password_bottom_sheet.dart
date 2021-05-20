import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../../bloc/password_dialog/password_dialog_bloc.dart';

class PasswordBottomSheet extends StatefulWidget {
  final bool promptForPassword;

  const PasswordBottomSheet({this.promptForPassword = false});

  @override
  _PasswordBottomSheetState createState() => _PasswordBottomSheetState();
}

class _PasswordBottomSheetState extends State<PasswordBottomSheet> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(_passwordChanged);
    _confirmPasswordController.addListener(_confirmPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: BlocConsumer<PasswordDialogBloc, PasswordDialogState>(
          listener: (ctx, state) {
            if (state.passwordWasSaved) {
              Navigator.of(ctx).pop(true);
            } else if (state.userIsValid != null && state.userIsValid == true) {
              Navigator.of(ctx).pop(true);
            }
          },
          builder: (ctx, state) => Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: SizedBox(
                      width: 100,
                      height: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  i18n.typeYourPassword,
                  style: Theme.of(context).textTheme.headline6,
                ),
                _buildPasswordInput(i18n, state),
                if (!widget.promptForPassword) _buildConfirmPasswordInput(i18n, state),
                _buildButtons(theme, i18n, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildPasswordInput(S i18n, PasswordDialogState state) {
    return TextFormField(
      obscureText: !state.showPassword,
      minLines: 1,
      maxLength: 10,
      controller: _passwordController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      focusNode: _passwordFocus,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        hintText: i18n.password,
        labelText: i18n.password,
        suffixIcon: IconButton(
          icon: Icon(
            state.showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => _showPassword(!state.showPassword),
        ),
      ),
      onFieldSubmitted: (_) {
        _fieldFocusChange(context, _passwordFocus, _confirmPasswordFocus);
      },
      autovalidateMode: state.isPasswordDirty ? AutovalidateMode.always : null,
      validator: (_) => (!widget.promptForPassword && !state.isPasswordValid) || (widget.promptForPassword && state.userIsValid == false)
          ? i18n.passwordIsNotValid
          : null,
    );
  }

  Widget _buildConfirmPasswordInput(S i18n, PasswordDialogState state) {
    return TextFormField(
      obscureText: !state.showConfirmPassword,
      minLines: 1,
      maxLength: 10,
      controller: _confirmPasswordController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      focusNode: _confirmPasswordFocus,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        hintText: i18n.confirmPassword,
        labelText: i18n.confirmPassword,
        suffixIcon: IconButton(
          icon: Icon(
            state.showConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => _showConfirmPassword(!state.showConfirmPassword),
        ),
      ),
      autovalidateMode: state.isConfirmPasswordDirty ? AutovalidateMode.always : null,
      validator: (_) => state.isConfirmPasswordValid ? null : i18n.confirmPasswordIsNotValid,
    );
  }

  Widget _buildButtons(ThemeData theme, S i18n, PasswordDialogState state) {
    return ButtonBar(
      buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
      children: <Widget>[
        if (!widget.promptForPassword)
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              i18n.cancel,
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ElevatedButton(
          onPressed: !widget.promptForPassword && !state.isFormValid
              ? null
              : !widget.promptForPassword
                  ? _submitForm
                  : !state.isPasswordValid
                      ? null
                      : _validatePassword,
          child: Text(i18n.ok),
        ),
      ],
    );
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _passwordChanged() => context.read<PasswordDialogBloc>().add(PasswordDialogEvent.passwordChanged(newValue: _passwordController.text));

  void _showPassword(bool show) => context.read<PasswordDialogBloc>().add(PasswordDialogEvent.showPassword(show: show));

  void _confirmPasswordChanged() =>
      context.read<PasswordDialogBloc>().add(PasswordDialogEvent.confirmPasswordChanged(newValue: _confirmPasswordController.text));

  void _showConfirmPassword(bool show) => context.read<PasswordDialogBloc>().add(PasswordDialogEvent.showConfirmPassword(show: show));

  void _submitForm() => context.read<PasswordDialogBloc>().add(const PasswordDialogEvent.submit());

  void _validatePassword() => context.read<PasswordDialogBloc>().add(PasswordDialogEvent.validatePassword(password: _passwordController.text));
}
