import 'package:flutter/material.dart';
import 'package:olx_clone/utils/theme.dart';

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.color,
    this.iconColor,
    this.textColor,
    this.fontSize,
    this.widthButton,
    this.isTextCentered = false,
  });
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color? color;
  final Color? iconColor;
  final Color? textColor;
  final int? fontSize;
  final double? widthButton;
  final bool isTextCentered;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthButton ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.of(context).colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisAlignment:
              isTextCentered
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: iconColor ?? AppTheme.of(context).colors.primary,
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor ?? AppTheme.of(context).colors.primary,
                fontSize: fontSize != null ? fontSize!.toDouble() : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
