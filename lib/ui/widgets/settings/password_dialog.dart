import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/password_dialog/password_dialog_bloc.dart';
import '../../../generated/i18n.dart';

class PasswordDialog extends StatefulWidget {
  final bool promptForPassword;

  const PasswordDialog({this.promptForPassword = false});

  @override
  _PasswordDialogState createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
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
    final i18n = I18n.of(context);
    final mediaQuery = MediaQuery.of(context);
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: mediaQuery.viewInsets.bottom,
        ),
        child: BlocConsumer<PasswordDialogBloc, PasswordDialogState>(
          listener: (ctx, state) {
            if (state.passwordWasSaved) {
              Navigator.of(ctx).pop(true);
            } else if (state.userIsValid != null && state.userIsValid) {
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

  Widget _buildPasswordInput(
    I18n i18n,
    PasswordDialogState state,
  ) {
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
      autovalidate: state.isPasswordDirty,
      validator: (_) => (!widget.promptForPassword && !state.isPasswordValid) ||
              (widget.promptForPassword && state.userIsValid == false)
          ? i18n.passwordIsNotValid
          : null,
    );
  }

  Widget _buildConfirmPasswordInput(
    I18n i18n,
    PasswordDialogState state,
  ) {
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
      autovalidate: state.isConfirmPasswordDirty,
      validator: (_) => state.isConfirmPasswordValid ? null : i18n.confirmPasswordIsNotValid,
    );
  }

  Widget _buildButtons(
    ThemeData theme,
    I18n i18n,
    PasswordDialogState state,
  ) {
    return ButtonBar(
      buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
      children: <Widget>[
        if (!widget.promptForPassword)
          OutlineButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              i18n.cancel,
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        RaisedButton(
          color: theme.primaryColor,
          onPressed: !widget.promptForPassword && !state.isFormValid
              ? null
              : !widget.promptForPassword ? _submitForm : !state.isPasswordValid ? null : _validatePassword,
          child: Text(i18n.ok),
        ),
      ],
    );
  }

  void _fieldFocusChange(
    BuildContext context,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _passwordChanged() =>
      context.bloc<PasswordDialogBloc>().add(PasswordChanged(newValue: _passwordController.text));

  void _showPassword(bool show) => context.bloc<PasswordDialogBloc>().add(ShowPassword(show: show));

  void _confirmPasswordChanged() =>
      context.bloc<PasswordDialogBloc>().add(ConfirmPasswordChanged(newValue: _confirmPasswordController.text));

  void _showConfirmPassword(bool show) => context.bloc<PasswordDialogBloc>().add(ShowConfirmPassword(show: show));

  void _submitForm() => context.bloc<PasswordDialogBloc>().add(const SubmitForm());

  void _validatePassword() => context.bloc<PasswordDialogBloc>().add(ValidatePassword(_passwordController.text));
}
