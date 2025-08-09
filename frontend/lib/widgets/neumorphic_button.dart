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
  bool _isHovered = false;
  bool _isPressed = false;





  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final buttonColor = widget.color ?? const Color(0xFF3498DB);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : _isHovered
                ? [
                    // ホバー時の軽微な影
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    // 通常時の軽微な影
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.98))
              : (Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0)),
          transformAlignment: Alignment.center,
          child: Center(
            child: Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
} 