import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donor.dart';
import '../providers/donor_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/donor_card.dart';
import '../widgets/filter_section.dart';
import '../widgets/skeleton_donor_card.dart';

/// Screen 3: Premium Donor Search & Filtering Screen.
/// Includes top hero banner, reactive horizontal blood group chips,
/// responsive layout (single column mobile / multi-column grid tablet),
/// and skeleton loading states.
class DonorSearchScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const DonorSearchScreen({
    super.key,
    this.onProfileTap,
  });

  static const String routeName = '/search';

  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorProvider>().fetchDonors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorProvider>(
      builder: (context, provider, _) {
        final user = _authService.currentUser;
        final donorProfile = provider.currentUserDonor;
        final String displayName = (donorProfile?.name.isNotEmpty == true)
            ? donorProfile!.name
            : (user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : (user?.email?.split('@').first ?? 'Donor'));
        final String initial = displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'U';
        final String firstName = displayName.split(' ').first;

        return Scaffold(
          backgroundColor: AppTheme.backgroundWarm,
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LifeDrop',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Save a Life Today',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryRed,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: InkWell(
                  onTap: widget.onProfileTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryRedLight.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryRed,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Hi, $firstName',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: RefreshIndicator(
                  color: AppTheme.primaryRed,
                  onRefresh: () => context.read<DonorProvider>().fetchDonors(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Hero Card Banner
                      SliverToBoxAdapter(
                        child: _buildHeroCard(displayName, donorProfile),
                      ),

                  // Reactive Filter Section
                  const SliverToBoxAdapter(
                    child: FilterSection(),
                  ),

                  // Results Summary Header
                  SliverToBoxAdapter(
                    child: _buildResultsSummary(),
                  ),

                  // Donor List / Grid / States
                  Consumer<DonorProvider>(
                    builder: (context, provider, child) {
                      // 1. Loading State with Skeletons
                      if (provider.isLoading) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const SkeletonDonorCard(),
                            childCount: 4,
                          ),
                        );
                      }

                      // 2. Error State
                      if (provider.errorMessage != null) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.roseSoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppTheme.errorRed,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    provider.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: () => provider.fetchDonors(),
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text('Try Again'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.primaryRed,
                                      minimumSize: const Size(140, 42),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final donors = provider.filteredDonors;

                      // 3. Empty State
                      if (donors.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppTheme.roseSoft.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_search_rounded,
                                      size: 56,
                                      color: AppTheme.primaryRed,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'No donors found',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Try changing your blood group or city filters.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: () => provider.clearFilters(),
                                        icon: const Icon(Icons.refresh_rounded, size: 18),
                                        label: const Text('Reset Filters'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppTheme.primaryRed,
                                          minimumSize: const Size(140, 44),
                                        ),
                                      ),
                                      if (provider.donors.isEmpty)
                                        OutlinedButton.icon(
                                          onPressed: () => provider.seedInitialDonors(),
                                          icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                                          label: const Text('Seed Firestore Donors'),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(160, 44),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // 4. Responsive Grid/List for Donors
                      return SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.crossAxisExtent > 680;
                          if (isWide) {
                            // Two-column responsive grid for tablet/desktop
                            return SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.3,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    DonorCard(donor: donors[index]),
                                childCount: donors.length,
                              ),
                            );
                          } else {
                            // Single column list for mobile
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    DonorCard(donor: donors[index]),
                                childCount: donors.length,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),

                  // Bottom padding for scroll clearance
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
);
}

  /// Refined Hero Card with personalized greeting and active donor status badge
  Widget _buildHeroCard(String displayName, Donor? donorProfile) {
    final bool isDonor = donorProfile != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF1F2),
            Color(0xFFFEE2E2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryRedLight.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.water_drop_rounded,
                      color: AppTheme.primaryRed,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Welcome, $displayName 👋',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryRedDark,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (isDonor) ...[
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.successGreen.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: AppTheme.successGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Registered Donor (${donorProfile.bloodGroup})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (donorProfile.city.isNotEmpty)
                        Text(
                          '📍 ${donorProfile.city}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your profile is active in the network. Recipients can reach you during urgent requests.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Search registered donors by blood group and city or register as a donor.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.bloodtype_rounded,
              color: AppTheme.primaryRed,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  /// Results summary header showing donor count
  Widget _buildResultsSummary() {
    return Consumer<DonorProvider>(
      builder: (context, provider, child) {
        final count = provider.filteredDonors.length;
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryRed,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Finding available donors...',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                'Showing $count ${count == 1 ? "donor" : "donors"}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              if (provider.selectedBloodGroup != 'All' ||
                  provider.selectedCity.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.roseSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Filtered',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
