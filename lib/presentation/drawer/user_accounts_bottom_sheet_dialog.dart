import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/drawer/sign_in_with_google_webview.dart';
import 'package:my_expenses/presentation/drawer/user_account_item.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';

class UserAccountsBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: BlocConsumer<UserAccountsBloc, UserAccountsState>(
          listener: (ctx, state) {
            final i18n = S.of(ctx);
            if (state.userWasDeleted) {
              ToastUtils.showSucceedToast(ctx, i18n.userWasSuccessfullyDeleted);
              ctx.read<DrawerBloc>().add(const DrawerEvent.init());
            } else if (state.activeUserChanged) {
              BlocUtils.raiseAllCommonBlocEvents(ctx);
            } else if (state.errorOccurred) {
              ToastUtils.showErrorToast(ctx, i18n.unknownErrorOcurred);
            }
          },
          builder: (ctx, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ModalSheetSeparator(),
              Text(
                i18n.accounts,
                style: Theme.of(context).textTheme.headline6,
              ),
              if (state.users.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.users.length,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (ctx, index) {
                    final user = state.users[index];
                    final canBeDeleted = state.users.length > 1;
                    return UserAccountItem(
                      id: user.id,
                      fullname: user.name,
                      email: user.email,
                      imgUrl: user.pictureUrl!,
                      isActive: user.isActive,
                      canBeDeleted: canBeDeleted,
                    );
                  },
                  // itemBuilder: (ctx, index) => _buildUserAccountItem(
                  //   state.users[index],
                  //   state.users.length > 1,
                  // ),
                ),
              if (state.users.isEmpty)
                NothingFound(
                  msg: i18n.noUserAccountsFound,
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                ),
              ButtonBar(
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      i18n.close,
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _addAccount(context),
                    child: Text(i18n.add),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _addAccount(BuildContext context) {
    Navigator.of(context).pop();
    final route = MaterialPageRoute(builder: (ctx) => const SignInWithGoogleWebView());
    Navigator.of(context).push(route);
  }
}
