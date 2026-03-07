import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/neo_theme.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor; // nullable → defaults to neo.surface from theme
  final Color? borderColor; // nullable → defaults to neo.inkOnCard from theme
  final double borderWidth;
  final bool isCircle;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 3.0,
    this.isCircle = false,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final neo = NeoTheme.of(context);
    final bg = backgroundColor ?? neo.surface;
    final border = borderColor ?? neo.inkOnCard;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: isCircle
            ? null
            : (borderRadius ?? BorderRadius.circular(0)),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        border: Border.all(color: border, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: NeoColors.ink,
            offset: const Offset(4, 4),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
