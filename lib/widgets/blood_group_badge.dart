import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium pill badge for blood groups.
/// Features a crisp droplet icon, bold typography, soft blush background,
/// and a refined border.
class BloodGroupBadge extends StatelessWidget {
  final String bloodGroup;
  final double fontSize;
  final bool isSolid;

  const BloodGroupBadge({
    super.key,
    required this.bloodGroup,
    this.fontSize = 14,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSolid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primaryRed,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRed.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              bloodGroup,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.roseSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryRed.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.water_drop_rounded,
            color: AppTheme.primaryRed,
            size: fontSize + 1,
          ),
          const SizedBox(width: 4),
          Text(
            bloodGroup,
            style: TextStyle(
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
