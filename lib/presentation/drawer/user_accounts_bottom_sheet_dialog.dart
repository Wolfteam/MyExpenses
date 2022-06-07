import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/drawer/user_account_item.dart';
import 'package:my_expenses/presentation/shared/loading.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/nothing_found.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';

class UserAccountsBottomSheetDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocProvider(
          create: (ctx) => Injection.getUserAccountsBloc(context.read<AppBloc>())..add(const UserAccountsEvent.init()),
          child: const _Content(),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return BlocConsumer<UserAccountsBloc, UserAccountsState>(
      listener: (ctx, state) {
        final i18n = S.of(ctx);
        state.maybeMap(
          initial: (state) {
            if (state.userWasDeleted) {
              ToastUtils.showSucceedToast(ctx, i18n.userWasSuccessfullyDeleted);
              ctx.read<DrawerBloc>().add(const DrawerEvent.init());
            } else if (state.activeUserChanged || state.accountWasAdded) {
              BlocUtils.raiseAllCommonBlocEvents(ctx);
            } else if (!state.isNetworkAvailable) {
              ToastUtils.showWarningToast(ctx, i18n.networkIsNotAvailable);
            } else if (state.signInResult != null) {
              if (state.signInResult == true) {
                final msg = '${i18n.syncing}\n${i18n.doNotCloseTheAppWhileAppSyncsData}';
                ToastUtils.showInfoToast(ctx, msg);
              } else {
                ToastUtils.showErrorToast(ctx, i18n.logInCancelledOrFailed);
              }
            }
          },
          orElse: () {},
        );
      },
      builder: (ctx, state) => state.maybeMap(
        initial: (state) => state.signInInProcess
            ? const Loading(useScaffold: false)
            : Column(
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
                    )
                  else
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
                      if (state.users.isEmpty)
                        ElevatedButton(
                          onPressed: () => context.read<UserAccountsBloc>().add(const UserAccountsEvent.signIn()),
                          child: Text(i18n.add),
                        ),
                    ],
                  )
                ],
              ),
        orElse: () => const Loading(useScaffold: false),
      ),
    );
  }
}
