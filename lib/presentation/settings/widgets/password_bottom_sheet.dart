import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_title.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class PasswordBottomSheet extends StatelessWidget {
  final bool promptForPassword;

  const PasswordBottomSheet({this.promptForPassword = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocProvider(
          create: (ctx) => Injection.passwordDialogBloc,
          child: _Form(promptForPassword: promptForPassword),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  final bool promptForPassword;

  const _Form({Key? key, required this.promptForPassword}) : super(key: key);

  @override
  _FormState createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String _currentPasswordValue = '';
  String _currentConfirmPasswordValue = '';

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(_passwordChanged);
    _confirmPasswordController.addListener(_confirmPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    return BlocConsumer<PasswordDialogBloc, PasswordDialogState>(
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
            ModalSheetSeparator(),
            ModalSheetTitle(title: i18n.typeYourPassword, padding: const EdgeInsets.only(bottom: 10)),
            TextFormField(
              obscureText: !state.showPassword,
              minLines: 1,
              maxLength: PasswordDialogBloc.maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
            ),
            if (!widget.promptForPassword)
              TextFormField(
                obscureText: !state.showConfirmPassword,
                minLines: 1,
                maxLength: PasswordDialogBloc.maxLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
              ),
            ButtonBar(
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
            )
          ],
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

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _passwordChanged() {
    if (_currentPasswordValue == _passwordController.text) {
      return;
    }
    _currentPasswordValue = _passwordController.text;
    context.read<PasswordDialogBloc>().add(PasswordDialogEvent.passwordChanged(newValue: _currentPasswordValue));
  }

  void _showPassword(bool show) => context.read<PasswordDialogBloc>().add(PasswordDialogEvent.showPassword(show: show));

  void _confirmPasswordChanged() {
    if (_currentConfirmPasswordValue == _confirmPasswordController.text) {
      return;
    }
    _currentConfirmPasswordValue = _confirmPasswordController.text;
    context.read<PasswordDialogBloc>().add(PasswordDialogEvent.confirmPasswordChanged(newValue: _currentConfirmPasswordValue));
  }

  void _showConfirmPassword(bool show) => context.read<PasswordDialogBloc>().add(PasswordDialogEvent.showConfirmPassword(show: show));

  void _submitForm() => context.read<PasswordDialogBloc>().add(const PasswordDialogEvent.submit());

  void _validatePassword() => context.read<PasswordDialogBloc>().add(PasswordDialogEvent.validatePassword(password: _passwordController.text));
}
