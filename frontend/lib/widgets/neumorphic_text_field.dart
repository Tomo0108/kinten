import 'package:flutter/material.dart';

class NeumorphicTextField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;

  const NeumorphicTextField({
    super.key,
    required this.label,
    required this.hint,
    this.onChanged,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  State<NeumorphicTextField> createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  bool _isFocused = false;

    @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ラベル
          Container(
            margin: const EdgeInsets.only(bottom: 12, left: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // 入力フィールド
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: _isFocused
                    ? const LinearGradient(
                        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFF8F9FA), Color(0xFFE8EAED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isFocused 
                      ? const Color(0xFF3498DB).withOpacity(0.4)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 12,
                          offset: const Offset(-6, -6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 8,
                          offset: const Offset(-4, -4),
                        ),
                      ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: _isFocused 
                      ? Colors.white.withOpacity(0.95)
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        enabled: widget.enabled && !widget.readOnly,
                        readOnly: widget.readOnly,
                        decoration: InputDecoration(
                          hintText: widget.hint,
                          hintStyle: TextStyle(
                            color: const Color(0xFF7F8C8D).withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: widget.onChanged,
                      ),
                    ),
                    if (widget.controller?.text.isNotEmpty == true)
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        child: GestureDetector(
                          onTap: () {
                            widget.controller?.clear();
                            widget.onChanged?.call('');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE74C3C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.clear,
                              color: Color(0xFFE74C3C),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 