import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/clay_colors.dart';
import '../theme/clay_shadows.dart';

class ClayInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const ClayInput({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<ClayInput> createState() => _ClayInputState();
}

class _ClayInputState extends State<ClayInput> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (value) => setState(() => _focused = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: ClayColors.surfaceAlt,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _focused
              ? [...ClayShadows.inner, ...ClayShadows.glow]
              : ClayShadows.inner,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            labelText: widget.label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
