import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;

// https://github.com/google/charts/issues/180
class CustomArcRendererConfig<D> extends charts.ArcRendererConfig<D> {
  /// Stroke color of the border of the arcs.
  @override
  final charts.Color stroke;

  /// Color of the "no data" state for the chart, used when an empty series is
  /// drawn.
  @override
  final charts.Color noDataColor;

  CustomArcRendererConfig({
    String customRendererId,
    double arcLength = 2 * pi,
    List<charts.ArcLabelDecorator> arcRendererDecorators = const [],
    double arcRatio,
    int arcWidth,
    int layoutPaintOrder = LayoutViewPaintOrder.arc,
    int minHoleWidthForCenterContent = 30,
    double startAngle = -pi / 2,
    double strokeWidthPx = 2.0,
    charts.CircleSymbolRenderer symbolRenderer,
    this.noDataColor,
    this.stroke,
  }) : super(
          customRendererId: customRendererId,
          arcLength: arcLength,
          arcRendererDecorators: arcRendererDecorators,
          arcRatio: arcRatio,
          arcWidth: arcWidth,
          layoutPaintOrder: layoutPaintOrder,
          minHoleWidthForCenterContent: minHoleWidthForCenterContent,
          startAngle: startAngle,
          strokeWidthPx: strokeWidthPx,
          symbolRenderer: symbolRenderer,
        );
}
