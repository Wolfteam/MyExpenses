import 'package:flutter/material.dart';

class SliverLoading extends StatelessWidget {
  final List<Widget> children;

  const SliverLoading({
    super.key,
    this.children = const [CircularProgressIndicator()],
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
