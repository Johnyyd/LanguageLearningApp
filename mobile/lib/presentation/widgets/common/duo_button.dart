import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

enum DuoButtonColor { green, blue, yellow, red, indigo }

class DuoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final DuoButtonColor color;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final bool isFullWidth;
  final bool isCompact;

  const DuoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = DuoButtonColor.green,
    this.height = 44,
    this.borderRadius = 14,
    this.icon,
    this.isFullWidth = true,
    this.isCompact = false,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  Color get _mainColor {
    if (widget.onPressed == null) return Colors.grey.shade400;
    switch (widget.color) {
      case DuoButtonColor.green:
        return AppColors.duoGreen;
      case DuoButtonColor.blue:
        return AppColors.duoBlue;
      case DuoButtonColor.yellow:
        return AppColors.duoYellow;
      case DuoButtonColor.red:
        return AppColors.duoRed;
      case DuoButtonColor.indigo:
        return AppColors.deepIndigo;
    }
  }

  Color get _shadowColor {
    if (widget.onPressed == null) return Colors.grey.shade600;
    switch (widget.color) {
      case DuoButtonColor.green:
        return AppColors.duoGreenShadow;
      case DuoButtonColor.blue:
        return AppColors.duoBlueShadow;
      case DuoButtonColor.yellow:
        return AppColors.duoYellowShadow;
      case DuoButtonColor.red:
        return AppColors.duoRedShadow;
      case DuoButtonColor.indigo:
        return AppColors.softIndigo;
    }
  }

  Color get _textColor {
    if (widget.color == DuoButtonColor.yellow) {
      return AppColors.deepIndigo;
    }
    return Colors.white;
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed!();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double targetHeight = widget.isCompact ? 38.0 : widget.height;
    final double shadowHeight = _isPressed ? 0.0 : 3.0;
    final double topOffset = _isPressed ? 3.0 : 0.0;

    Widget buttonContent = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 6),
        ],
        Text(
          widget.text.toUpperCase(),
          style: GoogleFonts.outfit(
            color: _textColor,
            fontSize: widget.isCompact ? 13 : 14.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        height: targetHeight + 3.0,
        width: widget.isFullWidth ? double.infinity : null,
        padding: EdgeInsets.only(top: topOffset),
        child: Container(
          decoration: BoxDecoration(
            color: _mainColor,
            borderRadius: BorderRadius.circular(widget.isCompact ? 10 : widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: _shadowColor,
                offset: Offset(0, shadowHeight),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: buttonContent,
        ),
      ),
    );
  }
}
