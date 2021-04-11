///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-11 15:39
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Currently supports only three sizes.
enum AdaptiveType { small, medium, large }

/// {@template widgets.adaptive_layout.AdaptiveWeightBuilder}
/// Build weight according to the given [type].
/// {@endtemplate}
typedef AdaptiveWeightBuilder = int Function(AdaptiveType type);

/// The size for the specific [AdaptiveType].
const Map<AdaptiveType, double> _defaultTypeBuilder = <AdaptiveType, double>{
  AdaptiveType.small: 540,
  AdaptiveType.medium: 720,
  AdaptiveType.large: 960,
};

/// The total weight for the specific [AdaptiveType].
const Map<AdaptiveType, int> _defaultColumnBuilder = <AdaptiveType, int>{
  AdaptiveType.small: 6,
  AdaptiveType.medium: 9,
  AdaptiveType.large: 12,
};

/// A widget that provides a responsive experience according to the constraints.
///
/// A familiar design is the BootStrap's responsive model, which used to uses
/// media query to adapt the width of the screen/viewport. Same as this one.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    Key? key,
    required this.children,
    this.maxWidth = 1080,
    this.alignment = Alignment.topCenter,
    this.typeBuilder = _defaultTypeBuilder,
    this.columnBuilder = _defaultColumnBuilder,
  }) : super(key: key);

  /// The widgets below this widget in the tree.
  ///
  /// Typically [AdaptiveChildWidget] widgets.
  final List<Widget> children;

  /// The maximum width for the layout.
  ///
  /// If the parent's media query has a larger constraints than the [maxWidth],
  /// the layout will stops expanding and fixed to [maxWidth].
  final double? maxWidth;

  /// The alignment that the layout should follow.
  ///
  /// By default, using [Alignment.topCenter] indicates contents will always be
  /// centered and topped while the constraints is changing.
  final AlignmentGeometry alignment;

  final Map<AdaptiveType, double> typeBuilder;

  final Map<AdaptiveType, int> columnBuilder;

  @override
  Widget build(BuildContext context) {
    Widget child = SingleChildScrollView(
      child: Wrap(children: children),
    );
    if (maxWidth != null) {
      child = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: child,
      );
    }
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) => AdaptiveNotifier(
        constraints: constraints,
        typeBuilder: typeBuilder,
        columnBuilder: columnBuilder,
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}

/// A concept model to store [BoxConstraints] and other builders.
///
/// Using [InheritedWidget] enables children obtain layout information from
/// their [BuildContext], without passing them deep into the tree.
class AdaptiveNotifier extends InheritedWidget {
  const AdaptiveNotifier({
    required this.constraints,
    required Widget child,
    this.typeBuilder = _defaultTypeBuilder,
    this.columnBuilder = _defaultColumnBuilder,
  }) : super(child: child);

  final BoxConstraints constraints;
  final Map<AdaptiveType, double> typeBuilder;
  final Map<AdaptiveType, int> columnBuilder;

  static AdaptiveNotifier of(BuildContext context) {
    final AdaptiveNotifier? inheritedElement =
        context.dependOnInheritedWidgetOfExactType<AdaptiveNotifier>();
    if (inheritedElement == null) {
      throw NullThrownError();
    }
    return inheritedElement;
  }

  @override
  bool updateShouldNotify(AdaptiveNotifier oldWidget) {
    return oldWidget.constraints != constraints ||
        oldWidget.columnBuilder != columnBuilder;
  }
}

/// A widget that controls the weight a child of a [AdaptiveLayout] should take.
class AdaptiveChildWidget extends StatelessWidget {
  const AdaptiveChildWidget({
    Key? key,
    required this.builder,
    required this.weightBuilder,
    this.factorBuilder,
  }) : super(key: key);

  final WidgetBuilder builder;

  /// {@macro widgets.adaptive_layout.AdaptiveWeightBuilder}
  final AdaptiveWeightBuilder weightBuilder;

  /// Customize the factor using the [AdaptiveNotifier].
  final double Function(AdaptiveNotifier)? factorBuilder;

  double _getFactor(BuildContext context) {
    final AdaptiveNotifier notifier = AdaptiveNotifier.of(context);
    if (factorBuilder != null) {
      return factorBuilder!.call(notifier);
    }
    final BoxConstraints _cs = notifier.constraints;
    final Map<AdaptiveType, double> tb = notifier.typeBuilder;
    final Map<AdaptiveType, int> cb = notifier.columnBuilder;
    final AdaptiveType type;
    if (_cs.maxWidth <= tb[AdaptiveType.small]!) {
      type = AdaptiveType.small;
    } else if (_cs.maxWidth <= tb[AdaptiveType.medium]!) {
      type = AdaptiveType.medium;
    } else {
      type = AdaptiveType.large;
    }
    return math.min(1.0, weightBuilder(type) / cb[type]!);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _getFactor(context),
      child: builder(context),
    );
  }
}
