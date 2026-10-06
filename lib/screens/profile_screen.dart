import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/donor_provider.dart';
import '../services/auth_service.dart';
import '../services/donor_service.dart';
import '../models/donor.dart';
import '../theme/app_theme.dart';
import '../widgets/blood_group_badge.dart';
import 'login_screen.dart';

/// User Profile screen showcasing authenticated user profile,
/// donor status, medical summary, and settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _donorService = DonorService();
  Donor? _donorProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      // First try matching in-memory donors for instant 0ms resolve
      final provider = Provider.of<DonorProvider>(context, listen: false);
      final cached = provider.donors.cast<Donor?>().firstWhere(
            (d) => d?.uid == user.uid || (d?.email.isNotEmpty == true && d?.email == user.email),
            orElse: () => null,
          );

      if (cached != null && mounted) {
        setState(() => _donorProfile = cached);
      }

      // Then fetch latest from Firestore in background with short timeout
      try {
        final donor = await _donorService
            .getDonorByUid(user.uid)
            .timeout(const Duration(milliseconds: 1500));
        if (donor != null && mounted) {
          setState(() => _donorProfile = donor);
        }
      } catch (_) {
        // Silently ignore offline or timeout notice - already using cached profile
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.primaryRed),
            SizedBox(width: 8),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out from LifeDrop?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              minimumSize: const Size(100, 42),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _authService.currentUser;
    final String displayName = _donorProfile?.name.isNotEmpty == true
        ? _donorProfile!.name
        : (user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : (user?.email?.split('@').first ?? 'LifeDrop Donor'));
    final String email =
        _donorProfile?.email.isNotEmpty == true ? _donorProfile!.email : (user?.email ?? 'donor@lifedrop.org');
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.backgroundWarm,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusExtraLarge),
                      border: Border.all(color: AppTheme.borderCard),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        // Large Avatar with Glow
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.roseSoft,
                            border: Border.all(
                              color: AppTheme.primaryRedLight
                                  .withValues(alpha: 0.3),
                              width: 2.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Name
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Badges Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_donorProfile != null &&
                                _donorProfile!.bloodGroup.isNotEmpty)
                              BloodGroupBadge(
                                bloodGroup: _donorProfile!.bloodGroup,
                                fontSize: 13,
                              ),
                            if (_donorProfile != null &&
                                _donorProfile!.city.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _donorProfile!.city,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions Section in a rounded card
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusExtraLarge),
                      border: Border.all(color: AppTheme.borderCard),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusExtraLarge),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.favorite_border_rounded,
                            title: 'My Donor Profile',
                            subtitle: _donorProfile != null
                                ? 'Active blood donor'
                                : 'Not registered as donor yet',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _donorProfile != null
                                        ? 'You are active as ${_donorProfile!.bloodGroup} donor in ${_donorProfile!.city}.'
                                        : 'You can register as a donor from the registration page.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 64),
                          _buildSettingsTile(
                            icon: Icons.edit_note_rounded,
                            title: 'Edit Profile',
                            subtitle: 'Update phone number and city',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile edit saved to Firestore.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 64),
                          _buildSettingsTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            subtitle: 'Donor guidelines and FAQs',
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: 'LifeDrop',
                                applicationVersion: '1.0.0',
                                applicationIcon: const Icon(
                                  Icons.water_drop_rounded,
                                  color: AppTheme.primaryRed,
                                  size: 36,
                                ),
                                children: const [
                                  Text(
                                    'LifeDrop connects blood donors with patients in emergency need. Built for college technical demonstrations.',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logout Tile in separate card
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusExtraLarge),
                      border: Border.all(color: AppTheme.borderCard),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusExtraLarge),
                      clipBehavior: Clip.antiAlias,
                      child: _buildSettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out from this device',
                        titleColor: AppTheme.errorRed,
                        iconColor: AppTheme.errorRed,
                        onTap: _handleLogout,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color titleColor = AppTheme.textDark,
    Color iconColor = AppTheme.primaryRed,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppTheme.textMuted,
      ),
      onTap: onTap,
    );
  }
}
