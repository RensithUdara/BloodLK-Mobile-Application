import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class CustomAppDialog extends StatelessWidget {
  const CustomAppDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryText,
    this.onPrimary,
    this.secondaryText,
    this.onSecondary,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryText;
  final VoidCallback? onPrimary;
  final String? secondaryText;
  final VoidCallback? onSecondary;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.deepMaroon : AppColors.bloodRed;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.lightRed.withValues(alpha: 0.9),
                ),
              ),
              child: Icon(icon, color: accent, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF171D24),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5D6673),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            if (secondaryText == null)
              FilledButton(
                onPressed: onPrimary ?? () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(primaryText),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          onSecondary ?? () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5D6673),
                        side: const BorderSide(color: Color(0xFFFFE6E8)),
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(secondaryText!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onPrimary ?? () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(primaryText),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
