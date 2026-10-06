import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifedrop/models/donor.dart';
import 'package:lifedrop/providers/donor_provider.dart';
import 'package:lifedrop/widgets/blood_group_badge.dart';

void main() {
  testWidgets('BloodGroupBadge displays blood group text and icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BloodGroupBadge(bloodGroup: 'O+'),
        ),
      ),
    );

    expect(find.text('O+'), findsOneWidget);
    expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
  });

  test('DonorProvider adds and retains newly registered donor at top', () {
    final provider = DonorProvider();
    final newDonor = Donor(
      uid: 'test_user_123',
      name: 'Ralliyah Rushdah',
      email: 'ralliyah@example.com',
      phone: '+91 9988776655',
      bloodGroup: 'B+',
      city: 'Kochi',
      lastDonationDate: 'First-time donor',
      createdAt: DateTime.now().toIso8601String(),
    );

    provider.addDonorLocally(newDonor);

    expect(provider.currentUserDonor, equals(newDonor));
    expect(provider.donors.first.name, equals('Ralliyah Rushdah'));
    expect(provider.filteredDonors.first.bloodGroup, equals('B+'));
  });
}
