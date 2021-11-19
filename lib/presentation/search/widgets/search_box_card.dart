import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class SearchBoxCard extends StatelessWidget {
  final bool showCleanButton;
  final FocusNode focusNode;
  final TextEditingController controller;

  const SearchBoxCard({
    Key? key,
    required this.showCleanButton,
    required this.focusNode,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);

    return Card(
      elevation: Styles.cardElevation,
      margin: Styles.edgeInsetAll10,
      shape: Styles.floatingCardShape,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Icon(Icons.search, size: 30),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              cursorColor: theme.colorScheme.secondary,
              maxLength: 50,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: Styles.edgeInsetHorizontal16,
                hintText: '${i18n.search}...',
              ),
            ),
          ),
          if (showCleanButton)
            IconButton(
              icon: const Icon(Icons.close),
              splashRadius: Styles.iconButtonSplashRadius,
              onPressed: _cleanSearchText,
            ),
        ],
      ),
    );
  }

  void _cleanSearchText() {
    focusNode.requestFocus();
    if (controller.text.isEmpty) {
      return;
    }
    controller.text = '';
  }
}
