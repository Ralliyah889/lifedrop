import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donor_provider.dart';
import '../theme/app_theme.dart';

/// Modern Filter Section featuring horizontal chips for blood groups
/// and a rounded search bar for city filtering. Connects to [DonorProvider].
class FilterSection extends StatefulWidget {
  const FilterSection({super.key});

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DonorProvider>(context, listen: false);
    _cityController = TextEditingController(text: provider.selectedCity);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorProvider>(
      builder: (context, donorProvider, child) {
        // Sync text field if reset externally
        if (_cityController.text != donorProvider.selectedCity &&
            donorProvider.selectedCity.isEmpty) {
          _cityController.clear();
        }

        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search City Input Field
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.borderCard, width: 1.2),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: TextField(
                  controller: _cityController,
                  onChanged: (val) => donorProvider.setCity(val),
                  decoration: InputDecoration(
                    hintText: 'Search city (e.g. Mumbai, Delhi)...',
                    hintStyle: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.primaryRed,
                      size: 20,
                    ),
                    suffixIcon: _cityController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            color: AppTheme.textMuted,
                            onPressed: () {
                              _cityController.clear();
                              donorProvider.setCity('');
                            },
                          )
                        : null,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Label & Quick Reset Link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Blood Group',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (donorProvider.selectedBloodGroup != 'All' ||
                      donorProvider.selectedCity.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _cityController.clear();
                        donorProvider.clearFilters();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.refresh_rounded,
                              size: 14, color: AppTheme.primaryRed),
                          SizedBox(width: 4),
                          Text(
                            'Reset Filters',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Horizontally Scrollable Blood Group Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: DonorProvider.bloodGroupOptions.map((bg) {
                    final isSelected = donorProvider.selectedBloodGroup == bg;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Text(bg),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryRed,
                          backgroundColor: AppTheme.surfaceWhite,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 13,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryRed
                                  : AppTheme.borderSubtle,
                              width: 1.2,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              donorProvider.setBloodGroup(bg);
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
