import 'package:flutter/material.dart';

class NeumorphicProgressIndicator extends StatelessWidget {
  final double? value;
  final Color color;
  final double height;

  const NeumorphicProgressIndicator({
    super.key,
    this.value,
    this.color = const Color(0xFF5A6B8C),
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
             decoration: BoxDecoration(
         color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
} 