import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a blood donor.
/// Maps directly to the Firestore 'donors' collection document structure.
class Donor {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;
  final String city;
  final String lastDonationDate;
  final String createdAt;

  Donor({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.city,
    required this.lastDonationDate,
    required this.createdAt,
  });

  /// Creates a Donor instance from a Firestore document snapshot.
  factory Donor.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Donor(
      uid: data['uid'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      bloodGroup: data['bloodGroup'] ?? '',
      city: data['city'] ?? '',
      lastDonationDate: data['lastDonationDate'] ?? '',
      createdAt: data['createdAt'] ?? '',
    );
  }

  /// Converts the Donor instance to a Map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'city': city,
      'lastDonationDate': lastDonationDate,
      'createdAt': createdAt,
    };
  }
}
