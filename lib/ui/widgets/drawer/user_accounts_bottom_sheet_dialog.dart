import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';

import '../../../bloc/drawer/drawer_bloc.dart';
import '../../../bloc/users_accounts/user_accounts_bloc.dart';
import '../../../common/utils/bloc_utils.dart';
import '../../../common/utils/toast_utils.dart';
import '../../../generated/i18n.dart';
import '../../../models/user_item.dart';
import '../modal_sheet_separator.dart';
import '../nothing_found.dart';
import 'sign_in_with_google_webview.dart';
import 'user_account_item.dart';

class UserAccountsBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: BlocConsumer<UserAccountsBloc, UserAccountsState>(
          listener: (ctx, state) {
            final i18n = I18n.of(context);
            if (state.userWasDeleted) {
              showSucceedToast(i18n.userWasSuccessfullyDeleted);
              ctx.read<DrawerBloc>().add(const InitializeDrawer());
            } else if (state.activeUserChanged) {
              BlocUtils.raiseAllCommonBlocEvents(ctx);
            } else if (state.errorOcurred) {
              showErrorToast(i18n.unknownErrorOcurred);
            }
          },
          builder: (ctx, state) => _buildPage(ctx, state),
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    UserAccountsState state,
  ) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);

    return Column(
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
            padding: const EdgeInsets.all(0),
            itemBuilder: (ctx, index) => _buildUserAccountItem(
              state.users[index],
              state.users.length > 1,
            ),
          ),
        if (state.users.isEmpty)
          NothingFound(
            msg: i18n.noUserAccountsFound,
            padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
          ),
        ButtonBar(
          buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
          children: <Widget>[
            OutlineButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                i18n.close,
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
            RaisedButton(
              color: theme.primaryColor,
              onPressed: () => _addAccount(context),
              child: Text(i18n.add),
            ),
          ],
        )
      ],
    );
  }

  UserAccountItem _buildUserAccountItem(
    UserItem user,
    bool canBeDeleted,
  ) {
    return UserAccountItem(
      id: user.id,
      fullname: user.name,
      email: user.email,
      imgUrl: user.pictureUrl,
      isActive: user.isActive,
      canBeDeleted: canBeDeleted,
    );
  }

  Future<void> _addAccount(BuildContext context) async {
    Navigator.of(context).pop();
    await FlutterUserAgent.init();
    final route = MaterialPageRoute(
      builder: (ctx) => const SignInWithGoogleWebView(),
    );
    Navigator.of(context).push(route);
  }
}
