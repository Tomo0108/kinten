import 'package:flutter/material.dart';

class NeumorphicContainer extends StatefulWidget {
  final Widget child;
  final double depth;
  final double borderRadius;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isPressed;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.depth = 4.0,
    this.borderRadius = 12.0,
         this.color = const Color(0xFFF8F9FA),
    this.padding,
    this.margin,
    this.isPressed = false,
  });

  @override
  State<NeumorphicContainer> createState() => _NeumorphicContainerState();
}

class _NeumorphicContainerState extends State<NeumorphicContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: this.widget.padding,
            margin: this.widget.margin,
            decoration: BoxDecoration(
              color: this.widget.color,
              borderRadius: BorderRadius.circular(this.widget.borderRadius),
              boxShadow: _isPressed || this.widget.isPressed
                  ? [
                      // 押された時の影（内側風の効果）
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ]
                                       : [
                         // 通常時の影（外側）
                         BoxShadow(
                           color: Colors.black.withOpacity(0.08),
                           blurRadius: this.widget.depth,
                           offset: Offset(0, this.widget.depth / 2),
                         ),
                         BoxShadow(
                           color: Colors.white.withOpacity(0.9),
                           blurRadius: this.widget.depth,
                           offset: Offset(-this.widget.depth / 2, -this.widget.depth / 2),
                         ),
                       ],
            ),
            child: this.widget.child,
          ),
    );
  }
} 