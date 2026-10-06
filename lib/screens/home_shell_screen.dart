import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/blood_group_badge.dart';
import 'donor_search_screen.dart';
import 'profile_screen.dart';

/// Authenticated shell screen providing responsive navigation:
/// - Material 3 [NavigationBar] on Mobile
/// - Material 3 [NavigationRail] on Tablet / Desktop (> 720px)
/// Hosts 3 primary destinations:
/// 0: Search (Find a Blood Donor)
/// 1: My Donors / Urgent Requests
/// 2: Profile (User & Donor Settings)
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _currentIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;

        final List<Widget> screens = [
          DonorSearchScreen(
            onProfileTap: () => _onDestinationSelected(2),
          ),
          const _MyDonorsView(),
          const ProfileScreen(),
        ];

        // Tablet & Desktop layout with NavigationRail
        if (isWide) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundWarm,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.search_rounded),
                      selectedIcon: Icon(Icons.search_rounded,
                          color: AppTheme.primaryRed),
                      label: Text('Search'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite_border_rounded),
                      selectedIcon: Icon(Icons.favorite_rounded,
                          color: AppTheme.primaryRed),
                      label: Text('My Donors'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded,
                          color: AppTheme.primaryRed),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppTheme.borderSubtle),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: screens[_currentIndex],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile layout with modern Material 3 NavigationBar
        return Scaffold(
          backgroundColor: AppTheme.backgroundWarm,
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              border: const Border(
                top: BorderSide(color: AppTheme.borderCard, width: 1.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  selectedIcon: Icon(Icons.search_rounded,
                      color: AppTheme.primaryRed),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded,
                      color: AppTheme.primaryRed),
                  label: 'My Donors',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded,
                      color: AppTheme.primaryRed),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tab 2: My Donors / Urgent Requests view
class _MyDonorsView extends StatelessWidget {
  const _MyDonorsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWarm,
      appBar: AppBar(
        title: const Text('My Donors'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Urgent Blood Need Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.roseSoft,
                          Color(0xFFFFF1F2),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusExtraLarge),
                      border: Border.all(
                        color: AppTheme.primaryRedLight.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.emergency_rounded,
                                color: AppTheme.primaryRed, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Blood Donation Guidelines',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRedDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'You can safely donate whole blood once every 3 months (90 days). Keep hydrated and eat a healthy meal prior to donation.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const BloodGroupBadge(
                              bloodGroup: 'Universal Donor: O-',
                              fontSize: 12,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Checking blood bank network...'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Learn More →',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Saved Donors Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Network Donors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Consumer<DonorProvider>(
                        builder: (context, provider, _) => Text(
                          '${provider.donors.length} in network',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Donor List Summary
                  Consumer<DonorProvider>(
                    builder: (context, provider, child) {
                      if (provider.donors.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLarge),
                            border: Border.all(color: AppTheme.borderCard),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 40,
                                color: AppTheme.textMuted,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No saved donors yet',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Use the search tab to find and contact registered donors.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Show top 3 donors from network
                      final recent = provider.donors.take(3).toList();
                      return Column(
                        children: recent.map((d) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(color: AppTheme.borderCard),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.roseSoft,
                                  child: Text(
                                    d.name.isNotEmpty
                                        ? d.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryRed,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '📍 ${d.city}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                BloodGroupBadge(
                                  bloodGroup: d.bloodGroup,
                                  fontSize: 13,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
