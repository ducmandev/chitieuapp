import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NeoButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final BorderRadiusGeometry? borderRadius;
  final double shadowOffset;
  final double pressedShadowOffset;

  const NeoButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = NeoColors.surface,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderWidth = 3.0,
    this.borderRadius,
    this.shadowOffset = 4.0,
    this.pressedShadowOffset = 0.0,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final offset = _isPressed
        ? widget.pressedShadowOffset
        : widget.shadowOffset;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? widget.shadowOffset - widget.pressedShadowOffset : 0,
          _isPressed ? widget.shadowOffset - widget.pressedShadowOffset : 0,
          0,
        ),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
          border: Border.all(color: NeoColors.ink, width: widget.borderWidth),
          boxShadow: [
            BoxShadow(
              color: NeoColors.ink,
              offset: Offset(offset, offset),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
