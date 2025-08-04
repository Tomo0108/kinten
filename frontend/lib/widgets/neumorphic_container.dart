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
    return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: this.widget.padding,
            margin: this.widget.margin,
            decoration: BoxDecoration(
              color: this.widget.color,
              borderRadius: BorderRadius.circular(this.widget.borderRadius),
              boxShadow: [
                // 軽微な影のみ
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: this.widget.child,
          );
  }
} 