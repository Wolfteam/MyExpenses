import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/drawer/widgets/logged_user_image.dart';

class HomeWelcome extends StatelessWidget {
  const HomeWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final S i18n = S.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();
    return BlocBuilder<DrawerBloc, DrawerState>(
      builder: (context, state) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  i18n.hello,
                  style: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                if (state.fullName.isNotNullEmptyOrWhitespace)
                  Text(
                    state.fullName!,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: state.isUserSignedIn
                ? LoggedUserImage(
                    image: state.img,
                    isUserSignedIn: state.isUserSignedIn,
                    radius: 20,
                    popContext: false,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
