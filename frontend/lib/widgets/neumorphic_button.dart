import 'package:flutter/material.dart';

class NeumorphicButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double height;
  final Color? color;
  final double borderRadius;

  const NeumorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.height = 56,
    this.color,
    this.borderRadius = 16,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final buttonColor = widget.color ?? const Color(0xFF3498DB);

    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}