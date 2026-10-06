import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Skeleton loader simulating donor cards while Firestore data is fetching.
/// Uses an animated opacity shimmer effect.
class SkeletonDonorCard extends StatefulWidget {
  const SkeletonDonorCard({super.key});

  @override
  State<SkeletonDonorCard> createState() => _SkeletonDonorCardState();
}

class _SkeletonDonorCardState extends State<SkeletonDonorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppTheme.borderSubtle,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBox(width: 48, height: 48, radius: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBox(width: 140, height: 16, radius: 6),
                    const SizedBox(height: 8),
                    _buildBox(width: 90, height: 12, radius: 4),
                  ],
                ),
              ),
              _buildBox(width: 58, height: 28, radius: 12),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppTheme.borderSubtle.withValues(alpha: 0.5)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBox(width: 130, height: 14, radius: 6),
              _buildBox(width: 96, height: 38, radius: 12),
            ],
          ),
        ],
      ),
    );
  }
}
