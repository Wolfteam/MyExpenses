import 'package:flutter/material.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:nil/nil.dart';

class InputSuffixIcon extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const InputSuffixIcon({
    Key? key,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !controller.text.isNullEmptyOrWhitespace && focusNode.hasFocus
        ? IconButton(
            alignment: Alignment.bottomCenter,
            icon: const Icon(Icons.close),
            onPressed: () => controller.clear(),
          )
        : nil;
  }
}
