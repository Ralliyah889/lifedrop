import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/donor.dart';
import '../providers/donor_provider.dart';
import '../services/auth_service.dart';
import '../services/donor_service.dart';
import '../theme/app_theme.dart';
import 'home_shell_screen.dart';

/// Screen 2: Visually guided multi-step Donor Registration.
/// Steps:
/// 1. Account Details (Name, Email, Password, Confirm)
/// 2. Donor Details (Phone, Blood Group, City, Donation Date)
/// 3. Success Celebration ("You're now a LifeDrop donor!")
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  final _authService = AuthService();
  final _donorService = DonorService();

  final _accountFormKey = GlobalKey<FormState>();
  final _donorFormKey = GlobalKey<FormState>();

  int _currentStep = 0; // 0: Account, 1: Donor, 2: Success
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _lastDonationDateController = TextEditingController();

  String? _selectedBloodGroup;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _lastDonationDateController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Validates Step 1 and advances to Step 2
  void _onNextFromAccount() {
    if (_accountFormKey.currentState!.validate()) {
      _goToStep(1);
    }
  }

  /// Opens Material DatePicker for selecting the donation date
  Future<void> _selectLastDonationDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 90)),
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select Last Donation Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryRed,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lastDonationDateController.text =
            DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  /// Submits the registration form, creates Firebase Auth account and Firestore doc
  Future<void> _handleRegister() async {
    if (!_donorFormKey.currentState!.validate()) return;

    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your blood group.'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create authenticated user with Firebase Auth
      final user = await _authService.registerWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (user == null) {
        throw Exception('User registration failed. Please try again.');
      }

      final fullName = _nameController.text.trim();

      // 2. Update Firebase Auth displayName
      try {
        await user.updateDisplayName(fullName);
        await user.reload();
      } catch (_) {}

      // 3. Prepare Donor model with user's UID
      final donor = Donor(
        uid: user.uid,
        name: fullName,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        bloodGroup: _selectedBloodGroup!,
        city: _cityController.text.trim(),
        lastDonationDate: _lastDonationDateController.text.trim().isNotEmpty
            ? _lastDonationDateController.text.trim()
            : 'First-time donor',
        createdAt: DateTime.now().toIso8601String(),
      );

      // 4. Update DonorProvider in memory immediately so dashboard shows donor
      if (mounted) {
        Provider.of<DonorProvider>(context, listen: false).addDonorLocally(donor);
      }

      // 5. Store into Cloud Firestore
      try {
        await _donorService.addDonor(donor);
      } catch (e) {
        debugPrint('Firestore addDonor notice: $e');
      }

      // 6. Advance to Success Step
      if (mounted) {
        _goToStep(2);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep < 2
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
                onPressed: () {
                  if (_currentStep == 1) {
                    _goToStep(0);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
        title: _currentStep < 2
            ? const Text(
                'Become a Donor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                // Top Progress Indicator
                if (_currentStep < 2) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      children: [
                        const Text(
                          'Your donation can make a real difference.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressStepper(),
                      ],
                    ),
                  ),
                ],

                // PageView for Smooth Step Transitions
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1Account(),
                      _buildStep2Donor(),
                      _buildStep3Success(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern Figma-style Stepper Bar: 1 Account Details ───── 2 Donor Details ───── 3 Complete
  Widget _buildProgressStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _buildStepItem(0, 'Account Details'),
          _buildStepLine(_currentStep >= 1),
          _buildStepItem(1, 'Donor Details'),
          _buildStepLine(_currentStep >= 2),
          _buildStepItem(2, 'Complete'),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepIndex, String title) {
    final bool isActive = _currentStep == stepIndex;
    final bool isCompleted = _currentStep > stepIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppTheme.primaryRed
                : isCompleted
                    ? AppTheme.successGreen
                    : AppTheme.surfaceMuted,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? AppTheme.primaryRed
                : isCompleted
                    ? AppTheme.textDark
                    : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isFilled) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: isFilled ? AppTheme.primaryRed : AppTheme.borderSubtle,
      ),
    );
  }

  /// Step 1: Account Details Form
  Widget _buildStep1Account() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
          border: Border.all(color: AppTheme.borderCard),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Form(
          key: _accountFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_pin_rounded,
                      color: AppTheme.primaryRed, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Step 1: Account Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your login credentials and personal name.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),

              // Full Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (val.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(val.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  hintText: 'Min 6 characters',
                  prefixIcon:
                      const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password is required';
                  }
                  if (val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  hintText: 'Re-enter password',
                  prefixIcon:
                      const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (val != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Next CTA
              FilledButton(
                onPressed: _onNextFromAccount,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 2: Donor Details Form
  Widget _buildStep2Donor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
          border: Border.all(color: AppTheme.borderCard),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Form(
          key: _donorFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.bloodtype_rounded,
                      color: AppTheme.primaryRed, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Step 2: Donor Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Provide your blood group and location to help recipients.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '+91 9876543210',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  final clean =
                      val.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
                  if (clean.length < 10) {
                    return 'Enter at least 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Blood Group Label & Horizontal Chips
              const Text(
                'Blood Group *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Attractive Chip Selector for Blood Groups
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bloodGroups.map((group) {
                  final isSelected = _selectedBloodGroup == group;
                  return ChoiceChip(
                    label: Text(group),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryRed,
                    backgroundColor: AppTheme.surfaceWhite,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryRed
                            : AppTheme.borderSubtle,
                        width: 1.2,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedBloodGroup = selected ? group : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // City Input
              TextFormField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  hintText: 'e.g. Mumbai, Delhi, Bangalore',
                  prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Last Donation Date Field with Material DatePicker
              TextFormField(
                controller: _lastDonationDateController,
                readOnly: true,
                onTap: _selectLastDonationDate,
                decoration: InputDecoration(
                  labelText: 'Last Donation Date',
                  hintText: 'Tap to select (Optional)',
                  prefixIcon:
                      const Icon(Icons.calendar_today_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.edit_calendar_rounded,
                      color: AppTheme.primaryRed,
                      size: 20,
                    ),
                    onPressed: _selectLastDonationDate,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Buttons Row: Back & Register
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => _goToStep(0),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Register as Donor',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  /// Step 3: Success Celebration State
  Widget _buildStep3Success() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
            border: Border.all(color: AppTheme.borderCard),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Check Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFDCFCE7), // Soft green
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_rounded,
                  size: 46,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(height: 24),

              // Success Title
              const Text(
                "You're now a LifeDrop donor!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Success Subtitle
              const Text(
                'Your donor profile has been created successfully. Patients and blood banks can now find you during emergencies.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),

              // Find Blood Donors CTA
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    HomeShellScreen.routeName,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text(
                  'Find Blood Donors',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
