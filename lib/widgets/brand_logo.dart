import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom Brand Logo for LifeDrop.
/// Combines a blood-drop motif with an embedded healthcare heart icon,
/// surrounded by soft glowing concentric aura rings.
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isLightBackground;

  const BrandLogo({
    super.key,
    this.size = 72,
    this.showText = true,
    this.isLightBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Concentric glowing aura rings
        Container(
          width: size + 24,
          height: size + 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.roseSoft.withValues(alpha: 0.45),
          ),
          alignment: Alignment.center,
          child: Container(
            width: size + 10,
            height: size + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.roseSoft,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryRedLight,
                    AppTheme.primaryRed,
                    AppTheme.primaryRedDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle water droplet background shape
                  Icon(
                    Icons.water_drop_rounded,
                    size: size * 0.65,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  // Heart symbol inside the droplet
                  Positioned(
                    bottom: size * 0.22,
                    child: Icon(
                      Icons.favorite_rounded,
                      size: size * 0.28,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (showText) ...[
          const SizedBox(height: 14),
          // App Title
          const Text(
            'LifeDrop',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          // Tagline
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Save a Life Today',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryRed,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
