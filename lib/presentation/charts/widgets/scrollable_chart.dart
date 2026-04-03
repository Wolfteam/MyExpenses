import 'package:flutter/material.dart';

class ScrollableChart extends StatelessWidget {
  final int pointCount;
  final double minWidthPerPoint;
  final double height;
  final Widget Function(double width) builder;

  const ScrollableChart({
    super.key,
    required this.pointCount,
    this.minWidthPerPoint = 40,
    required this.height,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final neededWidth = pointCount * minWidthPerPoint;
          final chartWidth = neededWidth > constraints.maxWidth
              ? neededWidth
              : constraints.maxWidth;

          if (chartWidth <= constraints.maxWidth) {
            return builder(chartWidth);
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: height,
              child: builder(chartWidth),
            ),
          );
        },
      ),
    );
  }
}
