import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donor.dart';

/// Service class for all Cloud Firestore operations on the 'donors' collection.
/// Handles CRUD and query/filter operations for donor records.
class DonorService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Reference to the 'donors' collection in Firestore.
  CollectionReference get _donorsCollection => _firestore.collection('donors');

  /// Adds a new donor record to Firestore.
  /// The document ID is set to the donor's UID for easy retrieval.
  Future<void> addDonor(Donor donor) async {
    await _donorsCollection
        .doc(donor.uid)
        .set(donor.toFirestore(), SetOptions(merge: true))
        .timeout(const Duration(seconds: 5));
  }

  /// Retrieves all donors from Firestore with fast timeout.
  /// Returns a list of [Donor] objects.
  Future<List<Donor>> getAllDonors() async {
    try {
      final snapshot = await _donorsCollection
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 4));
      return snapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList();
    } catch (_) {
      try {
        final snapshot = await _donorsCollection
            .get()
            .timeout(const Duration(seconds: 4));
        return snapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList();
      } catch (e) {
        return [];
      }
    }
  }

  /// Queries donors by blood group using a Firestore query.
  /// Returns all donors if [bloodGroup] is 'All' or empty.
  Future<List<Donor>> getDonorsByBloodGroup(String bloodGroup) async {
    if (bloodGroup == 'All' || bloodGroup.isEmpty) {
      return getAllDonors();
    }
    final snapshot = await _donorsCollection
        .where('bloodGroup', isEqualTo: bloodGroup)
        .get()
        .timeout(const Duration(seconds: 4));
    return snapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList();
  }

  /// Queries donors with optional blood group and city filters.
  /// Uses Firestore queries for blood group filtering and
  /// client-side filtering for city (case-insensitive partial match).
  Future<List<Donor>> getFilteredDonors({
    String? bloodGroup,
    String? city,
  }) async {
    Query query = _donorsCollection;

    // Apply blood group filter at Firestore query level
    if (bloodGroup != null && bloodGroup != 'All' && bloodGroup.isNotEmpty) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }

    final snapshot = await query.get().timeout(const Duration(seconds: 4));
    List<Donor> donors =
        snapshot.docs.map((doc) => Donor.fromFirestore(doc)).toList();

    // Apply city filter client-side (case-insensitive partial match)
    if (city != null && city.trim().isNotEmpty) {
      final cityLower = city.trim().toLowerCase();
      donors = donors
          .where((d) => d.city.toLowerCase().contains(cityLower))
          .toList();
    }

    return donors;
  }

  /// Retrieves a single donor by their UID.
  Future<Donor?> getDonorByUid(String uid) async {
    final doc =
        await _donorsCollection.doc(uid).get().timeout(const Duration(seconds: 4));
    if (doc.exists) {
      return Donor.fromFirestore(doc);
    }
    return null;
  }

  /// Seeds sample donor records directly to Cloud Firestore.
  /// Ideal for exam demonstrations to quickly populate the Firestore collection.
  Future<void> seedSampleDonorsToFirestore() async {
    final sampleDonors = [
      Donor(
        uid: 'sample_donor_1',
        name: 'Aisha Khan',
        email: 'aisha.khan@example.com',
        phone: '+91 98201 12345',
        bloodGroup: 'A+',
        city: 'Mumbai',
        lastDonationDate: '12 August 2026',
        createdAt: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
      ),
      Donor(
        uid: 'sample_donor_2',
        name: 'Rahul Sharma',
        email: 'rahul.sharma@example.com',
        phone: '+91 98110 54321',
        bloodGroup: 'O+',
        city: 'Mumbai',
        lastDonationDate: '15 September 2026',
        createdAt: DateTime.now().subtract(const Duration(days: 16)).toIso8601String(),
      ),
      Donor(
        uid: 'sample_donor_3',
        name: 'Priya Patel',
        email: 'priya.patel@example.com',
        phone: '+91 98980 98765',
        bloodGroup: 'B+',
        city: 'Delhi',
        lastDonationDate: '01 July 2026',
        createdAt: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      ),
      Donor(
        uid: 'sample_donor_4',
        name: 'Vikram Verma',
        email: 'vikram.v@example.com',
        phone: '+91 97170 33445',
        bloodGroup: 'O-',
        city: 'Bangalore',
        lastDonationDate: '20 June 2026',
        createdAt: DateTime.now().subtract(const Duration(days: 100)).toIso8601String(),
      ),
      Donor(
        uid: 'sample_donor_5',
        name: 'Sneha Rao',
        email: 'sneha.rao@example.com',
        phone: '+91 94480 66778',
        bloodGroup: 'AB+',
        city: 'Pune',
        lastDonationDate: '10 September 2026',
        createdAt: DateTime.now().subtract(const Duration(days: 21)).toIso8601String(),
      ),
      Donor(
        uid: 'sample_donor_6',
        name: 'Arjun Mehta',
        email: 'arjun.m@example.com',
        phone: '+91 98450 11223',
        bloodGroup: 'A-',
        city: 'Mumbai',
        lastDonationDate: '05 May 2026',
        createdAt: DateTime.now().subtract(const Duration(days: 140)).toIso8601String(),
      ),
    ];

    for (final donor in sampleDonors) {
      await addDonor(donor);
    }
  }
}

