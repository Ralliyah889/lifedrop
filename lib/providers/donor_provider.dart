import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/donor.dart';
import '../services/donor_service.dart';

/// Provider class that manages donor-related state using the Provider pattern.
/// Handles donor list, filters, loading states, and Firestore data retrieval.
class DonorProvider extends ChangeNotifier {
  final DonorService _donorService = DonorService();

  // ── State Variables ──

  /// Complete list of donors from Firestore & local registrations.
  List<Donor> _donors = [];
  List<Donor> get donors => _donors;

  /// Filtered list of donors based on current filter selections.
  List<Donor> _filteredDonors = [];
  List<Donor> get filteredDonors => _filteredDonors;

  /// Active logged-in user's donor profile (if registered as a donor).
  Donor? _currentUserDonor;
  Donor? get currentUserDonor => _currentUserDonor;

  /// Currently selected blood group filter. Defaults to 'All'.
  String _selectedBloodGroup = 'All';
  String get selectedBloodGroup => _selectedBloodGroup;

  /// Currently entered city filter text.
  String _selectedCity = '';
  String get selectedCity => _selectedCity;

  /// Whether a data fetch operation is in progress.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message from the last failed operation, if any.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Available blood group options for the filter dropdown.
  static const List<String> bloodGroupOptions = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // ── Initial Seed Data for Instant 0ms Load ──
  static final List<Donor> _initialSeedDonors = [
    Donor(
      uid: 'donor_seed_1',
      name: 'Aisha Khan',
      email: 'aisha.khan@example.com',
      phone: '+91 98201 12345',
      bloodGroup: 'A+',
      city: 'Mumbai',
      lastDonationDate: '12 August 2026',
      createdAt: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
    ),
    Donor(
      uid: 'donor_seed_2',
      name: 'Rahul Sharma',
      email: 'rahul.sharma@example.com',
      phone: '+91 98110 54321',
      bloodGroup: 'O+',
      city: 'Mumbai',
      lastDonationDate: '15 September 2026',
      createdAt: DateTime.now().subtract(const Duration(days: 16)).toIso8601String(),
    ),
    Donor(
      uid: 'donor_seed_3',
      name: 'Priya Patel',
      email: 'priya.patel@example.com',
      phone: '+91 98980 98765',
      bloodGroup: 'B+',
      city: 'Delhi',
      lastDonationDate: '01 July 2026',
      createdAt: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
    ),
    Donor(
      uid: 'donor_seed_4',
      name: 'Vikram Verma',
      email: 'vikram.v@example.com',
      phone: '+91 97170 33445',
      bloodGroup: 'O-',
      city: 'Bangalore',
      lastDonationDate: '20 June 2026',
      createdAt: DateTime.now().subtract(const Duration(days: 100)).toIso8601String(),
    ),
    Donor(
      uid: 'donor_seed_5',
      name: 'Sneha Rao',
      email: 'sneha.rao@example.com',
      phone: '+91 94480 66778',
      bloodGroup: 'AB+',
      city: 'Pune',
      lastDonationDate: '10 September 2026',
      createdAt: DateTime.now().subtract(const Duration(days: 21)).toIso8601String(),
    ),
    Donor(
      uid: 'donor_seed_6',
      name: 'Arjun Mehta',
      email: 'arjun.m@example.com',
      phone: '+91 98450 11223',
      bloodGroup: 'A-',
      city: 'Mumbai',
      lastDonationDate: '05 May 2026',
      createdAt: DateTime.now().subtract(const Duration(days: 140)).toIso8601String(),
    ),
  ];

  DonorProvider() {
    _donors = List.from(_initialSeedDonors);
    _applyFilters();
  }

  // ── Public Methods ──

  /// Adds a newly registered donor to the top of the local state and applies filters.
  void addDonorLocally(Donor donor) {
    _currentUserDonor = donor;
    _donors.removeWhere((d) =>
        d.uid == donor.uid ||
        (d.email.isNotEmpty && d.email.toLowerCase() == donor.email.toLowerCase()));
    _donors.insert(0, donor);
    _applyFilters();
    notifyListeners();
  }

  /// Sets or updates the active user's donor profile.
  void setCurrentUserDonor(Donor donor) {
    _currentUserDonor = donor;
    addDonorLocally(donor);
  }

  /// Fetches all donors from Firestore and merges smoothly with local state.
  Future<void> fetchDonors() async {
    _errorMessage = null;
    final currentUser = FirebaseAuth.instance.currentUser;

    try {
      final cloudDonors = await _donorService.getAllDonors();
      if (cloudDonors.isNotEmpty) {
        // Use a Map keyed by unique identifier to prevent duplicates
        final Map<String, Donor> donorMap = {};

        // 1. Add all cloud donors
        for (final d in cloudDonors) {
          final key = d.uid.isNotEmpty ? d.uid : (d.email.isNotEmpty ? d.email.toLowerCase() : d.name);
          donorMap[key] = d;
        }

        // 2. Identify if current user's profile is in cloudDonors
        if (currentUser != null && _currentUserDonor == null) {
          final match = cloudDonors.cast<Donor?>().firstWhere(
                (d) =>
                    d?.uid == currentUser.uid ||
                    (d?.email.isNotEmpty == true &&
                        d?.email.toLowerCase() == currentUser.email?.toLowerCase()),
                orElse: () => null,
              );
          if (match != null) {
            _currentUserDonor = match;
          }
        }

        // 3. Ensure _currentUserDonor is never lost
        if (_currentUserDonor != null) {
          final key = _currentUserDonor!.uid.isNotEmpty
              ? _currentUserDonor!.uid
              : _currentUserDonor!.email.toLowerCase();
          donorMap[key] = _currentUserDonor!;
        }

        // 4. Build merged list with current user's donor at the very top
        final List<Donor> mergedList = [];
        if (_currentUserDonor != null) {
          mergedList.add(_currentUserDonor!);
        }

        for (final d in donorMap.values) {
          if (_currentUserDonor != null) {
            if (d.uid == _currentUserDonor!.uid ||
                (d.email.isNotEmpty &&
                    d.email.toLowerCase() == _currentUserDonor!.email.toLowerCase())) {
              continue; // Already added at index 0
            }
          }
          mergedList.add(d);
        }

        _donors = mergedList;
        _applyFilters();
        notifyListeners();
      } else {
        // If Firestore is empty, retain current user donor at index 0
        if (_currentUserDonor != null) {
          addDonorLocally(_currentUserDonor!);
        }
      }

      // Check if active user profile can be fetched directly by UID if not already present
      if (_currentUserDonor == null && currentUser != null) {
        try {
          final profile = await _donorService.getDonorByUid(currentUser.uid);
          if (profile != null) {
            _currentUserDonor = profile;
            addDonorLocally(profile);
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Firestore fetch notice: $e');
    }
  }

  /// Updates the selected blood group filter and re-applies filters.
  /// Fetches fresh data from Firestore with the new filter.
  void setBloodGroup(String bloodGroup) {
    _selectedBloodGroup = bloodGroup;
    _applyFilters();
    notifyListeners();
  }

  /// Updates the city filter text and re-applies filters.
  void setCity(String city) {
    _selectedCity = city;
    _applyFilters();
    notifyListeners();
  }

  /// Fetches filtered donors directly from Firestore.
  /// Used when you want server-side filtering for blood group.
  Future<void> fetchFilteredDonors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _filteredDonors = await _donorService.getFilteredDonors(
        bloodGroup:
            _selectedBloodGroup == 'All' ? null : _selectedBloodGroup,
        city: _selectedCity.isEmpty ? null : _selectedCity,
      );
    } catch (e) {
      _errorMessage = 'Failed to filter donors. Please try again.';
      _filteredDonors = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clears all active filters and resets to showing all donors.
  void clearFilters() {
    _selectedBloodGroup = 'All';
    _selectedCity = '';
    _applyFilters();
    notifyListeners();
  }

  /// Seeds sample donor records directly into Cloud Firestore and refreshes.
  Future<void> seedInitialDonors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _donorService.seedSampleDonorsToFirestore();
      await fetchDonors();
    } catch (e) {
      _errorMessage = 'Could not seed donors. Verify Firestore configuration.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Private Methods ──

  /// Applies both blood group and city filters to the full donor list.
  /// Blood group uses exact match; city uses case-insensitive partial match.
  void _applyFilters() {
    _filteredDonors = _donors.where((donor) {
      // Blood group filter
      final matchesBloodGroup = _selectedBloodGroup == 'All' ||
          donor.bloodGroup == _selectedBloodGroup;

      // City filter (case-insensitive partial match)
      final matchesCity = _selectedCity.isEmpty ||
          donor.city.toLowerCase().contains(_selectedCity.toLowerCase());

      return matchesBloodGroup && matchesCity;
    }).toList();
  }
}
